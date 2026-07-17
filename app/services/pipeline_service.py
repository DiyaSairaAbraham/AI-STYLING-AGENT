import json
import os


from agents.vision_agent import analyze_user_image
from utils.wardrobe_manager import build_wardrobe_database
from agents.stylist_agent import generate_style_recommendation
from agents.image_agent import generate_outfit_image

from utils.logger import log



OUTPUT_JSON = "outputs/json"

OUTPUT_IMAGES = "outputs/images"




def run_full_pipeline(
        user_image_path: str,
        wardrobe_path: str
):


    log(
        "Starting AI Stylist Pipeline"
    )


    os.makedirs(
        OUTPUT_JSON,
        exist_ok=True
    )


    os.makedirs(
        OUTPUT_IMAGES,
        exist_ok=True
    )



    # =========================
    # MODULE 1
    # Vision
    # =========================


    m1 = analyze_user_image(
        user_image_path
    )



    with open(
        f"{OUTPUT_JSON}/user_profile.json",
        "w",
        encoding="utf-8"
    ) as f:


        json.dump(

            m1.model_dump(),

            f,

            indent=4,

            ensure_ascii=False

        )


    log(
        "Vision completed"
    )



    # =========================
    # MODULE 2
    # Wardrobe
    # =========================


    wardrobe_items = build_wardrobe_database(

        wardrobe_path

    )


    log(
        "Wardrobe completed"
    )



    # =========================
    # MODULE 3
    # Stylist
    # =========================


    recommendation = generate_style_recommendation(

        m1.model_dump(),

        wardrobe_items

    )



    with open(

        f"{OUTPUT_JSON}/recommendation.json",

        "w",

        encoding="utf-8"

    ) as f:


        json.dump(

            recommendation.model_dump(),

            f,

            indent=4,

            ensure_ascii=False

        )



    log(
        "Recommendation completed"
    )



    # =========================
    # MODULE 4
    # Image Generation
    # =========================


    generated_images=[]



    for index, outfit in enumerate(

        recommendation.recommendations,

        start=1

    ):


        try:


            image_path = generate_outfit_image(

                prompt=
                outfit.image_generation_prompt,

                user_image_path=
                user_image_path,

                output_path=
                f"{OUTPUT_IMAGES}/recommended_outfit_{index}.png"

            )



            generated_images.append(

                {
                    "category":
                    outfit.category,

                    "path":
                    image_path
                }

            )



        except Exception as e:


            generated_images.append(

                {
                    "category":
                    outfit.category,

                    "error":
                    str(e)
                }

            )



    log(
        "Pipeline completed successfully"
    )



    return {


        "user_profile":
        m1.model_dump(),



        "recommendations":
        recommendation.model_dump(),



        "images":
        generated_images

    }