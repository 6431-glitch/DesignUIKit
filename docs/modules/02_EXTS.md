# DesignExts Scope

## Ownership
- Sources/Exts: focused layer, size, and color extensions using DesignCore.
- CALayer.ShadowConfiguration, add(shadow:), addShadow, and removeShadow.
- CGSize addition with optional sizes and scalar division.
- UIColor hex parsing and RGB hex serialization.

## Contracts
- UIColor(hexString:) accepts 3, 6, and 8 digits after trimming non-alphanumerics.
- Invalid hex lengths fall back to black.
- hexString emits uppercase RGB with a leading # and excludes alpha.
- Preserve non-RGB color-space fallback handling.
- CGSize division by zero returns .zero without crashing.
- removeShadow resets shadow properties and leaves masksToBounds false.
- Helpers must not require a superview or window.
- Preserve source compatibility and avoid Archived APIs.

## Validation
- Add behavior tests in Tests/Exts; follow [validation](../14_TESTING.md).
