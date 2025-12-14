# WezTerm Backdrop Image Guide

## 🎨 Quick Reference for High-Quality Terminal Backgrounds

This guide provides curated sources and recommendations for backdrop images optimized for terminal use.

---

## 📊 Current Collection Analysis

Your `backdrops/` directory contains **15 high-quality images**:

### By Category:
- **Anime/Ghibli**: totoro.jpeg, frieren.jpeg, 5-cm.jpg, appa.jpg, pastel-samurai.jpg (5)
- **Space/Cosmic**: space.jpg, nord-space.png, astro-jelly.jpg, cloudy-quasar.png (4)
- **Action/Dramatic**: final-showdown.jpg, angry-samurai.jpg, sword.jpg (3)
- **Abstract/Artistic**: cherry-lava.jpg, voyage.jpg, sunset.jpg (3)

### Current Strengths:
✅ Excellent anime aesthetic variety
✅ Good space/cosmic representation
✅ Consistent naming convention
✅ Mix of light and dark themes

### Recommended Additions:
- 2-3 minimalist/gradient backgrounds (for focus work)
- 1-2 cyberpunk/neon themes
- 2-3 nature/landscape scenes
- 1-2 developer/coding themed wallpapers

---

## 🌟 Top 5 Theme Categories

### 1. 🎌 Anime & Studio Ghibli
**Why it works for terminals:**
- Nostalgic, calming aesthetics reduce stress during coding
- High detail provides visual interest without distraction
- Works exceptionally well at 0.3 opacity
- Complements Catppuccin Mocha color scheme

**Best Sources:**
| Source | Collection Size | Resolution | License |
|--------|----------------|------------|---------|
| [Wallpaper Flare](https://www.wallpaperflare.com/search?wallpaper=studio+ghibli) | 1000+ images | Up to 5K | Free |
| [Alpha Coders](https://alphacoders.com/studio-ghibli-wallpapers) | 150+ Spirited Away, 140+ Ghibli | 4K Ultra HD | Free |
| [WallpaperCG](https://wallpapercg.com/studio-ghibli-wallpapers) | Curated iconic scenes | 5K (5502x3000) | Free |

**Recommended Images:**
- ✓ My Neighbor Totoro rain scenes (ALREADY IN CONFIG)
- ✓ Frieren: Beyond Journey's End (ALREADY IN CONFIG)
- Spirited Away bathhouse exterior
- Howl's Moving Castle moving castle
- Castle in the Sky floating island
- Ponyo ocean scenes
- Kiki's Delivery Service city views

**Optimal Settings:**
```lua
opacity = 0.3,
hsb = { brightness = 0.3, saturation = 0.8 }
```

---

### 2. 🎯 Minimalist & Abstract
**Why it works for terminals:**
- **Zero distraction** - perfect for deep focus
- Geometric patterns naturally guide eye to terminal text
- Excellent for 8+ hour coding sessions
- Professional appearance for screenshares

**Best Sources:**
| Source | Collection Size | Features | License |
|--------|----------------|----------|---------|
| [Unsplash](https://unsplash.com/s/photos/minimal-abstract) | 30,000+ images | No attribution required | Free Commercial |
| [Pexels](https://www.pexels.com/search/4k%20wallpaper%20minimalist%20abstract/) | 400,000+ 4K | API available | Free Commercial |
| [awesome-terminal-backgrounds](https://github.com/drwpow/awesome-terminal-backgrounds) | 40+ gradients | Terminal-optimized | MIT |

**GitHub Gradients (Highly Recommended):**

**Warm Tones:**
- `candlelight.png` - Soft orange to pink gradient
- `ember.png` - Deep red to orange fire gradient
- `mango.png` - Yellow to orange tropical gradient
- `warm-flame.png` - Vibrant red-orange gradient

**Cool Tones:**
- `sapphire.png` - Deep blue gradient
- `mint.png` - Soft green to teal
- `misty-morning.png` - Light blue-gray gradient
- `frozen-dreams.png` - Icy blue gradient

**Balanced:**
- `fog.png` - Neutral gray gradient
- `maverick.png` - Purple to blue
- `grape.png` - Deep purple gradient
- `tempting-azure.png` - Sky blue gradient

**Optimal Settings:**
```lua
opacity = 0.35,
hsb = { brightness = 0.4, saturation = 0.7 }
```

---

### 3. 🌃 Cyberpunk & Futuristic
**Why it works for terminals:**
- Neon aesthetics **naturally complement** terminal syntax highlighting
- Dark backgrounds reduce eye strain
- High contrast when dimmed perfect for readability
- Embraces the "hacker" aesthetic developers love

**Best Sources:**
| Source | Collection Size | Style | License |
|--------|----------------|-------|---------|
| [WallpaperAccess](https://wallpaperaccess.com/minimalist-cyberpunk) | 55+ wallpapers | Minimalist focus | Free |
| [WallpaperBat](https://wallpaperbat.com/minimal-cyberpunk-wallpapers) | 60+ HD images | Clean cyberpunk | Free |
| [Peakpx](https://www.peakpx.com/en/search?q=cyberpunk+anime) | 500+ HD | Anime cyberpunk | Free |

**Recommended Styles:**
- **Neon cityscapes** - Tokyo/Hong Kong inspired city night views
- **Cyberpunk: Edgerunners** - Minimalist character silhouettes
- **Digital rain/Matrix** - Code-like falling text aesthetics
- **Synthwave** - Retro-futuristic neon gradients
- **Circuit boards** - Minimalist tech patterns

**Optimal Settings:**
```lua
opacity = 0.4,
hsb = { brightness = 0.35, saturation = 0.9 }  -- Keep saturation high for neon effect
```

---

### 4. 🌌 Space & Astronomy
**Why it works for terminals:**
- **Naturally dark** - best for reducing eye strain
- Deep blacks provide exceptional text contrast
- Professional and universally appealing
- No cultural/style preferences needed

**Best Sources:**
| Source | Collection Size | Quality | License |
|--------|----------------|---------|---------|
| [NASA Image Library](https://images.nasa.gov) | 10,000+ images | Authentic space photos | Public Domain |
| [Unsplash Space](https://unsplash.com/s/photos/space) | 5,000+ images | 4K professional | Free Commercial |
| [ESA/Hubble](https://esahubble.org/images/) | 3,000+ images | Telescope images | CC BY 4.0 |

**Recommended Images:**
- ✓ Nord Space theme (ALREADY IN CONFIG)
- ✓ Astro Jelly nebula (ALREADY IN CONFIG)
- ✓ Cloudy Quasar (ALREADY IN CONFIG)
- Pillars of Creation (Hubble)
- Andromeda Galaxy
- Crab Nebula
- Jupiter close-ups
- Saturn rings
- Earth from ISS

**Optimal Settings:**
```lua
opacity = 0.45,  -- Can go higher due to dark base
hsb = { brightness = 0.4, saturation = 0.85 }
```

---

### 5. 🏔️ Nature & Landscapes
**Why it works for terminals:**
- **Calming effect** - reduces coding stress
- Professional appearance for video calls
- Earth tones complement warm terminal themes
- Excellent for long focused sessions

**Best Sources:**
| Source | Collection Size | Focus | License |
|--------|----------------|-------|---------|
| [Unsplash Nature](https://unsplash.com/s/photos/landscape) | 50,000+ images | Professional photography | Free Commercial |
| [Pexels Nature](https://www.pexels.com/search/nature/) | 100,000+ images | High-quality curated | Free Commercial |

**Recommended Scenes:**
- **Mountain ranges at sunset** - Dramatic but not distracting (✓ Similar: sunset.jpg)
- **Forest scenes with depth** - Natural bokeh effect
- **Minimalist ocean/beach** - Horizontal lines guide focus
- **Desert landscapes** - Warm, minimal, calming
- **Northern lights** - Colorful but dark base

**Optimal Settings:**
```lua
opacity = 0.3,
hsb = { brightness = 0.25, saturation = 0.75 }  -- Reduce both for subtlety
```

---

## 🔧 Technical Specifications

### Optimal Image Properties

```lua
{
   resolution = "3840x2160",  -- 4K minimum for retina displays
   format = "JPEG",           -- For photos (smaller file size)
   format_alt = "PNG",        -- For graphics/logos (transparency support)
   color_profile = "sRGB",    -- For consistency across displays
   file_size = "< 5MB",       -- For fast loading
   bit_depth = "8-bit",       -- Standard, 16-bit unnecessary for backgrounds
}
```

### Recommended Opacity by Image Type

| Image Type | Opacity | Brightness | Saturation | Reasoning |
|------------|---------|------------|------------|-----------|
| **Dark images** (space, night) | 0.4-0.5 | 0.4 | 0.85 | Already dark, can show more |
| **Light images** (clouds, minimal) | 0.2-0.3 | 0.2 | 0.6 | Need heavy dimming |
| **High-detail** (anime, photography) | 0.25-0.35 | 0.3 | 0.8 | Current config ✓ |
| **Gradients & abstract** | 0.3-0.4 | 0.35 | 0.7 | Balanced |
| **Neon/cyberpunk** | 0.35-0.45 | 0.35 | 0.9 | Keep saturation high |

### WezTerm Configuration Example

```lua
-- In config/appearance.lua
background = {
   {
      source = { File = wezterm.config_dir .. '/backdrops/totoro.jpeg' },
      opacity = 0.3,
      hsb = {
         brightness = 0.3,  -- Dim for text readability
         saturation = 0.8,  -- Slight desaturation
         hue = 1.0,         -- No hue shift (default)
      },
      horizontal_align = 'Center',
      vertical_align = 'Middle',
      width = '100%',
      height = '100%',
      repeat_x = 'NoRepeat',
      repeat_y = 'NoRepeat',
   }
}
```

---

## 📦 Curated Free Image Sources

### Commercial Use OK (No Attribution Required)

#### 1. 🖼️ [Unsplash](https://unsplash.com)
- **Collection**: 3 million+ free images
- **Quality**: Professional photography
- **License**: Free for commercial use
- **Best for**: Nature, abstract, space, professional scenes

**Direct Links:**
- Minimal Abstract: `unsplash.com/s/photos/minimal-abstract`
- Programming: `unsplash.com/s/photos/programming`
- Coding Aesthetic: `unsplash.com/s/photos/coding-wallpaper`
- Space: `unsplash.com/s/photos/space`
- Nature: `unsplash.com/s/photos/landscape`

#### 2. 🎨 [Pexels](https://pexels.com)
- **Collection**: 400,000+ 4K wallpapers
- **Quality**: Curated high-quality
- **License**: Free for commercial use
- **Best for**: Minimalist, 4K wallpapers, developer themes

**Direct Links:**
- 4K Minimal Abstract: `pexels.com/search/4k%20wallpaper%20minimalist%20abstract/`
- Minimalist: `pexels.com/search/minimalist%20wallpaper/`

#### 3. 🐙 GitHub Repositories

**[awesome-terminal-backgrounds](https://github.com/drwpow/awesome-terminal-backgrounds)**
- **Collection**: 40+ terminal-optimized gradients
- **Quality**: Specifically designed for terminal use
- **License**: MIT
- **Best for**: Gradients, abstract, minimal

**Categories Available:**
- Gradient Backgrounds (13 options)
- Web Gradients (16 options)

**[sayimburak/wallpapers](https://github.com/sayimburak/wallpapers)**
- **Collection**: Curated high-quality collection
- **Quality**: Developer-focused
- **Features**: Installation scripts for Linux/Windows

**[ItsTerm1n4l/Wallpapers](https://github.com/ItsTerm1n4l/Wallpapers)**
- **Collection**: Categorized by style
- **Quality**: Mixed 4K and HD

#### 4. 🎌 Anime & Ghibli Sources

**[Alpha Coders](https://alphacoders.com)**
- **Collection**: 150+ Spirited Away, 140+ Studio Ghibli
- **Quality**: 4K Ultra HD
- **Features**: Crop and personalize options
- **License**: Free for personal use

**[Wallpaper Flare](https://wallpaperflare.com)**
- **Collection**: 1000+ Studio Ghibli wallpapers
- **Quality**: 1080P, 2K, 4K, 5K options
- **Features**: Multi-device downloads
- **License**: Free

**[WallpaperCat](https://wallpapercat.com/studio-ghibli-wallpapers)**
- **Collection**: 115 curated Studio Ghibli images
- **Quality**: High-definition
- **License**: Free

---

## 🎯 Best Practices

### 1. **Match Background Color to Image**
```lua
-- In config/appearance.lua
colors = {
   background = '#1f1f28',  -- Should approximate your image's base color
}
```
**Why**: Improves `dim` text visibility when image changes.

### 2. **Test with Your Color Scheme**
Some images work better with specific terminal color schemes:
- **Catppuccin Mocha** (current) → Warm tones, anime, sunset scenes
- **Tokyo Night** → Cyberpunk, neon, dark city scenes
- **Nord** → Cool tones, space, winter landscapes
- **Dracula** → Purple/pink tones, cyberpunk, synthwave

### 3. **Consider Animation (Use Sparingly)**
WezTerm supports animated GIF and PNG:
```lua
background = {
   {
      source = { File = '/path/to/animated.gif' },
      -- Animates only when window has focus
   }
}
```
**Warning**: Can be distracting. Best for:
- Subtle motion (floating particles, slow clouds)
- Demo/presentation mode
- Special occasions

### 4. **Use Focus Mode for Deep Work**
Toggle with `SUPER + b`:
- Removes image entirely
- Shows solid `colors.custom.background` color
- Zero distraction for complex tasks

### 5. **Organize by Mood/Task**
Consider naming convention:
```
backdrops/
├── focus/           # Minimal, gradients for deep work
│   ├── minimal-blue.png
│   └── gradient-purple.png
├── casual/          # Anime, colorful for general use
│   ├── totoro.jpeg
│   └── frieren.jpeg
└── professional/    # Nature, space for meetings
    ├── mountain-sunset.jpg
    └── space-nebula.jpg
```

---

## 🚀 How to Add New Backdrops

### Step-by-Step Process:

1. **Download high-quality image** from sources above
   ```bash
   # Example: Download from Unsplash
   wget https://unsplash.com/photos/[photo-id]/download?force=true -O new-wallpaper.jpg
   ```

2. **Resize if needed** (optional, for large files)
   ```bash
   # Using ImageMagick
   convert input.jpg -resize 3840x2160 output.jpg

   # Using sips (macOS)
   sips -Z 3840 input.jpg --out output.jpg
   ```

3. **Optimize file size** (recommended)
   ```bash
   # Using ImageOptim (macOS GUI)
   # Or jpegoptim (CLI)
   jpegoptim --size=2000k input.jpg

   # For PNG
   pngquant --quality=80-95 input.png
   ```

4. **Save to backdrops directory**
   ```bash
   mv new-wallpaper.jpg ~/.config/wezterm/backdrops/
   ```

5. **Use descriptive naming**
   ```
   ✅ cosmic-nebula-purple.jpg
   ✅ totoro-rain-scene.jpeg
   ✅ minimal-gradient-blue-4k.png

   ❌ image1.jpg
   ❌ wallpaper.png
   ❌ IMG_2394.jpg
   ```

6. **Reload WezTerm**
   - Images auto-detect on next load
   - Or use `SUPER + /` to test immediately

### Quick Add Script (Optional):

Create `~/scripts/add-wezterm-backdrop.sh`:
```bash
#!/bin/bash
# Add and optimize wallpaper for WezTerm

IMAGE_PATH="$1"
BACKDROP_DIR="$HOME/.config/wezterm/backdrops"
FILENAME=$(basename "$IMAGE_PATH")

# Optimize JPEG
if [[ $FILENAME == *.jpg ]] || [[ $FILENAME == *.jpeg ]]; then
    jpegoptim --size=3000k "$IMAGE_PATH"
fi

# Optimize PNG
if [[ $FILENAME == *.png ]]; then
    pngquant --quality=80-95 "$IMAGE_PATH" --output "$IMAGE_PATH"
fi

# Move to backdrops
mv "$IMAGE_PATH" "$BACKDROP_DIR/"
echo "✅ Added to WezTerm: $FILENAME"
```

---

## 🌐 Community Favorites (2024-2025)

Based on WezTerm GitHub discussions and community configs:

### 1. **Catppuccin-themed Wallpapers**
Match your terminal color scheme:
- Search: "catppuccin wallpaper mocha"
- Colors: Rosewater (#f5e0dc), Mauve (#cba6f7), Sapphire (#74c7ec)

### 2. **Tokyo Night Cityscapes**
Neon aesthetic matching Tokyo Night theme:
- Neon Tokyo streets at night
- Cyberpunk city views
- Blade Runner-inspired

### 3. **Nord-themed Landscapes**
Cool-toned matching Nord theme:
- ✓ Already have: `nord-space.png`
- Arctic landscapes
- Cool winter scenes
- Aurora borealis

### 4. **Dracula Color Palette**
Purple/pink tones matching Dracula theme:
- Synthwave gradients
- Purple nebulae
- Pink sunset scenes

### 5. **Material Design**
Google's Material Design aesthetics:
- Geometric shapes
- Bold gradients
- Flat design patterns

---

## 🎨 Current Config Strengths & Gaps

### Strengths (What You Have):
✅ **Excellent anime variety** - totoro, frieren, 5-cm
✅ **Strong space collection** - nord-space, astro-jelly, cloudy-quasar
✅ **Good action/dramatic** - final-showdown, angry-samurai, sword
✅ **Consistent naming** - All use lowercase with hyphens
✅ **Variety of moods** - From calm (totoro) to dramatic (final-showdown)

### Gaps (Opportunities for Expansion):

1. **Minimalist/Gradient** (PRIORITY)
   - Add 2-3 gradient backgrounds from awesome-terminal-backgrounds
   - Suggested: sapphire.png, ember.png, misty-morning.png
   - Use case: Deep focus work sessions

2. **Cyberpunk/Neon** (MEDIUM PRIORITY)
   - Add 1-2 neon cityscapes
   - Complements Catppuccin Mocha colors
   - Use case: Night coding sessions

3. **Pure Nature** (LOW PRIORITY)
   - You have `sunset.jpg` but could add more
   - Suggested: Mountain ranges, forest scenes
   - Use case: Calming backgrounds for long sessions

4. **Developer-themed** (OPTIONAL)
   - Code snippets, terminal screenshots
   - Subtle tech patterns
   - Use case: Professional screenshares

---

## 📈 Pro Tips

### Tip 1: Create Themed Collections
Use symbolic links to create collections:
```bash
mkdir -p ~/.config/wezterm/backdrops/{focus,casual,pro}
ln -s ../totoro.jpeg ~/.config/wezterm/backdrops/casual/
ln -s ../nord-space.png ~/.config/wezterm/backdrops/pro/
```

### Tip 2: Season Rotation
Manually rotate based on season:
- **Spring**: Cherry blossoms, pastel colors
- **Summer**: Bright, vibrant scenes
- **Fall**: Warm tones, sunsets (✓ sunset.jpg)
- **Winter**: Cool tones, space, nord themes

### Tip 3: Time-Based Selection
Consider creating a script to switch based on time:
```lua
-- In wezterm.lua (example concept)
local hour = tonumber(os.date('%H'))
local mode = (hour >= 6 and hour < 18) and 'day' or 'night'
```

### Tip 4: Dual Monitor Setup
Use different backgrounds for different monitors:
```lua
-- Advanced: Can detect screen and set different backgrounds
-- See WezTerm docs for per-screen configuration
```

---

## 🔗 Quick Links

### Essential Resources:
- [WezTerm Background Docs](https://wezterm.org/config/lua/config/background.html)
- [WezTerm Color Schemes](https://wezterm.org/colorschemes/index.html)
- [awesome-terminal-backgrounds](https://github.com/drwpow/awesome-terminal-backgrounds)
- [Show your wezterms (Community)](https://github.com/wezterm/wezterm/discussions/628)

### Image Sources:
- [Unsplash](https://unsplash.com) - Professional photography
- [Pexels](https://pexels.com) - Curated 4K wallpapers
- [NASA Images](https://images.nasa.gov) - Public domain space photos
- [Alpha Coders](https://alphacoders.com) - Anime/Ghibli wallpapers
- [Wallpaper Flare](https://wallpaperflare.com) - Multi-resolution downloads

---

**Last Updated**: December 2024
**Config Version**: Compatible with WezTerm 20240127+
**Maintained by**: Your WezTerm Configuration

---

## 💡 Need Help?

Check these files in your config:
- `CLAUDE.md` - Complete architecture documentation
- `config/appearance.lua` - Current background settings
- `utils/backdrops.lua` - Background management code
- `wezterm.lua` - Entry point and initialization

Press `SUPER + /` to select random background
Press `SUPER + b` to toggle focus mode
