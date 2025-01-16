import os
from firebase_admin import storage
from google.cloud import firestore
from google.cloud.firestore import FieldFilter
from typing import List, Dict, Optional, Tuple, Union


class FirestoreRepository:
    def __init__(self):
        self.db = firestore.Client()

    def write(self, collection: str, data: Union[Dict, List[Dict]]) -> None:
        collection_ref = self.db.collection(collection)
        batch = self.db.batch()

        documents = [data] if isinstance(data, dict) else data
        document_tags_seen = set()

        for document in documents:
            document_tag = document.get("document_tag")
            contents = document.get("contents")

            if not document_tag or not contents:
                raise ValueError("Each document must have 'document_tag' and 'contents'.")

            if document_tag in document_tags_seen:
                raise ValueError(f"Duplicate document tag '{document_tag}'")

            document_tags_seen.add(document_tag)
            doc_ref = collection_ref.document(document_tag)

            if doc_ref.get().exists:
                raise ValueError(f"Document '{document_tag}' already exists")

            batch.set(doc_ref, contents)

        batch.commit()
        return True

    def read(self, collection: str, identifier: Optional[str] = None, filters: Optional[List] = None) -> List[Dict]:
        collection_ref = self.db.collection(collection)
        
        if identifier:
            doc = collection_ref.document(identifier).get()
            return [doc.to_dict()] if doc.exists else []
        
        if filters:
            query = collection_ref
            for field, operator, value in filters:
                query = query.where(filter=FieldFilter(field, operator, value))
            docs = query.stream()
        else:
            docs = collection_ref.stream()
            
        return [doc.to_dict() for doc in docs]
        


class FirebaseStorageRepository:
    """
    Repository for handling file operations with Firebase Storage.
    """
    def __init__(self):
        self.bucket = storage.bucket("everyautomate.firebasestorage.app")

    def write_file(self, local_path: str, storage_path: str) -> str:
        """
        Upload a file to Firebase Storage.
        
        Args:
            local_path: Path to local file
            storage_path: Desired path in Firebase Storage
            
        Returns:
            str: Public URL of the uploaded file
        """
        blob = self.bucket.blob(storage_path)
        blob.upload_from_filename(local_path)
        return blob.public_url

    def read_file(self, storage_path: str, local_path: str) -> str:
        """
        Download a file from Firebase Storage.
        
        Args:
            storage_path: Path in Firebase Storage
            local_path: Desired local path to save file
            
        Returns:
            str: Path to local file
        """
        blob = self.bucket.blob(storage_path)
        blob.download_to_filename(local_path)
        return local_path

    def delete_file(self, storage_path: str) -> None:
        """Delete a file from Firebase Storage."""
        blob = self.bucket.blob(storage_path)
        blob.delete()

    def get_url(self, storage_path: str) -> str:
        """Get public URL for a file without downloading."""
        blob = self.bucket.blob(storage_path)
        return blob.public_url

    def store_product_files(
        self,
        store_id: str,
        product_id: str,
        image_paths: List[str],
        audio_path: str
    ) -> Tuple[List[str], str]:
        """
        Store product-related files in an organized structure.
        
        Args:
            store_id: Store identifier
            product_id: Product identifier
            image_paths: List of local paths to product images
            audio_path: Local path to audio file
            
        Returns:
            Tuple[List[str], str]: List of image URLs and audio URL
        """
        base_path = f"stores/{store_id}/products/{product_id}"
        
        # Store images
        image_urls = []
        for idx, image_path in enumerate(image_paths):
            extension = os.path.splitext(image_path)[1]
            storage_path = f"{base_path}/images/image_{idx}{extension}"
            image_url = self.write_file(image_path, storage_path)
            image_urls.append(image_url)
            
        # Store audio
        audio_extension = os.path.splitext(audio_path)[1]
        audio_storage_path = f"{base_path}/audio/description{audio_extension}"
        audio_url = self.write_file(audio_path, audio_storage_path)
        
        return image_urls, audio_url