import os
import shutil
from typing import Any

from fastapi import APIRouter, File, UploadFile
from fastapi.responses import JSONResponse
from pydantic import BaseModel

from agents.shopping_agent import create_search_links
from agents.stylist_agent import generate_style_recommendation
from agents.vision_agent import analyze_user_image


router = APIRouter(
    prefix="/recommendation",
    tags=["Recommendation Options"],
)


UPLOAD_DIR = "uploads"


class RegenerateRequest(BaseModel):
    user_image_path: str


class RegenerateOneRequest(BaseModel):
    user_image_path: str
    category: str


def _validate_category(category: str) -> None:
    if category not in {
        "Business Formal",
        "Smart Casual",
    }:
        raise ValueError(
            "Category must be either "
            "'Business Formal' or 'Smart Casual'."
        )


@router.post(
    "/options",
    response_model=None,
)
async def generate_options(
    user_image: UploadFile = File(...),
) -> Any:

    try:
        os.makedirs(
            UPLOAD_DIR,
            exist_ok=True,
        )

        filename = (
            user_image.filename
            or "user_image.jpg"
        )

        image_path = os.path.join(
            UPLOAD_DIR,
            filename,
        )

        with open(
            image_path,
            "wb",
        ) as buffer:
            shutil.copyfileobj(
                user_image.file,
                buffer,
            )

        print(
            "[INFO] Starting Function 1 recommendation flow"
        )

        # --------------------------------------------------
        # Module 1: Vision Agent
        # --------------------------------------------------

        user_profile = analyze_user_image(
            image_path,
        )

        # --------------------------------------------------
        # Module 3: Stylist Agent
        #
        # IMPORTANT:
        # No wardrobe is loaded here.
        # --------------------------------------------------

        recommendations = generate_style_recommendation(
            user_profile,
        )

        # --------------------------------------------------
        # Shopping Agent
        # --------------------------------------------------

        for outfit in recommendations.recommendations:
            outfit.shopping_links = create_search_links(
                outfit,
            )

        return {
            "status": "success",
            "message": (
                "Business Formal and Smart Casual "
                "outfit options generated"
            ),
            "user_image_path": image_path,
            "data": recommendations,
        }

    except Exception as exc:
        print(
            f"[ERROR] Recommendation failed: {str(exc)}"
        )

        return JSONResponse(
            status_code=500,
            content={
                "status": "failed",
                "message": (
                    "Unable to generate outfit options"
                ),
                "error": str(exc),
            },
        )


@router.post(
    "/regenerate",
    response_model=None,
)
async def regenerate_options(
    request: RegenerateRequest,
) -> Any:

    try:
        if not os.path.isfile(
            request.user_image_path
        ):
            return JSONResponse(
                status_code=400,
                content={
                    "status": "failed",
                    "message": (
                        "User image was not found"
                    ),
                },
            )

        print(
            "[INFO] Regenerating Function 1 recommendations"
        )

        user_profile = analyze_user_image(
            request.user_image_path,
        )

        # No wardrobe.
        recommendations = generate_style_recommendation(
            user_profile,
        )

        for outfit in recommendations.recommendations:
            outfit.shopping_links = create_search_links(
                outfit,
            )

        return {
            "status": "success",
            "message": (
                "New Business Formal and Smart Casual "
                "recommendations generated"
            ),
            "user_image_path": request.user_image_path,
            "data": recommendations,
        }

    except Exception as exc:
        print(
            f"[ERROR] Regeneration failed: {str(exc)}"
        )

        return JSONResponse(
            status_code=500,
            content={
                "status": "failed",
                "message": (
                    "Unable to regenerate recommendations"
                ),
                "error": str(exc),
            },
        )


@router.post(
    "/regenerate-one",
    response_model=None,
)
async def regenerate_one_option(
    request: RegenerateOneRequest,
) -> Any:

    try:
        _validate_category(
            request.category
        )

        if not os.path.isfile(
            request.user_image_path
        ):
            return JSONResponse(
                status_code=400,
                content={
                    "status": "failed",
                    "message": (
                        "User image was not found"
                    ),
                },
            )

        print(
            f"[INFO] Regenerating category: "
            f"{request.category}"
        )

        user_profile = analyze_user_image(
            request.user_image_path,
        )

        # No wardrobe.
        recommendation = generate_style_recommendation(
            user_profile,
            category=request.category,
        )

        if not recommendation.recommendations:
            return JSONResponse(
                status_code=500,
                content={
                    "status": "failed",
                    "message": (
                        "No outfit recommendation generated"
                    ),
                },
            )

        selected = (
            recommendation.recommendations[0]
        )

        selected.shopping_links = create_search_links(
            selected,
        )

        return {
            "status": "success",
            "message": (
                f"{request.category} "
                "recommendation regenerated"
            ),
            "recommendation": selected,
        }

    except ValueError as exc:
        return JSONResponse(
            status_code=400,
            content={
                "status": "failed",
                "message": str(exc),
            },
        )

    except Exception as exc:
        print(
            "[ERROR] Single recommendation "
            f"regeneration failed: {str(exc)}"
        )

        return JSONResponse(
            status_code=500,
            content={
                "status": "failed",
                "message": (
                    "Unable to regenerate recommendation"
                ),
                "error": str(exc),
            },
        )