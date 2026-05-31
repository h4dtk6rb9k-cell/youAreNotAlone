#!/usr/bin/env python3
"""
generate_art.py — DALL-E art pipeline for «Досье гражданина»

Usage:
    python Tools/generate_art.py --type tile   --name floor_a
    python Tools/generate_art.py --type tile   --name floor_b
    python Tools/generate_art.py --type char   --name player_e
    python Tools/generate_art.py --type char   --name player_s
    python Tools/generate_art.py --type prop   --name bed
    python Tools/generate_art.py --type all               # генерирует все определённые спрайты

Output: assets/art/generated/<type>_<name>.png
"""

import argparse
import base64
import io
import logging
import os
import sys
from pathlib import Path

# ── Зависимости ──────────────────────────────────────────────────────────────
try:
    from openai import OpenAI
except ImportError:
    sys.exit("openai не установлен. Запусти: pip install openai")

try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow не установлен. Запусти: pip install Pillow")

# ── Конфигурация ──────────────────────────────────────────────────────────────
OUTPUT_DIR = Path(__file__).parent.parent / "assets" / "art" / "generated"

# Размеры по типу (ширина, высота)
SIZES = {
    "tile":  (64, 32),
    "char":  (64, 96),
    "prop":  (64, 64),
    "ui":    (128, 128),
}

# Pixel-art downscale factor (чем выше — грубее пиксели)
PIXELATE_FACTOR = {
    "tile":  4,
    "char":  4,
    "prop":  4,
    "ui":    4,
}

# ── Библиотека промптов ───────────────────────────────────────────────────────
PROMPTS: dict[str, dict] = {

    # ── Тайлы пола ──────────────────────────────────────────────────────────

    "tile/floor_a": {
        "size": (64, 32),
        "prompt": (
            "single isometric diamond floor tile, SOLID dark wooden parquet, "
            "the diamond rhombus shape FILLS THE ENTIRE 64x32 frame edge to edge, "
            "flat top-down 2:1 isometric angle, dense wood grain, dark warm brown, "
            "NO transparency, NO empty space, NO gaps, solid opaque fill, "
            "the four corners of the image are the four points of the diamond, "
            "pixel art, muted desaturated, seamless tileable"
        ),
    },
    "tile/floor_b": {
        "size": (64, 32),
        "prompt": (
            "single isometric diamond floor tile, SOLID dark wooden parquet, "
            "the diamond rhombus shape FILLS THE ENTIRE 64x32 frame edge to edge, "
            "flat top-down 2:1 isometric angle, dense wood grain, slightly lighter "
            "warm brown than tile A, NO transparency, NO empty space, NO gaps, "
            "solid opaque fill, corners of image are diamond points, "
            "pixel art, muted desaturated, seamless tileable"
        ),
    },

    # ── Персонажи ────────────────────────────────────────────────────────────

    "char/player_e": {
        "size": (64, 96),
        "prompt": (
            "isometric RPG character sprite, facing right (east), "
            "adult male in worn civilian clothes, dark jacket, grey trousers, "
            "64x96 pixels, pixel art style, dark muted colors, "
            "Fallout 1 character style, transparent background, "
            "full body standing pose, bottom-center pivot, "
            "no outline glow, isolated character only"
        ),
    },
    "char/player_s": {
        "size": (64, 96),
        "prompt": (
            "isometric RPG character sprite, facing away (south), "
            "adult male in worn civilian clothes, dark jacket, grey trousers, "
            "64x96 pixels, pixel art style, dark muted colors, "
            "Fallout 1 character style, transparent background, "
            "full body standing pose, bottom-center pivot"
        ),
    },
    "char/player_se": {
        "size": (64, 96),
        "prompt": (
            "isometric RPG character sprite, facing south-east diagonal, "
            "adult male in worn civilian clothes, dark jacket, grey trousers, "
            "64x96 pixels, pixel art style, dark muted colors, "
            "Fallout 1 character style, transparent background, "
            "full body standing pose, bottom-center pivot"
        ),
    },
    "char/player_ne": {
        "size": (64, 96),
        "prompt": (
            "isometric RPG character sprite, facing north-east diagonal, "
            "adult male in worn civilian clothes, dark jacket, grey trousers, "
            "64x96 pixels, pixel art style, dark muted colors, "
            "Fallout 1 character style, transparent background, "
            "full body standing pose"
        ),
    },
    "char/player_n": {
        "size": (64, 96),
        "prompt": (
            "isometric RPG character sprite, facing north (from behind), "
            "adult male in worn civilian clothes, dark jacket, grey trousers, "
            "64x96 pixels, pixel art style, dark muted colors, "
            "Fallout 1 character style, transparent background, "
            "full body standing pose"
        ),
    },

    # ── Пропсы квартиры ──────────────────────────────────────────────────────

    "prop/bed": {
        "size": (96, 64),
        "prompt": (
            "isometric pixel art furniture, single bed with dark purple bedsheet, "
            "viewed from isometric 2:1 angle, pixel art style, "
            "dark muted tones, transparent background, "
            "Fallout isometric RPG style, no shadows outside object"
        ),
    },
    "prop/desk": {
        "size": (80, 56),
        "prompt": (
            "isometric pixel art furniture, wooden writing desk, "
            "viewed from isometric 2:1 angle, dark wood, "
            "pixel art style, transparent background, RPG game asset"
        ),
    },
    "prop/tv_console": {
        "size": (80, 48),
        "prompt": (
            "isometric pixel art furniture, old Soviet-style TV console with screen, "
            "viewed from isometric angle, dark grey, screen showing blue glow, "
            "pixel art style, transparent background, retro dystopian RPG"
        ),
    },
    "prop/door": {
        "size": (48, 80),
        "prompt": (
            "isometric pixel art, closed wooden door in wall, "
            "viewed from isometric 2:1 angle, dark brown wood, metal handle, "
            "pixel art style, transparent background, RPG game asset"
        ),
    },

    # ── Предметы (items) ─────────────────────────────────────────────────────

    "item/photo": {
        "size": (32, 32),
        "prompt": (
            "pixel art icon, small family photograph, sepia tones, "
            "old worn photo, 32x32 pixels, RPG inventory item icon, "
            "transparent background, simple readable design"
        ),
    },
    "item/badge": {
        "size": (32, 32),
        "prompt": (
            "pixel art icon, small metal work badge with text, "
            "dark grey metal, 32x32 pixels, RPG inventory item icon, "
            "Soviet-style ID badge, transparent background"
        ),
    },
    "item/badge_mvd": {
        "size": (32, 32),
        "prompt": (
            "pixel art icon, police badge, dark blue with star emblem, "
            "32x32 pixels, RPG inventory item icon, "
            "authoritarian dystopia style, transparent background"
        ),
    },
    "item/guide": {
        "size": (32, 32),
        "prompt": (
            "pixel art icon, small red government booklet, "
            "'citizen guide' style, 32x32 pixels, RPG inventory item icon, "
            "Soviet propaganda booklet, transparent background"
        ),
    },
    "item/book_atlas": {
        "size": (32, 32),
        "prompt": (
            "pixel art icon, old geographical atlas book, worn cover, "
            "32x32 pixels, RPG inventory item icon, "
            "dark green cover, transparent background"
        ),
    },
    "item/book_unnamed": {
        "size": (32, 32),
        "prompt": (
            "pixel art icon, old book with torn cover, forbidden contraband, "
            "32x32 pixels, RPG inventory item icon, "
            "dark worn cover with no title, transparent background"
        ),
    },
}

# ── Логгер ────────────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("generate_art")


# ── Pixel-art обработка ───────────────────────────────────────────────────────
def pixelate(img: Image.Image, target_w: int, target_h: int, factor: int = 4) -> Image.Image:
    """
    1. Масштабируем до target_w × target_h
    2. Уменьшаем в factor раз (nearest neighbor) — создаём пиксели
    3. Увеличиваем обратно до target_w × target_h (nearest neighbor)
    """
    img = img.resize((target_w, target_h), Image.LANCZOS)

    small_w = max(1, target_w // factor)
    small_h = max(1, target_h // factor)
    img = img.resize((small_w, small_h), Image.NEAREST)
    img = img.resize((target_w, target_h), Image.NEAREST)

    return img


def download_image(url: str) -> Image.Image:
    with urllib.request.urlopen(url) as resp:
        import io
        return Image.open(io.BytesIO(resp.read())).convert("RGBA")


# ── Генерация одного спрайта ──────────────────────────────────────────────────
def generate_sprite(
    client: OpenAI,
    sprite_key: str,
    sprite_type: str,
    sprite_name: str,
    dry_run: bool = False,
) -> Path:
    spec = PROMPTS[sprite_key]
    target_w, target_h = spec["size"]
    prompt = spec["prompt"]
    factor = PIXELATE_FACTOR.get(sprite_type, 4)

    out_path = OUTPUT_DIR / f"{sprite_type}_{sprite_name}.png"
    out_path.parent.mkdir(parents=True, exist_ok=True)

    log.info("Generating %s → %s  (%dx%d)", sprite_key, out_path.name, target_w, target_h)
    log.info("Prompt: %s", prompt[:120] + ("..." if len(prompt) > 120 else ""))

    if dry_run:
        log.info("[DRY RUN] Пропускаем API вызов")
        return out_path

    # gpt-image-1 — актуальная модель OpenAI (2025+)
    # Поддерживает transparent background через output_format
    response = client.images.generate(
        model="gpt-image-1",
        prompt=prompt,
        size="1024x1024",
        quality="medium",
        n=1,
    )

    # gpt-image-1 возвращает base64, не URL
    image_bytes = base64.b64decode(response.data[0].b64_json)
    img = Image.open(io.BytesIO(image_bytes)).convert("RGBA")
    img = pixelate(img, target_w, target_h, factor)
    img.save(out_path, "PNG")
    log.info("Saved: %s  (%d bytes)", out_path, out_path.stat().st_size)
    return out_path



# ── CLI ───────────────────────────────────────────────────────────────────────
def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Generate pixel-art sprites via DALL-E for 'Досье гражданина'",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    p.add_argument(
        "--type", "-t",
        choices=["tile", "char", "prop", "item", "ui", "all"],
        default=None,
        help="Тип спрайта или 'all' для генерации всех",
    )
    p.add_argument(
        "--name", "-n",
        default=None,
        help="Имя спрайта (floor_a, player_e, bed, …). Не нужно при --type all",
    )
    p.add_argument(
        "--api-key",
        default=os.environ.get("OPENAI_API_KEY"),
        help="OpenAI API key (по умолчанию из OPENAI_API_KEY)",
    )
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="Не вызывать API, только показать что будет сгенерировано",
    )
    p.add_argument(
        "--list",
        action="store_true",
        help="Показать все доступные спрайты и выйти",
    )
    return p


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if args.list:
        print("\nДоступные спрайты:\n")
        for key, spec in sorted(PROMPTS.items()):
            w, h = spec["size"]
            print(f"  {key:<30} {w}×{h}")
        print()
        return

    if args.type is None:
        parser.error("--type обязателен (или используй --list для просмотра спрайтов)")

    if not args.dry_run and not args.api_key:
        parser.error(
            "API key не задан. Используй --api-key или переменную OPENAI_API_KEY"
        )

    client = OpenAI(api_key=args.api_key) if not args.dry_run else None

    # Собираем список спрайтов для генерации
    if args.type == "all":
        targets = [(key, key.split("/")[0], key.split("/")[1]) for key in PROMPTS]
    else:
        if args.name is None:
            parser.error("--name обязателен если --type не 'all'")
        sprite_key = f"{args.type}/{args.name}"
        if sprite_key not in PROMPTS:
            available = [k for k in PROMPTS if k.startswith(args.type + "/")]
            parser.error(
                f"Спрайт '{sprite_key}' не найден.\n"
                f"Доступные для типа '{args.type}': {', '.join(available)}"
            )
        targets = [(sprite_key, args.type, args.name)]

    log.info("Генерация %d спрайт(ов) в %s", len(targets), OUTPUT_DIR)
    generated = []

    for sprite_key, sprite_type, sprite_name in targets:
        try:
            path = generate_sprite(client, sprite_key, sprite_type, sprite_name, args.dry_run)
            generated.append(path)
        except Exception as exc:
            log.error("Ошибка при генерации %s: %s", sprite_key, exc)

    log.info(
        "Готово: %d/%d спрайт(ов) сгенерировано",
        len(generated), len(targets),
    )
    for p in generated:
        log.info("  → %s", p)


if __name__ == "__main__":
    main()
