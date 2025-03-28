from typing import List, Optional, Dict, TypedDict
import uuid
import json
from utils.repositories import FirestoreRepository
from utils.models import Product  # Ensure Product is correctly imported
from utils.services import GeminiHandler, EmbeddingService, FirebaseStorageRepository  # Ensure correct paths

import logging

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
        """Extract product attributes using Gemini AI."""
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

            # Log the raw response for debugging
            logging.info(f"Extracted attributes: {raw_attributes}")

            if isinstance(raw_attributes, str):
                raw_attributes = json.loads(raw_attributes)

            if not isinstance(raw_attributes, dict):
                raise TypeError(f"Expected a dictionary for attributes but got {type(raw_attributes)}")

            return raw_attributes
        except Exception as e:
            logging.error(f"Failed to extract product attributes: {e}")
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
            if 'store_id' not in metadata:
                raise ValueError("Missing 'store_id' in metadata")

            product_id = self._generate_product_id()

            attributes = self._extract_product_attributes(
                temp_audio_path,
                temp_image_paths,
                metadata
            )

            try:
                image_urls, audio_url = self.storage_repo.store_product_files(
                    store_id=metadata['store_id'],
                    product_id=product_id,
                    image_paths=temp_image_paths,
                    audio_path=temp_audio_path
                )
            except Exception as e:
                logging.error(f"Failed to store product files: {e}")
                raise Exception(f"Failed to store product files: {str(e)}")

            try:
                search_text = f"{attributes.get('name', '')} {attributes.get('description', '')} {' '.join(attributes.get('tags', []))}"
                self.embedding_service.index_text(search_text, product_id)
            except Exception as e:
                logging.error(f"Failed to create search embedding: {e}")
                raise Exception(f"Failed to create search embedding: {str(e)}")

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

            try:
                product.create(self.product_repo)
            except Exception as e:
                logging.error(f"Failed to save product to database: {e}")
                raise Exception(f"Failed to save product to database: {str(e)}")

            return product

        except Exception as e:
            logging.error(f"Product creation failed: {e}")
            raise Exception(f"Product creation failed: {str(e)}")
