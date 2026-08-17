from openai import OpenAI

from config import OPENAI_API_KEY, VISION_MODEL
from schemas.models import Module1Output
from utils.image_utils import encode_image
from utils.logger import log


client = OpenAI(
    api_key=OPENAI_API_KEY
)





def analyze_user_image(
        image_path: str,
        style_type: str
) -> Module1Output:


    log("Running Vision Agent (Module 1)")

    prompt = f"""
You are a top-tier fashion stylist and visual analyst.

The user selected this style:

{style_type.upper()}

Analyze the user's image according to this selected style.

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

4. comments:
A short styling recommendation based on the selected style.
"""

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
                        "text":prompt
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