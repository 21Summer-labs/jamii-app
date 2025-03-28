from typing import List, Optional, Dict, TypedDict
import uuid
import json
from utils.repositories import FirestoreRepository

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