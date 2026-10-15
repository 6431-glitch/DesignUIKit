# Recipe: A Reusable List With Stable IDs

For larger datasets, embed a reusable UITableView in FContainer. Store the table
and data source on the screen owner; UITableView does not retain its data source.
```swift
import UIKit
import DesignUIKit
struct Row { let id: Int; let title: String }
let table = UITableView(frame: .zero, style: .plain)
table.register(UITableViewCell.self, forCellReuseIdentifier: "row")
var titles: [Int: String] = [:]
let source = UITableViewDiffableDataSource<Int, Int>(tableView: table) { table, path, id in
    let cell = table.dequeueReusableCell(withIdentifier: "row", for: path)
    cell.textLabel?.text = titles[id]
    return cell
}
let content = FContainer(content: table)
let host = UIView()
host.addSubview(content)
func render(_ rows: [Row]) {
    let ids = rows.map(\.id)
    guard Set(ids).count == ids.count else { return }
    let changed = rows.filter { titles[$0.id] != $0.title }.map(\.id)
    let retained = Set(source.snapshot().itemIdentifiers)
    titles = Dictionary(uniqueKeysWithValues: rows.map { ($0.id, $0.title) })
    var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
    snapshot.appendSections([0])
    snapshot.appendItems(ids, toSection: 0)
    snapshot.reloadItems(changed.filter { retained.contains($0) })
    source.apply(snapshot, animatingDifferences: true)
}
render([Row(id: 1, title: "First"), Row(id: 2, title: "Second")])
render([Row(id: 2, title: "Updated"), Row(id: 1, title: "First")])
```
- Attach content once; update snapshots on main. Only changed retained rows reload.
- Keep identity independent of editable text; reject duplicate IDs before mutation.
- Native reuse avoids eagerly constructing a view for every row in a large stack.
- Toolkit FList/FGrid adapters are also available; see [UIKit scope](../modules/04_UIKIT.md).
