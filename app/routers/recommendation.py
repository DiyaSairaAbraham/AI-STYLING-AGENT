import os
import shutil
from pathlib import Path
from typing import Any

from fastapi import APIRouter, File, HTTPException, UploadFile
from fastapi.responses import JSONResponse
from pydantic import BaseModel

from agents.image_agent import generate_outfit_image
from agents.shopping_agent import create_search_links
from agents.stylist_agent import (
    generate_style_recommendation,
    generate_wardrobe_recommendation,
)
from agents.vision_agent import analyze_user_image
from utils.wardrobe_manager import (
    get_wardrobe_image_paths,
    list_wardrobe,
)


router = APIRouter(
    prefix="/recommendation",
    tags=["Recommendation"],
)


UPLOAD_DIR = "uploads"
OUTPUT_DIR = "outputs/images"

ALLOWED_IMAGE_TYPES = {
    "image/jpeg",
    "image/jpg",
    "image/png",
    "image/webp",
    "application/octet-stream",
}

ALLOWED_EXTENSIONS = {
    ".jpg",
    ".jpeg",
    ".png",
    ".webp",
}


# ============================================================
# REQUEST MODELS
# ============================================================


class UserImageRequest(BaseModel):
    user_image_path: str


class WardrobeRequest(BaseModel):
    user_image_path: str
    wardrobe_source: str


class RegenerateWardrobeRequest(BaseModel):
    user_image_path: str
    wardrobe_source: str


# ============================================================
# HELPERS
# ============================================================


def _validate_user_image(path: str) -> None:
    if not os.path.isfile(path):
        raise HTTPException(
            status_code=400,
            detail=f"User image not found: {path}",
        )


def _validate_wardrobe_source(source: str) -> str:
    normalized = source.strip().lower()

    if normalized in {
        "personal",
        "personal wardrobe",
        "wardrobe_1",
        "1",
    }:
        return "personal"

    if normalized in {
        "commercial",
        "commercial wardrobe",
        "wardrobe_2",
        "2",
    }:
        return "commercial"

    raise HTTPException(
        status_code=400,
        detail=(
            "wardrobe_source must be "
            "'personal' or 'commercial'."
        ),
    )


def _safe_filename(
    filename: str | None,
    default_name: str = "user_image.jpg",
) -> str:
    """
    Prevent directory traversal and normalize the filename
    received from a mobile multipart upload.
    """
    if not filename:
        return default_name

    clean_name = Path(filename).name

    if not clean_name:
        return default_name

    return clean_name


def _validate_image_upload(
    upload: UploadFile,
) -> None:
    """
    Flutter/Android may send application/octet-stream even
    when the selected file is a valid image, so extension is
    accepted as a fallback.
    """
    content_type = (
        upload.content_type or ""
    ).strip().lower()

    filename = _safe_filename(
        upload.filename,
    )

    extension = Path(
        filename,
    ).suffix.lower()

    if (
        content_type not in ALLOWED_IMAGE_TYPES
        and extension not in ALLOWED_EXTENSIONS
    ):
        raise HTTPException(
            status_code=400,
            detail=(
                "Only JPG, JPEG, PNG and WEBP "
                "images are allowed."
            ),
        )


async def _save_upload(
    upload: UploadFile,
    default_name: str,
) -> str:
    _validate_image_upload(upload)

    os.makedirs(
        UPLOAD_DIR,
        exist_ok=True,
    )

    filename = _safe_filename(
        upload.filename,
        default_name,
    )

    extension = Path(
        filename,
    ).suffix.lower()

    if extension not in ALLOWED_EXTENSIONS:
        content_type = (
            upload.content_type or ""
        ).lower()

        if content_type in {
            "image/jpeg",
            "image/jpg",
        }:
            extension = ".jpg"
        elif content_type == "image/png":
            extension = ".png"
        elif content_type == "image/webp":
            extension = ".webp"
        else:
            extension = ".jpg"

        filename = (
            Path(filename).stem
            + extension
        )

    image_path = os.path.join(
        UPLOAD_DIR,
        filename,
    )

    try:
        with open(
            image_path,
            "wb",
        ) as buffer:
            shutil.copyfileobj(
                upload.file,
                buffer,
            )

    except OSError as exc:
        raise HTTPException(
            status_code=500,
            detail=(
                f"Unable to save uploaded image: {exc}"
            ),
        ) from exc

    return image_path


# ============================================================
# STEP 1 - UPLOAD USER IMAGE ONCE
# ============================================================


@router.post("/upload")
async def upload_user_image(
    user_image: UploadFile = File(...),
) -> dict[str, str]:

    image_path = await _save_upload(
        user_image,
        "user_image.jpg",
    )

    return {
        "status": "success",
        "message": (
            "User image uploaded successfully."
        ),
        "user_image_path": image_path,
    }


# ============================================================
# FUNCTION 1 - AI STYLING
# ============================================================


@router.post("/ai-style")
async def ai_style(
    request: UserImageRequest,
) -> Any:

    try:
        _validate_user_image(
            request.user_image_path,
        )

        print(
            "[INFO] Starting Function 1 - AI Styling",
        )

        user_profile = analyze_user_image(
            request.user_image_path,
        )

        recommendation = (
            generate_style_recommendation(
                user_profile,
            )
        )

        outfit = recommendation.recommendation

        outfit.shopping_links = (
            create_search_links(outfit)
        )

        os.makedirs(
            OUTPUT_DIR,
            exist_ok=True,
        )

        output_path = os.path.join(
            OUTPUT_DIR,
            "function1_ai_styling.png",
        )

        image_path = generate_outfit_image(
            prompt=outfit.image_generation_prompt,
            user_image_path=request.user_image_path,
            output_path=output_path,
        )

        return {
            "status": "success",
            "function": "AI Styling",
            "user_image_path": (
                request.user_image_path
            ),
            "recommendation": (
                outfit.model_dump()
            ),
            "image_path": image_path,
        }

    except HTTPException:
        raise

    except Exception as exc:
        print(
            f"[ERROR] Function 1 failed: {exc}",
        )

        return JSONResponse(
            status_code=500,
            content={
                "status": "failed",
                "function": "AI Styling",
                "message": (
                    "Unable to generate AI styling."
                ),
                "error": str(exc),
            },
        )


# ============================================================
# FUNCTION 2 - WARDROBE STYLING
# ============================================================


@router.post("/wardrobe-style")
async def wardrobe_style(
    request: WardrobeRequest,
) -> Any:

    try:
        _validate_user_image(
            request.user_image_path,
        )

        wardrobe_source = (
            _validate_wardrobe_source(
                request.wardrobe_source,
            )
        )

        print(
            "[INFO] Starting Function 2 - "
            f"{wardrobe_source} wardrobe",
        )

        wardrobe_items = list_wardrobe(
            wardrobe_source,
        )

        if not wardrobe_items:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"{wardrobe_source} "
                    "wardrobe is empty."
                ),
            )

        user_profile = analyze_user_image(
            request.user_image_path,
        )

        recommendation = (
            generate_wardrobe_recommendation(
                module1_data=user_profile,
                wardrobe_items=wardrobe_items,
                wardrobe_source=wardrobe_source,
            )
        )

        outfit = recommendation.recommendation

        wardrobe_image_paths = (
            get_wardrobe_image_paths(
                source=wardrobe_source,
                item_ids=outfit.selected_item_ids,
            )
        )

        os.makedirs(
            OUTPUT_DIR,
            exist_ok=True,
        )

        output_path = os.path.join(
            OUTPUT_DIR,
            f"function2_{wardrobe_source}_styling.png",
        )

        image_path = generate_outfit_image(
            prompt=outfit.image_generation_prompt,
            user_image_path=request.user_image_path,
            output_path=output_path,
            wardrobe_image_paths=(
                wardrobe_image_paths
            ),
        )

        return {
            "status": "success",
            "function": "Wardrobe Styling",
            "wardrobe_source": wardrobe_source,
            "user_image_path": (
                request.user_image_path
            ),
            "recommendation": (
                outfit.model_dump()
            ),
            "image_path": image_path,
        }

    except HTTPException:
        raise

    except Exception as exc:
        print(
            f"[ERROR] Function 2 failed: {exc}",
        )

        return JSONResponse(
            status_code=500,
            content={
                "status": "failed",
                "function": "Wardrobe Styling",
                "message": (
                    "Unable to generate "
                    "wardrobe styling."
                ),
                "error": str(exc),
            },
        )


# ============================================================
# FUNCTION 1 - REGENERATE
# ============================================================


@router.post("/regenerate")
async def regenerate_ai_style(
    request: UserImageRequest,
) -> Any:
    return await ai_style(request)


# ============================================================
# FUNCTION 2 - REGENERATE
# ============================================================


@router.post("/regenerate-wardrobe")
async def regenerate_wardrobe_style(
    request: RegenerateWardrobeRequest,
) -> Any:

    return await wardrobe_style(
        WardrobeRequest(
            user_image_path=(
                request.user_image_path
            ),
            wardrobe_source=(
                request.wardrobe_source
            ),
        ),
    )


# ============================================================
# OPTIONS
# ============================================================


@router.post("/options")
async def generate_options(
    user_image: UploadFile = File(...),
) -> Any:

    try:
        image_path = await _save_upload(
            user_image,
            "user_image.jpg",
        )

        _validate_user_image(
            image_path,
        )

        user_profile = analyze_user_image(
            image_path,
        )

        recommendation = (
            generate_style_recommendation(
                user_profile,
            )
        )

        recommendations = (
            recommendation.recommendations
        )

        return {
            "status": "success",
            "user_image_path": image_path,
            "data": {
                "recommendations": [
                    outfit.model_dump()
                    for outfit in recommendations
                ],
            },
        }

    except HTTPException:
        raise

    except Exception as exc:
        print(
            f"[ERROR] Options generation failed: {exc}",
        )

        return JSONResponse(
            status_code=500,
            content={
                "status": "failed",
                "message": (
                    "Unable to generate "
                    "styling options."
                ),
                "error": str(exc),
            },
        )