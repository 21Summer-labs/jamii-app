from typing import List, Optional
from utils.repositories import FirestoreRepository
from models import Store, Location  # Assuming Store and Location are defined here


class GetStore:
    def __init__(self, repo: FirestoreRepository):
        self.repo = repo
    
    def get_store(self, store_id: str) -> Optional[Store]:
        """
        Get details about a specific store.
        """
        store_data = self.repo.read(
            collection="stores",
            identifier=store_id
        )
        
        if not store_data:
            return None
            
        # Convert location dict to Location object
        store_data[0]['location'] = Location(**store_data[0]['location'])
        return Store(**store_data[0])
    
    def get_stores_by_owner(self, owner_id: str) -> List[Store]:
        """
        Get all stores owned by a specific user.
        """
        stores_data = self.repo.read(
            collection="stores",
            filters=[("owner_id", "==", owner_id)]
        )
        
        stores = []
        for store_data in stores_data:
            store_data['location'] = Location(**store_data['location'])
            stores.append(Store(**store_data))
        
        return stores
