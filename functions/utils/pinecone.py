import os
import enum
import logging
from pinecone.grpc import PineconeGRPC
from typing import List, TypeVar

# Define the TypeVar 'T' at the top
T = TypeVar('T')

class EmbeddingService:
    def __init__(self):
        api_key = "pcsk_3Bzop7_7RYdZmC46eYgCqYTjqPGbWeE3by8FNLQjahnhQuBvamR4jMyThAJf12QnnyymU9"
        index_host = "https://products-g91gzb3.svc.aped-4627-b74a.pinecone.io"
        namespace = "products-index"
        
        self.pc = PineconeGRPC(api_key=api_key)
        self.index = self.pc.Index(host=index_host)
        self.namespace = namespace

    def create_embedding(self, text: str) -> List[float]:
        """Create embedding for given text."""
        embedding = self.pc.inference.embed(
            model="multilingual-e5-large",
            inputs=[text],
            parameters={"input_type": "passage", "truncate": "END"}
        )[0]
        return embedding.values

    def index_text(self, text: str, vector_id: str) -> None:
        # Create the embedding
        embedding = self.create_embedding(text)

        # Prepare the vector to index
        vector = {
            "id": vector_id,
            "values": embedding,
            "metadata": {"original_text": text}
        }
        self.index.upsert(vectors=[vector], namespace=self.namespace)

    def query(self, query_vector: List[float], top_k: int, filter_conditions: Optional[Dict] = None) -> Dict:
        """Query the Pinecone index."""
        return self.index.query(
            namespace=self.namespace,
            vector=query_vector,
            filter=filter_conditions,
            top_k=top_k,
            include_metadata=True
        )

