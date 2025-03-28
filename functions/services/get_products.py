from typing import List, Optional, Dict, TypedDict
import uuid
import json
from utils.repositories import FirestoreRepository

class GetProducts:
    def __init__(self, product_repo: FirestoreRepository):
        self.product_repo = product_repo
    
    def get_store_products(self, store_id: str, 
                          category: Optional[str] = None,
                          page: int = 1,
                          page_size: int = 20) -> List[Product]:
        """
        Get all products for a specific store with optional filtering and pagination.
        """
        filters = [("store_id", "==", store_id)]
        if category:
            filters.append(("category", "==", category))
            
        # Calculate pagination
        start = (page - 1) * page_size
        
        products_data = self.product_repo.read(
            collection="products",
            filters=filters
        )
        
        # Apply pagination
        paginated_data = products_data[start:start + page_size]
        
        return [Product(**product) for product in paginated_data]