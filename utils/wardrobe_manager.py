from __future__ import annotations

import os
import shutil
from typing import Any

from PIL import Image

from config import WARDROBE_FILE

from utils.json_utils import (
    load_json,
    save_json,
)

from agents.wardrobe_agent import (
    analyze_wardrobe_folder,
    analyze_wardrobe_item,
)


# ==========================================================
# Folders
# ==========================================================

# Original clothing images used by the AI pipeline.
WARDROBE_IMAGE_FOLDER = "wardrobe"

# Small compressed images used only by the Flutter UI.
WARDROBE_THUMBNAIL_FOLDER = "wardrobe_thumbnails"


# ==========================================================
# Thumbnail configuration
# ==========================================================

# The Flutter wardrobe grid does not need large images.
# Keeping these small significantly reduces Android GPU memory use.
THUMBNAIL_MAX_WIDTH = 300
THUMBNAIL_MAX_HEIGHT = 400

# JPEG quality for UI thumbnails.
THUMBNAIL_QUALITY = 70


# ==========================================================
# Create wardrobe thumbnail
# ==========================================================

def create_wardrobe_thumbnail(
    image_path: str,
    item_id: str,
) -> str:
    """
    Create a small compressed JPEG thumbnail for the Flutter UI.

    The original wardrobe image is never modified.
    """

    os.makedirs(
        WARDROBE_THUMBNAIL_FOLDER,
        exist_ok=True,
    )

    thumbnail_filename = f"{item_id}.jpg"

    thumbnail_path = os.path.join(
        WARDROBE_THUMBNAIL_FOLDER,
        thumbnail_filename,
    )

    try:
        with Image.open(image_path) as source_image:
            image = source_image.convert("RGB")

            image.thumbnail(
                (
                    THUMBNAIL_MAX_WIDTH,
                    THUMBNAIL_MAX_HEIGHT,
                ),
                Image.Resampling.LANCZOS,
            )

            image.save(
                thumbnail_path,
                format="JPEG",
                quality=THUMBNAIL_QUALITY,
                optimize=True,
                progressive=True,
            )

        print(
            f"[INFO] Thumbnail created: {thumbnail_path}"
        )

        return thumbnail_path

    except Exception as e:
        print(
            f"[ERROR] Unable to create thumbnail "
            f"for {image_path}: {str(e)}"
        )
        raise


# ==========================================================
# Build wardrobe database
# ==========================================================

def build_wardrobe_database(
    folder_path: str,
) -> list[dict[str, Any]]:
    """
    Scan the wardrobe folder and rebuild wardrobe.json.

    The original clothing images remain untouched.
    Only small thumbnails are generated for Flutter.
    """

    print("[INFO] Scanning wardrobe folder...")

    try:
        wardrobe_items = analyze_wardrobe_folder(
            folder_path
        )

    except Exception as e:
        print(
            f"[ERROR] Unable to scan wardrobe folder: {str(e)}"
        )
        return []

    wardrobe: list[dict[str, Any]] = []

    image_extensions = [
        ".jpg",
        ".jpeg",
        ".png",
        ".webp",
    ]

    for index, item in enumerate(
        wardrobe_items,
        start=1,
    ):
        try:
            print(
                f"[INFO] Processing "
                f"{index}/{len(wardrobe_items)} : "
                f"{item.id_baju}"
            )

            image_path: str | None = None

            for ext in image_extensions:
                possible_path = os.path.join(
                    folder_path,
                    item.id_baju + ext,
                )

                if os.path.exists(possible_path):
                    image_path = possible_path
                    break

            if image_path is None:
                print(
                    f"[WARNING] Image not found for "
                    f"{item.id_baju}"
                )
                continue

            thumbnail_path = create_wardrobe_thumbnail(
                image_path=image_path,
                item_id=item.id_baju,
            )

            item = item.model_copy(
                update={
                    # Original image remains available to the AI pipeline.
                    "image_path": (
                        "/clothes/"
                        + os.path.basename(image_path)
                    ),

                    # Flutter uses only the small thumbnail.
                    "thumbnail_path": (
                        "/clothes-thumbnails/"
                        + os.path.basename(thumbnail_path)
                    ),
                }
            )

            wardrobe.append(
                item.model_dump()
            )

            save_json(
                wardrobe,
                WARDROBE_FILE,
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

def add_wardrobe_item(
    image_path: str,
) -> list[dict[str, Any]]:
    """
    Analyze one clothing image and add/update it in wardrobe.json.
    """

    wardrobe = load_json(
        WARDROBE_FILE
    )

    if wardrobe is None:
        wardrobe = []

    os.makedirs(
        WARDROBE_IMAGE_FOLDER,
        exist_ok=True,
    )

    filename = os.path.basename(
        image_path
    )

    destination = os.path.join(
        WARDROBE_IMAGE_FOLDER,
        filename,
    )

    if (
        os.path.abspath(image_path)
        != os.path.abspath(destination)
    ):
        shutil.copy2(
            image_path,
            destination,
        )

    item = analyze_wardrobe_item(
        destination
    )

    item_id = os.path.splitext(
        filename
    )[0]

    thumbnail_path = create_wardrobe_thumbnail(
        image_path=destination,
        item_id=item_id,
    )

    item = item.model_copy(
        update={
            "id_baju": item_id,

            # Original image for AI processing.
            "image_path": (
                "/clothes/"
                + filename
            ),

            # Small image for Flutter.
            "thumbnail_path": (
                "/clothes-thumbnails/"
                + os.path.basename(thumbnail_path)
            ),
        }
    )

    # Remove the previous database entry with the same ID.
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
        WARDROBE_FILE,
    )

    print(
        "[INFO] Wardrobe item added/updated."
    )

    return wardrobe


# ==========================================================
# Delete wardrobe item
# ==========================================================

def remove_wardrobe_item(
    item_id: str,
) -> list[dict[str, Any]]:
    """
    Remove a personal wardrobe item,
    its original image, and its thumbnail.
    """

    wardrobe = load_json(
        WARDROBE_FILE
    )

    if wardrobe is None:
        return []

    item_to_remove: dict[str, Any] | None = None

    for item in wardrobe:
        if item["id_baju"] == item_id:
            item_to_remove = item
            break

    if item_to_remove is None:
        return wardrobe

    # ======================================================
    # Delete original image
    # ======================================================

    image_url = item_to_remove.get(
        "image_path"
    )

    if image_url:
        image_file = image_url.replace(
            "/clothes/",
            "",
        )

        image_path = os.path.join(
            WARDROBE_IMAGE_FOLDER,
            image_file,
        )

        if os.path.exists(image_path):
            os.remove(image_path)

            print(
                f"[INFO] Deleted image {image_path}"
            )

    # ======================================================
    # Delete thumbnail
    # ======================================================

    thumbnail_url = item_to_remove.get(
        "thumbnail_path"
    )

    if thumbnail_url:
        thumbnail_file = thumbnail_url.replace(
            "/clothes-thumbnails/",
            "",
        )

        thumbnail_path = os.path.join(
            WARDROBE_THUMBNAIL_FOLDER,
            thumbnail_file,
        )

        if os.path.exists(thumbnail_path):
            os.remove(thumbnail_path)

            print(
                f"[INFO] Deleted thumbnail "
                f"{thumbnail_path}"
            )

    # ======================================================
    # Remove database entry
    # ======================================================

    wardrobe = [
        item
        for item in wardrobe
        if item["id_baju"] != item_id
    ]

    save_json(
        wardrobe,
        WARDROBE_FILE,
    )

    print(
        f"[INFO] Removed {item_id}"
    )

    return wardrobe


# ==========================================================
# Get complete personal wardrobe
# ==========================================================

def list_wardrobe() -> list[dict[str, Any]]:
    """
    Return the existing personal wardrobe database.

    This does not rebuild or re-analyze the wardrobe.
    """

    wardrobe = load_json(
        WARDROBE_FILE
    )

    if wardrobe is None:
        return []

    return wardrobe


# ==========================================================
# Filter wardrobe by category
# ==========================================================

def get_items_by_category(
    category: str,
) -> list[dict[str, Any]]:
    """
    Return personal wardrobe items matching a category.
    """

    wardrobe = load_json(
        WARDROBE_FILE
    )

    if wardrobe is None:
        return []

    return [
        item
        for item in wardrobe
        if item["category"].lower()
        == category.lower()
    ]