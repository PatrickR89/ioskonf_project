---
name: The Design System
colors:
  surface: '#fbf9f9'
  surface-dim: '#dbdad9'
  surface-bright: '#fbf9f9'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3f3'
  surface-container: '#efeded'
  surface-container-high: '#e9e8e7'
  surface-container-highest: '#e4e2e2'
  on-surface: '#1b1c1c'
  on-surface-variant: '#4e4639'
  inverse-surface: '#303031'
  inverse-on-surface: '#f2f0f0'
  outline: '#7f7667'
  outline-variant: '#d1c5b4'
  surface-tint: '#775a19'
  primary: '#775a19'
  on-primary: '#ffffff'
  primary-container: '#c5a059'
  on-primary-container: '#4e3700'
  inverse-primary: '#e9c176'
  secondary: '#5f5e5e'
  on-secondary: '#ffffff'
  secondary-container: '#e2dfde'
  on-secondary-container: '#636262'
  tertiary: '#5e5e5b'
  on-tertiary: '#ffffff'
  tertiary-container: '#a6a5a1'
  on-tertiary-container: '#3b3b38'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdea5'
  primary-fixed-dim: '#e9c176'
  on-primary-fixed: '#261900'
  on-primary-fixed-variant: '#5d4201'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1c1b1b'
  on-secondary-fixed-variant: '#474746'
  tertiary-fixed: '#e4e2dd'
  tertiary-fixed-dim: '#c8c6c2'
  on-tertiary-fixed: '#1b1c19'
  on-tertiary-fixed-variant: '#474744'
  background: '#fbf9f9'
  on-background: '#1b1c1c'
  surface-variant: '#e4e2e2'
typography:
  display-lg:
    fontFamily: Noto Serif
    fontSize: 40px
    fontWeight: '600'
    lineHeight: 48px
    letterSpacing: -0.02em
  display-md:
    fontFamily: Noto Serif
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Noto Serif
    fontSize: 24px
    fontWeight: '500'
    lineHeight: 32px
  headline-md:
    fontFamily: Noto Serif
    fontSize: 20px
    fontWeight: '500'
    lineHeight: 28px
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-md:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  container-margin: 24px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
  stack-xl: 64px
---

## Brand & Style

This design system is defined by an editorial sensibility, blending high-fashion minimalism with a digital-first approach. It targets a discerning audience that values clarity, exclusivity, and aesthetic restraint. The emotional response is one of calm sophistication, evoking the feeling of a luxury boutique or a high-end fashion editorial.

The style is rooted in **Minimalism** with subtle **Tactile** influences. It prioritizes generous whitespace to allow product photography to breathe, utilizing clean lines and a restricted color palette to maintain focus on the items. Depth is achieved through soft, ambient shadows rather than heavy borders, creating a lightweight, airy interface that feels premium and curated.

## Colors

The palette is anchored by a sophisticated hierarchy of neutrals and a singular, radiant accent.

- **Primary (Accent):** A muted, elegant Gold used sparingly for primary actions, calls-to-action, and critical highlights.
- **Secondary (Core):** A deep Charcoal Gray used for primary text and structural icons, providing high contrast against cream backgrounds.
- **Tertiary (Surface):** A Soft Cream that serves as the primary canvas color, offering a warmer, more premium alternative to pure white.
- **Neutral:** A range of mid-tone grays used for secondary text, borders, and inactive states to maintain a low-friction visual environment.

## Typography

This design system utilizes a traditional/modern pairing to establish editorial authority. 

**Noto Serif** is reserved for display and headline levels. It should be used to convey a sense of timelessness and luxury. Large display headings benefit from slightly tighter letter spacing.

**Manrope** provides a highly readable, geometric foundation for all functional text. It is used for body copy, buttons, and labels. Label styles utilize an uppercase transform and increased letter spacing to create clear visual separation for metadata and categories.

## Layout & Spacing

The layout philosophy follows a **fluid grid** model optimized for mobile viewing, emphasizing vertical rhythm and generous horizontal breathing room. 

- **Margins:** A wide 24px side margin is mandatory to maintain the "high-end" feel and prevent the UI from appearing cluttered.
- **Rhythm:** An 8px-based spacing system is used for most components, while larger 32px and 64px gaps are used to separate distinct content sections (e.g., between a product title and the descriptive text).
- **Grid:** For card layouts, use a 2-column grid with a 16px gutter to maximize image visibility while allowing for side-by-side comparison.

## Elevation & Depth

Visual hierarchy is established through a combination of **tonal layers** and **ambient shadows**. 

- **Surface Tiers:** Backgrounds use the Tertiary Soft Cream. Cards and modals use pure White (#FFFFFF) to subtly lift them from the base surface.
- **Shadow Character:** Shadows must be extremely diffused and low-opacity. Use a large blur radius (20px+) with a low alpha (approx 4-6%) charcoal tint. 
- **Interaction:** Upon interaction, components should not "pop" with heavy shadows; instead, they should use a subtle scale-down effect (98%) or a slight darkening of the background color to maintain the minimalist aesthetic.

## Shapes

The shape language is refined and consistent, leaning toward **Rounded** (Level 2).

- **Standard Elements:** Buttons and input fields use a 0.5rem (8px) radius.
- **Cards & Containers:** Clothing item cards and larger containers utilize a 1rem (16px) radius to soften the visual impact of high-density imagery.
- **Icons:** Use thin-stroke (1.5px) icons with slightly rounded caps to match the geometric nature of the Manrope typeface. Avoid sharp, filled icons unless used for active navigation states.

## Components

- **Buttons:** Primary buttons feature a Gold background with Charcoal text for maximum contrast. Secondary buttons are outlined in Charcoal with a transparent background. All buttons have a height of 56px for touch accessibility.
- **Cards:** Clothing item cards are the centerpiece. Use a 16px corner radius and a subtle ambient shadow. Images should have a 3:4 aspect ratio. Text within cards (Price, Name) should be center-aligned or left-aligned with ample padding (12px).
- **Input Fields:** Use a minimalist "floating label" style with a 1px bottom border in Charcoal. Avoid fully enclosed boxes unless for search bars.
- **Chips:** For sizes and categories, use Manrope Label-md text inside a Soft Cream capsule with a 1px Charcoal border.
- **Lists:** Product lists should feature generous vertical padding (20px+) and thin, light-gray dividers to maintain an airy feel.
- **Additional Elements:** Implement a "curated collection" slider that uses Noto Serif for section titles, emphasizing the editorial nature of the app.