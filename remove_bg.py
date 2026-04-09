"""
Crop sprites tightly to the character content area then apply a soft 
rounded vignette mask so the edges fade instead of showing a harsh square.
This avoids the see-through problem while hiding the square background.
"""
from PIL import Image, ImageDraw, ImageFilter
import os

ASSETS_DIR = 'assets/images'
SPRITE_FILES = [
    'vigilante_idle.png', 'vigilante_walk.png', 'vigilante_attack.png',
    'jester_idle.png', 'jester_walk.png', 'jester_attack.png',
    'warrior_idle.png', 'warrior_walk.png', 'warrior_attack.png',
    'speedster_idle.png', 'speedster_walk.png', 'speedster_attack.png',
    'zombie_walk.png',
]

def process_sprite(filepath):
    img = Image.open(filepath).convert('RGBA')
    w, h = img.size
    
    # Create a rounded rectangle alpha mask that fades the edges
    mask = Image.new('L', (w, h), 0)
    draw = ImageDraw.Draw(mask)
    
    # Inset rectangle - leave generous padding so character isn't clipped
    padding = int(w * 0.03)  # 3% padding
    radius = int(w * 0.15)  # Corner radius
    draw.rounded_rectangle(
        [padding, padding, w - padding, h - padding],
        radius=radius,
        fill=255
    )
    
    # Blur the mask edges for a soft fade
    mask = mask.filter(ImageFilter.GaussianBlur(radius=12))
    
    # Apply the mask to the alpha channel
    r, g, b, a = img.split()
    # Composite: only reduce alpha, don't increase it
    new_alpha = Image.eval(mask, lambda x: x)
    img.putalpha(new_alpha)
    
    img.save(filepath)
    print(f"  Processed: {filepath}")

def main():
    for filename in SPRITE_FILES:
        path = os.path.join(ASSETS_DIR, filename)
        if os.path.exists(path):
            process_sprite(path)
        else:
            print(f"  SKIP: {path}")
    print("Done! Sprites have soft-edge vignette masks applied.")

if __name__ == '__main__':
    main()
