from typing import List, Optional

from pydantic import BaseModel, Field, field_validator


# ============================================================
# MODULE 1 - USER ANALYSIS
# ============================================================


class UserFeatures(BaseModel):
    gender: str = Field(
        description=(
            "User's presentation style or visually observable "
            "gender presentation"
        )
    )

    skin_tone: str = Field(
        description=(
            "Visually observed skin tone or color palette context"
        )
    )

    hairstyle: str = Field(
        description=(
            "Visible hairstyle and hair color description"
        )
    )

    body_type: str = Field(
        description=(
            "General visible body silhouette or proportions"
        )
    )

    facial_features: str = Field(
        description=(
            "General visually observable facial features"
        )
    )


class CurrentOutfit(BaseModel):
    top: str = Field(
        description="Description of the currently worn top"
    )

    bottom: str = Field(
        description="Description of the currently worn bottom"
    )

    shoes: Optional[str] = Field(
        default=None,
        description="Description of the currently worn shoes"
    )

    accessories: Optional[str] = Field(
        default=None,
        description="Description of visible accessories"
    )


class OutfitAnalysis(BaseModel):
    advantages: List[str] = Field(
        description=(
            "Exactly 2 aspects of the user's current appearance "
            "or styling that are already advantageous"
        )
    )

    areas_for_improvement: List[str] = Field(
        description=(
            "Exactly 2 specific areas where the user's styling "
            "could be improved"
        )
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

# Kept untouched conceptually for Function 2.
# Function 1 does NOT use this model.


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
# FUNCTION 1 - SHOPPING LINKS
# ============================================================


class ShoppingItemLink(BaseModel):
    description: str = Field(
        description=(
            "Description of a clothing item for which "
            "similar products can be searched"
        )
    )

    hm: Optional[str] = Field(
        default=None,
        description="H&M shopping/search link"
    )

    uniqlo: Optional[str] = Field(
        default=None,
        description="UNIQLO shopping/search link"
    )


class ShoppingLinks(BaseModel):
    items: List[ShoppingItemLink] = Field(
        default_factory=list,
        description=(
            "H&M and UNIQLO search links for similar "
            "products in the generated outfit"
        )
    )


# ============================================================
# MODULE 3 - STYLIST OUTPUT
# ============================================================


class OutfitRecommendation(BaseModel):
    category: str = Field(
        description=(
            "Outfit category: Business Formal or Smart Casual"
        )
    )

    shopping_items: List[str] = Field(
        default_factory=list,
        description=(
            "Concise descriptions of individual garments, "
            "accessories or footwear that can be searched "
            "for similar products"
        )
    )

    styling_advice: str = Field(
        description=(
            "Detailed explanation of why the outfit suits "
            "the user, including the advantages and "
            "improvement areas"
        )
    )

    image_generation_prompt: str = Field(
        description=(
            "Detailed prompt for generating the personalized "
            "outfit image"
        )
    )

    shopping_links: Optional[ShoppingLinks] = Field(
        default=None,
        description=(
            "Shopping links for similar products"
        )
    )


class Module3Output(BaseModel):
    recommendations: List[OutfitRecommendation] = Field(
        description=(
            "Exactly 2 recommendations: "
            "Business Formal and Smart Casual"
        )
    )

    @field_validator("recommendations")
    @classmethod
    def validate_recommendations(
        cls,
        value: List[OutfitRecommendation],
    ) -> List[OutfitRecommendation]:

        if len(value) != 2:
            raise ValueError(
                "Module 3 must contain exactly 2 recommendations."
            )

        categories = {
            recommendation.category
            for recommendation in value
        }

        expected_categories = {
            "Business Formal",
            "Smart Casual",
        }

        if categories != expected_categories:
            raise ValueError(
                "Recommendations must contain exactly "
                "Business Formal and Smart Casual."
            )

        return value


# ============================================================
# MODULE 4 - IMAGE GENERATION OUTPUT
# ============================================================


class GeneratedImageOutput(BaseModel):
    outfit_category: str

    image_path: str