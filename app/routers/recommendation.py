import os
import shutil
from typing import Any

from fastapi import APIRouter, File, UploadFile
from fastapi.responses import JSONResponse
from pydantic import BaseModel

from agents.shopping_agent import create_search_links
from agents.stylist_agent import generate_style_recommendation
from agents.vision_agent import analyze_user_image
from utils.wardrobe_manager import list_wardrobe
from utils.commercial_wardrobe_manager import (
    list_commercial_wardrobe
)
from fastapi import Form

class RecommendationRequest(BaseModel):
    user_image_path: str
    style_type: str
    wardrobe_source: str

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
    request: RecommendationRequest,
) -> Any:

    try:

        print("[INFO] Running recommendation flow")

        user_profile = analyze_user_image(
            request.user_image_path,
            request.style_type,
        )

        if request.wardrobe_source == "personal":

            wardrobe_data = list_wardrobe()

        elif request.wardrobe_source == "commercial":

            wardrobe_data = list_commercial_wardrobe()

        elif request.wardrobe_source == "open_world":

            wardrobe_data = []

        

        recommendations = generate_style_recommendation(
            user_profile,
            wardrobe_data,
            request.style_type,
            request.wardrobe_source,
        )

        for outfit in recommendations.recommendations:

            outfit.shopping_links = create_search_links(
                outfit,
            )

        return {
            "status": "success",
            "message": "Outfit options generated",
            "user_image_path": request.user_image_path,
            "data": recommendations,
        }

    except Exception as e:

        print(
            f"[ERROR] Recommendation failed: {str(e)}",
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
) -> Any:
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
            "data": recommendations,
        }

    except Exception as e:
        print(
            f"[ERROR] Regeneration failed: {str(e)}",
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
) -> Any:
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
            request.style_type,
            request.wardrobe_source,
        )

        print(
            f">>> Stylist returned "
            f"{len(recommendation.recommendations)} "
            f"recommendation(s)"
        )

        print(
            f">>> Generated categories: "
            f"{[
                outfit.category
                for outfit in recommendation.recommendations
            ]}"
        )

        if not recommendation.recommendations:
            return JSONResponse(
                status_code=500,
                content={
                    "status": "failed",
                    "message": "No outfit recommendation generated",
                },
            )

        selected = recommendation.recommendations[0]

        selected.shopping_links = create_search_links(
            selected,
        )

        return {
            "status": "success",
            "message": (
                f"{request.category} recommendation regenerated"
            ),
            "recommendation": selected,
        }

    except Exception as e:
        print(
            "[ERROR] Single recommendation regeneration failed: "
            f"{str(e)}"
        )

        return JSONResponse(
            status_code=500,
            content={
                "status": "failed",
                "message": (
                    "Unable to regenerate recommendation"
                ),
                "error": str(e),
            },
        )