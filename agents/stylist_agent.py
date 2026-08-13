import json
from typing import Any

from openai import OpenAI

from config import OPENAI_API_KEY, STYLIST_MODEL
from schemas.models import Module3Output
from utils.logger import log


client = OpenAI(
    api_key=OPENAI_API_KEY,
)


STYLIST_PROMPT = """
You are an expert personal fashion director and stylist.

Your task is to design personalized outfit concepts based entirely on
the user's visual analysis.

FUNCTION 1 RULE:

The user has NOT selected a wardrobe.

You have COMPLETE FREEDOM to design the outfit.

Do NOT use:
- personal wardrobe
- commercial wardrobe
- wardrobe IDs
- wardrobe databases
- existing wardrobe clothing as mandatory items

The user's current outfit is provided ONLY to understand their current
style and identify opportunities for improvement.

You must generate EXACTLY TWO recommendations:

1. Business Formal
2. Smart Casual

Do not generate any other categories.

==================================================
USER ANALYSIS
==================================================

Use ALL of the following information:

- skin tone
- hairstyle
- hair color
- facial features
- body silhouette/proportions
- current outfit
- exactly 2 existing advantages
- exactly 2 areas for improvement

The advantages describe what is already working well.

The improvement areas describe specific aspects that can be improved.

The final styling must preserve or enhance the advantages while addressing
the improvement areas.

==================================================
OUTFIT DESIGN
==================================================

For EACH recommendation carefully determine:

GARMENTS:
- garment types
- silhouette
- fit
- proportions
- layering
- garment combinations

COLOR:
- colors that complement the observed skin tone
- coordinated color palette
- appropriate contrast
- colors that support the selected style

MATERIAL:
- suitable fabrics
- fabric weight
- texture
- material suitability for the occasion

PATTERN:
- whether a pattern should be used
- pattern type
- pattern scale
- how the pattern interacts with the overall appearance

ACCESSORIES:
- watch
- belt
- bag
- jewelry where appropriate
- other suitable accessories

HAIR:
- hairstyle recommendation
- hair presentation
- how the hairstyle complements the outfit
- maintain compatibility with the user's observed hair color

==================================================
STYLE REASONING
==================================================

Styling advice must explain:

1. Why the garments suit the user.
2. How the outfit preserves or enhances the 2 advantages.
3. How it addresses the 2 improvement areas.
4. Why the selected colors work with the observed skin tone.
5. Why the materials are appropriate.
6. Why the pattern choice works.
7. Why the accessories work.
8. Why the hairstyle complements the complete look.

==================================================
SHOPPING
==================================================

The application will provide H&M and UNIQLO links for similar products.

For each outfit, provide several concise shopping item descriptions.

Examples:

- tailored charcoal blazer
- white silk-blend blouse
- straight-leg black trousers
- structured leather handbag

Do NOT provide URLs yourself.

==================================================
IMAGE GENERATION
==================================================

Create a detailed image-generation prompt.

The generated image should represent the SAME GENERAL PERSON described by
the Vision Agent as closely as possible using observable textual
characteristics.

Do NOT claim that text alone guarantees exact identity preservation.

The image prompt MUST specify:

- full-body fashion photograph
- face clearly visible
- hair clearly visible
- complete outfit visible
- both shoes visible
- centered standing pose
- realistic proportions
- realistic garment construction
- realistic fabric appearance
- accurate clothing layering
- professional fashion photography
- clean studio background
- natural lighting
- realistic skin appearance
- no cropping
- no extra people
- no text
- no watermark

==================================================
OUTPUT
==================================================

Return ONLY structured output matching the provided schema.
"""


def generate_style_recommendation(
    module1_data: Any,
    wardrobe_items: list | None = None,
    category: str | None = None,
) -> Module3Output:
    """
    Generate Function 1 recommendations.

    Function 1 intentionally ignores wardrobe_items because it gives
    the stylist complete freedom to design new outfits.

    wardrobe_items remains in the signature for backward compatibility
    with existing callers and for Function 2 integration later.
    """

    log("Running Stylist Agent (Module 3)")

    try:
        if hasattr(module1_data, "model_dump"):
            module1_data = module1_data.model_dump()

        allowed_categories = {
            "Business Formal",
            "Smart Casual",
        }

        if category is None:
            category_instruction = """
Generate EXACTLY TWO recommendations:

1. Business Formal
2. Smart Casual

Do not generate any other categories.
"""
        else:
            normalized_category = category.strip()

            if normalized_category not in allowed_categories:
                raise ValueError(
                    "Category must be either "
                    "'Business Formal' or 'Smart Casual'."
                )

            category_instruction = f"""
Generate EXACTLY ONE recommendation.

Category:
{normalized_category}

Do not generate any other category.
"""

        context_prompt = f"""
TASK FOR THIS REQUEST:

{category_instruction}

USER VISUAL ANALYSIS:

{json.dumps(
    module1_data,
    indent=2,
    ensure_ascii=False,
)}

Remember:

- Function 1 does not use a wardrobe.
- You have complete freedom to design new clothing.
- Use the user's advantages.
- Address the user's improvement areas.
- Consider garment, hair, skin tone, material, pattern,
  accessories, fit, silhouette and proportions.
"""

        completion = client.beta.chat.completions.parse(
            model=STYLIST_MODEL,
            messages=[
                {
                    "role": "system",
                    "content": STYLIST_PROMPT,
                },
                {
                    "role": "user",
                    "content": context_prompt,
                },
            ],
            response_format=Module3Output,
        )

        result = completion.choices[0].message.parsed

        if result is None:
            raise ValueError(
                "Stylist Agent returned no structured result."
            )

        expected_count = (
            1
            if category is not None
            else 2
        )

        if len(result.recommendations) != expected_count:
            raise ValueError(
                f"Expected {expected_count} recommendation(s), "
                f"but received {len(result.recommendations)}."
            )

        actual_categories = {
            recommendation.category
            for recommendation in result.recommendations
        }

        if category is None:
            expected_categories = {
                "Business Formal",
                "Smart Casual",
            }

            if actual_categories != expected_categories:
                raise ValueError(
                    "Stylist Agent must return exactly "
                    "Business Formal and Smart Casual."
                )
        else:
            if result.recommendations[0].category != category:
                raise ValueError(
                    f"Stylist Agent returned "
                    f"'{result.recommendations[0].category}' "
                    f"instead of '{category}'."
                )

        log(
            "Stylist recommendation completed"
        )

        return result

    except Exception as exc:
        log(
            f"Stylist Agent failed: {str(exc)}"
        )
        raise