import json
import os

from agents.image_agent import (
    generate_outfit_image,
)
from agents.shopping_agent import (
    create_search_links,
)
from agents.stylist_agent import (
    generate_style_recommendation,
    generate_wardrobe_recommendation,
)
from agents.vision_agent import (
    analyze_user_image,
)

from utils.wardrobe_manager import (
    get_wardrobe_image_paths,
    list_wardrobe,
)
from utils.logger import log


OUTPUT_JSON = "outputs/json"
OUTPUT_IMAGES = "outputs/images"


def run_function_1_pipeline(
    user_image_path: str,
) -> dict:

    log(
        "Starting Function 1 AI Styling Pipeline"
    )

    os.makedirs(
        OUTPUT_JSON,
        exist_ok=True,
    )

    os.makedirs(
        OUTPUT_IMAGES,
        exist_ok=True,
    )

    # --------------------------------------------
    # Vision
    # --------------------------------------------

    module1 = analyze_user_image(
        user_image_path
    )

    # --------------------------------------------
    # AI Styling
    # --------------------------------------------

    recommendation = (
        generate_style_recommendation(
            module1
        )
    )

    outfit = (
        recommendation.recommendation
    )

    # --------------------------------------------
    # Shopping links
    # --------------------------------------------

    outfit.shopping_links = (
        create_search_links(
            outfit
        )
    )

    # --------------------------------------------
    # Image
    # --------------------------------------------

    image_path = generate_outfit_image(
        prompt=(
            outfit.image_generation_prompt
        ),
        user_image_path=user_image_path,
        output_path=(
            f"{OUTPUT_IMAGES}/"
            "function1_ai_styling.png"
        ),
    )

    result = {
        "user_profile": (
            module1.model_dump()
        ),
        "recommendation": (
            outfit.model_dump()
        ),
        "image": image_path,
    }

    with open(
        f"{OUTPUT_JSON}/function1.json",
        "w",
        encoding="utf-8",
    ) as file:
        json.dump(
            result,
            file,
            indent=4,
            ensure_ascii=False,
        )

    return result


def run_function_2_pipeline(
    user_image_path: str,
    wardrobe_source: str,
) -> dict:

    log(
        "Starting Function 2 Wardrobe Styling Pipeline"
    )

    os.makedirs(
        OUTPUT_JSON,
        exist_ok=True,
    )

    os.makedirs(
        OUTPUT_IMAGES,
        exist_ok=True,
    )

    # --------------------------------------------
    # Vision
    # --------------------------------------------

    module1 = analyze_user_image(
        user_image_path
    )

    # --------------------------------------------
    # Wardrobe
    # --------------------------------------------

    wardrobe = list_wardrobe(
        wardrobe_source
    )

    if not wardrobe:
        raise ValueError(
            f"{wardrobe_source} wardrobe is empty."
        )

    # --------------------------------------------
    # Wardrobe Styling
    # --------------------------------------------

    recommendation = (
        generate_wardrobe_recommendation(
            module1_data=module1,
            wardrobe_items=wardrobe,
            wardrobe_source=wardrobe_source,
        )
    )

    outfit = (
        recommendation.recommendation
    )

    # --------------------------------------------
    # Selected wardrobe images
    # --------------------------------------------

    wardrobe_images = (
        get_wardrobe_image_paths(
            source=wardrobe_source,
            item_ids=(
                outfit.selected_item_ids
            ),
        )
    )

    # --------------------------------------------
    # Image generation
    # --------------------------------------------

    image_path = generate_outfit_image(
        prompt=(
            outfit.image_generation_prompt
        ),
        user_image_path=user_image_path,
        wardrobe_image_paths=wardrobe_images,
        output_path=(
            f"{OUTPUT_IMAGES}/"
            f"function2_{wardrobe_source}.png"
        ),
    )

    result = {
        "user_profile": (
            module1.model_dump()
        ),
        "wardrobe_source": wardrobe_source,
        "recommendation": (
            outfit.model_dump()
        ),
        "image": image_path,
    }

    with open(
        f"{OUTPUT_JSON}/"
        f"function2_{wardrobe_source}.json",
        "w",
        encoding="utf-8",
    ) as file:
        json.dump(
            result,
            file,
            indent=4,
            ensure_ascii=False,
        )

    return result