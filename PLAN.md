# Plan — `dAIly drip` iOS app (DAIly Drip wardrobe + outfit generator)

> Per user request, after approval this file should be copied to `/Users/patrick/ioskonf_project/PLAN.md` (the repo root) as the first implementation step.

## Context

The repo contains a fresh Xcode SwiftUI skeleton (`dAIly drip/`, bundle id `io.iosKonf.dAIly-drip`, iOS 26.2 deployment target, no dependencies) and a complete set of HTML/PNG mockups in `stitch_design/` covering 4 screens plus a design-system spec. The goal is to turn that skeleton into a shippable iOS app — codenamed **DAIly Drip** in the mockups — that:

1. Onboards each user with a free-form (text or voice) self-description and uses AI to extract a structured style profile (gender, age, preferred styles, colors, vibe).
2. Lets the user build a digital **closet** by photographing garments; AI categorizes each item (type, season, occasion, dominant color) and the user can edit the suggestion before saving.
3. Generates **outfit recommendations** from the user's actual closet on demand (text or voice prompt for the occasion), respecting the stored style profile.

User decisions captured during planning:

- **AI:** Firebase AI Logic with **Gemini** (multimodal text + vision in one SDK).
- **Persistence:** **Firebase** — Auth (anonymous → upgradeable), Firestore for profile + closet metadata, Cloud Storage for photos.
- **Photo input:** both camera (default) and photo library, behind a single sheet.
- **Tab structure:** to be finalized during implementation; the plan defaults to *4 tabs (Closet · Generate · Scan · Profile) + a first-run onboarding cover sheet*, matching every mockup.

## High-level architecture

```
┌─────────────────────────────────────────────────────────────┐
│  SwiftUI app  (iOS 26.2, Swift 6 strict concurrency)        │
│                                                             │
│  Features/                                                  │
│   ├─ Onboarding   ── ProfilePromptView                      │
│   ├─ Closet       ── ClosetView, ItemDetailView             │
│   ├─ Scan         ── CapturePicker, ScanReviewView          │
│   ├─ Generate     ── OutfitGeneratorView, OutfitDetail      │
│   └─ Profile      ── ProfileView (re-enter onboarding)      │
│                                                             │
│  DesignSystem/    tokens, typography, components            │
│  Services/        AuthService, ProfileRepo, ClosetRepo,     │
│                   StorageService, AIService (Gemini),       │
│                   SpeechService                             │
│  Models/          UserProfile, ClosetItem, Outfit, enums    │
└─────────────────────────────────────────────────────────────┘
                ↓                        ↓
        Firebase Auth            Firebase AI Logic → Gemini
        Firestore                (text + vision, structured
        Cloud Storage             output via responseSchema)
```

Concurrency: strict Swift 6, `@MainActor` on views and view models, repos as `actor`s where they mutate caches, AI calls as `async throws` returning typed structs.

## Phase 0 — Repo + tooling prep

1. **Copy this plan** to `/Users/patrick/ioskonf_project/PLAN.md`.
2. **README.md** at repo root with project description, setup steps, and Firebase config instructions.
3. **`.gitignore`** — extend to ignore `GoogleService-Info.plist`, `*.xcuserstate`, `DerivedData/`, `xcuserdata/`, `.swiftpm/xcode/package.workspace`.
4. **`CLAUDE.md`** at repo root capturing the conventions in this plan (architecture, module boundaries, no force-unwraps, Swift 6 concurrency, design-token usage).
5. Adopt **swift-format** with the project's existing repo skill set (the `swiftui-pro` and `swift-concurrency` skills are already locked).

## Phase 1 — Firebase + dependencies

1. Create Firebase project (manual user step — document in README): enable Auth (Anonymous + Apple Sign-In), Firestore, Storage, **Vertex AI in Firebase** / Firebase AI Logic.
2. Drop `GoogleService-Info.plist` into the app target (gitignored).
3. Add SwiftPM dependencies via Xcode → Package Dependencies on `https://github.com/firebase/firebase-ios-sdk`:
   - `FirebaseAuth`
   - `FirebaseFirestore`
   - `FirebaseStorage`
   - `FirebaseAI` (Firebase AI Logic SDK — Gemini access)
4. Configure Firebase in `dAIly_dripApp.swift` via `FirebaseApp.configure()` in an `init()`.
5. Anonymous sign-in on first launch in an `AuthService` actor; expose `currentUserID` via `@Observable`. Defer real account upgrade to a follow-up.

## Phase 2 — Design system foundation

> **Canonical source:** the design tokens and component specs below are taken verbatim from `stitch_design/DESIGN.md` (also mirrored at `stitch_design/the_design_system/DESIGN.md` — the two files are identical). All values in this section are the source of truth; the SwiftUI implementation must mirror them, and views must **never** hard-code colors, fonts, radii, or spacing.

### 2.1 Brand & visual language

Editorial high-fashion minimalism with subtle tactile depth — a calm, luxury-boutique feel. Generous whitespace, restricted palette, soft ambient shadows (no heavy borders). Interaction depth = scale-down 98% / subtle background darkening, never heavy "pop" shadows.

### 2.2 Color tokens (light)

The palette is anchored by a hierarchy of neutrals and a single radiant gold accent.

| Token | Hex | Role |
|---|---|---|
| `primary` / `surface-tint` | `#775a19` | Muted gold accent — primary actions, active nav, CTAs |
| `on-primary` | `#ffffff` | Foreground on primary |
| `primary-container` | `#c5a059` | Lighter gold for containers/highlights |
| `on-primary-container` | `#4e3700` | Foreground on primary-container |
| `inverse-primary` | `#e9c176` | Inverted accent (e.g., on dark surfaces) |
| `primary-fixed` | `#ffdea5` | Fixed pale gold |
| `primary-fixed-dim` | `#e9c176` | Fixed dim gold |
| `on-primary-fixed` | `#261900` | |
| `on-primary-fixed-variant` | `#5d4201` | |
| `secondary` | `#5f5e5e` | Charcoal — primary text, structural icons |
| `on-secondary` | `#ffffff` | |
| `secondary-container` | `#e2dfde` | |
| `on-secondary-container` | `#636262` | |
| `secondary-fixed` | `#e5e2e1` | |
| `secondary-fixed-dim` | `#c8c6c5` | |
| `on-secondary-fixed` | `#1c1b1b` | |
| `on-secondary-fixed-variant` | `#474746` | |
| `tertiary` | `#5e5e5b` | Mid neutral |
| `on-tertiary` | `#ffffff` | |
| `tertiary-container` | `#a6a5a1` | |
| `on-tertiary-container` | `#3b3b38` | |
| `tertiary-fixed` | `#e4e2dd` | |
| `tertiary-fixed-dim` | `#c8c6c2` | |
| `on-tertiary-fixed` | `#1b1c19` | |
| `on-tertiary-fixed-variant` | `#474744` | |
| `surface` / `background` / `surface-bright` | `#fbf9f9` | Soft cream — main canvas |
| `surface-dim` | `#dbdad9` | Dimmed surface |
| `surface-container-lowest` | `#ffffff` | Cards, modals (lifted from surface) |
| `surface-container-low` | `#f5f3f3` | |
| `surface-container` | `#efeded` | |
| `surface-container-high` | `#e9e8e7` | |
| `surface-container-highest` | `#e4e2e2` | |
| `surface-variant` | `#e4e2e2` | |
| `on-surface` / `on-background` | `#1b1c1c` | Primary text |
| `on-surface-variant` | `#4e4639` | Secondary text / metadata |
| `inverse-surface` | `#303031` | Snackbars, dark overlays |
| `inverse-on-surface` | `#f2f0f0` | |
| `outline` | `#7f7667` | Borders, dividers |
| `outline-variant` | `#d1c5b4` | Subtle dividers |
| `error` | `#ba1a1a` | |
| `on-error` | `#ffffff` | |
| `error-container` | `#ffdad6` | |
| `on-error-container` | `#93000a` | |

### 2.3 Typography (Noto Serif + Manrope)

Display + headline use Noto Serif (editorial authority); body, buttons, labels use Manrope. Label styles uppercase + +0.05em tracking.

| Style | Family | Size | Weight | Line height | Tracking |
|---|---|---|---|---|---|
| `display-lg` | Noto Serif | 40 | 600 | 48 | -0.02em |
| `display-md` | Noto Serif | 32 | 600 | 40 | -0.01em |
| `headline-lg` | Noto Serif | 24 | 500 | 32 | — |
| `headline-md` | Noto Serif | 20 | 500 | 28 | — |
| `body-lg` | Manrope | 18 | 400 | 28 | — |
| `body-md` | Manrope | 16 | 400 | 24 | — |
| `body-sm` | Manrope | 14 | 400 | 20 | — |
| `label-lg` | Manrope | 14 | 600 | 20 | +0.05em, UPPERCASE |
| `label-md` | Manrope | 12 | 600 | 16 | +0.05em, UPPERCASE |

The "DAIly Drip" wordmark is **Noto Serif italic** (per the mockups; not a discrete token, but always render the brand mark this way).

### 2.4 Spacing (4px base)

| Token | px |
|---|---|
| `unit` | 4 |
| `stack-sm` | 8 |
| `stack-md` | 16 |
| `gutter` | 16 |
| `container-margin` | 24 |
| `stack-lg` | 32 |
| `stack-xl` | 64 |

Rules: 24px side margins are **mandatory** on every screen. 8px rhythm within components. 32–64px between distinct content sections. 2-column grids use a 16px gutter.

### 2.5 Radius

| Token | rem | pt |
|---|---|---|
| `sm` | 0.25 | 4 |
| `DEFAULT` | 0.5 | 8 |
| `md` | 0.75 | 12 |
| `lg` | 1 | 16 |
| `xl` | 1.5 | 24 |
| `full` | — | capsule |

Buttons + inputs: **8pt**. Item cards + large containers: **16pt**. Chips: capsule.

### 2.6 Elevation

- Surface tiers: cream `surface` (#fbf9f9) for backgrounds, white `surface-container-lowest` (#fff) for cards/modals to subtly lift.
- Shadows: extremely diffused — blur ≥ 20pt, alpha 4–6% on charcoal (`on-surface` tint).
- Interaction: 98% scale-down or background darkening — never heavier shadow on press.

### 2.7 Component specs (verbatim from DESIGN.md)

- **Primary button:** gold (`primary`) bg, charcoal text, 56pt tall, 8pt radius, label-lg text, scale-down 98% on press.
- **Secondary button:** transparent bg, 1px charcoal outline, charcoal text, 56pt tall, 8pt radius.
- **Item card:** 16pt radius, ambient shadow (≥20px blur, 4–6% charcoal), 3:4 image aspect, name + chips with 12pt padding, left- or center-aligned.
- **Input field:** floating-label style — 1px charcoal bottom border, no enclosing box (except search bars).
- **Chip:** capsule, soft-cream bg, 1px charcoal border, label-md text (uppercase + tracked).
- **Lists:** 20pt+ vertical padding per row, thin light-gray dividers (`outline-variant`).
- **Icons:** 1.5px stroke, slightly rounded caps. Use **filled** variants only for active bottom-nav state.
- **Curated collection slider** (Noto Serif section title) — reserved for future "saved outfits" rail.

### 2.8 Mapping to SwiftUI files

Files to create under `dAIly drip/DesignSystem/`:

| File | Purpose |
|---|---|
| `Color+Tokens.swift` | All semantic colors (primary `#775a19`, on-primary, surface `#fbf9f9`, surface-container, on-surface `#1b1c1c`, outline `#7f7667`, error, etc.) as `extension Color`. Provide both light values now; dark mode is a later concern. |
| `Typography.swift` | `Font.displayLg/displayMd/headlineLg/headlineMd/bodyLg/bodyMd/bodySm/labelLg/labelMd` using Noto Serif + Manrope. Includes a `.styleAILabel()` view modifier that uppercases + applies tracking for label styles. |
| `Spacing.swift` | `enum Spacing { static let unit: CGFloat = 4 ... stackXl = 64 }` plus `containerMargin = 24`, `gutter = 16`. |
| `Shapes.swift` | `RoundedRectangle` constants: `r8`, `r12`, `r16`, `r24`. |
| `Components/PrimaryButton.swift` | 56pt-tall, gold bg, label-lg text, scale-down 98% on press, optional trailing chevron. |
| `Components/SecondaryButton.swift` | Outlined charcoal variant. |
| `Components/Chip.swift` | Capsule, soft-cream bg, 1px charcoal border, label-md. Selectable variant for filter tabs/quick prompts. |
| `Components/FloatingLabelTextField.swift` | 1px bottom border, animated label, supports multi-line for the onboarding prompt. |
| `Components/ItemCard.swift` | 3:4 aspect image + name + chips, 16px radius, ambient shadow (20px blur, 5% charcoal). |
| `Components/BentoOutfitCard.swift` | 1 large 3:4 left + 2 stacked squares right, "Option 0X" label, italic Noto Serif title, "Wear This" CTA. |
| `Components/DAIlyDripTopBar.swift` | Menu icon · "DAIly Drip" Noto Serif italic wordmark · account icon. |
| `Components/DAIlyDripTabBar.swift` | Custom 4-tab bar (Closet / Generate / Scan / Profile) using SF Symbol thin-stroke icons + label-md serif labels; gold-tinted active state. |

**Fonts:** add Noto Serif (regular, italic, 500, 600) and Manrope (400, 600) via `.ttf`/`.otf` files in `Resources/Fonts/`, registered in the target's `UIAppFonts` Info.plist key (set via build setting since the project has no Info.plist file).

## Phase 3 — Data models

Create `dAIly drip/Models/`:

```swift
struct UserProfile: Codable, Identifiable {
    var id: String                 // == Firebase uid
    var rawDescription: String     // user's free-form prompt
    var age: Int?
    var gender: Gender?
    var preferredStyles: [String]  // e.g. "Minimalist", "Streetwear"
    var preferredColors: [String]
    var vibe: String?
    var updatedAt: Date
}

enum Gender: String, Codable, CaseIterable { case female, male, nonBinary, preferNotToSay }

struct ClosetItem: Codable, Identifiable {
    var id: String                 // Firestore doc id
    var ownerId: String
    var imagePath: String          // Cloud Storage path
    var thumbnailURL: URL?
    var name: String               // editable, default = AI-suggested
    var type: ItemType             // Tops / Bottoms / Shoes / Accessories / Outerwear / Dress
    var seasons: Set<Season>
    var occasions: Set<Occasion>
    var primaryColor: ColorTag     // name + hex
    var materials: [String]
    var createdAt: Date
}

enum ItemType: String, Codable, CaseIterable { case tops, bottoms, shoes, accessories, outerwear, dress }
enum Season: String, Codable, CaseIterable { case spring, summer, autumn, winter }
enum Occasion: String, Codable, CaseIterable { case casual, formal, business, sport, evening, beach }
struct ColorTag: Codable, Hashable { var name: String; var hex: String }

struct Outfit: Codable, Identifiable {
    var id: String
    var prompt: String
    var optionLabel: String        // "Option 01"
    var title: String              // "Evening Elegance"
    var itemIds: [String]          // 2-4 closet item ids
    var rationale: String          // short editorial blurb
    var createdAt: Date
}
```

Firestore layout:
```
users/{uid}                    → UserProfile
users/{uid}/items/{itemId}     → ClosetItem
users/{uid}/outfits/{outfitId} → Outfit
```
Cloud Storage layout: `users/{uid}/items/{itemId}.jpg` (full) + `_thumb.jpg`.

Security rules (capture in `firestore.rules` + `storage.rules` checked into the repo): each user can read/write only their own subtree.

## Phase 4 — Services

Under `dAIly drip/Services/`:

- **`AuthService` (actor, `@Observable` wrapper)** — anonymous sign-in on launch, exposes `userID`, listens to auth state.
- **`StorageService`** — uploads JPEG (max-edge 1600px, 0.85 quality) + 400px thumbnail, returns paths/URLs. Uses `AsyncThrowingStream` for upload progress.
- **`ProfileRepository`** — `func load() async throws -> UserProfile?`, `func save(_:) async throws`. Single-document Firestore listener exposed as `AsyncStream<UserProfile?>`.
- **`ClosetRepository`** — CRUD on `users/{uid}/items/*`, plus `items() -> AsyncStream<[ClosetItem]>` snapshot listener.
- **`OutfitRepository`** — saved generated outfits (so users can revisit).
- **`AIService`** — single entry point wrapping Firebase AI Logic + Gemini. Three methods (see Phase 5).
- **`SpeechService`** — wraps `SFSpeechRecognizer` + `AVAudioEngine` for live dictation, exposing `transcribe() -> AsyncThrowingStream<String, Error>`. Requires `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription`.
- **`PermissionsService`** — small helper for camera, photo library, mic, speech.

## Phase 5 — AI flows (Gemini via Firebase AI Logic)

Use `gemini-2.5-flash` for speed/cost on the categorize + extract paths and `gemini-2.5-pro` for outfit reasoning. Always request **structured output** via `responseMIMEType = "application/json"` + `responseSchema` so we decode straight into the `Codable` models above.

### 5.1 Profile extraction (text)
**Input:** `rawDescription: String`.
**Output schema:** subset of `UserProfile` (age, gender, preferredStyles, preferredColors, vibe).
**System prompt:** "You are a fashion stylist. Extract structured style attributes from a user's self-description. Be conservative — leave fields null when not stated."
**Used by:** `OnboardingViewModel.buildProfile()`.

### 5.2 Item categorization (vision)
**Input:** JPEG bytes (the captured photo).
**Output schema:** `{ name, type, seasons[], occasions[], primaryColor{name,hex}, materials[] }`.
**System prompt:** "You are categorizing a single clothing item from a photo. Return one type from {tops, bottoms, shoes, accessories, outerwear, dress}. Choose seasons/occasions conservatively."
**Used by:** `ScanReviewViewModel.analyze(image:)`. The view shows results in the bento-grid attribute cards; user edits, then taps "Save to Closet".

### 5.3 Outfit generation (text + structured catalog)
**Input:** the user prompt (occasion), the `UserProfile`, and the full closet as a JSON list of `{id, name, type, primaryColor.name, seasons, occasions}` (no images — keeps prompt small; under ~500 items is fine).
**Output schema:** array of 2-3 outfits, each `{ optionLabel, title, itemIds:[…], rationale }`.
**Constraint reinforced in the prompt:** every `itemIds` value MUST exist in the supplied closet; reject by validating in code and re-prompting once on mismatch.
**Used by:** `OutfitGeneratorViewModel.generate(prompt:)`. Results render into `BentoOutfitCard` using thumbnails fetched from `ClosetRepository`.

## Phase 6 — Screens

Each feature folder owns its `View` + `ViewModel` (the latter `@Observable`, `@MainActor`).

### 6.1 Onboarding (`Features/Onboarding/`)
- `OnboardingFlowView` — shown via `.fullScreenCover` from the root when `profileRepo.load()` returns nil.
- `ProfilePromptView` — hero copy, large `FloatingLabelTextField` (multi-line), microphone toggle (`SpeechService`) with a live transcript + "Stop" button, character counter, moodboard 2-column grid (static placeholder images for now), `PrimaryButton` "Build My Profile".
- On submit: call `AIService.extractProfile`, push to a confirmation step that shows the extracted chips (gender, style, colors, vibe), each chip tappable for inline edit. "Save & Continue" persists via `ProfileRepository` and dismisses.

### 6.2 Closet (`Features/Closet/`)
- `ClosetView` — top bar, "My Closet" display headline, horizontal `Chip`-based filter tabs (`ItemType.allCases`), `LazyVGrid` 2-col with `ItemCard`, FAB ("+") in bottom-right.
- Tapping FAB presents `CapturePickerSheet` (camera default, library option). The captured `UIImage` flows into the Scan flow.
- Tapping an `ItemCard` pushes `ItemDetailView` (large image + editable attribute cards mirroring Scan layout, plus delete).

### 6.3 Scan (`Features/Scan/`)
- `CapturePickerSheet` — `confirmationDialog` with "Take Photo" / "Choose from Library", driving `UIImagePickerController` (camera) and `PhotosPicker` (library).
- `ScanReviewView` — image canvas (3:4), "AI Analysis Active" pulse while `AIService.categorize` is in flight, then four editable attribute cards (Type, Season, Occasion, Color). "Save to Closet" → `StorageService.upload` → `ClosetRepository.create` → dismiss.
- The Scan tab itself just opens the same `CapturePickerSheet` directly.

### 6.4 Generate (`Features/Generate/`)
- `OutfitGeneratorView` — header copy, prompt bar (text field + mic), horizontal `Chip` strip of canned occasions ("Chic Dinner Date", "Business Casual", "Weekend Brunch", "Wedding Guest", "Travel Day"), submit triggers `viewModel.generate(prompt:)`.
- Results: vertical scroll of `BentoOutfitCard`s. Tapping "Wear This" opens `OutfitDetailView` (lists items, lets the user save/star the outfit via `OutfitRepository`).
- Empty state when closet has < 3 items: nudge to add more before generating.

### 6.5 Profile (`Features/Profile/`)
- `ProfileView` — show extracted profile chips, "Re-do my profile" button (re-enters `OnboardingFlowView` modally), "Sign out / delete account" affordances (later).

### 6.6 Root
- `RootView` — switches between `OnboardingFlowView` (cover) and a `TabView` with the four tabs, using `DAIlyDripTabBar` overlay (or iOS 26 `Tab` + custom `tabBarMinimizeBehavior`).
- `dAIly_dripApp.swift` — `FirebaseApp.configure()`, injects `AuthService`, `ProfileRepository`, `ClosetRepository`, `OutfitRepository`, `AIService`, `SpeechService` into the environment.

## Phase 7 — Permissions (Info.plist via build settings)

Add the following usage descriptions:

- `NSCameraUsageDescription` — "Take photos of your wardrobe so DAIly Drip can categorize them."
- `NSPhotoLibraryUsageDescription` — "Choose existing photos to add to your closet."
- `NSMicrophoneUsageDescription` — "Dictate your style profile and outfit prompts."
- `NSSpeechRecognitionUsageDescription` — "Convert your voice to text for profile and outfit prompts."

## Phase 8 — Testing

The project already has Swift Testing + UI test bundles. Add:

- **Unit tests** (Swift Testing): JSON decoding for each `responseSchema`, `ProfileRepository` round-trip against the Firebase Local Emulator Suite (document the emulator setup in README), `ClosetRepository` filtering, color-name → hex mapping, prompt builder for outfit generation.
- **Snapshot/preview tests:** SwiftUI previews for every component in `DesignSystem/` (light only for v1).
- **UI tests:** scripted run of the onboarding cover, closet empty state, FAB → photo-library path (camera path stubbed).

## Critical files (to be created)

- `dAIly drip/dAIly_dripApp.swift` — modify (add Firebase configure + environment injection).
- `dAIly drip/RootView.swift` — new.
- `dAIly drip/DesignSystem/` — new directory, all files in Phase 2 table.
- `dAIly drip/Models/` — new directory (`UserProfile.swift`, `ClosetItem.swift`, `Outfit.swift`, `Enums.swift`).
- `dAIly drip/Services/` — new directory (`AuthService.swift`, `ProfileRepository.swift`, `ClosetRepository.swift`, `OutfitRepository.swift`, `StorageService.swift`, `AIService.swift`, `SpeechService.swift`, `PermissionsService.swift`).
- `dAIly drip/Features/{Onboarding,Closet,Scan,Generate,Profile}/` — views + view models per Phase 6.
- `dAIly drip/Resources/Fonts/` — Noto Serif + Manrope.
- `firestore.rules`, `storage.rules` at repo root.
- `PLAN.md`, `README.md`, `CLAUDE.md` at repo root.

## Verification

End-to-end tests on a real device (camera doesn't work in the simulator):

1. **Cold start** → onboarding cover appears. Type "I love minimalist tailoring, neutral palette, age 32 woman" → tap mic to append a sentence → "Build My Profile". Confirm extracted chips show `Female`, age 32, "Minimalist", earth-tone colors. Save.
2. **Closet** → tap FAB → take a photo of any garment. Watch "AI Analysis Active" pulse, then verify the four attribute cards are populated. Edit Season → Save. Item appears in the Closet grid under the correct category tab.
3. **Repeat** for at least 5 items spanning tops, bottoms, shoes.
4. **Generate** → type "Sunday brunch, mid-September" → submit. Two-three outfit cards render, each citing items from the closet (verify by tapping "Wear This"). Tap mic and dictate a different prompt.
5. **Profile tab** → "Re-do my profile" reopens the onboarding flow with the existing description prefilled.
6. **Network off** → ensure UI surfaces a friendly retry banner instead of crashing.
7. **Firestore console** → confirm documents are created at `users/{uid}/items/*` and `users/{uid}/outfits/*`, and Storage shows uploaded JPEGs + thumbnails.
8. **`xcodebuild test`** — unit + UI tests green.

## Out of scope (explicit non-goals for v1)

- Real account upgrade beyond anonymous (Apple/Google sign-in flow).
- Outfit calendar / planner / push reminders.
- Sharing outfits or social feeds.
- Multi-user / household closets.
- Dark mode (color tokens are structured for it, but visuals are designed light-first).
- iPad-specific layout tuning.
