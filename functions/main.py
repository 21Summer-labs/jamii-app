from firebase_functions import https_fn
from firebase_admin import initialize_app
import json

# Import your existing services
from services import (
    ProductCreationService, ProductSearchService, 
    GetProducts, GetProduct, CreateStore, GetStore,
    FirestoreRepository, FirebaseStorageRepository,
    GeminiHandler, EmbeddingService
)

@https_fn.on_request()
def api(req: https_fn.Request) -> https_fn.Response:
    """Main API router for all operations"""
    try:
        # Extract the resource and operation from the path
        path_parts = req.path.strip('/').split('/')
        if len(path_parts) < 2:
            return https_fn.Response('Invalid path', status=400)
        
        resource, operation = path_parts[0], path_parts[1]
        
        # Product operations
        if resource == 'product':
            if operation == 'create' and req.method == 'POST':
                data = req.get_json()
                required_fields = ['store_id', 'temp_image_paths', 'temp_audio_path', 'metadata']
                
                if not all(field in data for field in required_fields):
                    return https_fn.Response('Missing required fields', status=400)
                
                product_service = ProductCreationService(
                    GeminiHandler(),
                    EmbeddingService(),
                    FirestoreRepository(),
                    FirebaseStorageRepository()
                )
                
                product = product_service.create_product(
                    temp_image_paths=data['temp_image_paths'],
                    temp_audio_path=data['temp_audio_path'],
                    metadata=data['metadata']
                )
                
                return https_fn.Response(json.dumps(product.__dict__), status=200)
                
            elif operation == 'search' and req.method == 'GET':
                query = req.args.get('query')
                store_id = req.args.get('store_id')
                limit = int(req.args.get('limit', 20))
                
                if not query:
                    return https_fn.Response('Search query is required', status=400)
                
                search_service = ProductSearchService(
                    GeminiHandler(),
                    EmbeddingService(),
                    FirestoreRepository()
                )
                
                products = search_service.search_products(
                    query=query,
                    store_id=store_id,
                    limit=limit
                )
                
                return https_fn.Response(
                    json.dumps([product.__dict__ for product in products]),
                    status=200
                )
                
            elif operation == 'list' and req.method == 'GET':
                store_id = req.args.get('store_id')
                category = req.args.get('category')
                page = int(req.args.get('page', 1))
                page_size = int(req.args.get('page_size', 20))
                
                if not store_id:
                    return https_fn.Response('Store ID is required', status=400)
                    
                products = GetProducts(FirestoreRepository()).get_store_products(
                    store_id=store_id,
                    category=category,
                    page=page,
                    page_size=page_size
                )
                
                return https_fn.Response(
                    json.dumps([product.__dict__ for product in products]),
                    status=200
                )
        
        # Store operations
        elif resource == 'store':
            if operation == 'create' and req.method == 'POST':
                store_data = req.get_json()
                store = CreateStore(FirestoreRepository()).create_store(store_data)
                return https_fn.Response(json.dumps(store.__dict__), status=200)
                
            elif operation == 'get' and req.method == 'GET':
                store_id = req.args.get('store_id')
                owner_id = req.args.get('owner_id')
                
                if not (store_id or owner_id):
                    return https_fn.Response('Store ID or Owner ID is required', status=400)
                    
                get_store_service = GetStore(FirestoreRepository())
                
                if store_id:
                    store = get_store_service.get_store(store_id)
                    return https_fn.Response(
                        json.dumps(store.__dict__) if store else 'Store not found',
                        status=200 if store else 404
                    )
                else:
                    stores = get_store_service.get_stores_by_owner(owner_id)
                    return https_fn.Response(
                        json.dumps([store.__dict__ for store in stores]),
                        status=200
                    )
        
        return https_fn.Response('Invalid resource or operation', status=400)
        
    except Exception as e:
        return https_fn.Response(str(e), status=500)

if __name__ == "__main__":
    # Initialize Firebase Admin with emulator
    import os
    os.environ["FIRESTORE_EMULATOR_HOST"] = "localhost:8080"
    os.environ["FIREBASE_STORAGE_EMULATOR_HOST"] = "localhost:9199"

    # Ensure the assets folder exists
    assets_folder = os.path.join(os.path.dirname(__file__), 'assets')
    if not os.path.exists(assets_folder):
        os.makedirs(assets_folder)

    
    try:
        initialize_app()
    except ValueError:
        # App already initialized
        pass

    # Test data
    test_store_data = {
        "document_tag": "test_store_18",  # Unique document tag for the store
        "contents": {
            "owner_id": "test_owner_1",
            "store_name": "Test Store",
            "description": "A test store",
            "location": {
                "latitude": 40.7128,
                "longitude": -74.0060
            }
        }
    }


    test_product_data = {
        "store_id": "test_store_1",
        "temp_image_paths": [
            os.path.join(assets_folder, "image1.jpg")  # Resolve image path relative to 'assets'
        ],
        "temp_audio_path": os.path.join(assets_folder, "audio.wav"),  # Resolve audio path relative to 'assets'
        "metadata": {
            "store_id": "test_store_1",
            "additional_info": "Test product"
        }
    }



    # Mock request class
    class MockRequest:
        def __init__(self, path: str, method: str, args=None, json_data=None):
            self.path = path
            self.method = method
            self.args = args or {}
            self._json = json_data

        def get_json(self):
            return self._json

    # Test functions
    def test_create_store():
        print("\nTesting store creation...")
        req = MockRequest("/store/create", "POST", json_data=test_store_data)
        response = api(req)
        print(f"Status: {response.status_code}")
        print(f"Response: {response.data}")
        return response

    def test_create_product():
        print("\nTesting product creation...")
        req = MockRequest("/product/create", "POST", json_data=test_product_data)
        response = api(req)
        print(f"Status: {response.status_code}")
        print(f"Response: {response.data}")
        return response

    def test_product_search():
        print("\nTesting product search...")
        req = MockRequest(
            "/product/search", 
            "GET", 
            args={"query": "test product", "store_id": "test_store_1"}
        )
        response = api(req)
        print(f"Status: {response.status_code}")
        print(f"Response: {response.data}")
        return response

    # Run tests
    print("Starting tests with Firebase emulator...")
    
    # Create test store
    store_response = test_create_store()
    if store_response.status_code == 200:
        # Use the created store's ID for product tests
        store_data = json.loads(store_response.data)
        test_product_data["store_id"] = store_data.get("store_id")
        
        # Create test product
        product_response = test_create_product()
        if product_response.status_code == 200:
            # Search for the created product
            test_product_search()