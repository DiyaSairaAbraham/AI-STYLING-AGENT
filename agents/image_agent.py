from openai import OpenAI

from config import OPENAI_API_KEY, IMAGE_MODEL
from utils.logger import log

import base64
import os


client = OpenAI(
    api_key=OPENAI_API_KEY
)



def generate_outfit_image(
        prompt: str,
        user_image_path: str,
        output_path="outputs/images/recommended_outfit.png"
):

    log(
        "Running Image Generator (Module 4)"
    )


    try:

        output_dir = os.path.dirname(
            output_path
        )


        if output_dir:

            os.makedirs(
                output_dir,
                exist_ok=True
            )


        with open(
            user_image_path,
            "rb"
        ) as image_file:


            response = client.images.edit(

                model=IMAGE_MODEL,

                image=[
                    image_file
                ],

                prompt=prompt,

                size="1024x1536"
            )



        if not response.data:

            raise Exception(
                "Image generation returned empty response"
            )



        image_base64 = response.data[0].b64_json



        with open(
            output_path,
            "wb"
        ) as f:

            f.write(
                base64.b64decode(
                    image_base64
                )
            )



        log(
            f"Image saved to {output_path}"
        )


        return output_path



    except Exception as e:

        log(
            f"Image generation failed: {str(e)}"
        )

        raise e