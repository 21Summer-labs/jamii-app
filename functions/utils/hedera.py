import firebase_admin
from firebase_admin import firestore
from hedera import (
    Client, 
    AccountCreateTransaction, 
    FileCreateTransaction,
    FileAppendTransaction,
    ContractCreateTransaction,
    ContractExecuteTransaction,
    ContractFunctionParameters,
    PrivateKey,
    Hbar
)
import logging

from firebase_admin import auth, firestore, credentials, initialize_app
from google.cloud import firestore  

# Initialize Firebase Firestore
db = firestore.client()

# Load Firebase credentials
cred = credentials.Certificate("firebase-config.json")
firebase_admin.initialize_app(cred)

# Firestore DB instance
db = firestore.client()


class HederaClient:
    def __init__(self, operator_id, operator_key):
        try:
            # Initialize Firebase if not already done
            if not firebase_admin._apps:
                firebase_admin.initialize_app()
            
            self.db = firestore.client()
            
            # Setup Hedera client
            self.client = Client.for_testnet()
            self.client.set_operator(operator_id, PrivateKey.fromString(operator_key))
        except Exception as e:
            logging.error(f"Initialization error: {e}")
            raise

    def create_wallet(self, firebase_uid):
        """
        Creates a new Hedera wallet and links it to the Firebase User ID.
        """
        try:
            new_private_key = PrivateKey.generate()
            new_public_key = new_private_key.public_key

            transaction = AccountCreateTransaction() \
                .set_key(new_public_key) \
                .set_initial_balance(Hbar(10))
            
            response = transaction.execute(self.client)
            receipt = response.get_receipt(self.client)
            hedera_account_id = receipt.account_id

            customer_ref = self.db.collection("customers").document(firebase_uid)
            customer_ref.set({
                "hedera_account_id": str(hedera_account_id),
                "hedera_private_key": str(new_private_key),
            })
            
            return {
                "customer_id": firebase_uid,
                "hedera_account_id": str(hedera_account_id),
            }
        except Exception as e:
            logging.error(f"Wallet creation error: {e}")
            raise

    def get_wallet(self, firebase_uid):
        """Fetch customer's Hedera account details using Firebase UID."""
        try:
            customer_ref = self.db.collection("customers").document(firebase_uid)
            customer_data = customer_ref.get()
            return customer_data.to_dict() if customer_data.exists else None
        except Exception as e:
            logging.error(f"Wallet retrieval error: {e}")
            raise

    def deploy_contract(self, store_owner_id, amount, delivery_fee, bytecode_path="LogisticsEscrow.bin"):
        """
        Deploys a smart contract to Hedera.
        """
        try:
            # Read bytecode
            with open(bytecode_path, "r") as f:
                bytecode = f.read().strip()

            # Create file to store bytecode
            file_tx = FileCreateTransaction().set_keys([self.client.get_operator_public_key()])
            file_response = file_tx.execute(self.client)
            file_receipt = file_response.get_receipt(self.client)
            file_id = file_receipt.file_id

            # Append bytecode to file
            append_tx = FileAppendTransaction().set_file_id(file_id).set_contents(bytecode)
            append_tx.execute(self.client)
            
            # Create contract
            contract_tx = ContractCreateTransaction() \
                .set_bytecode_file_id(file_id) \
                .set_gas(100000) \
                .set_constructor_parameters(
                    ContractFunctionParameters()
                    .addAddress(store_owner_id)
                    .addUint256(int(amount))
                    .addUint256(int(delivery_fee))
                )
            
            contract_response = contract_tx.execute(self.client)
            contract_receipt = contract_response.get_receipt(self.client)
            contract_id = contract_receipt.contract_id
            
            return contract_id
        except Exception as e:
            logging.error(f"Contract deployment error: {e}")
            raise

    def execute_contract(self, contract_id, function_name, params=None, gas=100000, payable_amount=0):
        """Executes a function on a deployed smart contract."""
        try:
            transaction = ContractExecuteTransaction() \
                .set_contract_id(contract_id) \
                .set_gas(gas)
            
            # Prepare function parameters if provided
            if params:
                func_params = ContractFunctionParameters()
                for param in params:
                    # Add type-specific parameter handling
                    if isinstance(param, str):
                        func_params.addAddress(param)
                    elif isinstance(param, int):
                        func_params.addUint256(param)
                    # Add more type handling as needed
                
                transaction.set_function(function_name, func_params)
            else:
                transaction.set_function(function_name)
            
            if payable_amount:
                transaction.set_payable_amount(Hbar(payable_amount))
            
            response = transaction.execute(self.client)
            return response.get_receipt(self.client)
        except Exception as e:
            logging.error(f"Contract execution error: {e}")
            raise

    def fund_contract(self, contract_id, amount, delivery_fee):
        return self.execute_contract(contract_id, "fundContract", gas=100000, payable_amount=amount + delivery_fee)

    def confirm_pickup(self, contract_id):
        return self.execute_contract(contract_id, "confirmPickup", gas=50000)

    def accept_delivery(self, contract_id, agent_id, amount):
        return self.execute_contract(contract_id, "acceptDelivery", agent_id, gas=100000, payable_amount=amount)

    def confirm_delivery(self, contract_id, customer_id, store_id, agent_id):
        return self.execute_contract(contract_id, "confirmDelivery", customer_id, store_id, agent_id, gas=100000)
