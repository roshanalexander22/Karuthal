import pytesseract
from PIL import Image
import io

class OCRService:
    @staticmethod
    def extract_text(image_bytes: bytes, lang: str = "mal+eng") -> str:
        try:
            img = Image.open(io.BytesIO(image_bytes))
            return pytesseract.image_to_string(img, lang=lang)
        except Exception as e:
            return f"OCR processing placeholder: {e}"
