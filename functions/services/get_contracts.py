from typing import Dict, List, Optional
import logging
from datetime import datetime

from utils.hedera import HederaClient
from utils.repositories import FirestoreRepository

class GetContracts:
    def __init__(self, 
                 hedera_client: HederaClient, 
                 firestore_repo: FirestoreRepository):
        """
        Initialize GetContracts service with Hedera and Firestore clients.
        
        :param hedera_client: Hedera blockchain client for contract interactions
        :param firestore_repo: Firestore repository for additional data retrieval
        """
        self.hedera_client = hedera_client
        self.firestore_repo = firestore_repo

    def get_available_contracts(self, 
                                delivery_agent_id: Optional[str] = None) -> List[Dict]:
        """
        Retrieve available contracts that can be picked up by delivery agents.
        
        :param delivery_agent_id: Optional ID to filter out already assigned contracts
        :return: List of available contract details
        """
        try:
            # Query Firestore for orders in PENDING status without assigned delivery agent
            pending_orders = self.firestore_repo.query(
                collection="orders",
                where_clause=[
                    ("contents.status", "==", "PENDING"),
                    # Optionally filter out orders already assigned to an agent
                    *([("contents.delivery_agent_id", "!=", delivery_agent_id)] 
                      if delivery_agent_id else [])
                ]
            )

            # Transform orders into contract details
            available_contracts = []
            for order in pending_orders:
                order_contents = order['contents']
                
                # Construct contract details
                contract_detail = {
                    "order_id": order_contents['order_id'],
                    "contract_id": order_contents.get('contract_id'),
                    "store_id": order_contents['store_id'],
                    "total_price": order_contents['total_price'],
                    "delivery_fee": order_contents['delivery_fee'],
                    "timestamp": order_contents['timestamp'],
                    "status": "AVAILABLE"
                }
                
                available_contracts.append(contract_detail)

            # Sort contracts by timestamp (oldest first)
            available_contracts.sort(key=lambda x: x['timestamp'])

            return available_contracts

        except Exception as e:
            logging.error(f"Error retrieving available contracts: {e}")
            raise

    def select_contract(self, 
                        delivery_agent_id: str, 
                        order_id: str) -> Dict:
        """
        Allow a delivery agent to select and claim a contract.
        
        :param delivery_agent_id: ID of the delivery agent
        :param order_id: ID of the order/contract to select
        :return: Updated order/contract details
        """
        try:
            # Retrieve the specific order
            order_data = self.firestore_repo.read(
                collection="orders", 
                document_tag=order_id
            )
            
            if not order_data:
                raise ValueError(f"Order {order_id} not found")
            
            # Check if order is still available
            if order_data['contents'].get('delivery_agent_id'):
                raise ValueError("Contract already assigned to another agent")
            
            if order_data['contents']['status'] != "PENDING":
                raise ValueError("Contract is no longer available")
            
            # Update order with delivery agent details
            updated_order = {
                **order_data['contents'],
                "delivery_agent_id": delivery_agent_id,
                "status": "ASSIGNED"
            }
            
            # Persist updated order
            self.firestore_repo.write(
                collection="orders",
                data={
                    "document_tag": order_id,
                    "contents": updated_order
                }
            )
            
            return updated_order

        except Exception as e:
            logging.error(f"Error selecting contract for agent {delivery_agent_id}: {e}")
            raise

    def get_agent_contracts(self, delivery_agent_id: str) -> List[Dict]:
        """
        Retrieve contracts assigned to a specific delivery agent.
        
        :param delivery_agent_id: ID of the delivery agent
        :return: List of contracts assigned to the agent
        """
        try:
            # Query Firestore for orders assigned to the delivery agent
            agent_orders = self.firestore_repo.query(
                collection="orders",
                where_clause=[
                    ("contents.delivery_agent_id", "==", delivery_agent_id)
                ]
            )

            # Transform orders into contract details
            agent_contracts = []
            for order in agent_orders:
                order_contents = order['contents']
                
                contract_detail = {
                    "order_id": order_contents['order_id'],
                    "contract_id": order_contents.get('contract_id'),
                    "store_id": order_contents['store_id'],
                    "total_price": order_contents['total_price'],
                    "delivery_fee": order_contents['delivery_fee'],
                    "status": order_contents['status']
                }
                
                agent_contracts.append(contract_detail)

            return agent_contracts

        except Exception as e:
            logging.error(f"Error retrieving contracts for agent {delivery_agent_id}: {e}")
            raise