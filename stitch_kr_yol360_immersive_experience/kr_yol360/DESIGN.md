---
name: Kréyol360
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#3a3939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#e4bebb'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#ab8986'
  outline-variant: '#5b403e'
  surface-tint: '#ffb3ae'
  primary: '#ffb3ae'
  on-primary: '#68000d'
  primary-container: '#ff5354'
  on-primary-container: '#5c000a'
  inverse-primary: '#ba1826'
  secondary: '#59de9b'
  on-secondary: '#003921'
  secondary-container: '#00a669'
  on-secondary-container: '#00311c'
  tertiary: '#e9c400'
  on-tertiary: '#3a3000'
  tertiary-container: '#c8a900'
  on-tertiary-container: '#4b3e00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdad7'
  primary-fixed-dim: '#ffb3ae'
  on-primary-fixed: '#410005'
  on-primary-fixed-variant: '#930016'
  secondary-fixed: '#78fbb6'
  secondary-fixed-dim: '#59de9b'
  on-secondary-fixed: '#002111'
  on-secondary-fixed-variant: '#005232'
  tertiary-fixed: '#ffe16d'
  tertiary-fixed-dim: '#e9c400'
  on-tertiary-fixed: '#221b00'
  on-tertiary-fixed-variant: '#544600'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
typography:
  display-lg:
    fontFamily: Epilogue
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Epilogue
    fontSize: 36px
    fontWeight: '800'
    lineHeight: 42px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Epilogue
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-md:
    fontFamily: Epilogue
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-bold:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  unit: 8px
  container-padding: 24px
  gutter: 16px
  section-gap: 48px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

The design system is a premium, immersive framework designed to celebrate Caribbean heritage through a high-fidelity digital lens. It targets a modern audience seeking deep cultural immersion, blending the vibrant energy of the islands with the sophistication of luxury fintech and lifestyle apps.

The aesthetic is **Vibrant Glassmorphism**. It utilizes deep, obsidian surfaces as a canvas for high-contrast tropical accents. The emotional response is "Rhythmic Elegance"—it feels alive, rhythmic like a drumbeat, yet polished and exclusive. Design elements should prioritize depth through translucency, fluid motion, and a tactile sense of quality that elevates cultural content to a premium status.

## Colors

The palette is rooted in the "After Hours" Caribbean sky. The primary background is a deep obsidian (#0A0A0A), providing the necessary contrast for the vibrant accent colors to glow.

- **Sunset Orange (#FF4E50):** Used for primary actions, critical brand moments, and progress indicators.
- **Tropical Emerald (#00A86B):** Used for secondary features, success states, and gamification milestones.
- **Warm Gold (#FFD700):** Reserved for premium status, rewards, and "Golden Hour" highlights.
- **Glass Surfaces:** Containers use a semi-transparent white tint with a heavy backdrop blur (20px-40px) to create the signature frosted glass effect.

## Typography

This design system uses a dual-font strategy to balance character with utility.

- **Headlines:** **Epilogue** provides a geometric yet expressive feel. For Display and Headline roles, use tight letter-spacing and heavy weights to mimic the boldness of woodblock posters and modern carnival branding.
- **Body & Labels:** **Be Vietnam Pro** offers a friendly, contemporary sans-serif experience that remains highly legible against dark, translucent backgrounds.
- **Hierarchy:** Maintain large scale differences between headers and body text to create a rhythmic "visual beat" across the page. Use `label-bold` for metadata and small navigation elements to ensure they aren't lost in the glass textures.

## Layout & Spacing

The layout philosophy follows a **Fluid Glass Grid**. Components should feel like they are floating on different planes of the obsidian background.

- **Margins:** High-density padding is essential. Desktop layouts should maintain a 12-column grid with 24px gutters, but with generous 80px+ side margins to keep content focused.
- **Mobile:** Use a 4-column grid with a minimum 24px container padding.
- **Vertical Rhythm:** Use the 8px base unit. Section gaps should be aggressive (48px or 64px) to allow the "breath" of the dark background to emphasize the premium nature of the content.
- **Safe Areas:** Ensure all glass containers have internal padding of at least 24px to prevent content from touching the delicate borders.

## Elevation & Depth

Hierarchy in this design system is achieved through "Optical Stacking" rather than traditional shadows.

1. **Base (Level 0):** Pure Obsidian (#0A0A0A). No glow, no blur.
2. **Surface (Level 1):** Translucent glass (3% white) with a 32px backdrop blur. Used for main content cards.
3. **Floating (Level 2):** Translucent glass (6% white) with a 64px backdrop blur and a 1px solid border (8% white). Used for modals and navigation bars.
4. **Accent Glows:** Use low-opacity radial gradients of Sunset Orange and Tropical Emerald in the background (far behind the glass) to create "pockets of light" that shine through the frosted layers.

## Shapes

The design system uses a "Hyper-Rounded" language to evoke a friendly, organic, and modern feel.

- **Primary Radius:** All main cards and containers use a 24px (1.5rem) radius.
- **Buttons & Chips:** Use fully pill-shaped (rounded-full) geometry to emphasize the gamified and tactile nature of the interface.
- **Interactive Elements:** When an item is hovered or active, the radius should remain consistent, but the border-opacity should increase to define the shape more clearly.

## Components

- **Buttons:** Primary buttons use a solid gradient from #FF4E50 to #FFD700. Secondary buttons are glass-pills with a white border.
- **Cards:** Must feature a 1px inner border (`rgba(255,255,255,0.1)`) to define the edges against the dark background. The backdrop-filter (blur) is mandatory.
- **Chips:** Small, pill-shaped glass elements used for categories. Use Tropical Emerald for "Active" states.
- **Input Fields:** Darker than the surface, slightly recessed appearance. The label should float above the field in `label-bold` style.
- **Progress Bars:** Thicker, 12px height with rounded ends. Use a glow effect (drop-shadow on the bar itself) using the accent color.
- **Gamified Elements:** Hexagonal or circular "Badges" with gold-tinted glass and metallic inner strokes for achievements.