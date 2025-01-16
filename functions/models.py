import uuid
from datetime import datetime
from dataclasses import asdict, dataclass, field
from typing import List, Dict, Optional
from repositories import FirestoreRepository

@dataclass
class Product:
    product_id: str
    store_id: str
    name: str
    description: str
    price: float
    category: str
    subcategory: str
    stock: int
    tags: List[str]
    images: List[str]
    audio: str  # Path to audio file in Firebase storage
    
    def create(self, repo: FirestoreRepository):
        data = {
            "document_tag": self.product_id,  # Set document_tag to product_id
            "contents": self.__dict__,  # Use the instance's dictionary representation
        }
        repo.write(collection="products", data=data)


@dataclass
class Location:
    latitude: float
    longitude: float


@dataclass
class Store:
    store_id: str
    owner_id: str  # Reference to User
    store_name: str
    description: str
    location: dict  # Change from Location to dict

    def create(self, repo: FirestoreRepository):
        """
        Create the store in Firestore with the specified document_tag.
        """
        # Prepare the data in the expected format for Firestore
        data = {
            "document_tag": self.store_id,
            "contents": self.__dict__,  # location is already a dict
        }

        # Write the data to Firestore
        repo.write(collection="stores", data=data)

