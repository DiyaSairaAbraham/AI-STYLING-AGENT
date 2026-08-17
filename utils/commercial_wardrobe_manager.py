import os

from config import (
    COMMERCIAL_DIR,
    COMMERCIAL_WARDROBE_FILE
)

from utils.json_utils import (
    load_json,
    save_json
)

from agents.wardrobe_agent import (
    analyze_wardrobe_item
)


def build_commercial_wardrobe_database():

    print("[INFO] Building commercial wardrobe database")

    wardrobe = []

    valid_extensions = (
        ".jpg",
        ".jpeg",
        ".png",
        ".webp"
    )

    for filename in os.listdir(COMMERCIAL_DIR):

        if not filename.lower().endswith(valid_extensions):
            continue

        image_path = os.path.join(
            COMMERCIAL_DIR,
            filename
        )

        try:

            item = analyze_wardrobe_item(
                image_path
            )

            item = item.model_copy(
                update={
                    "id_baju":
                    os.path.splitext(filename)[0],

                    "image_path":
                    "/commercial/" + filename
                }
            )

            wardrobe.append(
                item.model_dump()
            )

            print(
                f"[SUCCESS] {filename}"
            )

        except Exception as e:

            print(
                f"[ERROR] {filename}: {str(e)}"
            )

    save_json(
        wardrobe,
        COMMERCIAL_WARDROBE_FILE
    )

    print(
        f"[INFO] Saved {len(wardrobe)} commercial items"
    )

    return wardrobe


def list_commercial_wardrobe():

    wardrobe = load_json(
        COMMERCIAL_WARDROBE_FILE
    )

    if wardrobe is None:
        return []

    return wardrobe