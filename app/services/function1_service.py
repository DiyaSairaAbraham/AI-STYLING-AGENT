import json
import os
from typing import Any

from agents.image_agent import generate_outfit_image
from agents.shopping_agent import create_search_links
from agents.stylist_agent import generate_style_recommendation
from agents.vision_agent import analyze_user_image
from utils.logger import log


OUTPUT_JSON_DIR = "outputs/json"
OUTPUT_IMAGE_DIR = "outputs/images"
USER_PROFILE_FILE = os.path.join(
    OUTPUT_JSON_DIR,
    "user_profile.json",
)


def get_or_create_user_profile(
    user_image_path: str,
) -> Any:
    """
    Reuse an existing Vision result whenever possible.

    Vision is the expensive part that should not be repeated when
    the same uploaded user image is reused for Function 1 and
    Function 2.
    """

    os.makedirs(
        OUTPUT_JSON_DIR,
        exist_ok=True,
    )

    if os.path.isfile(USER_PROFILE_FILE):
        try:
            with open(
                USER_PROFILE_FILE,
                "r",
                encoding="utf-8",
            ) as file:
                cached_profile = json.load(file)

            log(
                "Using cached user profile. "
                "Vision Agent API call skipped."
            )

            return cached_profile

        except (json.JSONDecodeError, OSError) as exc:
            log(
                f"Cached profile could not be loaded: {exc}",
                level="WARNING",
            )

    log(
        "No cached user profile found. "
        "Running Vision Agent."
    )

    profile = analyze_user_image(
        user_image_path,
    )

    profile_data = profile.model_dump()

    with open(
        USER_PROFILE_FILE,
        "w",
        encoding="utf-8",
    ) as file:
        json.dump(
            profile_data,
            file,
            indent=4,
            ensure_ascii=False,
        )

    return profile_data


def run_function_1(
    user_image_path: str,
) -> dict[str, Any]:
    """
    Run Function 1: AI Styling.

    Flow:
        User image
        -> cached/new Vision analysis
        -> AI Stylist
        -> Shopping links
        -> Image generation

    Function 1 does not use either wardrobe.
    """

    log("========== FUNCTION 1 START ==========")

    if not os.path.isfile(user_image_path):
        raise FileNotFoundError(
            f"User image not found: {user_image_path}"
        )

    os.makedirs(
        OUTPUT_JSON_DIR,
        exist_ok=True,
    )

    os.makedirs(
        OUTPUT_IMAGE_DIR,
        exist_ok=True,
    )

    # Vision runs only when a cached profile is unavailable.
    user_profile = get_or_create_user_profile(
        user_image_path,
    )

    log("Running Stylist Agent for Function 1.")

    recommendations = generate_style_recommendation(
        user_profile,
    )

    for outfit in recommendations.recommendations:
        outfit.shopping_links = create_search_links(
            outfit,
        )

    recommendation_data = (
        recommendations.model_dump()
    )

    recommendation_file = os.path.join(
        OUTPUT_JSON_DIR,
        "function1_recommendations.json",
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

    generated_images: list[dict[str, str]] = []

    for index, outfit in enumerate(
        recommendations.recommendations,
        start=1,
    ):
        output_path = os.path.join(
            OUTPUT_IMAGE_DIR,
            f"function1_outfit_{index}.png",
        )

        try:
            image_path = generate_outfit_image(
                prompt=outfit.image_generation_prompt,
                user_image_path=user_image_path,
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
                f"Image generation failed for "
                f"{outfit.category}: {exc}",
                level="ERROR",
            )

            generated_images.append(
                {
                    "category": outfit.category,
                    "error": str(exc),
                }
            )

    log("========== FUNCTION 1 COMPLETE ==========")

    return {
        "user_profile": user_profile,
        "recommendations": recommendation_data,
        "images": generated_images,
    }