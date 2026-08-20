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


    if style_type.lower() == "formal":

        category_instruction = """
    Create EXACTLY 2 outfit recommendations.

    STYLE RULES:

    - ONLY formal and business outfits.
    - Allowed categories:
        1. Business Formal
        2. Smart Business

    - Blazers are allowed.
    - Dress shirts are allowed.
    - Tailored trousers are allowed.
    - Formal shoes are allowed.

    - NEVER generate:
        - Weekend Casual
        - Smart Casual
        - Streetwear
        - Resort Wear
        - Vacation Looks
        - Relaxed Casual Looks
    """

    elif style_type.lower() == "leisure":

        category_instruction = """
    Create EXACTLY 2 outfit recommendations.

    STYLE RULES:

    - ONLY leisure and casual outfits.
    - Allowed categories:
        1. Smart Casual
        2. Weekend Casual

    - T-shirts are allowed.
    - Polo shirts are allowed.
    - Casual shirts are allowed.
    - Jeans are allowed.
    - Chinos are allowed.
    - Sneakers are allowed.

    - NEVER generate:
        - Business Formal
        - Smart Business
        - Suit Looks
        - Office Looks
        - Formal Blazers
        - Formal Trousers
        - Business Attire
    """

    else:

        category_instruction = """
    Create EXACTLY 2 outfit recommendations.
    """

    if wardrobe_source == "open_world":

        wardrobe_section = """
    OPEN WORLD MODE

    You are NOT restricted to any wardrobe database.

    Create outfit recommendations freely from your fashion knowledge.

    Do NOT use wardrobe item IDs.

    Do NOT use commercial catalog items.

    Generate realistic clothing descriptions directly.
    """

    else:

        wardrobe_section = f"""

    Wardrobe Database:

    {json.dumps(wardrobe_data, indent=2)}

    Rules:

    - Only use wardrobe database items.
    - Do not invent clothes.
    """

    context_prompt = f"""
You are a professional fashion stylist AI.

You will be given:

1. User body + outfit analysis from Module 1.
2. Complete wardrobe database from Module 2.

TASK:

Selected Style:

{style_type.upper()}

IMPORTANT:

You MUST strictly follow the selected style.

If style is FORMAL:
generate ONLY formal/business outfits.

If style is LEISURE:
generate ONLY casual/leisure outfits.

Do not mix styles.

A leisure request must never return business outfits.

A formal request must never return casual outfits.

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

{wardrobe_section}

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