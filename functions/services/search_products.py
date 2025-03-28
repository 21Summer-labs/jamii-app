
import uuid
import json
from typing import List, Optional, Dict, TypedDict
from utils.repositories import FirestoreRepository
from utils.models import Product  # Ensure this module contains the Product class
from services.gemini import GeminiHandler  # Assuming this is where GeminiHandler is defined
from services.pinecone import EmbeddingService

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