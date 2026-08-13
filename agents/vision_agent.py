from openai import OpenAI

from config import OPENAI_API_KEY, VISION_MODEL
from schemas.models import Module1Output
from utils.image_utils import encode_image
from utils.logger import log


client = OpenAI(
    api_key=OPENAI_API_KEY
)


VISION_PROMPT = """
You are a professional fashion stylist and visual analyst.

Analyze the user's full-body image carefully.

Your task is ONLY to analyze the user and their current appearance.

Do NOT design a new outfit.

==================================================
1. USER FEATURES
==================================================

Identify visually observable characteristics:

- gender/presentation style
- skin tone
- hairstyle
- visible hair color
- body silhouette/proportions
- general facial features

Do not make unsupported claims.

==================================================
2. CURRENT OUTFIT
==================================================

Identify:

- top
- bottom
- shoes
- accessories

For visible clothing, describe where reasonably observable:

- garment type
- color
- material
- pattern
- fit
- overall style

If something cannot be determined reliably,
describe it conservatively.

==================================================
3. STYLE ANALYSIS
==================================================

Provide EXACTLY:

2 ADVANTAGES

These are aspects of the user's current appearance
or styling that are already working well.

2 AREAS FOR IMPROVEMENT

These are specific aspects that could be improved
through:

- clothing
- color
- fit
- material
- pattern
- accessories
- hairstyle
- overall styling

The observations must be useful to both:

1. Function 1 AI Styling
2. Function 2 Wardrobe Styling

IMPORTANT:

- Do not recommend outfits.
- Do not use a wardrobe database.
- Do not restrict future recommendations to current clothes.
- Be specific.
- Base observations only on the image.
- Return structured output only.
"""


def analyze_user_image(
    image_path: str,
) -> Module1Output:
    """
    Analyze the user's image and return structured
    fashion information.
    """

    log(
        "Running Vision Agent (Module 1)"
    )

    try:
        base64_image = encode_image(
            image_path
        )

        response = client.beta.chat.completions.parse(
            model=VISION_MODEL,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": VISION_PROMPT,
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": (
                                    "data:image/jpeg;base64,"
                                    f"{base64_image}"
                                ),
                            },
                        },
                    ],
                }
            ],
            response_format=Module1Output,
        )

        result = (
            response
            .choices[0]
            .message
            .parsed
        )

        if result is None:
            raise ValueError(
                "Vision Agent returned no structured result."
            )

        if len(result.analysis.advantages) != 2:
            raise ValueError(
                "Vision Agent must return exactly 2 advantages."
            )

        if len(
            result.analysis.areas_for_improvement
        ) != 2:
            raise ValueError(
                "Vision Agent must return exactly "
                "2 areas for improvement."
            )

        log(
            "Vision analysis completed successfully"
        )

        return result

    except Exception as exc:
        log(
            f"Vision Agent failed: {str(exc)}"
        )
        raise