from typing import Dict, List, Optional, Union, Any, BinaryIO
from google.cloud import storage
from google.cloud.storage import Blob
import os
import mimetypes
import hashlib
from datetime import datetime, timedelta

class StorageExecutor:
    """
    A class to manage file operations with Firebase Cloud Storage.
    Can be used alongside ScenarioExecutor for handling file uploads and downloads.
    """

    def __init__(self, bucket_name: str):
        """
        Initialize the StorageExecutor.

        :param bucket_name: Name of the Firebase Storage bucket
        """
        self.storage_client = storage.Client()
        self.bucket = self.storage_client.bucket(bucket_name)

    def read(
        self,
        path: str,
        download_path: Optional[str] = None,
        return_url: bool = False,
        expiration: Optional[int] = None
    ) -> Union[bytes, str]:
      
        blob = self.bucket.blob(path)
        
        if not blob.exists():
            raise ValueError(f"File does not exist at path: {path}")

        if return_url:
            expiration_delta = timedelta(minutes=expiration if expiration else 60)
            return blob.generate_signed_url(
                version="v4",
                expiration=expiration_delta,
                method="GET"
            )
        
        if download_path:
            os.makedirs(os.path.dirname(download_path), exist_ok=True)
            blob.download_to_filename(download_path)
            return download_path
        
        return blob.download_as_bytes()

    def write(
        self,
        path: str,
        file_obj: Union[str, bytes, BinaryIO],
        content_type: Optional[str] = None,
        metadata: Optional[Dict] = None
    ) -> Dict[str, Any]:
        
        blob = self.bucket.blob(path)
        
        # Handle different input types
        if isinstance(file_obj, str) and os.path.isfile(file_obj):
            # It's a file path
            content_type = content_type or mimetypes.guess_type(file_obj)[0]
            blob.upload_from_filename(file_obj)
            file_size = os.path.getsize(file_obj)
        elif isinstance(file_obj, bytes):
            # It's bytes data
            blob.upload_from_string(file_obj)
            file_size = len(file_obj)
        else:
            # It's a file-like object
            blob.upload_from_file(file_obj)
            file_obj.seek(0, 2)  # Seek to end
            file_size = file_obj.tell()
            file_obj.seek(0)  # Reset position

        # Set content type and metadata
        if content_type:
            blob.content_type = content_type
        if metadata:
            blob.metadata = metadata

        # Generate MD5 hash
        blob.reload()  # Refresh blob attributes
        
        return {
            "path": path,
            "size": file_size,
            "content_type": blob.content_type,
            "md5_hash": blob.md5_hash,
            "metadata": blob.metadata,
            "created": blob.time_created,
            "updated": blob.updated
        }

    def update(
        self,
        path: str,
        metadata: Dict,
        content_type: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Update a file's metadata in Firebase Storage.

        :param path: Path to the file
        :param metadata: New metadata dictionary
        :param content_type: Optional new content type
        :return: Updated file information
        :raises: ValueError if file doesn't exist
        """
        blob = self.bucket.blob(path)
        
        if not blob.exists():
            raise ValueError(f"File does not exist at path: {path}")

        if metadata:
            blob.metadata = metadata
        if content_type:
            blob.content_type = content_type
            
        blob.patch()
        
        return {
            "path": path,
            "content_type": blob.content_type,
            "metadata": blob.metadata,
            "updated": blob.updated
        }

    def delete(self, path: str, recursive: bool = False) -> None:
        """
        Delete a file or folder from Firebase Storage.

        :param path: Path to delete
        :param recursive: If True, recursively delete all files under path
        :raises: ValueError if path doesn't exist
        """
        if recursive:
            blobs = self.bucket.list_blobs(prefix=path)
            for blob in blobs:
                blob.delete()
        else:
            blob = self.bucket.blob(path)
            if not blob.exists():
                raise ValueError(f"File does not exist at path: {path}")
            blob.delete()

    def list(
        self,
        prefix: Optional[str] = None,
        delimiter: Optional[str] = None,
        include_metadata: bool = False
    ) -> List[Dict[str, Any]]:
        """
        List files in Firebase Storage.

        :param prefix: Optional prefix to filter results
        :param delimiter: Optional delimiter for hierarchy (e.g., '/')
        :param include_metadata: If True, includes full metadata for each file
        :return: List of file information dictionaries
        """
        blobs = self.bucket.list_blobs(prefix=prefix, delimiter=delimiter)
        results = []
        
        for blob in blobs:
            info = {
                "name": blob.name,
                "size": blob.size,
                "updated": blob.updated
            }
            
            if include_metadata:
                info.update({
                    "content_type": blob.content_type,
                    "md5_hash": blob.md5_hash,
                    "metadata": blob.metadata,
                    "created": blob.time_created
                })
                
            results.append(info)
            
        return results