# ServiceMark AI — Design System & Style Specification

**Version:** 1.0  
**Last Updated:** April 2026  
**Stack:** React 18, TypeScript, Tailwind CSS v3, Radix UI, Vite 5

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy)
2. [Color System](#2-color-system)
3. [Typography](#3-typography)
4. [Spacing & Layout](#4-spacing--layout)
5. [Shadows & Elevation](#5-shadows--elevation)
6. [Animation & Transitions](#6-animation--transitions)
7. [Component Specifications](#7-component-specifications)
8. [Admin Section Standards](#8-admin-section-standards)
9. [Responsive Strategy](#9-responsive-strategy)
10. [Copy & Terminology Conventions](#10-copy--terminology-conventions)
11. [Dark Mode](#11-dark-mode)
12. [Icon System](#12-icon-system)

---

## 1. Design Philosophy

- **Clean & Calm:** SaaS-style with abundant whitespace. Everything should feel trustworthy and operator-friendly.
- **High Contrast:** Dark slate sidebar, bright neutral main canvas.
- **Purposeful Teal:** Used selectively for CTAs, active states, and automation signals. Never decorative.
- **Status-Driven:** Colors carry urgency and intent. Every color communicates state.
- **No Hardcoded Colors:** All components use semantic CSS custom properties (design tokens). Never write `bg-white`, `text-black`, `bg-teal-500`, etc. Always use `bg-card`, `text-foreground`, `bg-primary`, etc.
- **No Em-Dashes:** UI copy never uses em-dashes. Messaging is short, direct, confident.

---

## 2. Color System

All colors are defined as HSL values in CSS custom properties (`index.css`). Components reference them via Tailwind utility classes mapped in `tailwind.config.ts`.

### 2.1 Brand Colors

| Token | HSL | Hex | Usage |
|---|---|---|---|
| `--color-primary-teal` | `180 100% 35%` | `#00B3B3` | Primary CTAs, active automation, links |
| `--color-slate` | `210 28% 16%` | `#1F2A33` | Sidebar, text, high-contrast elements |
| `--color-neutral-light` | `180 20% 97%` | `#F7F9F9` | Page backgrounds |

### 2.2 Semantic Tokens

| Token | HSL | Maps To | Usage |
|---|---|---|---|
| `--background` | `174 25% 97%` | `bg-background` | App background |
| `--foreground` | `210 28% 16%` | `text-foreground` | Primary text |
| `--card` | `0 0% 100%` | `bg-card` | Card/container backgrounds |
| `--card-foreground` | `210 28% 16%` | `text-card-foreground` | Text inside cards |
| `--primary` | `180 100% 35%` | `bg-primary`, `text-primary` | Brand teal for CTAs, active states |
| `--primary-foreground` | `0 0% 100%` | `text-primary-foreground` | Text on primary backgrounds |
| `--secondary` | `220 13% 91%` | `bg-secondary` | Secondary surfaces |
| `--muted` | `220 14% 96%` | `bg-muted` | Muted backgrounds, hover states |
| `--muted-foreground` | `220 9% 45%` | `text-muted-foreground` | Secondary text, labels, metadata |
| `--destructive` | `0 73% 50%` | `bg-destructive`, `text-destructive` | Errors, delete actions |
| `--warning` | `38 95% 52%` | `bg-warning` | Warnings, trial states |
| `--success` | `152 70% 46%` | `bg-success` | Success confirmations |
| `--border` | `220 13% 91%` | `border-border` | All borders |
| `--input` | `220 13% 91%` | `border-input` | Input field borders |
| `--ring` | `180 100% 32%` | `ring-ring` | Focus rings |
| `--radius` | `0.5rem` | `rounded-lg` | Default border radius |

### 2.3 Job Status Colors

Used for status badges and inline status text. Mapped to Tailwind via `smai-*` prefix.

| Status | Token | HSL | Tailwind Class | Visual |
|---|---|---|---|---|
| Awaiting Proposal | `--status-awaiting-proposal` | `217 95% 62%` | `bg-smai-status-awaiting` | Blue |
| Customer Waiting | `--status-customer-waiting` | `9 95% 65%` | `bg-smai-status-waiting` | Coral |
| Paused | `--status-paused` | `38 95% 52%` | `bg-smai-status-paused` | Amber |
| Delivery Issue | `--status-delivery-issue` | `0 78% 52%` | `bg-smai-status-issue` | Red |
| Active (Auto) | `--status-active` | `180 100% 35%` | `bg-smai-status-active` | Teal |
| Queued | `--status-queued` | `213 96% 68%` | `bg-smai-status-queued` | Light Blue |
| Closed Won | `--status-closed-won` | `152 70% 46%` | `bg-smai-status-won` | Green |
| Closed Lost | `--status-closed-lost` | `220 9% 64%` | `bg-smai-status-lost` | Gray |

### 2.4 Sidebar Tokens

| Token | HSL | Usage |
|---|---|---|
| `--sidebar-background` | `210 28% 16%` | Sidebar background (slate) |
| `--sidebar-foreground` | `0 0% 100%` | Sidebar text (white) |
| `--sidebar-primary` | `180 100% 35%` | Active nav item background |
| `--sidebar-accent` | `210 24% 22%` | Hover state on nav items |
| `--sidebar-border` | `210 24% 22%` | Internal sidebar dividers |

---

## 3. Typography

### 3.1 Font Stack

| Role | Family | Fallback |
|---|---|---|
| **Body / Headings** | `Inter` | `system-ui, -apple-system, sans-serif` |
| **Accents** | `Space Grotesk` | `system-ui, sans-serif` |

### 3.2 Type Scale (Utility Classes)

| Class | Size | Weight | Tracking | Usage |
|---|---|---|---|---|
| `.smai-h1` | `30px` / `36px` (lg) | Bold (700) | Tight | Page titles |
| `.smai-h2` | `20px` / `24px` (lg) | Semibold (600) | Tight | Section headers |
| `.smai-h3` | `16px` / `18px` (lg) | Semibold (600) | Normal | Subsection titles |
| `.smai-body` | `14px` / `16px` (lg) | Regular (400) | Normal | Body copy |
| `.smai-label` | `12px` | Semibold (600) | Wide, uppercase | Field labels, table headers, metadata |
| `.smai-accent` | — | — | — | Applies Space Grotesk font-family |

### 3.3 Label Convention

All field labels and table headers use the `.smai-label` class: **12px, semibold, uppercase, wide tracking, muted-foreground color**. This is a hard rule across all screens.

---

## 4. Spacing & Layout

### 4.1 Base Scale

4px base unit: `4, 8, 12, 16, 20, 24, 32, 48`

### 4.2 Page Layout

| Component | Spec |
|---|---|
| **PageContainer** | `max-w-[1280px]`, centered, `px-4 sm:px-6 lg:px-8`, `pt-6 lg:pt-8`, `pb-24 lg:pb-8` |
| **Desktop Sidebar** | Fixed left, `w-64`, full height, `bg-sidebar` |
| **Main Content Offset** | `lg:ml-64` (accounts for fixed sidebar) |
| **Content Card Width** | `max-w-3xl` or `max-w-5xl` depending on content density |
| **Horizontal Padding** | Unified `px-6` on desktop content cards |

### 4.3 Section Spacing

| Class | Value | Usage |
|---|---|---|
| `.smai-section-gap` | `space-y-8` | Between major page sections |
| `.smai-card-gap` | `space-y-4` | Between cards within a section |
| Form fields | `space-y-5` | Vertical rhythm inside forms |

---

## 5. Shadows & Elevation

| Token | Value | Tailwind Class | Usage |
|---|---|---|---|
| `--shadow-subtle` | `0 1px 3px 0 rgb(0 0 0 / 0.1)` | `shadow-smai-subtle` | Buttons, light elevation |
| `--shadow-card` | `0 1px 3px 0 rgb(0 0 0 / 0.12)` | `shadow-smai-card` | Card resting state |
| `--shadow-hover` | `0 4px 6px -1px rgb(0 0 0 / 0.1)` | `shadow-smai-hover` | Card hover state |
| (Tailwind) | `shadow-sm` | `shadow-sm` | Base card shadow |
| (Tailwind) | `shadow-lg` | `shadow-lg` | Hover-lifted cards |

---

## 6. Animation & Transitions

### 6.1 Standard Transitions

| Class | Spec | Usage |
|---|---|---|
| `.smai-transition` | `transition-all 200ms ease-out` | Default for all interactive elements |
| `.smai-hover-lift` | `hover:shadow-hover hover:-translate-y-0.5` | Unit cards (Job, KPI) |
| `.smai-hover-scale` | `hover:scale-[1.01]` | Subtle scale effect |
| `.smai-hover-border` | `hover:border-primary/30` | Border color shift on hover |

### 6.2 Card Interaction Standards

| Card Type | Hover Effect | Active Effect |
|---|---|---|
| **Unit cards** (Job Summary, KPI) | `shadow-lg`, `-translate-y-0.5`, `300ms` | `active:scale-[0.995]` |
| **Structural containers** (Hero, Trend, LOB) | None (static) | None |
| **Email preview** | `bg-primary/5` teal wash | None |

### 6.3 Keyframes

- `fade-in`: `opacity 0→1`, `translateY 10px→0`, `350ms ease-out`
- `accordion-down/up`: Height animation, `200ms ease-out`
- `attention-card-hover`: `shadow-md`, `-translate-y-[3px]`, `150ms`
- `collapseCard`: `opacity 1→0`, `max-height 500→0`, `200ms`

---

## 7. Component Specifications

### 7.1 SmaiButton

**Import:** `import { SmaiButton } from "@/components/smai"`

| Prop | Type | Default | Description |
|---|---|---|---|
| `variant` | `"primary" \| "secondary" \| "destructive" \| "ghost" \| "outline"` | `"primary"` | Visual style |
| `size` | `"sm" \| "md" \| "lg"` | `"md"` | Size preset |
| `isLoading` | `boolean` | `false` | Shows spinner, disables button |

**Variant Styles:**

| Variant | Background | Text | Border | Hover |
|---|---|---|---|---|
| `primary` | `bg-primary` | `text-primary-foreground` (white) | None | `bg-primary/90`, `shadow-hover` |
| `secondary` | `bg-white` | `text-primary` | `border-primary` | `bg-primary/5` |
| `destructive` | `bg-destructive` | `text-destructive-foreground` | None | `bg-destructive/90` |
| `ghost` | Transparent | `text-foreground` | None | `bg-muted` |
| `outline` | `bg-background` | `text-foreground` | `border-border` | `bg-muted` |

**Size Styles:**

| Size | Height | Padding | Font Size |
|---|---|---|---|
| `sm` | `h-9` | `px-3 py-2.5` | `text-sm` (14px) |
| `md` | `h-11` | `px-4 py-3` | `text-base` (16px) |
| `lg` | `h-12` | `px-6 py-3.5` | `text-lg` (18px) |

**Base Classes:** `rounded-lg`, `font-medium`, `transition-all 200ms ease-out`, `focus:ring-2 ring-primary ring-offset-2`

---

### 7.2 SmaiInput

**Import:** `import { SmaiInput } from "@/components/smai"`

| Prop | Type | Description |
|---|---|---|
| `label` | `string` | Uppercase label rendered above input |
| `error` | `string` | Red error message below input |
| `fieldKey` | `string` | Auto-resolves label/placeholder from field registry |
| `prefix` | `string` | Inline prefix (e.g., "$") |

**Spec:**
- Height: `h-12`
- Border: `border-border`, `rounded-lg`
- Background: `bg-white` (use `bg-card` in dark mode contexts)
- Focus: `ring-2 ring-primary`, border becomes `border-primary`
- Hover: `border-primary/50`
- Placeholder: `text-muted-foreground`
- Transition: `200ms ease-out`
- Label style: `.smai-label` (12px, uppercase, semibold, tracking-wide)
- Required indicator: Red asterisk `*` via `text-destructive`

---

### 7.3 SmaiTextarea

Same styling as SmaiInput with these differences:
- Min height: `min-h-[120px]`
- Resize: `resize-none`
- All other tokens identical

---

### 7.4 SmaiSelect

**Import:** `import { SmaiSelect } from "@/components/smai"`

Built on Radix UI `Select` primitive. **Not** a native `<select>`.

| Prop | Type | Description |
|---|---|---|
| `label` | `string` | Uppercase label |
| `error` | `string` | Error message |
| `options` | `{ value, label, group? }[]` | Options with optional grouping |
| `value` | `string` | Controlled value |
| `onValueChange` | `(value: string) => void` | Change handler |
| `placeholder` | `string` | Placeholder text |
| `fieldKey` | `string` | Field registry key |

**Trigger Spec:**
- Height: `h-12`, `rounded-lg`, `border-border`, `bg-white`
- Chevron: `ChevronDown` icon, `h-4 w-4`, `text-muted-foreground`
- Focus: `ring-2 ring-primary`
- Hover: `border-primary/50`

**Dropdown Spec:**
- `rounded-lg`, `border-border`, `bg-white`, `shadow-lg`
- Items: `py-3 px-3`, `rounded-md`, `hover:bg-muted`
- Selected item: `text-primary`, `bg-primary/5`
- Supports option groups with separator lines

---

### 7.5 SmaiCard

**Import:** `import { SmaiCard } from "@/components/smai"`

| Prop | Type | Default | Description |
|---|---|---|---|
| `padding` | `"sm" \| "md" \| "lg"` | `"md"` | Internal padding |
| `className` | `string` | — | Additional classes |

**Spec:**
- Background: `bg-card`
- Border: `border-border`
- Radius: `rounded-xl`
- Shadow: `shadow-sm`
- Transition: `smai-transition` (200ms ease-out)

**Padding Map:**

| Size | Value |
|---|---|
| `sm` | `p-4` |
| `md` | `p-6` |
| `lg` | `p-8` |

---

### 7.6 StatusBadge (Job Lifecycle)

**Import:** `import { StatusBadge } from "@/components/smai"`

Displays the **lifecycle state** of a job. Always a pill badge with tooltip.

| Status | Label | Background | Text |
|---|---|---|---|
| `in-campaign` | "In Campaign" | `bg-primary/70` | White |
| `paused` | "Paused" | `bg-smai-status-paused` (amber) | White |
| `closed-won` | "Won" | `bg-smai-status-won` (green) | White |
| `closed-lost` | "Lost" | `bg-smai-status-lost` (gray) | White |

**Spec:** `rounded-full`, `px-3 py-1.5`, `text-[12px]`, `font-medium`, tooltip on hover.

**Valid Statuses (Mutually Exclusive):** `in-campaign`, `paused`, `closed-won`, `closed-lost`

---

### 7.7 OverlayBadge (Attention Conditions)

**Import:** `import { OverlayBadge } from "@/components/smai"`

Flags that overlay the lifecycle state. A job can be "In Campaign" AND have an overlay.

| Overlay | Label | Background | Text |
|---|---|---|---|
| `customer-waiting` | "Customer Waiting" | `bg-smai-status-waiting` (coral) | White |
| `delivery-issue` | "Delivery Issue" | `bg-smai-status-issue` (red) | White |

Same pill styling as StatusBadge. Priority: Delivery Issue > Customer Waiting.

**Rules:**
- Terminal states (`closed-won`, `closed-lost`) never have overlays.
- Paused jobs only show `customer-waiting` if the condition is explicitly set (reply after pause).

---

### 7.8 JobSummaryCard

**Import:** `import { JobSummaryCard } from "@/components/smai"`

Dual-layout card with separate mobile and desktop renderings.

| Variant | Usage |
|---|---|
| `"attention"` | Needs Attention page |
| `"jobs"` | Jobs list page (shows originator line) |

**Mobile Layout (3-line):**
1. Customer Name + Value (right-aligned)
2. Street Address (truncated)
3. Context (location/LOB) + inline status text (lowercase, colored)

Right side: Circular action button (`w-10 h-10 rounded-full`) color-matched to condition.

**Desktop Layout (3-line):**
1. Customer Name + Value
2. Address
3. LOB + inline status text

Right side: SmaiButton CTA with contextual icon.

**Card Wrapper:** `rounded-xl`, `border-border`, `shadow-sm`, `p-3 lg:p-5`, hover: `shadow-lg`, `-translate-y-0.5`, `active:scale-[0.995]`, `300ms` transition.

---

### 7.9 JobListRow

Table-style row used in the Jobs list view.

**Layout:** `px-6 py-5`, `border-b border-border`, `hover:bg-muted/50`

**Content Rows:**
1. Customer Name (semibold, 16px) + StatusBadge (pill)
2. LOB + Job Description (truncated 40 chars) + Value (bold)
3. Engagement narrative (optional, 12px, muted)
4. Last reply (optional, italic, with MessageSquare icon)
5. Last SMAI action (optional, with Zap icon)

---

### 7.10 PageHeader

**Import:** `import { PageHeader } from "@/components/smai"`

| Prop | Type | Description |
|---|---|---|
| `title` | `string` | Page title |
| `subtitle` | `string` | Optional subtitle |
| `actions` | `ReactNode` | Right-aligned CTAs |

**Mobile:** Slate background header (`bg-sidebar-background`), white text, brand icon left, actions right. `-mx-4 -mt-6` bleed.

**Desktop:** White background, `text-3xl font-bold`, bottom border, actions right-aligned. `pb-6 mb-8 border-b`.

**CTA Alignment Rule:** Actions always align to the far right edge of the page container on both mobile and desktop.

---

### 7.11 PageContainer

**Import:** `import { PageContainer } from "@/components/smai"`

Constrains content width and provides consistent padding.

- Max width: `1280px`
- Padding: `px-4 sm:px-6 lg:px-8`
- Top: `pt-6 lg:pt-8`
- Bottom: `pb-24 lg:pb-8` (accounts for mobile bottom nav)

---

### 7.12 SmaiSidebar (Desktop)

Fixed left sidebar, visible `lg:` and up.

| Section | Spec |
|---|---|
| Logo | `h-16`, padded, links to `/` |
| Location Selector | Below logo, `border-b` |
| Nav Items | `space-y-3`, `px-3 py-2.5`, `rounded-lg` |
| Active State | `bg-sidebar-primary text-sidebar-primary-foreground font-semibold` |
| Inactive State | `text-sidebar-foreground/70`, hover: `bg-sidebar-accent` |
| Icons | `h-5 w-5`, `strokeWidth={2.5}` |
| Admin Link | Conditional on `user.role === "Admin"` |
| User Menu | Bottom of sidebar |
| Version | `v1.0.0` at very bottom, subtle |

---

### 7.13 BottomNav (Mobile)

Fixed bottom navigation, visible below `lg:` breakpoint.

- `h-16`, `bg-background`, `border-t border-border`
- Safe area padding: `env(safe-area-inset-bottom)`
- 4 items (5 if Admin): Attention, Jobs, Analytics, Settings, (Admin)
- Icons: `h-5 w-5`, `strokeWidth={2.5}`
- Labels: `text-[10px] font-medium`
- Active: `text-primary`
- Inactive: `text-muted-foreground`

---

### 7.14 LocationSelector

Dropdown for switching active location context. Two variants:

| Variant | Context | Style |
|---|---|---|
| `sidebar` | Desktop sidebar | Dark theme, sidebar tokens |
| `profile` | Profile slide-over | Light theme, standard tokens |

- Shows search input when > 6 locations
- "All Locations" option for users with global access
- Check icon on selected item
- MapPin icon prefix

---

## 8. Admin Section Standards

### 8.1 AdminTable

Specialized table components for the admin portal.

| Component | Spec |
|---|---|
| `AdminTH` | `h-10 px-4`, `text-[11px] font-semibold uppercase tracking-wider text-muted-foreground` |
| `AdminTR` | `border-b border-border`, `hover:bg-muted/50` |
| `AdminTR` (tinted) | `tint="amber"` → `bg-warning/5`, `tint="rose"` → `bg-destructive/5` |
| `AdminTD` | `px-4 py-4 align-middle` |

### 8.2 AdminStatusBadge

Pill-style badge for admin contexts. Rounded-full with border.

| Color Group | Statuses | Style |
|---|---|---|
| **Teal** | Active, Pilot, Connected, Operational, Clear, Success, Resolved, Admin | `bg-primary/15 text-primary border-primary/25` |
| **Amber** | Trialing, Requires Action, Warning, Pending | `bg-warning/15 text-warning-foreground border-warning/25` |
| **Red** | Error, Failure | `bg-destructive/15 text-destructive border-destructive/25` |
| **Gray** | Draft, Inactive, Not Connected, Stable, Info, User | `bg-muted text-muted-foreground border-border` |

**Spec:** `rounded-full border px-2.5 py-0.5 text-[11px] font-semibold tracking-wide`

### 8.3 AdminTabs

Underline-style tabs.

- Tab list: `flex gap-6 border-b border-border mb-6`
- Inactive trigger: `text-muted-foreground`, `hover:text-foreground`
- Active trigger: `text-primary`, 2px bottom border in `bg-primary`
- Implemented via `::after` pseudo-element

### 8.4 Stat Tiles

On Customer Management list:
- **3px solid teal left border** (`border-l-[3px]`, `border-primary`)
- Standard `SmaiCard` with `padding="md"`

### 8.5 Org Table Column Order

`ORG NAME` → `PLAN` → `STATUS` → `INDUSTRY` → `LOCATIONS` → `USERS` → `DATE ADDED`

### 8.6 Drill-Down Hierarchy

Organization List → Organization Detail Page → Location/User Slide-overs

---

## 9. Responsive Strategy

### 9.1 Breakpoints

| Breakpoint | Width | Usage |
|---|---|---|
| Base | `0px` | Mobile-first |
| `sm` | `640px` | Small tablets |
| `lg` | `1024px` | Desktop (sidebar visible, bottom nav hidden) |
| `2xl` | `1400px` | Max container width |

### 9.2 Layout Rules

| Element | Mobile (<1024) | Desktop (≥1024) |
|---|---|---|
| Navigation | Bottom tab bar | Fixed left sidebar |
| Page Header | Slate full-width bar | White with border-bottom |
| Content Padding | `px-4` | `px-8` |
| Top Padding | `pt-6` | `pt-8` |
| Bottom Padding | `pb-24` (for bottom nav) | `pb-8` |
| Cards | Full width | Constrained `max-w-3xl` or `max-w-5xl` |
| Job Cards | Mobile-specific 3-line layout | Desktop-specific layout with CTA button |

### 9.3 Mobile-Specific

- Safe area support via `env(safe-area-inset-bottom)`
- Touch targets: minimum `48px` (`min-w-[48px]`)
- Active states: `active:scale-95` on tappable elements
- No hover-dependent disclosures

---

## 10. Copy & Terminology Conventions

### 10.1 General Rules

- **No em-dashes** — ever. Use commas or periods instead.
- Copy is short, direct, and confident.
- Avoid overly technical or robotic phrasing.
- Role display: Show "Originator" instead of "User" in user-facing contexts.

### 10.2 Status Labels

Job status indicators primarily use **colored inline text** (not pills) to reduce visual weight on list views. Pills/badges are reserved for:
- High-importance states in modals or banners (e.g., "PENDING APPROVAL")
- The StatusBadge component on desktop job rows

**Inline Status Text Style:** Lowercase, colored, `text-[11px]` or `text-[12px]`, `font-medium`.

| State | Text | Color |
|---|---|---|
| In Campaign | "in campaign" | `text-primary` (teal) |
| Reply Needed | "reply needed" | `text-smai-status-waiting` (coral) |
| Delivery Issue | "delivery issue" | `text-destructive` (red) |
| Paused | "paused" | `text-orange-500` (amber) |
| Won | "won" | `text-smai-status-won` (green) |
| Lost | "lost" | `text-muted-foreground` (gray) |

### 10.3 Metadata Format

Bullet-separated inline: `"In Campaign • Customer waiting • 1 day ago"`

---

## 11. Dark Mode

Supported via `.dark` class on `<html>`. All semantic tokens have dark variants defined in `index.css`.

**Key Dark Mode Overrides:**

| Token | Light | Dark |
|---|---|---|
| `--background` | `174 25% 97%` | `210 28% 16%` |
| `--card` | `0 0% 100%` | `210 24% 20%` |
| `--primary` | `180 100% 35%` | `180 100% 40%` |
| `--muted` | `220 14% 96%` | `210 24% 22%` |
| `--border` | `220 13% 91%` | `210 24% 22%` |

**Rule:** Never use `bg-white` — always `bg-card`. Never use `text-black` — always `text-foreground`.

---

## 12. Icon System

**Library:** Lucide React (`lucide-react`)

### 12.1 Size Scale

| Class | Size | Usage |
|---|---|---|
| `.smai-icon-sm` / `h-4 w-4` | 16px | Inline with text, buttons |
| `.smai-icon-md` / `h-5 w-5` | 20px | Nav items, action buttons |
| `.smai-icon-lg` / `h-6 w-6` | 24px | Hero elements, empty states |

### 12.2 Stroke Width

- Navigation icons: `strokeWidth={2.5}` (bolder for clarity)
- Inline icons: Default (`strokeWidth={2}`)

### 12.3 Action Icon Mapping

| Action | Icon | Component |
|---|---|---|
| Proposal sent/delivered | `FileText` | Document |
| Follow-up sent | `Send` | Paper plane |
| Customer reply | `MessageCircle` | Speech bubble |
| Delivery failure | `AlertCircle` | Alert |
| Campaign state change | `RefreshCw` | Refresh |
| Open in Gmail | `ExternalLink` | External link |
| Generic automation | `Zap` | Lightning bolt |
| Navigation indicator | `ChevronRight` | Chevron |

---

## 13. Selection & Active State Standards

### 13.1 Segmented Controls

- Active: `bg-primary/10`, `text-primary` (teal tint)
- Inactive: `bg-transparent`, `text-muted-foreground`

### 13.2 Dashboard Toggles (Analytics)

- Active: `bg-card`, `shadow-sm`, `border-border` (raised/elevated look)
- Inactive: Transparent

### 13.3 Multi-Select Chips / Button Groups (Admin)

- **Selected:** Solid teal fill `bg-primary`, white text, checkmark icon
- **Unselected:** `border-border`, `bg-background`, `text-foreground`

### 13.4 Sidebar Nav Items

- Active: `bg-sidebar-primary text-sidebar-primary-foreground font-semibold`
- Inactive: `text-sidebar-foreground/70`, hover: `bg-sidebar-accent`

---

## 14. Form Standards

### 14.1 Layout

- Vertical rhythm: `space-y-5`
- No internal borders or section backgrounds inside forms
- Labels above inputs, using `.smai-label` class
- Required fields: Red asterisk after label text

### 14.2 Input Dimensions

- Height: `h-12` (48px) for all single-line inputs and selects
- Textarea: `min-h-[120px]`
- Border radius: `rounded-lg` (8px)

### 14.3 States

| State | Border | Ring | Background |
|---|---|---|---|
| Default | `border-border` | None | `bg-white` |
| Hover | `border-primary/50` | None | `bg-white` |
| Focus | `border-primary` | `ring-2 ring-primary` | `bg-white` |
| Error | `border-destructive` | `ring-2 ring-destructive` | `bg-white` |
| Disabled | `border-border` | None | `opacity-50` |

### 14.4 Helper Text

- Below input: `text-sm text-muted-foreground`
- Error text: `text-sm text-destructive`

---

## 15. Slide-Over Panels

Used for detail views (Location, User) opened from table rows.

| Property | Spec |
|---|---|
| Width | `w-full sm:max-w-[640px]` |
| Position | Fixed right, full height |
| Overlay | `bg-black/80` |
| Background | `bg-background` |
| Header | Title + close button (`X icon`), `border-b` |
| Content | Scrollable, `px-6 py-6` |
| Animation | Slide in from right |
| Section labels | `.smai-label` (uppercase, 12px) |
| Field values | `text-sm text-foreground` |
| Empty values | "—" (em-dash placeholder) |

---

## 16. Modal Dialogs

Built on Radix Dialog primitive.

| Property | Spec |
|---|---|
| Max width | `max-w-lg` (default), `max-w-md` for simple confirms |
| Position | Centered (`left-50% top-50% translate`) |
| Background | `bg-background` |
| Border radius | `sm:rounded-lg` |
| Shadow | `shadow-lg` |
| Close button | Top-right X icon, `h-5 w-5` |
| Footer | `flex justify-end gap-2`, Cancel link left, primary action right |
| Overlay | `bg-black/80` |
| Animation | `zoom-in-95`, `fade-in`, `200ms` |

---

## 17. Toast Notifications

**Library:** Sonner

Used for confirmations after mutations: "User updated.", "Job saved.", "Invite sent."

- Short, past-tense confirmations
- No em-dashes
- Auto-dismiss

---

*Built for ServiceMark AI. "From quote to booked job."*
