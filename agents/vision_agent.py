from openai import OpenAI

from config import OPENAI_API_KEY, VISION_MODEL
from schemas.models import Module1Output
from utils.image_utils import encode_image
from utils.logger import log


client = OpenAI(
    api_key=OPENAI_API_KEY
)


VISION_PROMPT = """
You are a top-tier fashion stylist and visual analyst.

Analyze the user's full-body image carefully.

Return structured JSON ONLY with:

1. user_features:
- gender
- skin_tone
- hairstyle
- body_type
- facial_features

2. current_outfit:
- top
- bottom
- shoes
- accessories

3. analysis:
- 2 advantages
- 2 areas for improvement

Be precise and consistent.
"""


def analyze_user_image(
        image_path: str
) -> Module1Output:


    log("Running Vision Agent (Module 1)")


    base64_image = encode_image(
        image_path
    )


    response = client.beta.chat.completions.parse(

        model=VISION_MODEL,

        messages=[
            {
                "role": "user",
                "content":[

                    {
                        "type":"text",
                        "text":VISION_PROMPT
                    },

                    {
                        "type":"image_url",
                        "image_url":{
                            "url":
                            f"data:image/jpeg;base64,{base64_image}"
                        }
                    }
                ]
            }
        ],

        response_format=Module1Output
    )


    result = (
        response
        .choices[0]
        .message
        .parsed
    )


    log("Vision analysis completed successfully")


    return result