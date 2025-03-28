
from typing import Dict, Any
import logging
from datetime import datetime

from utils.hedera import HederaClient
from utils.repositories import FirestoreRepository

class AcceptDelivery:
    def __init__(self, 
                 hedera_client: HederaClient, 
                 firestore_repo: FirestoreRepository):
        """
        Initialize AcceptDelivery service with Hedera and Firestore clients.
        
        :param hedera_client: Hedera blockchain client for contract interactions
        :param firestore_repo: Firestore repository for data management
        """
        self.hedera_client = hedera_client
        self.firestore_repo = firestore_repo

    def execute(self, 
                order_id: str, 
                delivery_agent_id: str) -> Dict[str, Any]:
        """
        Execute delivery acceptance process:
        1. Retrieve order details
        2. Validate order and delivery agent
        3. Call accept_delivery on Hedera contract
        4. Update order status
        
        :param order_id: Unique identifier for the order
        :param delivery_agent_id: ID of the delivery agent
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
            
            # 2. Validate order and delivery agent
            if order_contents.get('delivery_agent_id') != delivery_agent_id:
                raise ValueError("Delivery agent not assigned to this order")
            
            if order_contents['status'] != 'ASSIGNED':
                raise ValueError("Order is not in a state to be accepted")
            
            # Retrieve delivery agent's Hedera wallet
            agent_wallet = self.hedera_client.get_wallet(delivery_agent_id)
            if not agent_wallet:
                raise ValueError(f"No Hedera wallet found for delivery agent {delivery_agent_id}")
            
            # 3. Call accept_delivery on Hedera contract
            contract_id = order_contents.get('contract_id')
            if not contract_id:
                raise ValueError(f"No contract found for order {order_id}")
            
            # Calculate delivery amount (could be full amount or a portion)
            delivery_amount = order_contents.get('delivery_fee', 0)
            
            # Execute contract accept delivery method
            self.hedera_client.accept_delivery(
                contract_id=contract_id,
                agent_id=delivery_agent_id,
                amount=int(delivery_amount * 100)  # Convert to smallest unit
            )
            
            # 4. Update order status
            updated_order = {
                **order_contents,
                "status": "IN_DELIVERY",
                "delivery_accepted_at": datetime.now().isoformat()
            }
            
            # Persist updated order
            self.firestore_repo.write(
                collection="orders",
                data={
                    "document_tag": order_id,
                    "contents": updated_order
                }
            )
            
            return {
                "order": updated_order,
                "message": "Delivery accepted successfully"
            }

        except Exception as e:
            logging.error(f"Delivery acceptance failed for order {order_id}: {e}")
            raise

    def confirm_pickup(self, order_id: str) -> Dict[str, Any]:
        """
        Confirm pickup of the order by the delivery agent.
        
        :param order_id: Unique identifier for the order
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
            
            # 2. Validate order status
            if order_contents['status'] != 'IN_DELIVERY':
                raise ValueError("Order is not ready for pickup confirmation")
            
            # 3. Call confirm_pickup on Hedera contract
            contract_id = order_contents.get('contract_id')
            if not contract_id:
                raise ValueError(f"No contract found for order {order_id}")
            
            # Execute contract confirm pickup method
            self.hedera_client.confirm_pickup(contract_id)
            
            # 4. Update order status
            updated_order = {
                **order_contents,
                "status": "PICKED_UP",
                "pickup_confirmed_at": datetime.now().isoformat()
            }
            
            # Persist updated order
            self.firestore_repo.write(
                collection="orders",
                data={
                    "document_tag": order_id,
                    "contents": updated_order
                }
            )
            
            return {
                "order": updated_order,
                "message": "Order pickup confirmed successfully"
            }

        except Exception as e:
            logging.error(f"Pickup confirmation failed for order {order_id}: {e}")
            raise