# Choose the Smallest Update

## Decision Table
| What changed? | Use | What stays alive? |
| --- | --- | --- |
| Text, image, enabled state, visibility | Set the UIKit property or bind it | Existing component, parent, and siblings |
| Background or opacity | Fluent setter | Existing hierarchy |
| Width, height, padding, position | Layout setter | Existing hierarchy and unchanged owned constraints |
| Data-driven stack items | updateItems or bindItems with stable IDs | Retained-ID views and their local state |
| Manually supplied container children | Set the child array, then updateContent() | Unchanged instances in supported containers |
| A deliberately rebuilt FView body | reload() | The FView instance; its body is reconstructed |
| FList/FGrid data | Their section/item/snapshot APIs | Adapter-managed reusable content |

## Timing
- Appearance setters act immediately, including before attachment.
- Layout setters coalesce until layout or the next main-queue turn.
- configuration?.applyLayout() flushes that component's pending constraints.
- UIKit can relayout related views; this does not request hierarchy reconstruction.
- frame(width:/height:) means an Auto Layout size; padding/offset are additive.
- Use the [custom-layout recipe](08_CUSTOM_LAYOUT.md) when parent pins compete.

## Construction and Explicit Reload
- FView builds its body once when first attached, unless explicitly reloaded.
- Changing a value originally read by body does not automatically rebuild it.
- Retain component references or bind properties for ordinary data changes.
- reload() reapplies configuration, calls updateContent(), then customConfiguration.
- FView reload rebuilds its body; use it when that reconstruction is intended.
- FStack/FZStack reconcile supplied instances; FScroll refreshes owned content rules.
- Leaf reload keeps UIKit-managed subviews; FViewController retains child containment.
- FList/FGrid use data APIs rather than their deprecated reload() methods.
- Custom FComponent containers should implement updateContent() for owned children.
- Direct UIKit property changes can be replaced when reload reapplies stored config.

## Binding and Modifier Ownership
- Named bindings replace one slot; unkeyed bindings append subscriptions.
- Avoid binding setup inside repeatedly invoked customConfiguration callbacks.
- Reusing a keyed stack needs immutable values and stable IDs; manual arrangedContents
  assignment clears its keyed history. See [dynamic stacks](03_DYNAMIC_STACKS.md).
- Parent modifiers apply before local modifiers; local declarations take precedence.
- Built-in modifier snapshots restore prior state conditionally; custom modifiers
  must be idempotent and clean up their own side effects.
- [Binding lifetime details](../1.1.0/04_BINDINGS.md).
