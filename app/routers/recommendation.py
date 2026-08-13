import os
import shutil
from typing import Any

from fastapi import (
    APIRouter,
    File,
    HTTPException,
    UploadFile,
)
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


# ============================================================
# STEP 1 - UPLOAD USER IMAGE ONCE
# ============================================================


@router.post("/upload")
async def upload_user_image(
    user_image: UploadFile = File(...),
) -> dict[str, str]:

    allowed_types = {
        "image/jpeg",
        "image/png",
        "image/webp",
    }

    if user_image.content_type not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail=(
                "Only JPG, PNG and WEBP images are allowed."
            ),
        )

    os.makedirs(UPLOAD_DIR, exist_ok=True)

    filename = user_image.filename or "user_image.jpg"
    image_path = os.path.join(UPLOAD_DIR, filename)

    try:
        with open(image_path, "wb") as buffer:
            shutil.copyfileobj(
                user_image.file,
                buffer,
            )

        return {
            "status": "success",
            "message": "User image uploaded successfully.",
            "user_image_path": image_path,
        }

    except Exception as exc:
        raise HTTPException(
            status_code=500,
            detail=str(exc),
        ) from exc


# ============================================================
# FUNCTION 1 - AI STYLING
# ============================================================


@router.post("/ai-style")
async def ai_style(
    request: UserImageRequest,
) -> Any:

    try:
        _validate_user_image(
            request.user_image_path
        )

        print("[INFO] Starting Function 1 - AI Styling")

        user_profile = analyze_user_image(
            request.user_image_path
        )

        recommendation = generate_style_recommendation(
            user_profile
        )

        outfit = recommendation.recommendation

        outfit.shopping_links = create_search_links(
            outfit
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
            "user_image_path": request.user_image_path,
            "recommendation": outfit.model_dump(),
            "image_path": image_path,
        }

    except HTTPException:
        raise

    except Exception as exc:
        print(f"[ERROR] Function 1 failed: {exc}")

        return JSONResponse(
            status_code=500,
            content={
                "status": "failed",
                "function": "AI Styling",
                "message": "Unable to generate AI styling.",
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
            request.user_image_path
        )

        # Accepts "personal", "Personal Wardrobe",
        # "wardrobe_1", etc., but always returns "personal".
        wardrobe_source = _validate_wardrobe_source(
            request.wardrobe_source
        )

        print(
            "[INFO] Starting Function 2 - "
            f"{wardrobe_source} wardrobe"
        )

        # ----------------------------------------------------
        # Load already-built wardrobe
        # ----------------------------------------------------

        wardrobe_items = list_wardrobe(
            wardrobe_source
        )

        if not wardrobe_items:
            raise HTTPException(
                status_code=400,
                detail=(
                    f"{wardrobe_source} wardrobe is empty."
                ),
            )

        # ----------------------------------------------------
        # Vision analysis
        # ----------------------------------------------------

        user_profile = analyze_user_image(
            request.user_image_path
        )

        # ----------------------------------------------------
        # Wardrobe stylist
        # ----------------------------------------------------

        recommendation = generate_wardrobe_recommendation(
            module1_data=user_profile,
            wardrobe_items=wardrobe_items,
            wardrobe_source=wardrobe_source,
        )

        outfit = recommendation.recommendation

        # ----------------------------------------------------
        # Get actual selected wardrobe images
        # ----------------------------------------------------

        wardrobe_image_paths = get_wardrobe_image_paths(
            source=wardrobe_source,
            item_ids=outfit.selected_item_ids,
        )

        # ----------------------------------------------------
        # Generate final image
        # ----------------------------------------------------

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
            wardrobe_image_paths=wardrobe_image_paths,
        )

        return {
            "status": "success",
            "function": "Wardrobe Styling",
            "wardrobe_source": wardrobe_source,
            "user_image_path": request.user_image_path,
            "recommendation": outfit.model_dump(),
            "image_path": image_path,
        }

    except HTTPException:
        raise

    except Exception as exc:
        print(
            f"[ERROR] Function 2 failed: {exc}"
        )

        return JSONResponse(
            status_code=500,
            content={
                "status": "failed",
                "function": "Wardrobe Styling",
                "message": (
                    "Unable to generate wardrobe styling."
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
            user_image_path=request.user_image_path,
            wardrobe_source=request.wardrobe_source,
        )
    )