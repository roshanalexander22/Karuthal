class IntentDetectionService:
    @staticmethod
    async def detect_intent(user_utterance: str) -> str:
        # Classify into: READ_SCREEN, FILL_FORM, SET_REMINDER, SOS, TRANSCRIBE
        return "GENERAL_ASSISTANCE"
