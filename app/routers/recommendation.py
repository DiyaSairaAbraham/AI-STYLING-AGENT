from typing import Any

from fastapi import APIRouter
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from agents.shopping_agent import create_search_links
from agents.stylist_agent import generate_style_recommendation
from agents.vision_agent import analyze_user_image
from utils.commercial_wardrobe_manager import (
    list_commercial_wardrobe,
)
from utils.wardrobe_manager import list_wardrobe


router = APIRouter(
    prefix="/recommendation",
    tags=["Recommendation Options"],
)


# ============================================================
# Request models
# ============================================================

class RecommendationRequest(BaseModel):
    user_image_path: str
    style_type: str
    wardrobe_source: str

    # Empty list means the user selected no clothing.
    selected_item_ids: list[str] = Field(
        default_factory=list
    )


class RegenerateRequest(BaseModel):
    user_image_path: str
    style_type: str
    wardrobe_source: str

    selected_item_ids: list[str] = Field(
        default_factory=list
    )


class RegenerateOneRequest(BaseModel):
    user_image_path: str
    style_type: str
    wardrobe_source: str
    category: str

    selected_item_ids: list[str] = Field(
        default_factory=list
    )


# ============================================================
# Helper
# ============================================================

def get_wardrobe(
    wardrobe_source: str,
) -> list[dict[str, Any]]:

    if wardrobe_source == "personal":
        return list_wardrobe()

    if wardrobe_source == "commercial":
        return list_commercial_wardrobe()

    if wardrobe_source == "open_world":
        return []

    raise ValueError(
        "wardrobe_source must be personal, commercial, or open_world"
    )


# ============================================================
# Generate recommendations
# ============================================================

@router.post(
    "/options",
    response_model=None,
)
async def generate_options(
    request: RecommendationRequest,
) -> Any:

    try:

        print(
            "[INFO] Running recommendation flow"
        )

        print(
            f"[INFO] Style: {request.style_type}"
        )

        print(
            f"[INFO] Wardrobe source: "
            f"{request.wardrobe_source}"
        )

        print(
            f"[INFO] Selected wardrobe items: "
            f"{request.selected_item_ids}"
        )

        # ----------------------------------------------------
        # Module 1 - Vision
        # ----------------------------------------------------

        user_profile = analyze_user_image(
            request.user_image_path,
            request.style_type,
        )

        # ----------------------------------------------------
        # Module 2 - Wardrobe
        # ----------------------------------------------------

        wardrobe_data = get_wardrobe(
            request.wardrobe_source
        )

        print(
            f"[INFO] Available wardrobe items: "
            f"{len(wardrobe_data)}"
        )

        # ----------------------------------------------------
        # Module 3 - Stylist
        # ----------------------------------------------------

        recommendations = (
            generate_style_recommendation(
                module1_data=user_profile,
                wardrobe_items=wardrobe_data,
                style_type=request.style_type,
                wardrobe_source=request.wardrobe_source,
                selected_item_ids=request.selected_item_ids,
            )
        )

        # ----------------------------------------------------
        # Module 4 - Shopping links
        # ----------------------------------------------------

        for outfit in recommendations.recommendations:

            outfit.shopping_links = create_search_links(
                outfit
            )

        print(
            "[INFO] Recommendation flow completed"
        )

        return {
            "status": "success",
            "message": "Outfit options generated",
            "user_image_path": request.user_image_path,
            "selected_item_ids": request.selected_item_ids,
            "data": recommendations,
        }

    except Exception as e:

        print(
            f"[ERROR] Recommendation failed: {str(e)}"
        )

        return JSONResponse(
            status_code=500,
            content={
                "status": "failed",
                "message": (
                    "Unable to generate outfit options"
                ),
                "error": str(e),
            },
        )


# ============================================================
# Regenerate all recommendations
# ============================================================

@router.post(
    "/regenerate",
    response_model=None,
)
async def regenerate_options(
    request: RegenerateRequest,
) -> Any:

    try:

        print(
            "[INFO] Regenerating recommendations"
        )

        user_profile = analyze_user_image(
            request.user_image_path,
            request.style_type,
        )

        wardrobe_data = get_wardrobe(
            request.wardrobe_source
        )

        recommendations = (
            generate_style_recommendation(
                module1_data=user_profile,
                wardrobe_items=wardrobe_data,
                style_type=request.style_type,
                wardrobe_source=request.wardrobe_source,
                selected_item_ids=request.selected_item_ids,
            )
        )

        for outfit in recommendations.recommendations:

            outfit.shopping_links = create_search_links(
                outfit
            )

        return {
            "status": "success",
            "message": "New recommendations generated",
            "user_image_path": request.user_image_path,
            "selected_item_ids": request.selected_item_ids,
            "data": recommendations,
        }

    except Exception as e:

        print(
            f"[ERROR] Regeneration failed: {str(e)}"
        )

        return JSONResponse(
            status_code=500,
            content={
                "status": "failed",
                "message": (
                    "Unable to regenerate recommendations"
                ),
                "error": str(e),
            },
        )


# ============================================================
# Regenerate one recommendation
# ============================================================

@router.post(
    "/regenerate-one",
    response_model=None,
)
async def regenerate_one_option(
    request: RegenerateOneRequest,
) -> Any:

    try:

        print(
            f"[INFO] Regenerating category: "
            f"{request.category}"
        )

        user_profile = analyze_user_image(
            request.user_image_path,
            request.style_type,
        )

        wardrobe_data = get_wardrobe(
            request.wardrobe_source
        )

        recommendations = (
            generate_style_recommendation(
                module1_data=user_profile,
                wardrobe_items=wardrobe_data,
                style_type=request.style_type,
                wardrobe_source=request.wardrobe_source,
                selected_item_ids=request.selected_item_ids,
            )
        )

        print(
            f">>> Stylist returned "
            f"{len(recommendations.recommendations)} "
            f"recommendation(s)"
        )

        print(
            ">>> Generated categories: "
            f"{[outfit.category for outfit in recommendations.recommendations]}"
        )

        if not recommendations.recommendations:

            return JSONResponse(
                status_code=500,
                content={
                    "status": "failed",
                    "message": (
                        "No outfit recommendation generated"
                    ),
                },
            )

        # Try to return the requested category.
        selected = next(
            (
                outfit
                for outfit in recommendations.recommendations
                if outfit.category.lower()
                == request.category.lower()
            ),
            recommendations.recommendations[0],
        )

        selected.shopping_links = create_search_links(
            selected
        )

        return {
            "status": "success",
            "message": (
                f"{request.category} "
                "recommendation regenerated"
            ),
            "recommendation": selected,
        }

    except Exception as e:

        print(
            "[ERROR] Single recommendation regeneration "
            f"failed: {str(e)}"
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