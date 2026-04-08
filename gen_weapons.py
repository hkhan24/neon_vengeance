"""
Generate detailed weapon projectile sprites:
1. Batarang - bat-shaped throwing weapon with cyan glow
2. Joke Bomb - round bomb with purple fuse and grin face
3. Thunder Zap - lightning bolt with yellow electric glow
4. Lasso - golden glowing whip coil
"""
from PIL import Image, ImageDraw, ImageFilter
import math, os

ASSETS_DIR = 'assets/images'
SIZE = 128  # Small projectile sprites

def draw_glow(img, color, blur_radius=6):
    """Add an outer glow effect."""
    glow = img.copy()
    glow = glow.filter(ImageFilter.GaussianBlur(radius=blur_radius))
    result = Image.new('RGBA', img.size, (0, 0, 0, 0))
    result.paste(glow, (0, 0))
    result = Image.alpha_composite(result, img)
    return result

def generate_batarang():
    """Bat-shaped boomerang with cyan glow."""
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = SIZE // 2, SIZE // 2
    
    # Bat wing shape using polygon points
    points = [
        # Left wing
        (cx - 55, cy - 5),
        (cx - 50, cy - 20),
        (cx - 35, cy - 25),
        (cx - 20, cy - 15),
        # Left ear notch
        (cx - 15, cy - 22),
        (cx - 8, cy - 12),
        # Center top
        (cx, cy - 8),
        # Right ear notch
        (cx + 8, cy - 12),
        (cx + 15, cy - 22),
        # Right wing
        (cx + 20, cy - 15),
        (cx + 35, cy - 25),
        (cx + 50, cy - 20),
        (cx + 55, cy - 5),
        # Right wing bottom
        (cx + 45, cy + 5),
        (cx + 25, cy + 8),
        # Center bottom
        (cx + 10, cy + 12),
        (cx, cy + 18),
        (cx - 10, cy + 12),
        # Left wing bottom
        (cx - 25, cy + 8),
        (cx - 45, cy + 5),
    ]
    
    # Main body - dark steel
    draw.polygon(points, fill=(30, 30, 40, 255), outline=(0, 220, 255, 255), width=2)
    
    # Inner detail lines
    draw.line([(cx - 30, cy), (cx + 30, cy)], fill=(0, 180, 220, 180), width=1)
    draw.line([(cx, cy - 8), (cx, cy + 12)], fill=(0, 180, 220, 180), width=1)
    
    # Center emblem dot
    draw.ellipse([cx-4, cy-4, cx+4, cy+4], fill=(0, 255, 255, 255))
    
    # Apply glow
    img = draw_glow(img, (0, 220, 255), blur_radius=4)
    
    img.save(os.path.join(ASSETS_DIR, 'batarang.png'))
    print("  Created: batarang.png")

def generate_joke_bomb():
    """Round bomb with purple tint and evil grin."""
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = SIZE // 2, SIZE // 2 + 8
    radius = 32
    
    # Bomb body - dark purple sphere
    draw.ellipse([cx-radius, cy-radius, cx+radius, cy+radius], 
                 fill=(60, 20, 80, 255), outline=(180, 80, 220, 255), width=2)
    
    # Highlight arc (shiny spot)
    draw.arc([cx-radius+5, cy-radius+5, cx-5, cy-5], 200, 320, fill=(140, 80, 180, 200), width=3)
    
    # Evil grin
    draw.arc([cx-15, cy-5, cx+15, cy+15], 10, 170, fill=(255, 200, 0, 255), width=2)
    
    # Eyes
    draw.ellipse([cx-12, cy-12, cx-6, cy-6], fill=(255, 200, 0, 255))
    draw.ellipse([cx+6, cy-12, cx+12, cy-6], fill=(255, 200, 0, 255))
    
    # Fuse on top
    fuse_points = [(cx, cy - radius), (cx + 5, cy - radius - 12), 
                   (cx + 12, cy - radius - 18), (cx + 8, cy - radius - 25)]
    draw.line(fuse_points, fill=(180, 160, 100, 255), width=3)
    
    # Fuse spark
    spark_x, spark_y = cx + 8, cy - radius - 25
    for angle in range(0, 360, 45):
        ex = spark_x + int(8 * math.cos(math.radians(angle)))
        ey = spark_y + int(8 * math.sin(math.radians(angle)))
        draw.line([(spark_x, spark_y), (ex, ey)], fill=(255, 200, 50, 255), width=1)
    draw.ellipse([spark_x-3, spark_y-3, spark_x+3, spark_y+3], fill=(255, 255, 200, 255))
    
    # Apply glow
    img = draw_glow(img, (180, 80, 220), blur_radius=5)
    
    img.save(os.path.join(ASSETS_DIR, 'joke_bomb.png'))
    print("  Created: joke_bomb.png")

def generate_thunder_zap():
    """Lightning bolt with yellow-white electric effect."""
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = SIZE // 2, SIZE // 2
    
    # Main lightning bolt shape
    bolt_points = [
        (cx - 5, cy - 45),
        (cx + 20, cy - 45),
        (cx + 5, cy - 10),
        (cx + 25, cy - 10),
        (cx - 10, cy + 45),
        (cx + 2, cy + 5),
        (cx - 18, cy + 5),
    ]
    
    # Outer glow layer (wider)
    glow_offset = 3
    glow_points = [(x + (glow_offset if x > cx else -glow_offset), 
                    y + (glow_offset if y > cy else -glow_offset)) 
                   for x, y in bolt_points]
    draw.polygon(glow_points, fill=(255, 255, 100, 80))
    
    # Main bolt body
    draw.polygon(bolt_points, fill=(255, 255, 50, 255), outline=(255, 200, 0, 255), width=2)
    
    # Inner white core
    inner_points = [
        (cx - 2, cy - 40),
        (cx + 15, cy - 40),
        (cx + 3, cy - 8),
        (cx + 20, cy - 8),
        (cx - 5, cy + 38),
        (cx + 3, cy + 7),
        (cx - 13, cy + 7),
    ]
    draw.polygon(inner_points, fill=(255, 255, 220, 255))
    
    # Electric sparks around the bolt
    import random
    random.seed(42)  # Deterministic
    for _ in range(12):
        sx = cx + random.randint(-35, 35)
        sy = cy + random.randint(-40, 40)
        ex = sx + random.randint(-8, 8)
        ey = sy + random.randint(-8, 8)
        draw.line([(sx, sy), (ex, ey)], fill=(200, 200, 255, 180), width=1)
    
    # Apply glow
    img = draw_glow(img, (255, 255, 100), blur_radius=6)
    
    img.save(os.path.join(ASSETS_DIR, 'thunder_zap.png'))
    print("  Created: thunder_zap.png")

def generate_lasso():
    """Golden glowing whip/lasso coil."""
    img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    cx, cy = SIZE // 2, SIZE // 2
    
    # Lasso rope coil - series of arcs
    for i in range(3):
        offset = i * 12
        draw.arc([cx - 40 + offset, cy - 15, cx + 40 - offset, cy + 15 + offset],
                 0, 360, fill=(255, 200, 50, 255), width=4)
    
    # Straight rope line extending right
    draw.line([(cx + 10, cy), (cx + 55, cy - 10)], fill=(255, 215, 0, 255), width=4)
    draw.line([(cx + 55, cy - 10), (cx + 55, cy - 5)], fill=(255, 215, 0, 255), width=3)
    
    # Golden glow overlay
    glow_layer = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_layer)
    glow_draw.ellipse([cx-45, cy-25, cx+50, cy+30], fill=(255, 200, 50, 30))
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(radius=8))
    img = Image.alpha_composite(glow_layer, img)
    
    # Apply glow
    img = draw_glow(img, (255, 200, 50), blur_radius=4)
    
    img.save(os.path.join(ASSETS_DIR, 'lasso.png'))
    print("  Created: lasso.png")

def main():
    generate_batarang()
    generate_joke_bomb()
    generate_thunder_zap()
    generate_lasso()
    print("Done! All weapon sprites generated.")

if __name__ == '__main__':
    main()
