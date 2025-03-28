from dataclasses import dataclass
from datetime import datetime
import logging
from typing import Dict, Any

from models import Order
from utils.repositories import FirestoreRepository
from utils.hedera import HederaClient

class CreateOrder:
    def __init__(self, 
                 firestore_repo: FirestoreRepository, 
                 hedera_client: HederaClient):
        """
        Initialize CreateOrder service with required dependencies.
        
        :param firestore_repo: Firestore repository for data persistence
        :param hedera_client: Hedera blockchain client for contract operations
        """
        self.firestore_repo = firestore_repo
        self.hedera_client = hedera_client

    def execute(self, 
                user_id: str, 
                store_id: str, 
                total_price: float, 
                delivery_fee: float) -> Dict[str, Any]:
        """
        Execute order creation process:
        1. Generate unique order ID
        2. Create Order object
        3. Deploy Hedera smart contract
        4. Fund contract from customer wallet
        5. Persist order in Firestore

        :param user_id: ID of the customer placing the order
        :param store_id: ID of the store fulfilling the order
        :param total_price: Total price of items in the order
        :param delivery_fee: Delivery fee for the order
        :return: Dictionary containing order and contract details
        """
        try:
            # 1. Generate unique order ID (you might want to use a more robust ID generation method)
            order_id = f"order_{datetime.now().timestamp()}"

            # 2. Retrieve customer's Hedera wallet details
            customer_wallet = self.hedera_client.get_wallet(user_id)
            if not customer_wallet:
                raise ValueError(f"No Hedera wallet found for user {user_id}")

            # 3. Create Order object
            order = Order(
                order_id=order_id,
                user_id=user_id,
                store_id=store_id,
                total_price=total_price,
                delivery_fee=delivery_fee,
                status="PENDING",
                timestamp=datetime.now()
            )

            # 4. Deploy Hedera smart contract
            contract_id = self.hedera_client.deploy_contract(
                store_owner_id=store_id,
                amount=int(total_price * 100),  # Convert to cents/smallest unit
                delivery_fee=int(delivery_fee * 100)
            )

            # 5. Fund contract from customer wallet
            self.hedera_client.fund_contract(
                contract_id=contract_id, 
                amount=int(total_price * 100), 
                delivery_fee=int(delivery_fee * 100)
            )

            # 6. Persist order in Firestore with contract details
            order_data = {
                **order.__dict__,
                "contract_id": str(contract_id)
            }
            
            self.firestore_repo.write(
                collection="orders", 
                data={
                    "document_tag": order_id,
                    "contents": order_data
                }
            )

            return {
                "order": order_data,
                "contract_id": str(contract_id)
            }

        except Exception as e:
            logging.error(f"Order creation failed: {e}")
            raise

    def cancel_order(self, order_id: str):
        """
        Cancel an existing order and handle contract refund.
        
        :param order_id: ID of the order to cancel
        """
        try:
            # Retrieve order details from Firestore
            order_ref = self.firestore_repo.read(
                collection="orders", 
                document_tag=order_id
            )
            
            if not order_ref:
                raise ValueError(f"Order {order_id} not found")
            
            order_data = order_ref['contents']
            contract_id = order_data.get('contract_id')
            
            if not contract_id:
                raise ValueError(f"No contract associated with order {order_id}")
            
            # Refund logic would be implemented here using contract method
            # This is a placeholder and depends on your specific smart contract implementation
            # self.hedera_client.refund_contract(contract_id)
            
            # Update order status
            updated_order_data = {
                **order_data,
                "status": "CANCELLED"
            }
            
            self.firestore_repo.write(
                collection="orders", 
                data={
                    "document_tag": order_id,
                    "contents": updated_order_data
                }
            )
            
            return {"status": "Order cancelled successfully"}
        
        except Exception as e:
            logging.error(f"Order cancellation failed: {e}")
            raise