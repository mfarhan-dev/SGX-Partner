# SGX Partners branding decision

4 September 2026

The owner supplied two JPEG logos and requested Android/iOS application icons. This instruction supersedes the older requirement to retain the navy SVG. The borderless second reference was selected because the outer border in the first wastes launcher space. Both partner roles continue to use one app identity.

## Applied

- A square, white-backed version of the supplied red/black/yellow mark, prepared with built-in ImageGen and visually reviewed. This is a raster adaptation, not an official vector master or pixel-identical reproduction.
- Source: `assets/branding/sgx-icon-source.png`; 1024px shared icon: `assets/branding/sgx-app-icon.png`.
- Existing iOS AppIcon catalog filenames/sizes replaced with opaque RGB PNGs. The system supplies launcher corner masking; corners are not baked into the assets.
- Android density-specific legacy icons and 108dp adaptive foreground assets with white background and safe-zone spacing.
- Shared SgxLogo widget uses the new PNG for splash/login/onboarding; native display names are SGX Partners.
- Original navy SVG retained as historical material, no longer consumed by SgxLogo.

Regenerate platform assets on macOS from repository root:

```sh
swift -module-cache-path /tmp/sgx-icon-swift-cache tools/export_app_icons.swift
```

## Theme recommendation

Current Flutter primary is #1E3A8A. The role tokens also specify a navy primary; neither matches the newly supplied logo colors. Keep navy as the UI action color for this icon change, with neutral surfaces and the full-color logo on white. This preserves the existing visual hierarchy and status system. Yellow should stay an accent in the logo, not become small text on white. Red branding may coexist with an error role, but a future red-primary theme must distinguish destructive actions with wording, icons and component treatment, not color alone.

This is a design recommendation, not a claim that Apple or Google mandates a navy palette. If changing the entire brand theme later, update semantic light/dark tokens and audit contrast together instead of replacing every blue value with logo red.

## Platform references and limits

- [Android adaptive icons](https://developer.android.com/develop/ui/compose/system/icon_design_adaptive): separate foreground/background layers, 108dp canvas, inner 66dp safe zone, OS masks.
- [Apple app icons](https://developer.apple.com/design/human-interface-guidelines/app-icons): square icon construction and system masking. This project retains its existing PNG asset-catalog workflow; custom Icon Composer layers and dark/tinted variants are not included.
- [Material color roles](https://m3.material.io/styles/color/roles): use semantic roles for consistent UI theming.

Android custom monochrome themed artwork is not included. Device launcher rendering and iOS archive validation must be checked before store release. Obtain the original vector artwork for future exact brand reproduction.

## Generation prompt

Edit the supplied SGX logo into a production flat app-icon master. Preserve the distinctive interlocking red S, black sweeping G and upper swoosh, yellow x, and small circled R, shapes and proportions faithfully. Pure white opaque square background; no border, rounded corners, shadow, gradients or texture. Center the complete logo optically with safe space; retain source proportions. One square image, not a mockup. Platform sizing is performed by the deterministic Swift exporter.
