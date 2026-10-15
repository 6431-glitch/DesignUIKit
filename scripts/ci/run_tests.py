"""Run isolated iOS or Catalyst checks on the selected Xcode toolchain."""
import argparse
import json
import platform
from pathlib import Path
import re
import subprocess
import sys


def capture(*command):
    return subprocess.check_output(command, text=True).strip()


def simulator_template(devices, sdk_version):
    """Prefer the newest installed iOS runtime usable by the selected SDK."""
    candidates = []
    sdk_version = (sdk_version + (0, 0, 0))[:3]
    for runtime, entries in devices.items():
        match = re.fullmatch(r'com\.apple\.CoreSimulator\.SimRuntime\.iOS-([\d-]+)', runtime)
        if not match:
            continue
        version = (tuple(int(part) for part in match[1].split('-')) + (0, 0, 0))[:3]
        if version > sdk_version:
            continue
        for device in entries:
            if device.get('isAvailable') and device['name'].startswith('iPhone'):
                candidates.append((version, runtime, device['deviceTypeIdentifier']))
    if not candidates:
        raise RuntimeError('No available iPhone simulator compatible with the selected Xcode SDK.')
    _, runtime, device_type = max(candidates)
    return runtime, device_type


def run_logged(command, log):
    print('+ ' + ' '.join(map(str, command)), flush=True)
    with log.open('w') as stream:
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        for line in process.stdout:
            print(line, end='', flush=True)
            stream.write(line)
        code = process.wait()
    if code:
        raise subprocess.CalledProcessError(code, command)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('suite', choices=['ios', 'catalyst'])
    parser.add_argument('--work-dir', type=Path, required=True)
    args = parser.parse_args()
    work = args.work_dir.resolve()
    work.mkdir(parents=True, exist_ok=True)
    # A unique work directory prevents old results from masking a failed rerun.
    if any(work.glob('*.xcresult')):
        raise RuntimeError('Use a fresh work directory; result bundles already exist.')
    print(capture('xcodebuild', '-version'), flush=True)
    print('Verifying commit ' + capture('git', 'rev-parse', 'HEAD'), flush=True)
    base = ['xcodebuild', 'test', '-disableAutomaticPackageResolution',
            '-parallel-testing-enabled', 'NO', '-maximum-concurrent-test-simulator-destinations', '1',
            'CODE_SIGNING_ALLOWED=NO']
    simulator = None
    try:
        if args.suite == 'ios':
            sdk = tuple(int(part) for part in capture('xcrun', '--sdk', 'iphonesimulator', '--show-sdk-version').split('.'))
            devices = json.loads(capture('xcrun', 'simctl', 'list', 'devices', 'available', '-j'))['devices']
            runtime, device_type = simulator_template(devices, sdk)
            simulator = capture('xcrun', 'simctl', 'create', 'DesignUIKit CI ' + work.name, device_type, runtime)
            (work / 'simulator-id').write_text(simulator)
            destination = 'platform=iOS Simulator,id=' + simulator
            print(f'Created isolated simulator {simulator} ({runtime})', flush=True)
            run_logged(['xcrun', 'simctl', 'boot', simulator], work / 'simulator-boot.log')
            run_logged(['xcrun', 'simctl', 'bootstatus', simulator, '-b'], work / 'simulator-ready.log')
            run_logged(base + ['-scheme', 'DesignUIKit-Package', '-destination', destination,
                       '-derivedDataPath', str(work / 'DerivedData'),
                       '-resultBundlePath', str(work / 'package.xcresult')], work / 'package.log')
            run_logged([sys.executable, 'scripts/ci/check_examples.py', '--derived-data', str(work / 'DerivedData'),
                        '--output-dir', str(work / 'examples')], work / 'examples.log')
        else:
            destination = f'platform=macOS,variant=Mac Catalyst,arch={platform.machine()}'
            run_logged(base + ['-scheme', 'DesignUIKit-Package', '-destination', destination,
                       '-derivedDataPath', str(work / 'PackageDerivedData'),
                       '-resultBundlePath', str(work / 'package.xcresult')], work / 'package.log')
            run_logged(base + ['-project', 'Tests/CatalystHost/CatalystHost.xcodeproj',
                       '-scheme', 'CatalystHost', '-destination', destination,
                       '-derivedDataPath', str(work / 'HostDerivedData'),
                       '-resultBundlePath', str(work / 'hosted.xcresult')], work / 'hosted.log')
    finally:
        if simulator:
            subprocess.run(['xcrun', 'simctl', 'shutdown', simulator], check=False, capture_output=True)
            subprocess.run(['xcrun', 'simctl', 'delete', simulator], check=False)
            (work / 'simulator-id').unlink(missing_ok=True)


if __name__ == '__main__':
    main()
