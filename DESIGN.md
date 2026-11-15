# DESIGN.md - Rutin Visual System

Dial: ENERGY 2 / RHYTHM 2 / MOTION 2
Mode: Operate (mobile task & daily ritual tracker)

## 1. Visual Identity & Soul

Rutin feels like a **tactile daily field notebook** rather than a sterile corporate dashboard or a neon gamified arcade.
- **Primary Identity Motif:** Tactile bordered surfaces (`1dp` crisp stroke on warm paper/pine ink, zero floating drop-shadows) paired with a single **tabular ritual progress bar** that celebrates completion when all scheduled habits for the day are done.
- **One Focal Point per Screen:**
  - **Home (`/`):** Today's Ritual Progress header (`done/target` + progress bar + completion banner) leading directly into the one-tap habit list.
  - **Detail (`/habit/:id`):** Hero Streak Banner (Current Streak as primary number, Best Streak as secondary anchor), followed by a 3-column tabular rate strip and the 3-month activity heatmap.
  - **Form (`/habit/new`, `/habit/:id/edit`):** Grouped field sections with live preview of the chosen color and icon.
  - **Onboarding (`/onboarding`):** Editorial welcome card with 3 concrete value pillars (1-tap check, offline privacy, streak heatmap) and a specific CTA.

## 2. Color System (2 Core + 1 Accent + 9 Habit Swatches)

Every color has a single written role (R-01, R-29, R-31):
- **Core 1 - Forest Emerald (`#1B6B45` light / `#4ADE80` dark):** Primary brand action, active navigation, and completed progress bar fill. Chosen to evoke steady daily growth without the AI-default blue-purple gradient.
- **Core 2 - Warm Paper & Pine Ink Neutrals:**
  - Light canvas: `#FAF7F2` (background), `#F2EDE4` (secondary container), `#FFFFFF` (card surface), `#1C1917` (stone ink text), `#57534E` (muted text), `#E5DEC9` (1dp border).
  - Dark canvas: `#111513` (background), `#1A201D` (card surface), `#242C28` (secondary container), `#F5F3EF` (warm white text), `#A8A29E` (muted text), `#2E3833` (1dp border).
- **Deliberate Accent - Amber Sun (`#D97706` light / `#F59E0B` dark):** Used **only** at the key moment (active streak counter and 100% daily completion banner).
- **9 Habit Swatches (`habitColors`):** Mid-luminance swatches verified at `>= 3.0:1` contrast against both light (`#FFFFFF`) and dark (`#1A201D`) card surfaces.

## 3. Typography & Numeric Discipline

- System geometric/humanist sans (`Roboto` on Android) with tight scale steps and explicit weight hierarchy (`w700` display/titles, `w600` section headers, `w400` body).
- `FontFeature.tabularFigures()` enabled on all counters (`done/target`, streak numbers, percentages, reminder times) so digits never jitter when incremented.

## 4. Spacing, Radius, and Elevation Scale

- **Spacing scale:** `4, 8, 12, 16, 24, 32 dp`. More space above section headers (`24dp`) than below (`8dp`).
- **Radius hierarchy (R-11 - not pill-everything):**
  - `rMicro = 4dp`: heatmap cells
  - `rControl = 12dp`: week-strip day tiles, inputs, frequency segments
  - `rCard = 16dp`: habit cards, hero streak banner, stat strip
  - `rPill = 999dp`: check-off toggle button and primary CTA button only
- **Elevation (R-12):** `0` shadow on cards and bars; hierarchy is established via surface tint and `1dp` border (`outlineVariant`).

## 5. Motion Purpose (MOTION 2, 150-250ms)

- `200ms` (`Curves.easeOutCubic`) on habit completion toggle (`AnimatedSwitcher` + scale/icon swap) and daily progress bar fill (`TweenAnimationBuilder`).
- No endless loops, no decorative pulsing dots, no page-load choreography.
