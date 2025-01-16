
from typing import List, Optional, Dict, TypedDict
import uuid
import json

# Custom type imports
from models import Product, Store, Location
from repositories import FirestoreRepository, FirebaseStorageRepository
from utils import GeminiHandler, EmbeddingService

class ProductCreationService:
    def __init__(
        self,
        assistant_service: GeminiHandler,
        embedding_service: EmbeddingService,
        product_repo: FirestoreRepository,
        storage_repo: FirebaseStorageRepository
    ):
        self.assistant_service = assistant_service
        self.embedding_service = embedding_service
        self.product_repo = product_repo
        self.storage_repo = storage_repo

    def _generate_product_id(self) -> str:
        """Generate a unique product ID."""
        return str(uuid.uuid4())

    def _extract_product_attributes(
        self,
        temp_audio_path: str,
        temp_image_paths: List[str],
        metadata: Dict
        ) -> Dict:
        """Extract product attributes using Gemini."""
        try:
            class ProductAttributes(TypedDict):
                name: str
                description: str
                price: float
                category: str
                subcategory: str
                tags: List[str]

            prompt = f"""
            Based on the provided images and audio description, extract the following product details:
            - Product name
            - Detailed description
            - Appropriate price
            - Category and subcategory
            - Relevant tags
            
            Additional context: {metadata.get('additional_info', '')}
            Please provide the attributes in a structured format.
            """
            raw_attributes = self.assistant_service.process_content(
                schema=ProductAttributes,
                text=prompt,
                image_path=temp_image_paths[0] if temp_image_paths else None,
                audio_path=temp_audio_path,
                use_json=True
            )
            
            # Add debug to confirm the output type
            print(f"Debug - raw attributes output: {raw_attributes}")
            
            # Parse JSON if needed
            if isinstance(raw_attributes, str):
                raw_attributes = json.loads(raw_attributes)
            
            if not isinstance(raw_attributes, dict):
                raise TypeError(f"Expected a dictionary for attributes but got {type(raw_attributes)}")
            
            return raw_attributes
        except Exception as e:
            raise Exception(f"Failed to extract product attributes: {str(e)}")

    def create_product(
        self,
        temp_image_paths: List[str],
        temp_audio_path: str,
        metadata: dict
    ) -> Product:
        """
        Create a product using the provided images, audio description, and metadata.
        """
        try:
            # Generate product ID first
            product_id = self._generate_product_id()
            
            # Extract product attributes using temporary files
            attributes = self._extract_product_attributes(
                temp_audio_path,
                temp_image_paths,
                metadata
            )
            
            # Store files and get URLs
            try:
                image_urls, audio_url = self.storage_repo.store_product_files(
                    store_id=metadata['store_id'],
                    product_id=product_id,
                    image_paths=temp_image_paths,
                    audio_path=temp_audio_path
                )
            except Exception as e:
                raise Exception(f"Failed to store product files: {str(e)}")
            
            # Create embedding for search - Fixed this section
            try:
                # Add debug logging to see what we're getting
                print(f"Debug - attributes received: {attributes}")
                
                # Make sure attributes are properly accessed as a dictionary
                if isinstance(attributes, dict):
                    search_text = f"{attributes.get('name', '')} {attributes.get('description', '')} {' '.join(attributes.get('tags', []))}"
                else:
                    # If attributes is not a dictionary, convert it to string representation
                    search_text = str(attributes)
                
                self.embedding_service.index_text(search_text, product_id)
            except Exception as e:
                raise Exception(f"Failed to create search embedding: {str(e)} - Attributes type: {type(attributes)}")
            
            # Create product instance with storage URLs
            product = Product(
                product_id=product_id,
                store_id=metadata['store_id'],
                name=attributes['name'],
                description=attributes['description'],
                price=attributes['price'],
                category=attributes['category'],
                subcategory=attributes['subcategory'],
                images=image_urls,
                audio=audio_url,
                stock=metadata.get('stock', 0),
                tags=attributes.get('tags', [])
            )
            
            # Save to repository
            try:
                product.create(self.product_repo)
            except Exception as e:
                raise Exception(f"Failed to save product to database: {str(e)}")
            
            return product

        except Exception as e:
            raise Exception(f"Product creation failed: {str(e)}")

class SearchFilters(TypedDict):
    description: Optional[str]
    category: Optional[str]
    subcategory: Optional[str]
    tags: Optional[List[str]]
    min_price: Optional[float]
    max_price: Optional[float]


class ProductSearchService:
    def __init__(
        self,
        assistant_service: GeminiHandler,
        embedding_service: EmbeddingService,
        product_repo: FirestoreRepository
    ):
        try:
            self.assistant_service = assistant_service
            self.embedding_service = embedding_service 
            self.product_repo = product_repo
        except Exception as e:
            print(f"Failed to initialize ProductSearchService: {str(e)}")
            raise

    def _extract_search_filters(self, query: str) -> SearchFilters:
        try:
            prompt = f"""
            Given the search query: '{query}', extract relevant search filters.
            Focus on understanding product attributes like category, subcategory, and tags.
            """
            filters = self.assistant_service.process_content(
                schema=SearchFilters,
                text=prompt,
                use_json=True
            )
            return filters
        except Exception as e:
            print(f"Failed to extract search filters from query '{query}': {str(e)}")
            raise

    def _build_filter_conditions(
        self,
        filters: SearchFilters,
        store_id: Optional[str]
    ) -> Dict:
        try:
            conditions = {}
            if filters.get("category"):
                conditions["category"] = filters["category"]
            if filters.get("subcategory"):
                conditions["subcategory"] = filters["subcategory"]
            return conditions
        except Exception as e:
            print(f"Failed to build filter conditions: {str(e)}")
            raise

    def _fetch_products(self, product_ids: List[str]) -> List[Product]:
        products = []
        for pid in product_ids:
            try:
                product_data = self.product_repo.read("products", pid)
                if product_data and product_data[0]:
                    products.append(Product(**product_data[0]))
            except Exception as e:
                print(f"Failed to fetch product {pid}: {str(e)}")
                continue
        return products

    def search_products(
        self,
        query: str,
        store_id: Optional[str] = None,
        limit: int = 20
    ) -> List[Product]:
        try:
            filters = self._extract_search_filters(query)
            
            query_embedding = self.embedding_service.create_embedding(query)
            
            filter_conditions = None
            
            search_results = self.embedding_service.query(
                query_vector=query_embedding,
                top_k=limit,
                filter_conditions=filter_conditions
            )
            
            product_ids = [result["id"] for result in search_results["matches"]]
            products = self._fetch_products(product_ids)
            
            return products
        except Exception as e:
            print(f"Product search failed for query '{query}': {str(e)}")
            raise

class GetProducts:
    def __init__(self, product_repo: FirestoreRepository):
        self.product_repo = product_repo
    
    def get_store_products(self, store_id: str, 
                          category: Optional[str] = None,
                          page: int = 1,
                          page_size: int = 20) -> List[Product]:
        """
        Get all products for a specific store with optional filtering and pagination.
        """
        filters = [("store_id", "==", store_id)]
        if category:
            filters.append(("category", "==", category))
            
        # Calculate pagination
        start = (page - 1) * page_size
        
        products_data = self.product_repo.read(
            collection="products",
            filters=filters
        )
        
        # Apply pagination
        paginated_data = products_data[start:start + page_size]
        
        return [Product(**product) for product in paginated_data]

class GetProduct:
    def __init__(self, product_repo: FirestoreRepository):
        self.product_repo = product_repo
    
    def get_product(self, product_id: str) -> Optional[Product]:
        """
        Get details about a specific product.
        """
        product_data = self.product_repo.read(
            collection="products",
            identifier=product_id
        )
        
        if not product_data:
            return None
            
        return Product(**product_data[0])


class CreateStore:
    def __init__(self, repo: FirestoreRepository):
        self.repo = repo

    def create_store(self, store_data: dict) -> Store:
        """
        Create a new store with the provided information.
        """
        contents = store_data.get("contents")
        if not contents:
            raise ValueError("Store data must contain 'contents'")

        # Validate required fields
        required_fields = ['owner_id', 'store_name', 'description', 'location']
        for field in required_fields:
            if field not in contents:
                raise ValueError(f"Missing required field in contents: {field}")

        # Generate store_id if not provided
        if 'store_id' not in contents:
            contents['store_id'] = str(uuid.uuid4())

        # Create Store instance directly using the provided data
        store = Store(**contents)

        # Create the store in Firestore
        store.create(self.repo)

        return store



class GetStore:
    def __init__(self, repo: FirestoreRepository):
        self.repo = repo
    
    def get_store(self, store_id: str) -> Optional[Store]:
        """
        Get details about a specific store.
        """
        store_data = self.repo.read(
            collection="stores",
            identifier=store_id
        )
        
        if not store_data:
            return None
            
        # Convert location dict to Location object
        store_data[0]['location'] = Location(**store_data[0]['location'])
        return Store(**store_data[0])
    
    def get_stores_by_owner(self, owner_id: str) -> List[Store]:
        """
        Get all stores owned by a specific user.
        """
        stores_data = self.repo.read(
            collection="stores",
            filters=[("owner_id", "==", owner_id)]
        )
        
        stores = []
        for store_data in stores_data:
            store_data['location'] = Location(**store_data['location'])
            stores.append(Store(**store_data))
        
        return stores
