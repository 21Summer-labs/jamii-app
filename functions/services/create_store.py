import uuid
from utils.repositories import FirestoreRepository
from models import Store  # Assuming Store is defined here

class CreateStore:
    def __init__(self, repo: FirestoreRepository):
        self.repo = repo

    def create_store(self, store_data: dict) -> Store:
        """
        Create a new store with the provided information.
        """
        contents = store_data.get("contents")
        if not contents:
            raise ValueError("Store data must contain 'contents'")

        # Validate required fields
        required_fields = ['owner_id', 'store_name', 'description', 'location']
        for field in required_fields:
            if field not in contents:
                raise ValueError(f"Missing required field in contents: {field}")

        # Generate store_id if not provided
        if 'store_id' not in contents:
            contents['store_id'] = str(uuid.uuid4())

        # Create Store instance directly using the provided data
        store = Store(**contents)

        # Create the store in Firestore
        store.create(self.repo)

        return store
