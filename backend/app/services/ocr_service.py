import pytesseract
from PIL import Image
import io

class OCRService:
    @staticmethod
    def extract_text_from_image(image_bytes: bytes, lang: str = "mal+eng") -> str:
        """Extract text from image using Tesseract OCR."""
        try:
            image = Image.open(io.BytesIO(image_bytes))
            text = pytesseract.image_to_string(image, lang=lang)
            return text
        except Exception as e:
            return f"OCR processing placeholder: {str(e)}"
