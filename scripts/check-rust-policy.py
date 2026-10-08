#!/usr/bin/env python3
"""Validate the binary-only global manifest without downloading/executing tools."""
import copy
from pathlib import Path
import re
import tomllib

ROOT = Path(__file__).resolve().parents[1]
PLATFORMS = ("linux-x64", "linux-arm64", "macos-arm64")


def validate(config, lock):
    settings = config["settings"]
    for key in ("locked", "locked_verify_provenance"):
        assert settings.get(key) is True, f"{key} must be enabled"
    for key in ("auto_install", "exec_auto_install", "not_found_auto_install"):
        assert settings.get(key) is False, f"{key} must be disabled"
    assert {"cargo", "asdf"} <= set(settings["disable_backends"])
    assert not settings.get("trusted_config_paths"), "no blanket project trust"
    for key in ("cosign", "github_attestations", "minisign", "slsa"):
        assert settings["aqua"].get(key) is True, f"aqua.{key} must be enabled"
    assert set(config["tools"]) == set(lock["tools"]), "config/lock tool mismatch"
    for tool, version in config["tools"].items():
        backend, repo = tool.split(":", 1)
        assert backend in ("aqua", "github"), f"nonbinary backend: {tool}"
        assert re.fullmatch(r"\d+\.\d+\.\d+", version), f"inexact pin: {tool}"
        entries = lock["tools"][tool]
        assert len(entries) == 1, f"ambiguous lock: {tool}"
        entry = entries[0]
        assert entry["version"] == version and entry["backend"] == tool
        for platform in PLATFORMS:
            artifact = entry.get("platforms." + platform, {})
            url = artifact.get("url", "")
            assert url.startswith(f"https://github.com/{repo}/releases/download/"), (tool, platform, url)
            assert re.fullmatch(r"sha256:[0-9a-f]{64}", artifact.get("checksum", "")), (tool, platform, "missing digest")
            assert "/" + version + "/" in url or "/v" + version + "/" in url, (tool, platform, "wrong release")
            asset = url.rsplit("/", 1)[1]
            arch_names = ("x86_64", "amd64") if platform == "linux-x64" else ("aarch64", "arm64", "universal")
            assert any(arch in asset for arch in arch_names), (tool, platform, "wrong architecture")


def main():
    config = tomllib.loads((ROOT / "users/haru/mise/config.toml").read_text())
    lock = tomllib.loads((ROOT / "users/haru/mise/mise.lock").read_text())
    validate(config, lock)
    tool = next(iter(config["tools"]))
    # Regression checks: the gate must reject weakened policy and incomplete locks.
    bad_config = copy.deepcopy(config)
    bad_config["settings"]["locked"] = False
    bad_lock = copy.deepcopy(lock)
    del bad_lock["tools"][tool][0]["platforms.macos-arm64"]["checksum"]
    for c, l in ((bad_config, lock), (config, bad_lock)):
        try:
            validate(c, l)
        except AssertionError:
            pass
        else:
            raise AssertionError("policy gate accepted an unsafe fixture")
    print(f"binary policy: {len(config['tools'])} exact pins, {len(config['tools']) * len(PLATFORMS)} upstream artifacts; negative checks pass")


if __name__ == "__main__":
    main()
