from typing import Dict, Any
import logging
from datetime import datetime

from utils.hedera import HederaClient
from utils.repositories import FirestoreRepository

class ConfirmDelivery:
    def __init__(self, 
                 hedera_client: HederaClient, 
                 firestore_repo: FirestoreRepository):
        """
        Initialize ConfirmDelivery service with Hedera and Firestore clients.
        
        :param hedera_client: Hedera blockchain client for contract interactions
        :param firestore_repo: Firestore repository for data management
        """
        self.hedera_client = hedera_client
        self.firestore_repo = firestore_repo

    def execute(self, 
                order_id: str, 
                customer_id: str) -> Dict[str, Any]:
        """
        Confirm order delivery and update status to delivered.
        
        :param order_id: Unique identifier for the order
        :param customer_id: ID of the customer confirming delivery
        :return: Updated order details
        """
        try:
            # 1. Retrieve order details
            order_data = self.firestore_repo.read(
                collection="orders", 
                document_tag=order_id
            )
            
            if not order_data:
                raise ValueError(f"Order {order_id} not found")
            
            order_contents = order_data['contents']
            
            # 2. Validate order and customer
            if order_contents['user_id'] != customer_id:
                raise ValueError("Customer not authorized to confirm this delivery")
            
            if order_contents['status'] != 'IN_TRANSIT':
                raise ValueError(f"Cannot confirm delivery. Current status: {order_contents['status']}")
            
            # 3. Retrieve contract and additional details
            contract_id = order_contents.get('contract_id')
            store_id = order_contents.get('store_id')
            delivery_agent_id = order_contents.get('delivery_agent_id')
            
            if not all([contract_id, store_id, delivery_agent_id]):
                raise ValueError(f"Missing required information for order {order_id}")
            
            # 4. Call confirm_delivery on Hedera contract
            self.hedera_client.confirm_delivery(
                contract_id=contract_id,
                customer_id=customer_id,
                store_id=store_id,
                agent_id=delivery_agent_id
            )
            
            # 5. Update order status
            updated_order = {
                **order_contents,
                "status": "DELIVERED",
                "delivered_at": datetime.now().isoformat()
            }
            
            # 6. Persist updated order
            self.firestore_repo.write(
                collection="orders",
                data={
                    "document_tag": order_id,
                    "contents": updated_order
                }
            )
            
            return {
                "order": updated_order,
                "message": "Order delivery confirmed successfully"
            }

        except Exception as e:
            logging.error(f"Delivery confirmation failed for order {order_id}: {e}")
            raise

    def rate_delivery(self, 
                      order_id: str, 
                      customer_id: str, 
                      rating: int, 
                      review: str = None) -> Dict[str, Any]:
        """
        Allow customer to rate and review the delivery.
        
        :param order_id: Unique identifier for the order
        :param customer_id: ID of the customer
        :param rating: Delivery rating (e.g., 1-5)
        :param review: Optional customer review
        :return: Updated order details with rating
        """
        try:
            # 1. Retrieve order details
            order_data = self.firestore_repo.read(
                collection="orders", 
                document_tag=order_id
            )
            
            if not order_data:
                raise ValueError(f"Order {order_id} not found")
            
            order_contents = order_data['contents']
            
            # 2. Validate order and customer
            if order_contents['user_id'] != customer_id:
                raise ValueError("Customer not authorized to rate this delivery")
            
            if order_contents['status'] != 'DELIVERED':
                raise ValueError("Only delivered orders can be rated")
            
            # 3. Validate rating
            if not 1 <= rating <= 5:
                raise ValueError("Rating must be between 1 and 5")
            
            # 4. Update order with rating and review
            updated_order = {
                **order_contents,
                "delivery_rating": rating,
                "delivery_review": review,
                "rated_at": datetime.now().isoformat()
            }
            
            # 5. Persist updated order
            self.firestore_repo.write(
                collection="orders",
                data={
                    "document_tag": order_id,
                    "contents": updated_order
                }
            )
            
            return {
                "order": updated_order,
                "message": "Delivery rated successfully"
            }

        except Exception as e:
            logging.error(f"Delivery rating failed for order {order_id}: {e}")
            raise