"""Check the real compiler output without downloading the connectome."""
import subprocess
import sys

from flywirehead.neural import brain


def test_native_kernel_builds_and_exports_the_runtime_entry_point(tmp_path, monkeypatch):
    library = tmp_path / brain.LIBRARY.name
    monkeypatch.setattr(brain, "LIBRARY", library)
    metadata = brain.build()
    # A separate process releases the DLL before Windows cleans up tmp_path.
    subprocess.run(
        [sys.executable, "-c", "import ctypes, sys; assert ctypes.CDLL(sys.argv[1]).memory_advance", str(library)],
        check=True,
    )

    def unexpected_rebuild(*args, **kwargs):
        raise AssertionError("An unchanged verified kernel should reuse its build")

    monkeypatch.setattr(brain.subprocess, "run", unexpected_rebuild)
    assert brain.build() == metadata
