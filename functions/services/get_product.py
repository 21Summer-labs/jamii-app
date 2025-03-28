from utils.repositories import FirestoreRepository

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