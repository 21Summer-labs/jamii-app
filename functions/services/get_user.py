from utils.auth import FirebaseAuthService
from utils.hedera import HederaClient
from utils.repositories import FirestoreRepository

class GetUser:
    def __init__(self, operator_id, operator_key):
        self.auth_service = FirebaseAuthService()
        self.hedera_client = HederaClient(operator_id, operator_key)
    
    def execute(self, firebase_uid: str):
        """
        Fetches user details from Firebase and their associated Hedera wallet.
        """
        # Get user details from Firebase
        user_response = self.auth_service.get_user(firebase_uid)
        
        if "error" in user_response:
            return {"success": False, "message": "Failed to retrieve user", "error": user_response["error"]}
        
        # Get Hedera wallet details
        wallet_response = self.hedera_client.get_wallet(firebase_uid)
        
        return {"success": True, "user": user_response, "wallet": wallet_response}