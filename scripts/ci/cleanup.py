"""Remove only this run's derived data; retain logs and result bundles."""
import os
from pathlib import Path
import re
import subprocess
import shutil
import sys

root = Path(os.environ['RUNNER_TEMP']).resolve()
work = Path(sys.argv[1]).resolve()
expected = root / f"designuikit-{os.environ['GITHUB_RUN_ID']}-{os.environ['GITHUB_RUN_ATTEMPT']}"
if work.parent != expected or work.name not in {'ios', 'catalyst'}:
    raise SystemExit('Refusing to clean a directory outside this CI run.')
marker = work / 'simulator-id'
if marker.is_file():
    simulator = marker.read_text().strip()
    if not re.fullmatch(r'[0-9A-Fa-f-]{36}', simulator):
        raise SystemExit('Invalid owned simulator identifier.')
    subprocess.run(['xcrun', 'simctl', 'shutdown', simulator], check=False, capture_output=True)
    subprocess.run(['xcrun', 'simctl', 'delete', simulator], check=False)
    marker.unlink()
for name in ('DerivedData', 'PackageDerivedData', 'HostDerivedData'):
    path = work / name
    if path.is_symlink():
        raise SystemExit(f'Refusing to follow symlink: {path}')
    if path.exists():
        shutil.rmtree(path)
