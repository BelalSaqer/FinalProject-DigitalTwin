from pathlib import Path

import numpy as np
import uvicorn
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from tensorflow import keras

app = FastAPI(title="Digital Twin Prediction API")

MODEL_PATH = Path(__file__).with_name("calibrated_model.keras")
model = None


class InputData(BaseModel):
    series_data: list[list[float]]


@app.on_event("startup")
def load_model() -> None:
    global model

    try:
        model = keras.models.load_model(MODEL_PATH)
        print("✅ Model loaded successfully!")
    except Exception as e:
        model = None
        print(f"❌ Error loading model: {e}")


@app.get("/")
def healthcheck() -> dict:
    return {
        "status": "ok" if model is not None else "model_not_loaded",
        "model_path": str(MODEL_PATH),
    }


@app.post("/predict")
async def predict(data: InputData) -> dict:
    if model is None:
        raise HTTPException(status_code=500, detail="Model is not loaded.")

    try:
        arr = np.array(data.series_data, dtype=np.float32)

        if arr.shape != (30, 16):
            raise HTTPException(
                status_code=400,
                detail=f"Expected shape (30, 16), but got {arr.shape}",
            )

        arr = np.expand_dims(arr, axis=0)  # shape: (1, 30, 16)

        prediction = model.predict(arr, verbose=0)
        value = float(np.asarray(prediction).reshape(-1)[0])

        return {
            "prediction": value,
            "status": "success",
        }

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8002)