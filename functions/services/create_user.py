from utils.auth import FirebaseAuthService
from utils.hedera import HederaClient
from utils.repositories import FirestoreRepository

class CreateUser:
    def __init__(self, operator_id, operator_key):
        self.auth_service = FirebaseAuthService()
        self.hedera_client = HederaClient(operator_id, operator_key)
    
    def execute(self, email: str, password: str, display_name: str = None):
        """
        Creates a new user in Firebase Auth and then generates a Hedera wallet for them.
        """
        # Create user in Firebase Auth
        user_response = self.auth_service.signup(email, password, display_name)
        
        if "error" in user_response:
            return {"success": False, "message": "Failed to create user", "error": user_response["error"]}
        
        firebase_uid = user_response["uid"]
        
        # Create Hedera wallet
        try:
            wallet_response = self.hedera_client.create_wallet(firebase_uid)
            return {"success": True, "user": user_response, "wallet": wallet_response}
        except Exception as e:
            return {"success": False, "message": "Failed to create wallet", "error": str(e)}
