# Fast View Update Contracts

## Appearance and Layout
- background/opacity apply directly to the existing view, including before mount.
- frame, padding, offset, ratio, priority, and attachment changes invalidate only
  the owning configuration; chained changes coalesce until layout/the main queue.
- Call configuration?.applyLayout() to flush constraints synchronously.
- Toolkit-owned constraints update constants in place; consumer constraints survive.
- Explicit dimensions and parent edges keep the configured layout priority.
- Stack-managed children use stack positioning; explicit dimensions still apply.
- Explicit size plus all parent edges can conflict; use ignore(edges:) or
  attachToParent(false) when the parent must not determine that dimension.

## Explicit Content Updates
- updateContent() updates container-owned content without lifecycle dispatch.
- reload() reapplies configuration, calls updateContent(), then customConfiguration.
- FView reload explicitly rebuilds its body; leaf reload preserves subviews.
- FStack and FZStack reconcile instances; FScroll rebuilds owned layout rules
  while retaining unchanged content instances. FList/FGrid use their data APIs.
- Custom container conformers should implement updateContent() for owned children.

## Keyed Stack Example
```swift
struct Row: Equatable { let id: Int; let title: String }
stack.updateItems(rows, id: \.id,
    makeView: { FLabel($0.title) },
    update: { (label: FLabel, row: Row) in label.text = row.title })
```
- IDs retain view instances across insertions, removals, and reorders.
- New IDs call makeView; changed retained values call update; equal values skip it.
- makeView must fully configure a distinct view; use immutable model snapshots.
- Non-Equatable models can supply areEquivalent: explicitly.
- Duplicate IDs or reused view instances return false before installing content.
- updateItemsResult adds structured rejection details; [diagnostics](../usage/10_DIAGNOSTICS.md).
- Manual arrangedContents assignment clears keyed history; the next keyed call
  creates new views. Existing unkeyed APIs remain available.

## Modifiers and Layers
- Local modifiers remain separate from inherited rules resolved from the parent.
- Built-in styles restore prior values on reparenting/reload unless directly changed.
- Custom modifiers must be idempotent and own cleanup of arbitrary side effects.
- Modifier return values do not replace views; mutate and return the same view.
- Shape/shadow geometry is recalculated on configuration/bounds changes.
- The shadow helper disables same-layer clipping. Use an outer shadow container
  and an inner shaped view when both a visible shadow and clipped content are needed.
