from firebase_functions import https_fn
from firebase_admin import initialize_app, auth
import json
import importlib
import logging

# Initialize Firebase app
initialize_app()

# Service Registry with dynamic import paths
SERVICE_REGISTRY = {
    'accept_delivery': ('services.accept_delivery.AcceptDelivery', 'execute'),
    'create_product': ('services.create_product.CreateProduct', 'execute'),
    'create_store': ('services.create_store.CreateStore', 'create_store'),
    'create_user': ('services.create_user.CreateUser', 'execute'),
    'get_product': ('services.get_product.GetProduct', 'get_product'),
    'get_store': ('services.get_store.GetStore', 'get_store'),
    'get_store_products': ('services.get_products.GetProducts', 'get_store_products'),
    'get_user': ('services.get_user.GetUser', 'execute'),
    'search_products': ('services.search_products.ProductSearchService', 'search_products'),
    'create_order': ('services.create_order.CreateOrder', 'execute'),
    'get_order_by_id': ('services.get_order.GetOrder', 'get_order_by_id'),
    'get_order_by_user': ('services.get_order.GetOrder', 'get_order_by_user'),
    'get_order_by_store': ('services.get_order.GetOrder', 'get_order_by_store'),
    'get_contracts': ('services.get_contracts.GetContracts', 'get_available_contracts'),
    'select_contract': ('services.get_contracts.GetContracts', 'select_contract'),
    'confirm_pickup': ('services.confirm_pickup.ConfirmPickup', 'execute'),
    'confirm_delivery': ('services.confirm_delivery.ConfirmDelivery', 'execute'),
}

def import_service(service_path):
    """Dynamically import a service class"""
    try:
        module_path, class_name = service_path.rsplit('.', 1)
        module = importlib.import_module(module_path)
        return getattr(module, class_name)
    except (ImportError, AttributeError) as e:
        logging.error(f"Error importing service {service_path}: {e}")
        raise ValueError(f"Service not found: {service_path}")

def create_service_dependencies():
    """Create and return service dependencies"""
    from repositories.firestore_repository import FirestoreRepository
    from utils.hedera import HederaClient
    import os
    
    return {
        'firestore_repo': FirestoreRepository(),
        'hedera_client': HederaClient(
            operator_id=os.getenv('HEDERA_OPERATOR_ID'),
            operator_key=os.getenv('HEDERA_OPERATOR_KEY')
        )
    }

@https_fn.on_request()
def api(req: https_fn.Request) -> https_fn.Response:
    """Firebase function that routes requests to appropriate services"""
    
    # Handle CORS preflight
    if req.method == 'OPTIONS':
        return https_fn.Response('', status=204, headers={
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST',
            'Access-Control-Allow-Headers': 'Content-Type',
        })
    
    headers = {'Access-Control-Allow-Origin': '*'}

    try:
        # Validate request method
        if req.method != 'POST':
            return https_fn.Response(
                json.dumps({"error": "Only POST requests are supported"}), 
                status=405, 
                headers=headers
            )
        
        # Parse request body
        body = req.get_json(silent=True)
        if not body:
            return https_fn.Response(
                json.dumps({"error": "Invalid JSON payload"}), 
                status=400, 
                headers=headers
            )
        
        # Extract service name and payload
        service_name = body.get('service')
        payload = body.get('payload', {})

        # Validate service name
        if not service_name or service_name not in SERVICE_REGISTRY:
            return https_fn.Response(
                json.dumps({"error": f"Invalid service: {service_name}"}), 
                status=400, 
                headers=headers
            )

        # Import and instantiate service
        service_path, method_name = SERVICE_REGISTRY[service_name]
        ServiceClass = import_service(service_path)

        # Inject dependencies
        dependencies = create_service_dependencies()
        service_instance = ServiceClass(**{
            k: dependencies[k] for k in dependencies if k in service_path
        })

        # Call the appropriate method dynamically
        service_method = getattr(service_instance, method_name)
        result = service_method(**payload)

        return https_fn.Response(json.dumps(result), status=200, headers=headers)

    except Exception as e:
        logging.error(f"API Error: {str(e)}")
        return https_fn.Response(
            json.dumps({"error": str(e)}), 
            status=500, 
            headers=headers
        )
