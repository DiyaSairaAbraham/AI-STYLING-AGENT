import json
import os

from agents.image_agent import generate_outfit_image
from agents.shopping_agent import create_search_links
from agents.stylist_agent import generate_style_recommendation
from agents.vision_agent import analyze_user_image
from utils.logger import log


OUTPUT_JSON = "outputs/json"
OUTPUT_IMAGES = "outputs/images"


def run_function_1_pipeline(
    user_image_path: str,
) -> dict:
    """
    Execute Function 1.

    Flow:

    User Image
        -> Vision Agent
        -> Stylist Agent
        -> Shopping Links
        -> Image Generator

    Function 1 does NOT use the personal or commercial wardrobe.
    """

    log(
        "Starting Function 1 AI Stylist Pipeline"
    )

    os.makedirs(
        OUTPUT_JSON,
        exist_ok=True,
    )

    os.makedirs(
        OUTPUT_IMAGES,
        exist_ok=True,
    )

    # ==========================================
    # MODULE 1 - VISION
    # ==========================================

    log(
        "Starting Vision Agent"
    )

    module1 = analyze_user_image(
        user_image_path,
    )

    with open(
        f"{OUTPUT_JSON}/user_profile.json",
        "w",
        encoding="utf-8",
    ) as file:

        json.dump(
            module1.model_dump(),
            file,
            indent=4,
            ensure_ascii=False,
        )

    log(
        "Vision completed"
    )

    # ==========================================
    # MODULE 3 - STYLIST
    # ==========================================

    log(
        "Starting Stylist Agent"
    )

    recommendations = (
        generate_style_recommendation(
            module1,
        )
    )

    # ==========================================
    # SHOPPING LINKS
    # ==========================================

    for outfit in (
        recommendations.recommendations
    ):

        outfit.shopping_links = (
            create_search_links(
                outfit,
            )
        )

    with open(
        f"{OUTPUT_JSON}/recommendation.json",
        "w",
        encoding="utf-8",
    ) as file:

        json.dump(
            recommendations.model_dump(),
            file,
            indent=4,
            ensure_ascii=False,
        )

    log(
        "Styling recommendations completed"
    )

    # ==========================================
    # MODULE 4 - IMAGE GENERATION
    # ==========================================

    generated_images = []

    for index, outfit in enumerate(
        recommendations.recommendations,
        start=1,
    ):

        try:

            image_path = generate_outfit_image(
                prompt=(
                    outfit.image_generation_prompt
                ),
                user_image_path=(
                    user_image_path
                ),
                output_path=(
                    f"{OUTPUT_IMAGES}/"
                    f"recommended_outfit_{index}.png"
                ),
            )

            generated_images.append(
                {
                    "category": outfit.category,
                    "path": image_path,
                }
            )

        except Exception as exc:

            log(
                f"Image generation failed for "
                f"{outfit.category}: {str(exc)}"
            )

            generated_images.append(
                {
                    "category": outfit.category,
                    "error": str(exc),
                }
            )

    log(
        "Function 1 pipeline completed successfully"
    )

    return {
        "user_profile": (
            module1.model_dump()
        ),
        "recommendations": (
            recommendations.model_dump()
        ),
        "images": generated_images,
    }


# -------------------------------------------------
# Backward-compatible wrapper
# -------------------------------------------------

def run_full_pipeline(
    user_image_path: str,
    wardrobe_path: str | None = None,
) -> dict:
    """
    Backward-compatible wrapper for existing callers.

    wardrobe_path is intentionally ignored because Function 1
    does not use a wardrobe.

    Function 2 can use a separate pipeline later.
    """

    return run_function_1_pipeline(
        user_image_path,
    )