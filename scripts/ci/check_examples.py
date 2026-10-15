"""Typecheck guide snippets independently against the simulator build products."""
import argparse
import platform
from pathlib import Path
import re
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--derived-data', type=Path, required=True)
parser.add_argument('--output-dir', type=Path, required=True)
args = parser.parse_args()
products = args.derived_data / 'Build/Products/Debug-iphonesimulator'
modulemap = args.derived_data / 'Build/Intermediates.noindex/GeneratedModuleMaps-iphonesimulator/RxCocoaRuntime.modulemap'
if not products.is_dir() or not modulemap.is_file():
    raise SystemExit('Build the iOS package before typechecking guide examples.')
sdk = subprocess.check_output(['xcrun', '--sdk', 'iphonesimulator', '--show-sdk-path'], text=True).strip()
args.output_dir.mkdir(parents=True, exist_ok=True)
base = ['xcrun', 'swiftc', '-typecheck', '-swift-version', '5',
        '-target', f'{platform.machine()}-apple-ios13.0-simulator', '-sdk', sdk,
        '-I', str(products), '-F', str(products / 'PackageFrameworks'),
        '-module-cache-path', str(args.output_dir / 'ModuleCache'),
        '-Xcc', f'-fmodule-map-file={modulemap}']
count = skipped = 0
failures = []
for path in sorted(Path('docs/usage').glob('*.md')):
    for block in re.findall(r'```swift\n(.*?)```', path.read_text(), re.S):
        if block.lstrip().startswith(('.package(', '.product(')):
            skipped += 1
            continue
        count += 1
        imports, lines = [], []
        for line in block.splitlines():
            (imports if line.startswith('import ') else lines).append(line)
        output = args.output_dir / f'example-{count}.swift'
        output.write_text('\n'.join(imports) + '\n@MainActor func usageExample() {\n'
                          + '\n'.join('    ' + line for line in lines) + '\n}\n')
        print(f'Typechecking {path} (example {count})', flush=True)
        if subprocess.run(base + [str(output)]).returncode:
            failures.append(str(path))
if not count:
    raise SystemExit('No Swift examples found; check guide discovery.')
print(f'{count} examples checked; {skipped} manifest fragments excluded; {len(failures)} failures.')
raise SystemExit(bool(failures))
