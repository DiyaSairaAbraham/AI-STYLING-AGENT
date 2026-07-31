import json
import os

from agents.vision_agent import analyze_user_image
from utils.wardrobe_manager import build_wardrobe_database
from agents.stylist_agent import generate_style_recommendation
from agents.image_agent import generate_outfit_image


# Create output folders
os.makedirs("outputs/images", exist_ok=True)
os.makedirs("outputs/json", exist_ok=True)


# =========================
# MODULE 1 - Vision Agent
# =========================

m1 = analyze_user_image(
    "user.jpg"
)


with open(
    "outputs/json/user_profile.json",
    "w",
    encoding="utf-8"
) as f:

    json.dump(
        m1.model_dump(),
        f,
        indent=4,
        ensure_ascii=False
    )


print(
    "[INFO] User profile saved to outputs/json/user_profile.json"
)



# =========================
# MODULE 2 - Wardrobe Agent
# =========================

wardrobe_items = build_wardrobe_database(
    "wardrobe"
)



# =========================
# MODULE 3 - Stylist Agent
# =========================

result = generate_style_recommendation(
    m1.model_dump(),
    wardrobe_items
)


print(result)



with open(
    "outputs/json/recommendation.json",
    "w",
    encoding="utf-8"
) as f:

    json.dump(
        result.model_dump(),
        f,
        indent=4,
        ensure_ascii=False
    )


print(
    "[INFO] Recommendation saved to outputs/json/recommendation.json"
)



# =========================
# MODULE 4 - Image Generator
# =========================

print(
    "[INFO] Running Image Generator (Module 4)"
)



for index, outfit in enumerate(
        result.recommendations,
        start=1
):

    print(
        f"[INFO] Generating image for {outfit.category}"
    )


    image_path = generate_outfit_image(
        outfit.image_generation_prompt,
        user_image_path="user.jpg",
        output_path=f"outputs/images/recommended_outfit_{index}.png"
    )


    print(
        f"[INFO] Image saved: {image_path}"
    )


print(
    "[INFO] All outfit images generated successfully."
)