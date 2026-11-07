from dataclasses import dataclass

@dataclass
class ASRConfig:
    model_name: str = "ai4bharat/indicconformer_asr"
    sample_rate: int = 16000
    language: str = "ml"
    chunk_size_seconds: float = 2.0
