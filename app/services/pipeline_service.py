import json
import os
from typing import Any

from agents.image_agent import generate_outfit_image
from agents.stylist_agent import generate_style_recommendation
from agents.vision_agent import analyze_user_image
from utils.logger import log
from utils.wardrobe_manager import build_wardrobe_database


OUTPUT_JSON = "outputs/json"
OUTPUT_IMAGES = "outputs/images"


def run_full_pipeline(
    user_image_path: str,
    wardrobe_path: str,
    style_type: str,
    wardrobe_source: str,
) -> dict[str, Any]:

    log("Starting AI Stylist Pipeline")

    os.makedirs(
        OUTPUT_JSON,
        exist_ok=True,
    )

    os.makedirs(
        OUTPUT_IMAGES,
        exist_ok=True,
    )

    # =====================================================
    # MODULE 1 - VISION
    # =====================================================

    m1 = analyze_user_image(
        image_path=user_image_path,
        style_type=style_type,
    )

    user_profile = m1.model_dump()

    with open(
        f"{OUTPUT_JSON}/user_profile.json",
        "w",
        encoding="utf-8",
    ) as file:

        json.dump(
            user_profile,
            file,
            indent=4,
            ensure_ascii=False,
        )

    log("Vision completed")

    # =====================================================
    # MODULE 2 - WARDROBE
    # =====================================================

    wardrobe_items = build_wardrobe_database(
        wardrobe_path
    )

    log("Wardrobe completed")

    # =====================================================
    # MODULE 3 - STYLIST
    # =====================================================

    recommendation = generate_style_recommendation(
        module1_data=user_profile,
        wardrobe_items=wardrobe_items,
        style_type=style_type,
        wardrobe_source=wardrobe_source,
        selected_item_ids=[],
    )

    recommendation_data = recommendation.model_dump()

    with open(
        f"{OUTPUT_JSON}/recommendation.json",
        "w",
        encoding="utf-8",
    ) as file:

        json.dump(
            recommendation_data,
            file,
            indent=4,
            ensure_ascii=False,
        )

    log("Recommendation completed")

    # =====================================================
    # MODULE 4 - IMAGE GENERATION
    # =====================================================

    generated_images: list[dict[str, str]] = []

    if not recommendation.recommendations:
        raise ValueError(
            "Stylist returned no outfit recommendation."
        )

    # The stylist is configured to return exactly one outfit.
    outfit = recommendation.recommendations[0]

    try:

        image_path = generate_outfit_image(
            prompt=outfit.image_generation_prompt,
            user_image_path=user_image_path,
            output_path=(
                f"{OUTPUT_IMAGES}/recommended_outfit.png"
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
            f"{outfit.category}: {exc}"
        )

        generated_images.append(
            {
                "category": outfit.category,
                "error": str(exc),
            }
        )

    log("Pipeline completed successfully")

    return {
        "user_profile": user_profile,
        "recommendations": recommendation_data,
        "images": generated_images,
    }