# Zones — Brand Guidelines

## App Overview
Zones is a native macOS world clock and timezone manager. Track multiple cities, visualize time differences, and schedule meetings across time zones without mental math.

---

## Icon Concept

**Visual:** A stylized globe or circular world map with meridian lines, with a clock overlay.
- A rounded square icon
- A simple globe in brand indigo/purple tones
- Overlaid with a subtle clock face or time zone wedge
- Clean, flat, modern cartographic style
- Sizes: 16, 32, 64, 128, 256, 512, 1024

**Alternative concept:** A simple circle divided into colored wedges (like a pie chart) representing different time zones, with city abbreviations around the edge.

---

## Color Palette

| Role | Hex | Usage |
|------|-----|-------|
| Primary Indigo | `#6366F1` | Active states, current time zone, CTAs |
| Deep Indigo | `#4F46E5` | Pressed states, dark mode accent |
| Light Indigo | `#A5B4FC` | Highlights, selected zone |
| Daytime Yellow | `#FBBF24` | Daytime hours in zone cards |
| Night Purple | `#7C3AED` | Nighttime hours |
| Sunrise Orange | `#F97316` | Dawn hours |
| Sunset Pink | `#EC4899` | Dusk hours |
| Background Light | `#F8FAFC` | Main background (light) |
| Background Dark | `#0F0F23` | Main background (dark) |
| Surface Light | `#FFFFFF` | Cards (light) |
| Surface Dark | `#1E1B4B` | Cards (dark) |
| Text Primary Light | `#1E293B` | Headings (light) |
| Text Primary Dark | `#E2E8F0` | Headings (dark) |
| Text Secondary | `#64748B` | Subtitles, secondary info |
| Border Light | `#E2E8F0` | Dividers (light) |
| Border Dark | `#312E81` | Dividers (dark) |
| Success | `#10B981` | Meeting slot available |
| Warning | `#F59E0B` | Overlap warning |
| Destructive | `#EF4444` | Remove city |

---

## Typography

- **Display / City Name:** SF Pro Display, Bold — 20px
- **Current Time (large):** SF Pro Display, Light — 48px (large, the hero number)
- **Section Headings:** SF Pro Text, Semibold — 14px
- **Time (zone cards):** SF Pro Rounded, Medium — 24px
- **Body / Labels:** SF Pro Text, Regular — 13px
- **Caption / Offset:** SF Pro Text, Regular — 12px, secondary

**Font Stack:**
```
font-family: -apple-system, BlinkMacSystemFont, "SF Pro Rounded", "SF Pro Display", sans-serif;
```

---

## Visual Motif

**Theme:** "Earth from Above" — cartographic, clean, with a sense of global scale. The app should feel like looking at Earth from orbit — serene, organized, connected.

- **Zone cards:** Each city shown as a rounded card with:
  - City name + country flag emoji
  - Large current time (hero element)
  - Day/night arc indicator (yellow = day, purple = night)
  - UTC offset below
- **Day/night visualization:** A subtle arc/wave above the time that transitions yellow→orange→purple based on time of day
- **Meeting planner:** A horizontal strip showing overlapping availability across selected zones
- **Menu bar:** Optional time display for primary zone
- **Empty state:** A small globe with latitude/longitude grid lines, "Add your first city"

**Spatial rhythm:** 8pt grid. Cards in responsive grid (2-4 columns based on window width). Card padding 16px.

---

## macOS-Specific Behavior

- **Window:** `NSWindow` with toolbar. Minimum 700×500. Resizable.
- **Menu Bar:** Optional menu bar icon showing primary city time.
- **Drag-to-reorder:** City cards can be dragged to reorder
- **Meeting slots:** Visual bar showing overlapping business hours across selected zones
- **Dark Mode:** Full support. Night purple becomes deeper shade.
- **Keyboard shortcuts:** `⌘N` add city, `⌘⇧N` new meeting slot, `⌘R` refresh time.

---

## Sizes & Behavior

| Element | Default | Compact (Menu Bar) |
|---------|---------|--------------------|
| Zone card | 280×160px | 200×120px |
| Time display | 48px font | 24px font |
| Icon size | 16×16 | 14×14 |
| Card padding | 16px | 12px |
| Grid columns | 2-4 (responsive) | 2 |

Window resizable. Cards reflow in grid. Menu bar mode: single compact line.
