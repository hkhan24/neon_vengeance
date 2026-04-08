"""
Generate styled placeholder sprites for the Divine Warrior and Bolt Speedster.
Creates simple but visually distinct character silhouettes with color coding.
"""
from PIL import Image, ImageDraw
import os

ASSETS_DIR = 'assets/images'
SIZE = 512

def draw_humanoid(draw, cx, cy, scale, color, accent, pose='idle'):
    """Draw a simple humanoid figure with given color scheme and pose."""
    s = scale
    
    # Head
    head_r = int(28 * s)
    draw.ellipse([cx - head_r, cy - int(130*s), cx + head_r, cy - int(130*s) + head_r*2], fill=color, outline=accent, width=2)
    
    # Body / Torso
    body_top = cy - int(100*s)
    body_bot = cy - int(20*s)
    body_w = int(35*s)
    draw.polygon([
        (cx - body_w, body_top),
        (cx + body_w, body_top),
        (cx + int(25*s), body_bot),
        (cx - int(25*s), body_bot),
    ], fill=color, outline=accent, width=2)
    
    # Belt / accent stripe
    belt_y = cy - int(25*s)
    draw.rectangle([cx - int(28*s), belt_y, cx + int(28*s), belt_y + int(8*s)], fill=accent)
    
    # Legs
    leg_top = body_bot
    leg_bot = cy + int(60*s)
    leg_offset = int(12*s)
    
    if pose == 'walk':
        # Walking pose - legs apart
        draw.polygon([
            (cx - leg_offset - int(5*s), leg_top),
            (cx - leg_offset + int(5*s), leg_top),
            (cx - int(30*s), leg_bot),
            (cx - int(40*s), leg_bot),
        ], fill=color, outline=accent, width=2)
        draw.polygon([
            (cx + leg_offset - int(5*s), leg_top),
            (cx + leg_offset + int(5*s), leg_top),
            (cx + int(30*s), leg_bot),
            (cx + int(20*s), leg_bot),
        ], fill=color, outline=accent, width=2)
    else:
        # Standing legs
        for side in [-1, 1]:
            draw.polygon([
                (cx + side * (leg_offset - int(5*s)), leg_top),
                (cx + side * (leg_offset + int(5*s)), leg_top),
                (cx + side * (leg_offset + int(3*s)), leg_bot),
                (cx + side * (leg_offset - int(3*s)), leg_bot),
            ], fill=color, outline=accent, width=2)
    
    # Arms
    arm_top = body_top + int(10*s)
    arm_bot = cy - int(5*s)
    
    if pose == 'attack':
        # Attack pose - arm extended forward
        draw.polygon([
            (cx + body_w, arm_top),
            (cx + body_w + int(5*s), arm_top),
            (cx + int(80*s), arm_top + int(15*s)),
            (cx + int(75*s), arm_top + int(25*s)),
        ], fill=color, outline=accent, width=2)
        # Weapon glow
        for i in range(3):
            r = int((15 - i*4)*s)
            draw.ellipse([cx + int(80*s) - r, arm_top + int(10*s) - r, 
                         cx + int(80*s) + r, arm_top + int(10*s) + r], 
                        fill=accent if i == 0 else None, outline=accent, width=2)
    else:
        # Normal arms
        for side in [-1, 1]:
            draw.polygon([
                (cx + side * body_w, arm_top),
                (cx + side * (body_w + int(5*s)), arm_top),
                (cx + side * (body_w + int(8*s)), arm_bot),
                (cx + side * (body_w - int(2*s)), arm_bot),
            ], fill=color, outline=accent, width=2)


def create_sprite(filename, base_color, accent_color, pose='idle', extras=None):
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    cx, cy = SIZE // 2, SIZE // 2 + 30
    draw_humanoid(draw, cx, cy, 1.8, base_color, accent_color, pose)
    
    # Draw extras (tiara, lightning bolts, etc.)
    if extras == 'tiara':
        # Golden tiara
        draw.polygon([
            (cx - 25, cy - 250), (cx, cy - 280), (cx + 25, cy - 250),
            (cx + 15, cy - 240), (cx - 15, cy - 240),
        ], fill=(255, 215, 0), outline=(255, 180, 0), width=2)
    elif extras == 'lightning':
        # Lightning bolt on chest
        points = [
            (cx - 8, cy - 100), (cx + 5, cy - 70),
            (cx - 3, cy - 70), (cx + 10, cy - 40),
            (cx - 2, cy - 55), (cx + 6, cy - 55),
            (cx - 10, cy - 85), 
        ]
        draw.polygon(points, fill=(255, 255, 0))
    
    img.save(os.path.join(ASSETS_DIR, filename))
    print(f"  Created: {filename}")


def main():
    # Divine Warrior - red/gold
    warrior_base = (180, 30, 30)
    warrior_accent = (255, 200, 50)
    create_sprite('warrior_idle.png', warrior_base, warrior_accent, 'idle', 'tiara')
    create_sprite('warrior_walk.png', warrior_base, warrior_accent, 'walk', 'tiara')
    create_sprite('warrior_attack.png', warrior_base, warrior_accent, 'attack', 'tiara')
    
    # Bolt Speedster - red/yellow
    speedster_base = (200, 40, 40)
    speedster_accent = (255, 255, 80)
    create_sprite('speedster_idle.png', speedster_base, speedster_accent, 'idle', 'lightning')
    create_sprite('speedster_walk.png', speedster_base, speedster_accent, 'walk', 'lightning')
    create_sprite('speedster_attack.png', speedster_base, speedster_accent, 'attack', 'lightning')
    
    print("Done! Warrior and Speedster sprites generated.")

if __name__ == '__main__':
    main()
