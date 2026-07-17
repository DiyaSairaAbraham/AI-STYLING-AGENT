from utils.json_utils import load_json, save_json
from agents.wardrobe_agent import (
    analyze_wardrobe_folder,
    analyze_wardrobe_item
)

import os

from config import WARDROBE_FILE


def build_wardrobe_database(folder_path: str):
    """
    Load wardrobe database if it exists.
    Otherwise scan wardrobe folder once.
    """

    wardrobe = load_json(WARDROBE_FILE)

    if wardrobe is not None:
        print("[INFO] Existing wardrobe database found.")
        return wardrobe

    print("[INFO] No wardrobe database found. Scanning wardrobe...")

    wardrobe_items = analyze_wardrobe_folder(folder_path)

    wardrobe = [
        item.model_dump()
        for item in wardrobe_items
    ]

    save_json(
        wardrobe,
        WARDROBE_FILE
    )

    print("[INFO] Wardrobe database created.")

    return wardrobe


def add_wardrobe_item(image_path: str):
    """
    Analyze one clothing item and append it to wardrobe.json.
    """

    wardrobe = load_json(WARDROBE_FILE)

    if wardrobe is None:
        wardrobe = []

    print(f"[INFO] Adding wardrobe item: {image_path}")

    item = analyze_wardrobe_item(image_path)

    filename = os.path.basename(image_path)

    item = item.model_copy(
        update={
            "id_baju": os.path.splitext(filename)[0]
        }
)

    existing = next(
        (
            cloth
            for cloth in wardrobe
            if cloth["id_baju"] == item.id_baju
        ),
        None
    )

    if existing:
        print(f"[INFO] {item.id_baju} already exists.")
        return wardrobe

    wardrobe.append(
        item.model_dump()
    )

    save_json(
        wardrobe,
        WARDROBE_FILE
    )

    print("[INFO] Wardrobe item added successfully.")

    return wardrobe


def remove_wardrobe_item(item_id: str):
    """
    Remove clothing item from wardrobe.json.
    """

    wardrobe = load_json(WARDROBE_FILE)

    if wardrobe is None:
        print("[WARNING] No wardrobe database found.")
        return []

    updated = [
        item
        for item in wardrobe
        if item["id_baju"] != item_id
    ]

    if len(updated) == len(wardrobe):
        print(f"[WARNING] {item_id} not found.")
        return wardrobe

    save_json(
        updated,
        WARDROBE_FILE
    )

    print(f"[INFO] Removed {item_id}")

    return updated


def list_wardrobe():
    """
    Return all wardrobe items.
    """

    wardrobe = load_json(WARDROBE_FILE)

    if wardrobe is None:
        return []

    return wardrobe


def get_items_by_category(category: str):
    """
    Return wardrobe items of a given category.
    """

    wardrobe = load_json(WARDROBE_FILE)

    if wardrobe is None:
        return []

    return [
        item
        for item in wardrobe
        if item["category"].lower() == category.lower()
    ]