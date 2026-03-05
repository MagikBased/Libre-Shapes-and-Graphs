# GShapes Addon (First Packaging Pass)

This addon package contains the reusable Godot Shapes runtime scripts.

## Included

- `Scripts/core/` runtime classes (`GShapes*`, graph helpers, animation helpers)
- `Scripts/base/` primitive shape classes required by runtime (`Shape`, `Circle`, `Rectangle`, `Line`)

## Not Included (yet)

- Demo scenes and demo runner scripts
- CI/export tooling
- Versioned release zip workflow

## Install Into Another Project

1. Copy `addons/gshapes` into the target project's `addons/` folder.
2. Open **Project Settings -> Plugins**.
3. Enable **GShapes**.
4. Use classes directly by `class_name` (for example `GShapes`, `GShapesCompatibleScene`, `GraphAxes2D`).

## Notes

- This first pass is packaged in `AddonPackage/` so it does not collide with this repository's live project scripts.
- Next pass should add a minimal sample scene and automated validation in a clean host project.

## Smoke Test

- Open and run `res://addons/gshapes/examples/gshapes_addon_smoke.tscn`.
- Expected console line: `[GShapesAddonSmoke] PASS`.
