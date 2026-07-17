from pathlib import Path
import os
from dotenv import load_dotenv

# =========================
# Load environment variables
# =========================
load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# =========================
# Base project directory
# =========================
BASE_DIR = Path(__file__).parent

# =========================
# Models
# =========================
VISION_MODEL = "gpt-5.5"
TEXT_MODEL = "gpt-5.5"
WARDROBE_MODEL = "gpt-5.5"
STYLIST_MODEL = "gpt-5.5"
IMAGE_MODEL = "gpt-image-1"
# =========================
# Output directories
# =========================
OUTPUT_DIR = BASE_DIR / "outputs"

MODULE1_DIR = OUTPUT_DIR / "module1"
MODULE2_DIR = OUTPUT_DIR / "module2"
MODULE3_DIR = OUTPUT_DIR / "module3"
IMAGES_DIR = OUTPUT_DIR / "images"

# =========================
# Database
# =========================
DATABASE_DIR = BASE_DIR / "database"
WARDROBE_FILE = DATABASE_DIR / "wardrobe" / "wardrobe.json"
CACHE_FILE = DATABASE_DIR / "cache" / "user_profile.json"

# =========================
# Runtime settings
# =========================
MAX_RETRIES = 3
IMAGE_SIZE = "1024x1024"
TEMPERATURE = 1.0

# =========================
# Ensure folders exist
# =========================
for path in [MODULE1_DIR, MODULE2_DIR, MODULE3_DIR, IMAGES_DIR]:
    path.mkdir(parents=True, exist_ok=True)