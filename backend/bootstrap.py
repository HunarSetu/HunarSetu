"""First-boot seeding for deployments.

A fresh deployment gets an empty volume: no database, no product images and no
pricing index, so the catalogue renders blank and pricing falls back to the cost
floor. This copies the bundled demo data into place the first time the app
starts on an empty volume, and does nothing on every boot after that.

Each of the three stores is checked independently, so a partially-populated
volume gets only the pieces it is missing.
"""

from __future__ import annotations

import logging
import shutil
from pathlib import Path

from .config import PROJECT_ROOT, get_settings

logger = logging.getLogger(__name__)

SEED_DIR = PROJECT_ROOT / "deploy" / "seed"


def _sqlite_path(database_url: str) -> Path | None:
    """Local file behind a sqlite:/// URL, or None for any other backend."""
    prefix = "sqlite:///"
    if not database_url.startswith(prefix):
        return None
    return Path(database_url[len(prefix):])


def _is_empty(directory: Path) -> bool:
    return not directory.exists() or not any(directory.iterdir())


def _chroma_needs_seed(directory: Path) -> bool:
    """True when no vectors are present.

    Chroma keeps its vectors in a UUID-named subdirectory beside chroma.sqlite3.
    Merely constructing a client creates the directory and an empty sqlite file,
    so "directory exists" is not evidence of data.
    """
    if not directory.exists():
        return True
    return not any(child.is_dir() for child in directory.iterdir())


def seed_runtime_data() -> None:
    """Populate empty runtime stores from deploy/seed. Safe to call every boot."""
    if not SEED_DIR.exists():
        return

    settings = get_settings()

    # 1. Database ------------------------------------------------------------
    db_path = _sqlite_path(settings.database_url)
    seed_db = SEED_DIR / "hunarsetu.db"
    if db_path is not None and seed_db.exists() and not db_path.exists():
        db_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(seed_db, db_path)
        logger.info("Seeded database -> %s", db_path)

    # 2. Product images ------------------------------------------------------
    uploads = Path(settings.upload_dir)
    seed_uploads = SEED_DIR / "uploads"
    if seed_uploads.exists() and _is_empty(uploads):
        uploads.mkdir(parents=True, exist_ok=True)
        for child in seed_uploads.iterdir():
            target = uploads / child.name
            if child.is_dir():
                shutil.copytree(child, target, dirs_exist_ok=True)
            else:
                shutil.copy2(child, target)
        logger.info("Seeded uploads -> %s", uploads)

    # 3. Pricing vector index ------------------------------------------------
    seed_chroma = SEED_DIR / "chroma_db"
    if seed_chroma.exists():
        try:
            from ML.pricing.config import get_settings as pricing_settings
            chroma = Path(pricing_settings().chromadb_path)
        except Exception as exc:  # pricing module optional at boot
            logger.warning("Could not resolve ChromaDB path: %s", exc)
            return
        if _chroma_needs_seed(chroma):
            chroma.mkdir(parents=True, exist_ok=True)
            shutil.copytree(seed_chroma, chroma, dirs_exist_ok=True)
            logger.info("Seeded pricing index -> %s", chroma)
