from dataclasses import dataclass, field
from enum import Enum
from typing import List, Optional
from datetime import datetime

# Communication

class MessageStatus(Enum):
    SENT = "SENT"
    DELIVERED = "DELIVERED"
    READ = "READ"

@dataclass
class MessageContent:
    text: Optional[str]
    media_url: Optional[str]
    product_reference: Optional[str]  # Reference to Product

@dataclass
class Message:
    message_id: str
    conversation_id: str  # Reference to Conversation
    sender_id: str
    content: MessageContent
    status: MessageStatus
    timestamp: datetime

@dataclass
class Conversation:
    conversation_id: str
    shopper_id: str  # Reference to User
    store_owner_id: str  # Reference to User
    store_id: str  # Reference to Store
    status: str  # ACTIVE, ARCHIVED, BLOCKED
    created_at: datetime
    last_message_at: datetime

    def create(self):
        pass

    def archive(self):
        self.status = "ARCHIVED"