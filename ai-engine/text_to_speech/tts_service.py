class TTSService:
    @staticmethod
    async def synthesize(text: str, language: str = "ml", speed: float = 0.85) -> bytes:
        """Synthesize Malayalam/English speech using Indic-TTS / DhVaani."""
        return b"WAV_AUDIO_STUB_BYTES"
