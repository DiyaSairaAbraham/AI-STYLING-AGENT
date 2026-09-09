import json
import random
from typing import Any

from openai import OpenAI

from config import OPENAI_API_KEY, STYLIST_MODEL
from schemas.models import Module3Output
from utils.logger import log
from utils.outfit_history import (
    get_outfit_history_for_stylist,
    save_generated_outfit,
)


client = OpenAI(
    api_key=OPENAI_API_KEY
)


def generate_style_recommendation(
    module1_data: Any,
    wardrobe_items: list,
    style_type: str,
    wardrobe_source: str,
    selected_item_ids: list[str] | None = None,
) -> Module3Output:

    log("Running Stylist Agent (Module 3)")

    selected_item_ids = selected_item_ids or []

    variation_seed = random.randint(
        1000,
        9999,
    )

    if hasattr(
        module1_data,
        "model_dump",
    ):
        module1_data = module1_data.model_dump()

    wardrobe_data: list[dict[str, Any]] = []

    for item in wardrobe_items:
        if hasattr(
            item,
            "model_dump",
        ):
            wardrobe_data.append(
                item.model_dump()
            )
        elif isinstance(
            item,
            dict,
        ):
            wardrobe_data.append(item)

    # ----------------------------------------------------
    # Load previous outfit history
    # ----------------------------------------------------

    previous_outfits = get_outfit_history_for_stylist(
        style_type=style_type,
        wardrobe_source=wardrobe_source,
    )

    log(
        "Previous outfits found: "
        f"{len(previous_outfits)}"
    )

    # ----------------------------------------------------
    # Separate explicitly selected items
    # ----------------------------------------------------

    selected_items = [
        item
        for item in wardrobe_data
        if str(item.get("id_baju", ""))
        in {
            str(item_id)
            for item_id in selected_item_ids
        }
    ]

    selected_ids_found = {
        str(item.get("id_baju"))
        for item in selected_items
        if item.get("id_baju")
    }

    missing_selected_ids = [
        str(item_id)
        for item_id in selected_item_ids
        if str(item_id) not in selected_ids_found
    ]

    optional_wardrobe = [
        item
        for item in wardrobe_data
        if str(item.get("id_baju", ""))
        not in selected_ids_found
    ]

    random.shuffle(optional_wardrobe)

    # ----------------------------------------------------
    # Style rules
    # ----------------------------------------------------

    if style_type.lower() == "formal":

        category_instruction = """
Create EXACTLY 1 outfit recommendation.

STYLE RULES:

- ONLY formal and business outfits.
- The outfit should be appropriate for formal,
  professional, or business occasions.
- Blazers are allowed.
- Dress shirts are allowed.
- Tailored trousers are allowed.
- Formal shoes are allowed.
- Dresses are allowed.

NEVER generate:

- Weekend Casual
- Smart Casual
- Streetwear
- Resort Wear
- Vacation Looks
- Relaxed Casual Looks
"""

    elif style_type.lower() == "leisure":

        category_instruction = """
Create EXACTLY 1 outfit recommendation.

STYLE RULES:

- ONLY leisure and casual outfits.
- The outfit should be appropriate for relaxed,
  everyday, weekend, or casual occasions.
- T-shirts are allowed.
- Polo shirts are allowed.
- Casual shirts are allowed.
- Jeans are allowed.
- Chinos are allowed.
- Sneakers are allowed.
- Dresses are allowed.

NEVER generate:

- Business Formal
- Smart Business
- Suit Looks
- Office Looks
- Formal Blazers
- Formal Trousers
- Business Attire
"""

    else:

        category_instruction = """
Create EXACTLY 1 outfit recommendation.

Follow the selected style strictly.
"""

    # ----------------------------------------------------
    # Wardrobe source
    # ----------------------------------------------------

    if wardrobe_source.lower() == "open_world":

        wardrobe_section = """
OPEN WORLD / AI STYLING MODE

The user does not have a restricted wardrobe.

Create the outfit freely using fashion knowledge.

Do not use wardrobe item IDs.

Do not pretend invented clothing items belong
to the user's personal wardrobe.

Generate realistic clothing descriptions directly.
"""

    elif wardrobe_source.lower() == "commercial":

        wardrobe_section = f"""
COMMERCIAL WARDROBE MODE

The following clothing items are available:

{json.dumps(
    wardrobe_data,
    indent=2,
    ensure_ascii=False,
)}

Use only appropriate available commercial items.

Never invent a commercial wardrobe item.

The outfit must be composed from the available
commercial wardrobe whenever possible.
"""

    else:

        wardrobe_section = f"""
PERSONAL WARDROBE MODE

AVAILABLE PERSONAL WARDROBE:

{json.dumps(
    optional_wardrobe,
    indent=2,
    ensure_ascii=False,
)}

USER-SELECTED ITEMS:

{json.dumps(
    selected_items,
    indent=2,
    ensure_ascii=False,
)}

WARDROBE RULES:

- Only use items from the personal wardrobe.
- Never invent wardrobe items.
- Explicitly selected items have priority.
- Additional wardrobe items may be selected when
  required to complete the outfit.
- Additional items should not duplicate the clothing
  type of explicitly selected items when possible.
- If the user selected no items, choose the best
  combination automatically from the wardrobe.
"""

    # ----------------------------------------------------
    # Selected-item rules
    # ----------------------------------------------------

    if selected_items:

        selected_instruction = f"""
USER-SELECTED CLOTHING

The user explicitly selected these wardrobe items:

{json.dumps(
    selected_items,
    indent=2,
    ensure_ascii=False,
)}

MANDATORY SELECTION RULES:

1. Treat the selected items as intentional choices.
2. Use compatible selected items in the outfit.
3. NEVER silently replace a compatible selected item.
4. You may add other wardrobe items to complete
   the outfit.
5. If the user selected only a shirt, choose suitable
   trousers and shoes if required.
6. If the user selected trousers, choose a compatible
   top and shoes.
7. If the user selected shoes, choose compatible clothing.
8. If multiple pieces were selected, coordinate the
   remaining pieces around them.
9. The selected item IDs must appear in selected_items.
10. Never claim an item was selected if its ID does not
    exist in the wardrobe database.

Selected item IDs:

{json.dumps(selected_item_ids)}
"""

    else:

        selected_instruction = """
USER-SELECTED CLOTHING

The user did not select any wardrobe items.

IMPORTANT:

The user intentionally chose to let the AI stylist
make the clothing selection.

Do NOT ask for a selection.

Automatically choose the most suitable outfit from
the available wardrobe when a wardrobe is provided.

For OPEN WORLD / AI STYLING mode, freely create
the most suitable outfit using fashion knowledge.
"""

    # ----------------------------------------------------
    # Missing IDs
    # ----------------------------------------------------

    missing_instruction = ""

    if missing_selected_ids:

        missing_instruction = f"""
WARNING:

The following selected item IDs were requested by
the user but could not be found:

{json.dumps(missing_selected_ids)}

Do not invent these items.

Use only items that actually exist.
"""

    # ----------------------------------------------------
    # Previous outfit history
    # ----------------------------------------------------

    if previous_outfits:

        history_section = f"""
OUTFIT HISTORY

The following outfits were previously generated for
this same style and wardrobe source:

{json.dumps(
    previous_outfits,
    indent=2,
    ensure_ascii=False,
)}

HISTORY RULES:

1. Do NOT simply reproduce a previous outfit.
2. Avoid using the exact same combination of wardrobe
   item IDs.
3. Avoid generating an outfit that is substantially
   similar to a previous outfit.
4. Change the clothing combination whenever possible.
5. Vary colors, layering, silhouettes, accessories,
   footwear, or other styling elements when appropriate.
6. For OPEN WORLD / AI STYLING, avoid repeating the
   same clothing concept or overall outfit description.
7. For PERSONAL or COMMERCIAL wardrobe modes, prioritize
   unused combinations of available items.
8. If the wardrobe is small and some repetition is
   unavoidable, make the styling meaningfully different.
9. Never violate the user's explicitly selected items
   merely to avoid history repetition.
"""

    else:

        history_section = """
OUTFIT HISTORY

No previous outfit exists for this style and wardrobe
source.

Create a fresh recommendation.
"""

    # ----------------------------------------------------
    # Final prompt
    # ----------------------------------------------------

    context_prompt = f"""
You are a professional fashion stylist AI.

You will be given:

1. User body and outfit analysis from Module 1.
2. Wardrobe information from Module 2 when applicable.
3. A selected style.
4. Optional clothing items explicitly selected by the user.
5. Previous outfit history.

TASK:

Create EXACTLY 1 outfit recommendation.

Selected Style:

{style_type.upper()}

Wardrobe Source:

{wardrobe_source.upper()}

IMPORTANT:

You MUST strictly follow the selected style.

If style is FORMAL:
generate ONLY one formal/business outfit.

If style is LEISURE:
generate ONLY one casual/leisure outfit.

Do not mix styles.

{category_instruction}

{selected_instruction}

{missing_instruction}

{history_section}

{wardrobe_section}

OUTFIT COMPLETION:

When the user selects only some clothing pieces,
treat those pieces as the foundation of the outfit.

Add other suitable wardrobe items when necessary.

When the user selects NOTHING:

Automatically curate the outfit.

Do not interpret an empty selection as an error.

Do not ask the user to select clothing.

For personal wardrobe mode, select suitable items
from the user's wardrobe.

For commercial wardrobe mode, select suitable items
from the commercial wardrobe.

For open-world / AI styling mode, create the outfit
freely from fashion knowledge.

VARIATION:

This is styling session {variation_seed}.

Variation must NEVER override explicitly selected
clothing.

The selected items are always the priority.

OUTFIT HISTORY HAS HIGH PRIORITY:

Never intentionally reproduce a previous outfit.

Try to create a genuinely different clothing
combination or styling concept.

IMAGE REQUIREMENTS:

- Photorealistic fashion photography.
- Full body.
- Face fully visible.
- Hair visible.
- Both shoes visible.
- Centered standing pose.
- No cropping.
- Leave sufficient space above the head.
- Leave sufficient space below the feet.
- Preserve the identity of the person from the
  reference image.
- Show the complete outfit clearly.
- Personal wardrobe clothing must match the
  selected wardrobe items exactly.
- Commercial wardrobe clothing must match the
  selected commercial items.
- Open-world clothing should be realistic and
  clearly described.

USER ANALYSIS:

{json.dumps(
    module1_data,
    indent=2,
    ensure_ascii=False,
)}

OUTPUT REQUIREMENTS:

Provide exactly ONE recommendation containing:

- Category
- Selected wardrobe items
- Styling advice
- Image generation prompt

For personal and commercial wardrobe modes,
selected_items must contain the actual wardrobe
items used for the outfit.

For open-world / AI styling mode, describe the
clothing directly when no wardrobe IDs exist.

Return ONLY structured output.
"""

    try:

        completion = client.beta.chat.completions.parse(
            model=STYLIST_MODEL,
            messages=[
                {
                    "role": "user",
                    "content": context_prompt,
                }
            ],
            response_format=Module3Output,
        )

        result = (
            completion
            .choices[0]
            .message
            .parsed
        )

        if result is None:
            raise ValueError(
                "Stylist model returned no structured output."
            )

        if len(result.recommendations) != 1:
            raise ValueError(
                "Stylist model did not return exactly one recommendation."
            )

        # ------------------------------------------------
        # Save the generated outfit immediately
        # ------------------------------------------------

        recommendation = result.recommendations[0]

        save_generated_outfit(
            style_type=style_type,
            wardrobe_source=wardrobe_source,
            recommendation=recommendation,
        )

        log(
            "Stylist recommendation completed"
        )

        log(
            "Outfit history updated successfully"
        )

        return result

    except Exception as e:

        log(
            f"Stylist agent failed: {str(e)}"
        )

        raise