import os
import shutil

from fastapi import APIRouter, File, UploadFile
from fastapi.responses import JSONResponse
from pydantic import BaseModel

from agents.shopping_agent import create_search_links
from agents.stylist_agent import generate_style_recommendation
from agents.vision_agent import analyze_user_image
from utils.wardrobe_manager import list_wardrobe


class RegenerateRequest(BaseModel):
    user_image_path: str


class RegenerateOneRequest(BaseModel):
    user_image_path: str
    category: str


router = APIRouter(
    prefix="/recommendation",
    tags=["Recommendation Options"],
)


UPLOAD_DIR = "uploads"


@router.post("/options", response_model=None)
async def generate_options(
    user_image: UploadFile = File(...),
):
    try:
        os.makedirs(
            UPLOAD_DIR,
            exist_ok=True,
        )

        filename = user_image.filename or "user_image.jpg"

        image_path = os.path.join(
            UPLOAD_DIR,
            filename,
        )

        with open(image_path, "wb") as buffer:
            shutil.copyfileobj(
                user_image.file,
                buffer,
            )

        print("[INFO] Running fast recommendation flow")

        # Module 1: Vision Agent
        user_profile = analyze_user_image(
            image_path,
        )

        # Module 2: Load wardrobe database
        wardrobe_data = list_wardrobe()

        # Module 3: Stylist Agent
        recommendations = generate_style_recommendation(
            user_profile,
            wardrobe_data,
        )

        # Module 4: Shopping Agent
        for outfit in recommendations.recommendations:
            outfit.shopping_links = create_search_links(
                outfit,
            )

        return {
            "status": "success",
            "message": "Outfit options generated",
            "user_image_path": image_path,
            "data": recommendations.model_dump(),
        }

    except Exception as e:
        print(
            f"[ERROR] Recommendation failed: {e}",
        )

        return JSONResponse(
            status_code=500,
            content={
                "status": "failed",
                "message": "Unable to generate outfit options",
                "error": str(e),
            },
        )


@router.post("/regenerate", response_model=None)
async def regenerate_options(
    request: RegenerateRequest,
):
    try:
        print("[INFO] Regenerating recommendations")

        user_profile = analyze_user_image(
            request.user_image_path,
        )

        wardrobe_data = list_wardrobe()

        recommendations = generate_style_recommendation(
            user_profile,
            wardrobe_data,
        )

        for outfit in recommendations.recommendations:
            outfit.shopping_links = create_search_links(
                outfit,
            )

        return {
            "status": "success",
            "message": "New recommendations generated",
            "user_image_path": request.user_image_path,
            "data": recommendations.model_dump(),
        }

    except Exception as e:
        print(
            f"[ERROR] Regeneration failed: {e}",
        )

        return JSONResponse(
            status_code=500,
            content={
                "status": "failed",
                "message": "Unable to regenerate recommendations",
                "error": str(e),
            },
        )


@router.post("/regenerate-one", response_model=None)
async def regenerate_one_option(
    request: RegenerateOneRequest,
):
    try:
        print(
            f"[INFO] Regenerating category: {request.category}",
        )

        user_profile = analyze_user_image(
            request.user_image_path,
        )

        wardrobe_data = list_wardrobe()

        recommendations = generate_style_recommendation(
            user_profile,
            wardrobe_data,
        )

        selected = None

        for outfit in recommendations.recommendations:
            if outfit.category == request.category:
                selected = outfit
                break

        if selected is None:
            return JSONResponse(
                status_code=404,
                content={
                    "status": "failed",
                    "message": (
                        f"Category '{request.category}' not found"
                    ),
                },
            )

        selected.shopping_links = create_search_links(
            selected,
        )

        return {
            "status": "success",
            "message": (
                f"{request.category} recommendation regenerated"
            ),
            "recommendation": selected.model_dump(),
        }

    except Exception as e:
        print(
            "[ERROR] Single recommendation regeneration failed: "
            f"{e}",
        )

        return JSONResponse(
            status_code=500,
            content={
                "status": "failed",
                "message": "Unable to regenerate recommendation",
                "error": str(e),
            },
        )