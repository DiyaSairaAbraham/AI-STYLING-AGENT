from fastapi import APIRouter, UploadFile, File, HTTPException
import os
import shutil

from agents.vision_agent import analyze_user_image
from agents.stylist_agent import generate_style_recommendation
from utils.wardrobe_manager import build_wardrobe_database
from agents.shopping_agent import create_search_links
router = APIRouter(
    prefix="/recommendation",
    tags=["Recommendation Options"]
)

UPLOAD_DIR = "uploads"


@router.post("/options")
async def generate_options(user_image: UploadFile = File(...)):
    try:
        # Create uploads folder if it doesn't exist
        os.makedirs(UPLOAD_DIR, exist_ok=True)

        # Save uploaded image
        image_path = os.path.join(UPLOAD_DIR, user_image.filename)

        with open(image_path, "wb") as buffer:
            shutil.copyfileobj(user_image.file, buffer)

        print("[INFO] Running fast recommendation flow")

        # Module 1: Vision Agent
        user_profile = analyze_user_image(image_path)

        # Module 2: Wardrobe Agent
        wardrobe_data = build_wardrobe_database("wardrobe")

        # Module 3: Stylist Agent only (NO image generation)
        recommendations = generate_style_recommendation(
            user_profile,
            wardrobe_data
        )
        # Module 4: Shopping Agent
        for outfit in recommendations.recommendations:
            outfit.shopping_links = create_search_links(outfit)

        return {
            "status": "success",
            "message": "Outfit options generated",
            "data": recommendations
        }

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )