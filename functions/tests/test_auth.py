import unittest
from unittest.mock import patch, MagicMock
from infrastructure.firebase_auth.auth_service import FirebaseAuthService

class TestFirebaseAuthService(unittest.TestCase):
    
    @patch("infrastructure.firebase_auth.auth_service.auth.create_user")
    def test_signup_success(self, mock_create_user):
        mock_user = MagicMock()
        mock_user.uid = "12345"
        mock_user.email = "test@example.com"
        mock_user.display_name = "Test User"
        
        mock_create_user.return_value = mock_user
        
        result = FirebaseAuthService.signup("test@example.com", "password123", "Test User")
        
        self.assertEqual(result["uid"], "12345")
        self.assertEqual(result["email"], "test@example.com")
        self.assertEqual(result["display_name"], "Test User")

    @patch("infrastructure.firebase_auth.auth_service.auth.create_user")
    def test_signup_failure(self, mock_create_user):
        mock_create_user.side_effect = Exception("Signup failed")
        
        result = FirebaseAuthService.signup("test@example.com", "password123")
        
        self.assertIn("error", result)
        self.assertEqual(result["error"], "Signup failed")
    
    @patch("infrastructure.firebase_auth.auth_service.auth.get_user")
    def test_get_user_success(self, mock_get_user):
        mock_user = MagicMock()
        mock_user.uid = "12345"
        mock_user.email = "test@example.com"
        mock_user.display_name = "Test User"
        mock_user.phone_number = "1234567890"
        mock_user.photo_url = "http://example.com/photo.jpg"
        
        mock_get_user.return_value = mock_user
        
        result = FirebaseAuthService.get_user("12345")
        
        self.assertEqual(result["uid"], "12345")
        self.assertEqual(result["email"], "test@example.com")
        self.assertEqual(result["display_name"], "Test User")
        self.assertEqual(result["phone_number"], "1234567890")
        self.assertEqual(result["photo_url"], "http://example.com/photo.jpg")

    @patch("infrastructure.firebase_auth.auth_service.auth.get_user")
    def test_get_user_failure(self, mock_get_user):
        mock_get_user.side_effect = Exception("User not found")
        
        result = FirebaseAuthService.get_user("invalid_uid")
        
        self.assertIn("error", result)
        self.assertEqual(result["error"], "User not found")

if __name__ == "__main__":
    unittest.main()