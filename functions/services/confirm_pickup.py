from typing import Dict, Any
import logging
from datetime import datetime

from utils.hedera import HederaClient
from utils.repositories import FirestoreRepository

class ConfirmPickup:
    def __init__(self, 
                 hedera_client: HederaClient, 
                 firestore_repo: FirestoreRepository):
        """
        Initialize ConfirmPickup service with Hedera and Firestore clients.
        
        :param hedera_client: Hedera blockchain client for contract interactions
        :param firestore_repo: Firestore repository for data management
        """
        self.hedera_client = hedera_client
        self.firestore_repo = firestore_repo

    def execute(self, 
                order_id: str, 
                delivery_agent_id: str) -> Dict[str, Any]:
        """
        Confirm order pickup and update status to in transit.
        
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
            
            if order_contents['status'] not in ['ASSIGNED', 'PICKED_UP']:
                raise ValueError(f"Cannot confirm pickup. Current status: {order_contents['status']}")
            
            # 3. Retrieve contract details
            contract_id = order_contents.get('contract_id')
            if not contract_id:
                raise ValueError(f"No contract found for order {order_id}")
            
            # 4. Call confirm_pickup on Hedera contract
            self.hedera_client.confirm_pickup(contract_id)
            
            # 5. Update order status
            updated_order = {
                **order_contents,
                "status": "IN_TRANSIT",
                "in_transit_at": datetime.now().isoformat()
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
                "message": "Order confirmed in transit"
            }

        except Exception as e:
            logging.error(f"Pickup confirmation failed for order {order_id}: {e}")
            raise