from typing import List, Optional

from pydantic import BaseModel, Field, field_validator


# ============================================================
# MODULE 1 - USER ANALYSIS
# ============================================================


class UserFeatures(BaseModel):
    gender: str = Field(
        description="Visually observable gender/presentation style."
    )

    skin_tone: str = Field(
        description="Visually observed skin tone."
    )

    hairstyle: str = Field(
        description="Visible hairstyle and hair color."
    )

    body_type: str = Field(
        description="General visible body silhouette or proportions."
    )

    facial_features: str = Field(
        description="General visually observable facial features."
    )


class CurrentOutfit(BaseModel):
    top: str = Field(
        description="Description of the currently worn top."
    )

    bottom: str = Field(
        description="Description of the currently worn bottom."
    )

    shoes: Optional[str] = Field(
        default=None,
        description="Description of the currently worn shoes."
    )

    accessories: Optional[str] = Field(
        default=None,
        description="Description of visible accessories."
    )


class OutfitAnalysis(BaseModel):
    advantages: List[str] = Field(
        description="Exactly 2 current styling advantages."
    )

    areas_for_improvement: List[str] = Field(
        description="Exactly 2 areas for improvement."
    )

    @field_validator(
        "advantages",
        "areas_for_improvement",
    )
    @classmethod
    def validate_exactly_two(
        cls,
        value: List[str],
    ) -> List[str]:
        if len(value) != 2:
            raise ValueError(
                "This field must contain exactly 2 items."
            )

        return value


class Module1Output(BaseModel):
    user_features: UserFeatures
    current_outfit: CurrentOutfit
    analysis: OutfitAnalysis


# ============================================================
# MODULE 2 - WARDROBE TAGGING
# ============================================================


class WardrobeItemTags(BaseModel):
    id_baju: Optional[str] = None

    image_path: Optional[str] = None

    category: str

    sub_category: str

    color: str

    material: str

    fit: str

    style: str

    pattern: str

    formality_level: str

    suitable_occasions: List[str]


# ============================================================
# SHOPPING LINKS - FUNCTION 1
# ============================================================


class ShoppingItemLink(BaseModel):
    description: str

    hm: Optional[str] = None

    uniqlo: Optional[str] = None


class ShoppingLinks(BaseModel):
    items: List[ShoppingItemLink] = Field(
        default_factory=list
    )


# ============================================================
# FUNCTION 1 - AI STYLING
# ============================================================


class AIStylingRecommendation(BaseModel):
    style_name: str = Field(
        description=(
            "A concise name for the AI-generated outfit."
        )
    )

    shopping_items: List[str] = Field(
        default_factory=list,
        description=(
            "Concise descriptions of garments, footwear "
            "and accessories that can be searched online."
        )
    )

    styling_advice: str = Field(
        description=(
            "Explanation of why the AI-generated outfit "
            "suits the user."
        )
    )

    image_generation_prompt: str = Field(
        description=(
            "Detailed prompt for generating the final "
            "personalized outfit image."
        )
    )

    shopping_links: Optional[ShoppingLinks] = None


class Function1Output(BaseModel):
    recommendation: AIStylingRecommendation


# ============================================================
# FUNCTION 2 - WARDROBE STYLING
# ============================================================


class WardrobeOutfitRecommendation(BaseModel):
    style_name: str = Field(
        description="Name of the generated wardrobe outfit."
    )

    selected_item_ids: List[str] = Field(
        description=(
            "IDs of wardrobe items used in the outfit. "
            "Every ID must come from the provided wardrobe."
        )
    )

    styling_advice: str = Field(
        description=(
            "Explanation of how the selected wardrobe items "
            "work together for the user."
        )
    )

    image_generation_prompt: str = Field(
        description=(
            "Detailed prompt for generating the final image "
            "using only the selected wardrobe items."
        )
    )


class Function2Output(BaseModel):
    wardrobe_source: str

    recommendation: WardrobeOutfitRecommendation


# ============================================================
# GENERATED IMAGE
# ============================================================


class GeneratedImageOutput(BaseModel):
    outfit_category: str
    image_path: str