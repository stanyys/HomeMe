"""Smoke test: the package is installed in the workspace and importable."""

import homeme_resale_loader


def test_package_exposes_installed_version() -> None:
    assert homeme_resale_loader.__version__ == "0.1.0"
