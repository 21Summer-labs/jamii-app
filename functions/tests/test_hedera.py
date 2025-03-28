import pytest
from unittest.mock import Mock, patch
from datetime import datetime

from utils.hedera import HederaClient
from hedera import (
    Client, 
    AccountCreateTransaction, 
    FileCreateTransaction,
    ContractCreateTransaction,
    ContractExecuteTransaction,
    PrivateKey,
    Hbar
)

@pytest.fixture
def mock_hedera_client():
    """
    Fixture to create a mocked HederaClient instance for testing.
    """
    # Mock Firebase initialization
    with patch('firebase_admin.initialize_app'), \
         patch('firebase_admin.credentials.Certificate'), \
         patch('firebase_admin.firestore.client') as mock_firestore:
        
        # Setup mock Firestore client
        mock_db = Mock()
        mock_firestore.return_value = mock_db
        
        # Create HederaClient with mock credentials
        client = HederaClient(
            operator_id="0.0.1234", 
            operator_key="some_private_key"
        )
        
        return client, mock_db

class TestHederaClient:
    def test_initialization(self, mock_hedera_client):
        """
        Test HederaClient initialization.
        """
        hedera_client, mock_db = mock_hedera_client
        
        # Verify Hedera client setup
        assert hedera_client.client is not None
        assert hedera_client.db is not None

    def test_create_wallet(self, mock_hedera_client):
        """
        Test wallet creation process.
        """
        hedera_client, mock_db = mock_hedera_client
        
        # Mock Firebase user ID
        firebase_uid = "test_user_123"
        
        # Mock Hedera account creation
        with patch('hedera.AccountCreateTransaction.execute') as mock_execute, \
             patch('hedera.AccountCreateTransaction.get_receipt') as mock_receipt:
            # Setup mock return values
            mock_account_id = Mock()
            mock_account_id.account_id = "0.0.5678"
            mock_receipt.return_value.account_id = mock_account_id
            mock_execute.return_value.get_receipt.return_value = mock_receipt.return_value
            
            # Mock Firestore document set
            mock_doc = Mock()
            mock_db.collection.return_value.document.return_value = mock_doc
            
            # Execute wallet creation
            result = hedera_client.create_wallet(firebase_uid)
            
            # Assertions
            assert "customer_id" in result
            assert "hedera_account_id" in result
            
            # Verify Firestore document was set
            mock_doc.set.assert_called_once()

    def test_get_wallet(self, mock_hedera_client):
        """
        Test retrieving wallet details.
        """
        hedera_client, mock_db = mock_hedera_client
        
        # Firebase UID
        firebase_uid = "test_user_123"
        
        # Mock Firestore document retrieval
        mock_doc = Mock()
        mock_doc.exists = True
        mock_doc.to_dict.return_value = {
            "hedera_account_id": "0.0.5678",
            "hedera_private_key": "some_private_key"
        }
        
        # Setup mock Firestore client
        mock_db.collection.return_value.document.return_value.get.return_value = mock_doc
        
        # Execute wallet retrieval
        wallet = hedera_client.get_wallet(firebase_uid)
        
        # Assertions
        assert wallet is not None
        assert wallet["hedera_account_id"] == "0.0.5678"

    def test_deploy_contract(self, mock_hedera_client):
        """
        Test smart contract deployment.
        """
        hedera_client, mock_db = mock_hedera_client
        
        # Mock bytecode reading
        with patch('builtins.open', create=True) as mock_open:
            mock_open.return_value.__enter__.return_value.read.return_value = "mock_bytecode"
            
            # Mock various Hedera transactions
            with patch('hedera.FileCreateTransaction.execute') as mock_file_create, \
                 patch('hedera.FileAppendTransaction.execute') as mock_file_append, \
                 patch('hedera.ContractCreateTransaction.execute') as mock_contract_create:
                
                # Setup mock return values
                mock_file_id = Mock()
                mock_file_id.file_id = "0.0.9876"
                mock_contract_id = Mock()
                mock_contract_id.contract_id = "0.0.5432"
                
                mock_file_create.return_value.get_receipt.return_value.file_id = mock_file_id
                mock_contract_create.return_value.get_receipt.return_value.contract_id = mock_contract_id
                
                # Execute contract deployment
                contract_id = hedera_client.deploy_contract(
                    store_owner_id="0.0.1111", 
                    amount=100, 
                    delivery_fee=10
                )
                
                # Assertions
                assert contract_id == "0.0.5432"

    def test_execute_contract(self, mock_hedera_client):
        """
        Test contract execution.
        """
        hedera_client, mock_db = mock_hedera_client
        
        # Mock contract execution
        with patch('hedera.ContractExecuteTransaction.execute') as mock_execute:
            # Setup mock return values
            mock_receipt = Mock()
            mock_execute.return_value.get_receipt.return_value = mock_receipt
            
            # Execute contract method
            result = hedera_client.execute_contract(
                contract_id="0.0.5432", 
                function_name="testFunction",
                params=["0.0.1111", 100]
            )
            
            # Assertions
            assert result == mock_receipt

    def test_fund_contract(self, mock_hedera_client):
        """
        Test contract funding.
        """
        hedera_client, mock_db = mock_hedera_client
        
        # Mock contract funding
        with patch.object(hedera_client, 'execute_contract') as mock_execute:
            # Execute fund contract
            hedera_client.fund_contract(
                contract_id="0.0.5432", 
                amount=100, 
                delivery_fee=10
            )
            
            # Verify execute_contract was called with correct parameters
            mock_execute.assert_called_once_with(
                contract_id="0.0.5432", 
                function_name="fundContract", 
                gas=100000, 
                payable_amount=110
            )

    def test_confirm_pickup(self, mock_hedera_client):
        """
        Test confirm pickup method.
        """
        hedera_client, mock_db = mock_hedera_client
        
        # Mock contract execution
        with patch.object(hedera_client, 'execute_contract') as mock_execute:
            # Execute confirm pickup
            hedera_client.confirm_pickup(contract_id="0.0.5432")
            
            # Verify execute_contract was called with correct parameters
            mock_execute.assert_called_once_with(
                contract_id="0.0.5432", 
                function_name="confirmPickup", 
                gas=50000
            )

def test_hedera_client_error_handling():
    """
    Test error handling during Hedera client initialization.
    """
    with pytest.raises(Exception):
        # Attempt to create client with invalid credentials
        HederaClient(operator_id=None, operator_key=None)