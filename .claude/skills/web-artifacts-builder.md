---
name: web-artifacts-builder
description: |
  Suite of tools for creating elaborate, multi-component HTML artifacts using modern frontend web technologies.
  Use for complex artifacts requiring state management, routing, or shadcn/ui components.
  NOT for simple single-file HTML/JSX artifacts.
---

# Web Artifacts Builder

Build powerful frontend artifacts with React + TypeScript + Tailwind CSS + shadcn/ui.

## Workflow

1. **Initialize** project with scripts/init-artifact.sh
2. **Develop** by editing generated code
3. **Bundle** into single HTML using scripts/bundle-artifact.sh
4. **Display** artifact to user
5. **Test** (optional) after presenting

## Stack

- React 18 + TypeScript (Vite)
- Tailwind CSS 3.4.1 with shadcn/ui theming
- 40+ shadcn/ui components pre-installed
- Parcel for bundling to single HTML

## Design Guidelines

AVOID "AI slop": excessive centered layouts, purple gradients, uniform rounded corners, Inter font.

## Quick Start

### Initialize
```bash
bash scripts/init-artifact.sh <project-name>
cd <project-name>
```

### Develop
Edit `src/` files. Use `@/` path aliases.

### Bundle
```bash
bash scripts/bundle-artifact.sh
```

Creates `bundle.html` - self-contained artifact with all JS/CSS inlined.

## Components Reference

shadcn/ui: https://ui.shadcn.com/docs/components

Available: Accordion, Alert, AlertDialog, Avatar, Badge, Button, Calendar, Card, Carousel, Chart, Checkbox, Collapsible, Combobox, Command, ContextMenu, DataTable, DatePicker, Dialog, Drawer, DropdownMenu, Form, HoverCard, Input, InputOTP, Label, Menubar, NavigationMenu, Pagination, Popover, Progress, RadioGroup, ResizablePanel, ScrollArea, Select, Separator, Sheet, Skeleton, Slider, Sonner, Switch, Table, Tabs, Textarea, Toast, Toggle, ToggleGroup, Tooltip
