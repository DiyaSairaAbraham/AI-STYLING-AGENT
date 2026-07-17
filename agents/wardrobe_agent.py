from openai import OpenAI

from schemas.models import WardrobeItemTags
from config import OPENAI_API_KEY, WARDROBE_MODEL
from utils.logger import log

import base64
import os
import mimetypes


client = OpenAI(
    api_key=OPENAI_API_KEY
)



def analyze_wardrobe_item(
        image_path: str
) -> WardrobeItemTags:


    log(
        f"Analyzing clothing item: {image_path}"
    )


    with open(
        image_path,
        "rb"
    ) as f:

        base64_image = base64.b64encode(
            f.read()
        ).decode("utf-8")



    mime_type, _ = mimetypes.guess_type(
        image_path
    )


    if mime_type is None:
        mime_type = "image/jpeg"



    completion = client.beta.chat.completions.parse(

        model=WARDROBE_MODEL,

        messages=[
            {
                "role":"user",

                "content":[

                    {
                        "type":"text",
                        "text":
                        """
                        Analyze this clothing item.

                        Identify:

                        - category
                        - sub_category
                        - color
                        - material
                        - fit
                        - style
                        - pattern
                        - formality_level
                        - suitable_occasions

                        Return fashion metadata only.
                        """
                    },

                    {
                        "type":"image_url",

                        "image_url":{
                            "url":
                            f"data:{mime_type};base64,{base64_image}"
                        }
                    }
                ]
            }
        ],

        response_format=WardrobeItemTags
    )


    result = (
        completion
        .choices[0]
        .message
        .parsed
    )


    log(
        "Clothing analysis completed"
    )


    return result





def analyze_wardrobe_folder(
        folder_path:str
):


    log(
        "Scanning wardrobe folder"
    )


    wardrobe=[]


    valid_extensions=(
        ".jpg",
        ".jpeg",
        ".png",
        ".webp"
    )


    if not os.path.exists(folder_path):

        raise FileNotFoundError(
            f"Wardrobe folder not found: {folder_path}"
        )


    for filename in os.listdir(folder_path):


        if filename.lower().endswith(
            valid_extensions
        ):


            image_path=os.path.join(
                folder_path,
                filename
            )


            log(
                f"Processing {filename}"
            )


            item=analyze_wardrobe_item(
                image_path
            )


            item=item.model_copy(
                update={
                    "id_baju":
                    os.path.splitext(filename)[0]
                }
            )


            wardrobe.append(
                item
            )


    log(
        f"{len(wardrobe)} clothing items analyzed"
    )


    return wardrobe