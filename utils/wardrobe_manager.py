import os
import shutil

from config import WARDROBE_FILE

from utils.json_utils import (
    load_json,
    save_json
)

from agents.wardrobe_agent import (
    analyze_wardrobe_folder,
    analyze_wardrobe_item
)


# Folder that stores wardrobe images
WARDROBE_IMAGE_FOLDER = "wardrobe"


# ==========================================================
# Build wardrobe database
# ==========================================================

def build_wardrobe_database(folder_path: str):
    """
    Scan wardrobe folder and rebuild wardrobe.json.

    Saves after every successful item so that
    API failures do not destroy progress.
    """

    print("[INFO] Scanning wardrobe folder...")


    # Scan folder safely
    try:

        wardrobe_items = analyze_wardrobe_folder(
            folder_path
        )

    except Exception as e:

        print(
            f"[ERROR] Unable to scan wardrobe folder: {str(e)}"
        )

        return []


    wardrobe = []


    image_extensions = [
        ".jpg",
        ".jpeg",
        ".png",
        ".webp"
    ]


    for index, item in enumerate(
        wardrobe_items,
        start=1
    ):

        try:

            print(
                f"[INFO] Processing {index}/{len(wardrobe_items)} : {item.id_baju}"
            )


            image_url = None


            for ext in image_extensions:

                possible = os.path.join(
                    folder_path,
                    item.id_baju + ext
                )


                if os.path.exists(possible):

                    image_url = (
                        "/clothes/"
                        + os.path.basename(possible)
                    )

                    break


            item = item.model_copy(
                update={
                    "image_path": image_url
                }
            )


            wardrobe.append(
                item.model_dump()
            )


            # Save immediately after success
            save_json(
                wardrobe,
                WARDROBE_FILE
            )


            print(
                f"[SUCCESS] Saved {item.id_baju}"
            )


        except Exception as e:


            print(
                f"[WARNING] Skipping {item.id_baju}"
            )


            print(
                f"[ERROR] {str(e)}"
            )


            continue



    print(
        "[INFO] Wardrobe database rebuild completed."
    )


    print(
        f"[INFO] Total items saved: {len(wardrobe)}"
    )


    return wardrobe




# ==========================================================
# Add wardrobe item
# ==========================================================

def add_wardrobe_item(image_path: str):
    """
    Analyze one clothing image and add/update it
    in wardrobe.json.
    """

    wardrobe = load_json(
        WARDROBE_FILE
    )


    if wardrobe is None:

        wardrobe = []


    os.makedirs(
        WARDROBE_IMAGE_FOLDER,
        exist_ok=True
    )


    filename = os.path.basename(
        image_path
    )


    destination = os.path.join(
        WARDROBE_IMAGE_FOLDER,
        filename
    )


    if os.path.abspath(image_path) != os.path.abspath(destination):

        shutil.copy(
            image_path,
            destination
        )


    item = analyze_wardrobe_item(
        destination
    )


    item = item.model_copy(
        update={
            "id_baju": os.path.splitext(filename)[0],
            "image_path": "/clothes/" + filename
        }
    )


    # Remove old version if exists

    wardrobe = [

        cloth
        for cloth in wardrobe
        if cloth["id_baju"] != item.id_baju

    ]


    wardrobe.append(
        item.model_dump()
    )


    save_json(
        wardrobe,
        WARDROBE_FILE
    )


    print(
        "[INFO] Wardrobe item added/updated."
    )


    return wardrobe




# ==========================================================
# Delete wardrobe item
# ==========================================================

def remove_wardrobe_item(item_id: str):
    """
    Remove wardrobe item and delete its image.
    """

    wardrobe = load_json(
        WARDROBE_FILE
    )


    if wardrobe is None:

        return []


    item_to_remove = None


    for item in wardrobe:


        if item["id_baju"] == item_id:

            item_to_remove = item

            break



    if item_to_remove is None:

        return wardrobe



    image_url = item_to_remove.get(
        "image_path"
    )


    if image_url:


        image_file = image_url.replace(
            "/clothes/",
            ""
        )


        image_path = os.path.join(
            WARDROBE_IMAGE_FOLDER,
            image_file
        )


        if os.path.exists(image_path):

            os.remove(
                image_path
            )


            print(
                f"[INFO] Deleted image {image_path}"
            )



    wardrobe = [

        item
        for item in wardrobe
        if item["id_baju"] != item_id

    ]


    save_json(
        wardrobe,
        WARDROBE_FILE
    )


    print(
        f"[INFO] Removed {item_id}"
    )


    return wardrobe




# ==========================================================
# Get complete wardrobe
# ==========================================================

def list_wardrobe():

    wardrobe = load_json(
        WARDROBE_FILE
    )


    if wardrobe is None:

        return []


    return wardrobe




# ==========================================================
# Filter wardrobe by category
# ==========================================================

def get_items_by_category(category: str):

    wardrobe = load_json(
        WARDROBE_FILE
    )


    if wardrobe is None:

        return []


    return [

        item
        for item in wardrobe
        if item["category"].lower() == category.lower()

    ]