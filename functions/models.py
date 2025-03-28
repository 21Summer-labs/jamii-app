import uuid
from datetime import datetime
from dataclasses import asdict, dataclass, field
from typing import List, Dict, Optional
from typing import Optional

from utils.repositories import FirestoreRepository

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


@dataclass
class User:
    user_id: str
    name: str
    email: str
    wallet_address: str


@dataclass
class Order:
    order_id: str
    user_id: str
    store_id: str
    total_price: float
    delivery_fee: float
    status: str
    timestamp: datetime
    contract_id: Optional[str] = None  # New field to store Hedera contract ID
    delivery_agent_id: Optional[str] = None  # Optional field for delivery agent
    
    def create(self, repo: FirestoreRepository):
        """
        Create the order in Firestore repository.
        
        :param repo: Firestore repository to persist the order
        """
        data = {
            "document_tag": self.order_id,
            "contents": self.__dict__,  # Convert the entire dataclass to a dictionary
        }
        repo.write(collection="orders", data=data)