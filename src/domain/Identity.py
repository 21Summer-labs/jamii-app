from dataclasses import dataclass, field
from enum import Enum
from typing import List, Optional
from datetime import datetime

# Identity and Access Management

@dataclass
class User:
    user_id: str
    full_name: str
    email: str
    phone_number: str
    join_date: datetime
    password: str  # hashed

    def change_password(self, new_password: str):
        self.password = new_password  # Ensure proper hashing


