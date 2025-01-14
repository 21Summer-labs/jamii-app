from dataclasses import dataclass, field
from enum import Enum
from typing import List, Optional
from datetime import datetime

# Store Management

@dataclass
class Location:
    latitude: float
    longitude: float
    address: str
    city: str
    country: str

@dataclass
class ImageData:
    url: str
    description: Optional[str] = None


@dataclass
class Store:
    store_id: str
    owner_id: str  # Reference to User
    store_name: str
    description: str
    owner_message: str # link to audio file of a message from the store owner
    images: List[ImageData]
    location: Location
    business_hours: str
    category: str
    rating: float

    def create(self):
        # get metadata
        # get location
        pass

    def update(self, store_name: Optional[str] = None, description: Optional[str] = None):
        if store_name:
            self.store_name = store_name
        if description:
            self.description = description

        # if image
        # if location
        # if category

