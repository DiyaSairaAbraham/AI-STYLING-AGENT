import json
import random

from openai import OpenAI

from config import OPENAI_API_KEY, STYLIST_MODEL
from schemas.models import Module3Output
from utils.logger import log


client = OpenAI(
    api_key=OPENAI_API_KEY
)


def generate_style_recommendation(
    module1_data,
    wardrobe_items: list,
    style_type: str,
    wardrobe_source: str
):
    log(
        "Running Stylist Agent (Module 3)"
    )

    variation_seed = random.randint(
        1000,
        9999
    )

    if hasattr(
        module1_data,
        "model_dump"
    ):
        module1_data = module1_data.model_dump()

    wardrobe_data = []

    for item in wardrobe_items:
        if hasattr(
            item,
            "model_dump"
        ):
            wardrobe_data.append(
                item.model_dump()
            )
        else:
            wardrobe_data.append(
                item
            )

    random.shuffle(
        wardrobe_data
    )

    if category is None:

        if style_type.lower() == "formal":

            category_instruction = """
    Create EXACTLY 2 outfit recommendations.

    Categories:

    1. Business Formal
    2. Smart Business
    """

        else:

            category_instruction = """
    Create EXACTLY 2 outfit recommendations.

    Categories:

    1. Smart Casual
    2. Weekend Casual
    """

    context_prompt = f"""
You are a professional fashion stylist AI.

You will be given:

1. User body + outfit analysis from Module 1.
2. Complete wardrobe database from Module 2.

TASK:

Selected Style:

{style_type.upper()}

{category_instruction}

Each recommendation request should generate different combinations whenever the wardrobe allows.

Do not repeatedly select the same clothing pieces across requests.

If multiple suitable items exist, intentionally vary your selections.

Prioritize diversity over consistency while still maintaining good fashion sense.

Variation ID:

{variation_seed}

Treat this variation ID as a unique styling session.

When multiple clothing items satisfy the same requirement,
prefer different choices from previous styling sessions.

Randomly explore different colour combinations,
layering styles,
accessories,
and shoe pairings.

Never always choose the first matching wardrobe item.

Use this variation ID to explore different outfit combinations.

Categories:

1. Business Formal

2. Smart Casual

3. Weekend Casual

For each outfit provide:

- Category
- Selected wardrobe items
- Styling advice
- Image generation prompt

Rules:

- Only use wardrobe database items.
- Do not invent clothes.
- Do not repeat outfit combinations.
- Prefer different clothing pieces across different requests.
- Avoid always selecting the first suitable clothing items.
- Explore different color combinations and styling approaches.

IMAGE REQUIREMENTS:

- Photorealistic fashion photography.
- Full body.
- Face visible.
- Hair visible.
- Shoes visible.
- Centered standing pose.
- No cropping.

User Analysis:

{json.dumps(module1_data, indent=2)}

Wardrobe Database:

{json.dumps(wardrobe_data, indent=2)}

Return ONLY structured output.
"""

    try:
        completion = client.beta.chat.completions.parse(
            model=STYLIST_MODEL,
            messages=[
                {
                    "role": "user",
                    "content": context_prompt
                }
            ],
            response_format=Module3Output
        )

        result = (
            completion
            .choices[0]
            .message
            .parsed
        )

        log(
            "Stylist recommendation completed"
        )

        return result

    except Exception as e:
        log(
            f"Stylist agent failed: {str(e)}"
        )
        raise