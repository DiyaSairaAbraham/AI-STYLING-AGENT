import json
import os
from typing import Any

from agents.image_agent import generate_outfit_image
from agents.stylist_agent import generate_style_recommendation
from utils.logger import log
from utils.wardrobe_manager import (
    build_wardrobe_database,
    list_wardrobe,
)


OUTPUT_JSON_DIR = "outputs/json"
OUTPUT_IMAGE_DIR = "outputs/images"

WARDROBE_1_DIR = os.path.join(
    "wardrobe",
    "wardrobe_1",
)

WARDROBE_2_DIR = os.path.join(
    "wardrobe",
    "wardrobe_2",
)

WARDROBE_1_FILE = os.path.join(
    OUTPUT_JSON_DIR,
    "wardrobe_1.json",
)

WARDROBE_2_FILE = os.path.join(
    OUTPUT_JSON_DIR,
    "wardrobe_2.json",
)

USER_PROFILE_FILE = os.path.join(
    OUTPUT_JSON_DIR,
    "user_profile.json",
)


def _load_user_profile() -> dict[str, Any]:
    """
    Load the user profile created by Vision Agent.

    Function 2 should not call Vision again.
    """

    if not os.path.isfile(USER_PROFILE_FILE):
        raise FileNotFoundError(
            "User profile not found. "
            "Run the user-image analysis first."
        )

    with open(
        USER_PROFILE_FILE,
        "r",
        encoding="utf-8",
    ) as file:
        return json.load(file)


def _build_wardrobe_if_needed(
    folder_path: str,
    output_file: str,
) -> list[dict[str, Any]]:
    """
    Load a cached wardrobe database if available.

    Otherwise analyze the wardrobe images once and save the result.
    """

    if os.path.isfile(output_file):
        try:
            with open(
                output_file,
                "r",
                encoding="utf-8",
            ) as file:
                cached = json.load(file)

            if isinstance(cached, list):
                log(
                    f"Using cached wardrobe: {output_file}"
                )
                return cached

        except (json.JSONDecodeError, OSError) as exc:
            log(
                f"Could not load cached wardrobe "
                f"{output_file}: {exc}",
                level="WARNING",
            )

    if not os.path.isdir(folder_path):
        raise FileNotFoundError(
            f"Wardrobe folder not found: {folder_path}"
        )

    log(
        f"Building wardrobe database from {folder_path}"
    )

    wardrobe = build_wardrobe_database(
        folder_path=folder_path,
    )

    with open(
        output_file,
        "w",
        encoding="utf-8",
    ) as file:
        json.dump(
            wardrobe,
            file,
            indent=4,
            ensure_ascii=False,
        )

    return wardrobe


def _prepare_wardrobe_items(
    wardrobe_1: list[dict[str, Any]],
    wardrobe_2: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    """
    Combine the two wardrobe databases while preserving
    their source wardrobe.
    """

    combined: list[dict[str, Any]] = []

    for item in wardrobe_1:
        item_copy = dict(item)
        item_copy["wardrobe_source"] = "Wardrobe 1"
        combined.append(item_copy)

    for item in wardrobe_2:
        item_copy = dict(item)
        item_copy["wardrobe_source"] = "Wardrobe 2"
        combined.append(item_copy)

    return combined


def run_function_2(
    wardrobe_choice: str = "both",
) -> dict[str, Any]:
    """
    Run Function 2: Wardrobe Styling.

    Wardrobe choices:
        - wardrobe_1
        - wardrobe_2
        - both

    The user profile is loaded from the cached Vision result.
    """

    log("========== FUNCTION 2 START ==========")

    if wardrobe_choice not in {
        "wardrobe_1",
        "wardrobe_2",
        "both",
    }:
        raise ValueError(
            "wardrobe_choice must be "
            "'wardrobe_1', 'wardrobe_2' or 'both'."
        )

    os.makedirs(
        OUTPUT_JSON_DIR,
        exist_ok=True,
    )

    os.makedirs(
        OUTPUT_IMAGE_DIR,
        exist_ok=True,
    )

    # --------------------------------------------------
    # Load cached user analysis.
    # NO Vision API call here.
    # --------------------------------------------------

    user_profile = _load_user_profile()

    # --------------------------------------------------
    # Wardrobe 1
    # --------------------------------------------------

    wardrobe_1: list[dict[str, Any]] = []

    if wardrobe_choice in {
        "wardrobe_1",
        "both",
    }:
        wardrobe_1 = _build_wardrobe_if_needed(
            WARDROBE_1_DIR,
            WARDROBE_1_FILE,
        )

    # --------------------------------------------------
    # Wardrobe 2
    # --------------------------------------------------

    wardrobe_2: list[dict[str, Any]] = []

    if wardrobe_choice in {
        "wardrobe_2",
        "both",
    }:
        wardrobe_2 = _build_wardrobe_if_needed(
            WARDROBE_2_DIR,
            WARDROBE_2_FILE,
        )

    combined_wardrobe = _prepare_wardrobe_items(
        wardrobe_1,
        wardrobe_2,
    )

    if not combined_wardrobe:
        raise ValueError(
            "No clothing items were found in the "
            "selected wardrobe."
        )

    log(
        f"Loaded {len(combined_wardrobe)} wardrobe items."
    )

    # --------------------------------------------------
    # Stylist Agent
    # --------------------------------------------------

    log(
        "Running Stylist Agent for Function 2."
    )

    recommendations = generate_style_recommendation(
        user_profile,
        wardrobe_items=combined_wardrobe,
    )

    recommendation_data = (
        recommendations.model_dump()
    )

    recommendation_file = os.path.join(
        OUTPUT_JSON_DIR,
        "function2_recommendations.json",
    )

    with open(
        recommendation_file,
        "w",
        encoding="utf-8",
    ) as file:
        json.dump(
            recommendation_data,
            file,
            indent=4,
            ensure_ascii=False,
        )

    # --------------------------------------------------
    # Image Generation
    # --------------------------------------------------

    generated_images: list[dict[str, str]] = []

    for index, outfit in enumerate(
        recommendations.recommendations,
        start=1,
    ):
        output_path = os.path.join(
            OUTPUT_IMAGE_DIR,
            f"function2_outfit_{index}.png",
        )

        try:
            image_path = generate_outfit_image(
                prompt=outfit.image_generation_prompt,
                user_image_path=(
                    user_profile.get(
                        "user_image_path",
                        "",
                    )
                    or "",
                ),
                output_path=output_path,
            )

            generated_images.append(
                {
                    "category": outfit.category,
                    "image_path": image_path,
                }
            )

        except Exception as exc:
            log(
                f"Function 2 image generation failed "
                f"for {outfit.category}: {exc}",
                level="ERROR",
            )

            generated_images.append(
                {
                    "category": outfit.category,
                    "error": str(exc),
                }
            )

    log("========== FUNCTION 2 COMPLETE ==========")

    return {
        "user_profile": user_profile,
        "wardrobe_choice": wardrobe_choice,
        "wardrobe_1_count": len(wardrobe_1),
        "wardrobe_2_count": len(wardrobe_2),
        "recommendations": recommendation_data,
        "images": generated_images,
    }