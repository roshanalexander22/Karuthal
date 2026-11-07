# Sahaayi Accessibility & Inclusive Design Guidelines

Designed in compliance with **WCAG 2.1 AA/AAA** and tailored specifically for senior citizens and users with visual or motor impairments.

---

## 1. Visual Design Rules
- **Minimum Touch Targets**: Every button, interactive element, and toggle must be at least **56x56 dp** (exceeding the standard 48x48 dp Android baseline).
- **High Contrast Ratios**: Text-to-background contrast ratio must be at least **7:1** for normal text and **4.5:1** for large text.
- **Dynamic Type Support**: UI layouts must scale up to 200% font scaling without text truncation or layout overflow (`RenderFlex` errors).
- **Malayalam Typography**: Legible font families with clear vowel ligatures (e.g., *Noto Sans Malayalam*). Minimum body font size: **18 sp**.

---

## 2. Interaction Patterns
- **No Complex Gestures**: Avoid multi-finger swipes, long-press-and-drag, or pinch-to-zoom requirements. Single tap and voice confirmation only.
- **Audio & Haptic Feedback**: Every action provides distinct auditory and haptic acknowledgement.
- **Screen Reader Semantics**: All widgets must declare descriptive `Semantics(label: ...)` in both Malayalam and English.

---

## 3. Voice-First Ergonomics
- Clear speech pace control: Default speech rate is set to 0.85x normal speed to accommodate elderly auditory processing.
- Simple, respectful phrasing in Malayalam (*"ശരി, ഞാൻ ഇത് വായിക്കാം"* - *"Sure, I will read this for you"*).
