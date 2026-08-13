import json
from typing import Any

from openai import OpenAI

from config import OPENAI_API_KEY, STYLIST_MODEL
from schemas.models import Function1Output, Function2Output
from utils.logger import log


client = OpenAI(
    api_key=OPENAI_API_KEY,
)


# ============================================================
# FUNCTION 1 - AI STYLING
# ============================================================

AI_STYLING_PROMPT = """
You are an expert personal fashion stylist.

You are performing FUNCTION 1: AI STYLING.

The user has NOT selected a wardrobe.

You have complete freedom to design ONE outfit using
your fashion intelligence.

You MAY invent garments, footwear and accessories.

Do NOT use:

- personal wardrobe
- commercial wardrobe
- wardrobe IDs
- wardrobe databases
- wardrobe image paths

Use the user's visual analysis to create a highly
personalized outfit.

Consider:

- skin tone
- hairstyle
- hair color
- body silhouette
- facial features
- current outfit
- styling advantages
- improvement areas
- color harmony
- garment fit
- proportions
- material
- pattern
- accessories
- occasion

Return EXACTLY ONE recommendation.

The shopping_items field must contain concise descriptions
of individual products that could be searched online.

Do NOT provide URLs.

The application will create H&M and UNIQLO search links
automatically.

The image_generation_prompt must describe:

- the same general person
- full-body composition
- clearly visible face
- clearly visible hair
- complete outfit
- both shoes visible
- realistic proportions
- realistic garment construction
- realistic fabrics
- accurate layering
- professional fashion photography
- clean studio background
- natural lighting
- realistic skin appearance
- no cropping
- no extra people
- no text
- no watermark

Return structured output only.
"""


# ============================================================
# FUNCTION 2 - WARDROBE STYLING
# ============================================================

WARDROBE_STYLING_PROMPT = """
You are an expert personal fashion stylist.

You are performing FUNCTION 2: WARDROBE STYLING.

The user has selected a specific wardrobe.

You MUST use ONLY the wardrobe items supplied in the
AVAILABLE WARDROBE section.

You are NOT allowed to invent clothing, footwear,
or accessories.

Every clothing item used in the recommendation MUST
correspond to an existing wardrobe item ID.

You may intelligently combine the supplied wardrobe items.

Return EXACTLY ONE complete outfit.

Consider:

- user's skin tone
- hairstyle
- hair color
- body silhouette
- facial features
- current outfit
- styling advantages
- improvement areas
- wardrobe item colors
- wardrobe compatibility
- proportions
- occasion
- layering
- material
- pattern
- overall coordination

IMPORTANT IMAGE RULES:

The generated image must reproduce ONLY the clothing
items selected from the supplied wardrobe.

Do NOT introduce invented:

- watches
- bags
- jewelry
- belts
- shoes
- jackets
- shirts
- trousers
- skirts
- dresses
- accessories
- other clothing

unless that item exists in the supplied wardrobe and
has been selected using its valid wardrobe ID.

The image-generation prompt MUST clearly state that the
supplied wardrobe images are the authoritative references
for the clothing.

The image generator must reproduce the selected wardrobe
items as closely as possible in:

- garment type
- color
- material
- pattern
- silhouette
- visible construction
- overall appearance

The user's identity/general appearance comes from the
Vision Agent/user image.

The clothing comes ONLY from the selected wardrobe images.

Return structured output only.
"""


# ============================================================
# HELPERS
# ============================================================

def _normalize_wardrobe_source(source: str) -> str:
    """
    Convert all accepted source names to the canonical values
    used internally by the application.
    """
    normalized = source.strip().lower()

    if normalized in {
        "personal",
        "personal wardrobe",
        "wardrobe_1",
        "1",
    }:
        return "personal"

    if normalized in {
        "commercial",
        "commercial wardrobe",
        "wardrobe_2",
        "2",
    }:
        return "commercial"

    raise ValueError(
        "wardrobe_source must be "
        "'personal' or 'commercial'."
    )


def _display_wardrobe_source(source: str) -> str:
    """Return the human-readable wardrobe source name."""
    if source == "personal":
        return "Personal Wardrobe"

    if source == "commercial":
        return "Commercial Wardrobe"

    raise ValueError(
        f"Unsupported wardrobe source: {source}"
    )


# ============================================================
# FUNCTION 1
# ============================================================

def generate_style_recommendation(
    module1_data: Any,
) -> Function1Output:
    """
    Generate exactly one AI-created outfit.

    Function 1 does not use either wardrobe.
    """

    log("Running AI Styling Agent")

    try:
        if hasattr(module1_data, "model_dump"):
            module1_data = module1_data.model_dump()

        context_prompt = f"""
FUNCTION: AI STYLING

The user has not selected a wardrobe.

Create exactly ONE outfit using your own fashion intelligence.

USER VISUAL ANALYSIS:

{json.dumps(
    module1_data,
    indent=2,
    ensure_ascii=False,
)}
"""

        completion = client.beta.chat.completions.parse(
            model=STYLIST_MODEL,
            messages=[
                {
                    "role": "system",
                    "content": AI_STYLING_PROMPT,
                },
                {
                    "role": "user",
                    "content": context_prompt,
                },
            ],
            response_format=Function1Output,
        )

        result = completion.choices[0].message.parsed

        if result is None:
            raise ValueError(
                "AI Stylist returned no result."
            )

        if result.recommendation is None:
            raise ValueError(
                "AI Stylist returned no recommendation."
            )

        if not result.recommendation.shopping_items:
            raise ValueError(
                "AI Stylist returned no shopping items."
            )

        log(
            "AI Styling recommendation completed"
        )

        return result

    except Exception as exc:
        log(
            f"AI Styling failed: {str(exc)}"
        )
        raise


# ============================================================
# FUNCTION 2
# ============================================================

def generate_wardrobe_recommendation(
    module1_data: Any,
    wardrobe_items: list[dict],
    wardrobe_source: str,
) -> Function2Output:
    """
    Generate exactly one outfit using ONLY the supplied wardrobe.

    Accepted wardrobe_source values:

        personal
        commercial
        Personal Wardrobe
        Commercial Wardrobe
        wardrobe_1
        wardrobe_2
        1
        2
    """

    log(
        "Running Wardrobe Styling Agent "
        f"using {wardrobe_source}"
    )

    try:
        # Normalize the source so the stylist, router and
        # wardrobe manager all use the same internal value.
        normalized_source = _normalize_wardrobe_source(
            wardrobe_source
        )

        display_source = _display_wardrobe_source(
            normalized_source
        )

        if hasattr(module1_data, "model_dump"):
            module1_data = module1_data.model_dump()

        if not wardrobe_items:
            raise ValueError(
                f"{display_source} is empty."
            )

        wardrobe_ids = {
            str(item["id_baju"])
            for item in wardrobe_items
            if item.get("id_baju")
        }

        if not wardrobe_ids:
            raise ValueError(
                f"No valid wardrobe IDs found in "
                f"{display_source}."
            )

        context_prompt = f"""
FUNCTION: WARDROBE STYLING

WARDROBE SOURCE:

{display_source}

USER VISUAL ANALYSIS:

{json.dumps(
    module1_data,
    indent=2,
    ensure_ascii=False,
)}

AVAILABLE WARDROBE ITEMS:

{json.dumps(
    wardrobe_items,
    indent=2,
    ensure_ascii=False,
)}

VALID WARDROBE IDS:

{json.dumps(
    sorted(wardrobe_ids),
    indent=2,
)}

STRICT SELECTION RULE:

Create exactly ONE complete outfit.

You may select ONLY wardrobe items listed above.

Every value in selected_item_ids MUST exactly match
one of the VALID WARDROBE IDS.

Do not invent an item.

Do not create an item description and pretend that it
belongs to the wardrobe.

Do not add an accessory unless it exists in the wardrobe.

The final outfit must be constructed entirely from
the supplied wardrobe.

The image-generation prompt must explicitly identify
the selected wardrobe IDs and instruct the image
generator that the supplied wardrobe images are the
authoritative clothing references.
"""

        completion = client.beta.chat.completions.parse(
            model=STYLIST_MODEL,
            messages=[
                {
                    "role": "system",
                    "content": WARDROBE_STYLING_PROMPT,
                },
                {
                    "role": "user",
                    "content": context_prompt,
                },
            ],
            response_format=Function2Output,
        )

        result = completion.choices[0].message.parsed

        if result is None:
            raise ValueError(
                "Wardrobe Stylist returned no result."
            )

        if result.recommendation is None:
            raise ValueError(
                "Wardrobe Stylist returned no recommendation."
            )

        selected_ids = {
            str(item_id)
            for item_id in result.recommendation.selected_item_ids
        }

        if not selected_ids:
            raise ValueError(
                "Wardrobe Stylist selected no wardrobe items."
            )

        invalid_ids = selected_ids - wardrobe_ids

        if invalid_ids:
            raise ValueError(
                "Wardrobe Stylist selected invalid wardrobe IDs: "
                f"{sorted(invalid_ids)}"
            )

        # Force the returned source to the canonical value
        # expected by the API response.
        result.wardrobe_source = normalized_source

        log(
            "Wardrobe Styling recommendation completed"
        )

        return result

    except Exception as exc:
        log(
            f"Wardrobe Styling failed: {str(exc)}"
        )
        raise