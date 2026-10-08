#!/usr/bin/env python3
"""Validate the owner's minor-pin, optional-lock CLI policy without downloads."""
import copy
from pathlib import Path
import re
import tomllib

ROOT = Path(__file__).resolve().parents[1]


def validate(config):
    settings = config["settings"]
    assert not settings.get("locked", False), "do not force locks on projects"
    assert not settings.get("lockfile", False), "do not generate global locks"
    for key in ("auto_install", "exec_auto_install", "not_found_auto_install"):
        assert settings.get(key) is False, f"{key} must be disabled"
    assert {"cargo", "asdf"} <= set(settings["disable_backends"])
    assert not settings.get("trusted_config_paths"), "no blanket project trust"
    for key in ("cosign", "github_attestations", "minisign", "slsa"):
        assert settings["aqua"].get(key) is True, f"aqua.{key} must be enabled"
    assert config["tools"], "missing CLI manifest"
    for tool, version in config["tools"].items():
        backend, _ = tool.split(":", 1)
        assert backend in ("aqua", "github"), f"nonbinary backend: {tool}"
        assert re.fullmatch(r"\d+\.\d+", version), f"not a minor pin: {tool}"
    assert "github:starship/starship" not in config["tools"], "Starship stays Nix-owned"


def main():
    config = tomllib.loads((ROOT / "users/haru/mise/config.toml").read_text())
    validate(config)
    assert not (ROOT / "users/haru/mise/mise.lock").exists(), "no managed mise lock"
    packages = (ROOT / "users/haru/packages.nix").read_text()
    for tool in ("tokei", "eza"):
        assert re.search(rf"^\s+{tool}\s", packages, re.M), f"retain Nix {tool}"
    # Negative fixtures protect the owner-selected policy, not the old lock mandate.
    fixtures = []
    for setting in ("locked", "lockfile", "auto_install"):
        bad = copy.deepcopy(config)
        bad["settings"][setting] = True
        fixtures.append(bad)
    bad = copy.deepcopy(config)
    bad["tools"][next(iter(config["tools"]))] = "latest"
    fixtures.append(bad)
    bad = copy.deepcopy(config)
    bad["tools"]["cargo:example"] = "1.0"
    fixtures.append(bad)
    for bad in fixtures:
        try:
            validate(bad)
        except AssertionError:
            pass
        else:
            raise AssertionError("policy gate accepted an unsafe fixture")
    print(f"CLI policy: {len(config['tools'])} minor pins, optional project locks, Nix exceptions retained; negative checks pass")


if __name__ == "__main__":
    main()
