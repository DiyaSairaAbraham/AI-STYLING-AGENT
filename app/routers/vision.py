import os
import shutil
from typing import Any

from fastapi import APIRouter, File, HTTPException, UploadFile

from agents.vision_agent import analyze_user_image
from utils.json_utils import save_json


router = APIRouter(
    prefix="/vision",
    tags=["Vision"],
)


UPLOAD_DIR = "uploads"
PROFILE_FILE = "outputs/json/user_profile.json"


@router.post("/analyze")
async def analyze_image(
    file: UploadFile = File(...),
) -> dict[str, Any]:
    allowed_types = {
        "image/jpeg",
        "image/png",
        "image/webp",
    }

    if file.content_type not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail="Only JPG, PNG and WEBP images are allowed.",
        )

    os.makedirs(UPLOAD_DIR, exist_ok=True)
    os.makedirs(
        os.path.dirname(PROFILE_FILE),
        exist_ok=True,
    )

    filename = file.filename or "user_image.jpg"
    image_path = os.path.join(UPLOAD_DIR, filename)

    try:
        with open(image_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        result = analyze_user_image(image_path)

        profile_data = result.model_dump()

        save_json(
            profile_data,
            PROFILE_FILE,
        )

        return {
            "status": "success",
            "message": "Vision analysis completed.",
            "profile": profile_data,
            "profile_file": PROFILE_FILE,
        }

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail={
                "status": "failed",
                "message": "Vision analysis failed.",
                "error": str(exc),
            },
        ) from exc