"""Regression checks for CI destination selection and cleanup boundaries."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from run_tests import simulator_template


def device(name='iPhone 17', available=True):
    return {'name': name, 'isAvailable': available, 'deviceTypeIdentifier': 'iphone-type'}


class DestinationTests(unittest.TestCase):
    def test_ignores_newer_runtime_than_selected_xcode(self):
        devices = {'com.apple.CoreSimulator.SimRuntime.iOS-26-5': [device()],
                   'com.apple.CoreSimulator.SimRuntime.iOS-27-0': [device()]}
        runtime, _ = simulator_template(devices, (26, 5))
        self.assertEqual(runtime, 'com.apple.CoreSimulator.SimRuntime.iOS-26-5')

    def test_accepts_equivalent_patch_version(self):
        runtime = 'com.apple.CoreSimulator.SimRuntime.iOS-26-5-0'
        self.assertEqual(simulator_template({runtime: [device()]}, (26, 5))[0], runtime)

    def test_selects_latest_compatible_runtime(self):
        devices = {'com.apple.CoreSimulator.SimRuntime.iOS-18-2': [device()],
                   'com.apple.CoreSimulator.SimRuntime.iOS-26-5': [device()]}
        self.assertEqual(simulator_template(devices, (26, 5))[0],
                         'com.apple.CoreSimulator.SimRuntime.iOS-26-5')

    def test_rejects_unavailable_non_ios_and_ipad_only_destinations(self):
        for devices in ({'com.apple.CoreSimulator.SimRuntime.iOS-26-5': [device(available=False)]},
                        {'com.apple.CoreSimulator.SimRuntime.iOS-26-5': [device('iPad')]},
                        {'com.apple.CoreSimulator.SimRuntime.tvOS-26-5': [device()]}):
            with self.subTest(devices=devices), self.assertRaisesRegex(RuntimeError, 'No available iPhone'):
                simulator_template(devices, (26, 5))


class CleanupTests(unittest.TestCase):
    def test_only_owned_build_directories_are_removed(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            work = root / 'designuikit-123-1/ios'
            build = work / 'DerivedData'
            build.mkdir(parents=True)
            log = work / 'package.log'
            log.write_text('failure evidence')
            outside = root / 'unrelated'
            outside.mkdir()
            environment = dict(os.environ, RUNNER_TEMP=str(root), GITHUB_RUN_ID='123', GITHUB_RUN_ATTEMPT='1')
            command = [sys.executable, str(Path(__file__).with_name('cleanup.py'))]
            subprocess.run(command + [str(work)], env=environment, check=True)
            self.assertFalse(build.exists())
            self.assertTrue(log.exists())
            rejected = subprocess.run(command + [str(outside)], env=environment, capture_output=True)
            self.assertNotEqual(rejected.returncode, 0)
            self.assertTrue(outside.exists())


if __name__ == '__main__':
    unittest.main()
