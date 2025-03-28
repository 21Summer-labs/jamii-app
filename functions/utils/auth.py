# infrastructure/firebase_auth/auth_service.py
import firebase_admin
from firebase_admin import auth, credentials

# Initialize Firebase Admin SDK (Ensure you have serviceAccountKey.json)
cred = credentials.Certificate("config/serviceAccountKey.json")
firebase_admin.initialize_app(cred)

class FirebaseAuthService:
    
    @staticmethod
    def signup(email: str, password: str, display_name: str = None):
        """ Creates a new user in Firebase Auth """
        try:
            user = auth.create_user(
                email=email,
                password=password,
                display_name=display_name
            )
            return {"uid": user.uid, "email": user.email, "display_name": user.display_name}
        except Exception as e:
            return {"error": str(e)}

    @staticmethod
    def get_user(uid: str):
        """ Fetches user details from Firebase Auth """
        try:
            user = auth.get_user(uid)
            return {
                "uid": user.uid,
                "email": user.email,
                "display_name": user.display_name,
                "phone_number": user.phone_number,
                "photo_url": user.photo_url
            }
        except Exception as e:
            return {"error": str(e)}
