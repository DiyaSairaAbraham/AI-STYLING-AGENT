#MODULE 1
from pydantic import BaseModel, Field
from typing import List, Optional

#USER FEATURES
class UserFeatures(BaseModel):
    gender: str = Field(description="User's presentation style or gender expression")
    skin_tone: str = Field(description="Skin tone or color palette context")
    hairstyle: str = Field(description="Hair style description")
    body_type: str = Field(description="Body silhouette description")
    facial_features: str = Field(description="General facial feature description")

#CURRENT OUTFIT
class CurrentOutfit(BaseModel):
    top: str
    bottom: str
    shoes: Optional[str] = None 
    accessories: Optional[str] = None
#OUTFIT ANALYSIS

class OutfitAnalysis(BaseModel):
    advantages: List[str] = Field(description="Exactly 2 advantages")
    areas_for_improvement: List[str] = Field(description="Exactly 2 improvements")

#MODULE 1 OUTPUT

class Module1Output(BaseModel):
    user_features: UserFeatures
    current_outfit: CurrentOutfit
    analysis: OutfitAnalysis

# MODULE 2- WARDROBE TAGGING
class WardrobeItemTags(BaseModel):
    id_baju: str | None = None

    image_path: str | None = None

    category: str
    sub_category: str
    color: str
    material: str
    fit: str
    style: str
    pattern: str
    formality_level: str
    suitable_occasions: List[str]

#MODULE 3 -STYLIST OUTPUT

class SelectedWardrobeItem(BaseModel):
    id_baju: str
    description: str

class ShoppingLinks(BaseModel):
    hm: str
    uniqlo: str

class OutfitRecommendation(BaseModel):
    category: str = Field(
        description="Outfit style category, for example Business Formal, Smart Casual, Weekend Casual"
    )

    selected_items: List[SelectedWardrobeItem] = Field(
        description="Wardrobe items selected for this outfit"
    )

    styling_advice: str = Field(
        description="Explanation of why this outfit suits the user"
    )

    image_generation_prompt: str = Field(
        description="Detailed prompt for generating the outfit image"
    )

    shopping_links: Optional[ShoppingLinks] = None



class Module3Output(BaseModel):
    recommendations: List[OutfitRecommendation] = Field(
        description="Exactly 3 outfit recommendations"
    )
#Module4 output
class GeneratedImageOutput(BaseModel):
    outfit_category: str
    image_path: str