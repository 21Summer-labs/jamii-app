
# domain/repositories/firestore_repository.py
from typing import List, Dict, Optional
from google.cloud import firestore
from google.cloud.firestore import FieldFilter


class FirestoreRepository:
    def __init__(self, db: firestore.Client):
        """

        :param db: Firestore database client instance.
        """
        self.db = db
    
    def read(self, collection: str, identifier: Optional[str] = None, filters: Optional[List] = None) -> List[Dict]:
        """
        Read documents from a Firestore collection.

        :param collection: The Firestore collection name.
        :param identifier: Optional document identifier.
        :param filters: Optional list of filters as tuples (field, operator, value).
        :return: List of documents as dictionaries.
        """
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
    
    def write(self, collection: str, data: Union[Dict, List[Dict]]) -> None:
        """
        Write new documents to a Firestore collection.

        :param collection: The Firestore collection name.
        :param data: A single document or list of documents to write.
        :raises ValueError: If data does not meet the required structure or has duplicate tags.
        """
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
    
    def update(self, collection: str, identifier: str, updates: Dict) -> None:
        """
        Update an existing Firestore document.

        :param collection: The Firestore collection name.
        :param identifier: Document identifier to update.
        :param updates: Dictionary of updates to apply.
        :raises ValueError: If the document does not exist.
        """
        doc_ref = self.db.collection(collection).document(identifier)
        if not doc_ref.get().exists:
            raise ValueError(f"Document '{identifier}' does not exist")
        doc_ref.update(updates)
        return True
    
    def delete(self, collection: str, identifier: Optional[str] = None, field: Optional[str] = None) -> None:
        """
        Delete documents or fields from a Firestore collection.

        :param collection: The Firestore collection name.
        :param identifier: Optional document identifier to delete.
        :param field: Optional specific field to delete within a document.
        """
        collection_ref = self.db.collection(collection)

        if identifier and field:
            doc_ref = collection_ref.document(identifier)
            doc_ref.update({field: firestore.DELETE_FIELD})
        elif identifier:
            collection_ref.document(identifier).delete()
        else:
            self._delete_collection(collection_ref)

    def _delete_collection(self, coll_ref, batch_size: int = 10) -> None:
        """
        Helper method to delete an entire Firestore collection in batches.

        :param coll_ref: Firestore collection reference.
        :param batch_size: Number of documents to delete per batch.
        """
        docs = coll_ref.limit(batch_size).stream()
        deleted = 0

        batch = self.db.batch()
        for doc in docs:
            batch.delete(doc.reference)
            deleted += 1

        if deleted >= batch_size:
            self._delete_collection(coll_ref, batch_size)
