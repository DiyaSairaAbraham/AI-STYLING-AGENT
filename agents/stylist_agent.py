from openai import OpenAI

from config import OPENAI_API_KEY, STYLIST_MODEL
from schemas.models import Module3Output
from utils.logger import log

import json


client = OpenAI(
    api_key=OPENAI_API_KEY
)



def generate_style_recommendation(
        module1_data,
        wardrobe_items: list
):


    log(
        "Running Stylist Agent (Module 3)"
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




    context_prompt = f"""

You are a professional fashion stylist AI.

You will be given:

1. User body + outfit analysis from Module 1.
2. Complete wardrobe database from Module 2.


TASK:

Create EXACTLY 3 outfit recommendations.


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
- Maintain user's identity.
- Maintain hairstyle, skin tone and body proportions.


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
                    "role":"user",
                    "content":context_prompt
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
            "Three outfit recommendations completed"
        )


        return result



    except Exception as e:


        log(
            f"Stylist agent failed: {str(e)}"
        )

        raise e