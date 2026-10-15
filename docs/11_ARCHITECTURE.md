# Architecture

## Ownership
- DesignCore owns shared builders, preferences, associated storage, and utilities.
- DesignExts owns focused color, layer, and geometry extensions.
- DesignExternal owns thin external-library exports.
- DesignUIKit owns base views, themes/fonts, Fast View, and list infrastructure.
- DesignCombineUIKit and DesignRxUIKit own their reactive integrations.
- See [module scopes](modules/00_INDEX.md) for detailed contracts.

## Boundaries
- Keep dependency flow one-way; see [dependencies](12_DEPENDENCIES.md).
- Do not import reactive integration targets into the base UIKit target.
- Reactive BaseBlocks are MVVM blueprints, not feature implementations.
- A ViewModel can coordinate multiple injected use cases by business intent.
- Concrete use cases belong in consuming feature/domain modules.
- Extension-backed state uses ObjectAssociation storage.
- Theme/font registration remains centralized in its system classes.

## Compatibility
- Preserve public source compatibility unless explicitly authorized otherwise.
- Keep iOS/tvOS guards aligned with Package.swift.
- Exclude Archived APIs from new implementations.
- Preserve idempotent child-controller containment and bounds-safe adapters.

## Update Direction
- Preserve existing UIKit instances for property-only changes.
- Keep appearance, layout, and structural updates distinct.
- Fluent setters apply appearance immediately and coalesce owned layout changes.
- Keyed stack updates retain unchanged views; see [contracts](1.1.0/03_UPDATE_CONTRACTS.md).
