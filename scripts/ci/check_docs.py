"""Validate maintained documentation and Catalyst host source/dependency coverage."""
from pathlib import Path
import re
import subprocess


def local_links(path):
    for target in re.findall(r'\[[^\]]*\]\(([^)]+)\)', path.read_text()):
        if '://' not in target and not target.startswith('#'):
            yield (path.parent / target.split('#')[0]).resolve()


def main():
    files = [Path('AGENTS.md'), Path('README.md'), *Path('docs').rglob('*.md')]
    errors = []
    for path in files:
        count = len(path.read_text().splitlines())
        if count > 50:
            errors.append(f'{path}: {count} lines (limit 50)')
        for target in local_links(path):
            if not target.exists():
                errors.append(f'{path}: missing {target}')
    tracked = subprocess.check_output(
        ['git', 'ls-files', '--cached', '--others', '--exclude-standard'], text=True).splitlines()
    guides = {name for name in tracked if Path(name).name == 'AGENTS.md'}
    if guides != {'AGENTS.md'}:
        errors.append(f'Only the root AGENTS.md is allowed: {sorted(guides)}')

    seen = set()

    def visit(path):
        path = path.resolve()
        if path in seen:
            return
        seen.add(path)
        for target in local_links(path):
            if target.is_file() and target.suffix == '.md':
                visit(target)

    visit(Path('docs/00_INDEX.md'))
    for path in [Path('AGENTS.md'), *Path('docs').rglob('*.md')]:
        if path.resolve() not in seen:
            errors.append(f'Unindexed {path}')

    host = Path('Tests/CatalystHost/CatalystHost.xcodeproj')
    project = (host / 'project.pbxproj').read_text()
    for source in Path('Tests/UIKit').glob('*.swift'):
        if f'path = "{source.name}";' not in project and f'path = {source.name};' not in project:
            errors.append(f'{source}: missing from Catalyst hosted test target')
    pins = host / 'project.xcworkspace/xcshareddata/swiftpm/Package.resolved'
    if Path('Package.resolved').read_bytes() != pins.read_bytes():
        errors.append('Catalyst host dependency pins differ from Package.resolved')
    print('\n'.join(errors) if errors else
          f'PASS: {len(files)} Markdown files; links, index, line limits, and host coverage valid.')
    return bool(errors)


if __name__ == '__main__':
    raise SystemExit(main())
