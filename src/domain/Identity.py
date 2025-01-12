from dataclasses import dataclass, field
from enum import Enum
from typing import List, Optional
from datetime import datetime

# Identity and Access Management

class UserType(Enum):
    SHOPPER = "SHOPPER"
    STORE_OWNER = "STORE_OWNER"

class UserStatus(Enum):
    ACTIVE = "ACTIVE"
    INACTIVE = "INACTIVE"
    SUSPENDED = "SUSPENDED"

@dataclass
class Location:
    latitude: float
    longitude: float
    address: str
    city: str
    country: str

@dataclass
class UserProfile:
    full_name: str
    location: Location
    preferred_language: str
    join_date: datetime
    last_login_date: datetime

@dataclass
class User:
    user_id: str
    email: str
    phone_number: str
    password: str  # hashed
    profile: UserProfile
    user_type: UserType
    status: UserStatus

    def register(self):
        pass

    def update_profile(self, profile: UserProfile):
        self.profile = profile

    def change_password(self, new_password: str):
        self.password = new_password  # Ensure proper hashing

    def deactivate(self):
        self.status = UserStatus.INACTIVE
