from dataclasses import dataclass, field
from enum import Enum
from typing import List, Optional
from datetime import datetime

# Store Management

class StoreStatus(Enum):
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"
    SUSPENDED = "SUSPENDED"

class VerificationStatus(Enum):
    PENDING = "PENDING"
    VERIFIED = "VERIFIED"
    REJECTED = "REJECTED"

@dataclass
class ImageData:
    url: str
    description: Optional[str] = None

@dataclass
class BusinessHours:
    weekly_schedule: List[str]  # Example: ["Mon-Fri: 9AM-5PM"]

    def is_open(self, day: str, time: str) -> bool:
        pass

    def get_next_opening_time(self):
        pass

@dataclass
class Store:
    store_id: str
    owner_id: str  # Reference to User
    store_name: str
    description: str
    images: List[ImageData]
    location: Location
    business_hours: BusinessHours
    category: str
    status: StoreStatus
    rating: float
    verification_status: VerificationStatus

    def create(self):
        pass

    def update(self, store_name: Optional[str] = None, description: Optional[str] = None):
        if store_name:
            self.store_name = store_name
        if description:
            self.description = description
