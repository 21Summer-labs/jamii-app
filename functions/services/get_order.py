from typing import Dict, Any, Optional, List
import logging

from utils.repositories import FirestoreRepository
from models import Order

class GetOrder:
    def __init__(self, firestore_repo: FirestoreRepository):
        """
        Initialize GetOrder service with Firestore repository.
        
        :param firestore_repo: Firestore repository for data retrieval
        """
        self.firestore_repo = firestore_repo

    def by_id(self, order_id: str) -> Optional[Dict[str, Any]]:
        """
        Retrieve a specific order by its ID.
        
        :param order_id: Unique identifier for the order
        :return: Order details or None if not found
        """
        try:
            order_data = self.firestore_repo.read(
                collection="orders", 
                document_tag=order_id
            )
            
            return order_data['contents'] if order_data else None
        except Exception as e:
            logging.error(f"Error retrieving order {order_id}: {e}")
            raise

    def by_user(self, user_id: str) -> List[Dict[str, Any]]:
        """
        Retrieve all orders for a specific user.
        
        :param user_id: ID of the user
        :return: List of user's orders
        """
        try:
            # Query Firestore for orders belonging to the user
            query_results = self.firestore_repo.query(
                collection="orders",
                where_clause=[
                    ("contents.user_id", "==", user_id)
                ]
            )
            
            # Extract contents from query results
            return [result['contents'] for result in query_results]
        except Exception as e:
            logging.error(f"Error retrieving orders for user {user_id}: {e}")
            raise

    def by_store(self, store_id: str) -> List[Dict[str, Any]]:
        """
        Retrieve all orders for a specific store.
        
        :param store_id: ID of the store
        :return: List of store's orders
        """
        try:
            # Query Firestore for orders belonging to the store
            query_results = self.firestore_repo.query(
                collection="orders",
                where_clause=[
                    ("contents.store_id", "==", store_id)
                ]
            )
            
            # Extract contents from query results
            return [result['contents'] for result in query_results]
        except Exception as e:
            logging.error(f"Error retrieving orders for store {store_id}: {e}")
            raise

    def filter_by_status(self, status: str) -> List[Dict[str, Any]]:
        """
        Retrieve orders filtered by their current status.
        
        :param status: Order status to filter by (e.g., 'PENDING', 'COMPLETED', 'CANCELLED')
        :return: List of orders matching the status
        """
        try:
            # Query Firestore for orders with specific status
            query_results = self.firestore_repo.query(
                collection="orders",
                where_clause=[
                    ("contents.status", "==", status)
                ]
            )
            
            # Extract contents from query results
            return [result['contents'] for result in query_results]
        except Exception as e:
            logging.error(f"Error retrieving orders with status {status}: {e}")
            raise

    def recent_orders(self, limit: int = 10) -> List[Dict[str, Any]]:
        """
        Retrieve most recent orders.
        
        :param limit: Number of recent orders to retrieve
        :return: List of recent orders
        """
        try:
            # Query Firestore for recent orders sorted by timestamp
            query_results = self.firestore_repo.query(
                collection="orders",
                order_by=[("contents.timestamp", "desc")],
                limit=limit
            )
            
            # Extract contents from query results
            return [result['contents'] for result in query_results]
        except Exception as e:
            logging.error(f"Error retrieving recent orders: {e}")
            raise