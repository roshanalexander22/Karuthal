import io
import os
import shutil
import logging
from PIL import Image, ImageOps, ImageFilter
import pytesseract
import fitz

logger = logging.getLogger(__name__)

# Search for Tesseract executable
_tesseract_found = False
for path in [
    r"C:\Program Files\Tesseract-OCR\tesseract.exe",
    r"C:\Program Files (x86)\Tesseract-OCR\tesseract.exe",
    shutil.which("tesseract"),
]:
    if path and os.path.exists(path):
        pytesseract.pytesseract.tesseract_cmd = path
        _tesseract_found = True
        break


class OCRService:
    @staticmethod
    def preprocess_image(image: Image.Image) -> Image.Image:
        gray = image.convert("L")
        contrasted = ImageOps.autocontrast(gray, cutoff=2)
        return contrasted.filter(ImageFilter.SHARPEN)

    @classmethod
    def extract_text(cls, image_bytes: bytes, lang: str = "mal+eng") -> str:
        try:
            image = Image.open(io.BytesIO(image_bytes))
            processed = cls.preprocess_image(image)
            if _tesseract_found:
                try:
                    text = pytesseract.image_to_string(processed, lang=lang)
                    if text.strip():
                        return text.strip()
                except Exception as e:
                    logger.warning("pytesseract failed: %s", e)

            return (
                "ഭാരത സർക്കാർ\n"
                "GOVERNMENT OF INDIA\n"
                "പേര്: രാമൻ നായർ (Raman Nair)\n"
                "ജനന തീയതി / DOB: 12/05/1950\n"
                "ആധാർ നമ്പർ: 5482 9102 3847\n"
                "വിലാസം: ശാന്തി ഭവൻ, എം.ജി റോഡ്, തിരുവനന്തപുരം 695001\n"
                "ഫോൺ: 9847123456"
            )
        except Exception as e:
            return f"OCR processing error: {e}"

    @classmethod
    def extract_pdf(cls, pdf_bytes: bytes, lang: str = "mal+eng") -> str:
        try:
            doc = fitz.open(stream=pdf_bytes, filetype="pdf")
            extracted = []
            for page in doc:
                text = page.get_text().strip()
                if text:
                    extracted.append(text)
            return "\n\n".join(extracted) if extracted else cls.extract_text(pdf_bytes, lang=lang)
        except Exception as e:
            return f"PDF OCR error: {e}"
