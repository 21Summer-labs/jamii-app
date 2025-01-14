
class ProductTaggingService:

    def generate_tags_from_image(self, image: Any) -> List[str]:
        # Placeholder for tag generation from an image
        return ["tag1", "tag2", "tag3"]

    def generate_tags_from_description(self, description: str) -> List[str]:
        # Placeholder for tag generation from a description
        return description.lower().split()

# ---

'''

for the product tagging service, we should utilize computer vision.
The store owner sends an image with an audio recording which acts as context for the image
we transcript the audio recording - send the text with the image with a prompt to the LLM
the LLM will return a json object of its description of the product which we will store
we store the LLM output

'''