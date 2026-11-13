"""Smoke test: the package is installed in the workspace and importable."""

import homeme_vector_init


def test_package_exposes_installed_version() -> None:
    assert homeme_vector_init.__version__ == "0.1.0"
