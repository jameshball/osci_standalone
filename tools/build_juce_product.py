#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import platform
import shutil
import subprocess
from pathlib import Path


def run(command: list[str], cwd: Path, environment: dict[str, str] | None = None) -> None:
    print("+", " ".join(command), flush=True)
    subprocess.run(command, cwd=cwd, env=environment, check=True)


def main() -> int:
    parser = argparse.ArgumentParser(description="Build a Projucer product consistently on macOS, Windows, and Linux.")
    parser.add_argument("--root", required=True, type=Path)
    parser.add_argument("--project", required=True)
    parser.add_argument("--build-folder", required=True)
    parser.add_argument("--configuration", default="Release", choices=("Debug", "Release"))
    parser.add_argument("--bridge-features", choices=("full", "idn-client"))
    parser.add_argument("--target", help="Xcode scheme, Visual Studio project, or Linux make target")
    parser.add_argument("--architecture", default="x64")
    parser.add_argument("--disable-code-signing", action="store_true", help="Disable Xcode code signing for CI verification builds")
    args = parser.parse_args()

    root = args.root.resolve()
    project = root / args.project
    if args.bridge_features:
        bridge = root / "modules" / "laser_dac_c"
        if platform.system() == "Windows":
            run(["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(bridge / "scripts" / "build.ps1"), "-Features", args.bridge_features], bridge)
        elif platform.system() == "Darwin":
            environment = dict(os.environ)
            environment["LDC_FEATURES"] = args.bridge_features
            run([str(bridge / "scripts" / "build_macos_universal.sh")], bridge, environment)
        else:
            environment = dict(os.environ)
            environment["LDC_FEATURES"] = args.bridge_features
            run([str(bridge / "scripts" / "build.sh")], bridge, environment)

    projucer = os.environ.get("PROJUCER_PATH") or shutil.which("Projucer")
    if not projucer and platform.system() == "Darwin":
        candidate = Path.home() / "JUCE" / "Projucer.app" / "Contents" / "MacOS" / "Projucer"
        if candidate.is_file():
            projucer = str(candidate)
    if not projucer:
        raise SystemExit("Set PROJUCER_PATH to the Projucer executable")
    run([projucer, "--resave", str(project)], root)

    build_root = root / "Builds" / args.build_folder
    if platform.system() == "Darwin":
        xcode_root = build_root / "MacOSX"
        command = ["xcodebuild", "-project", f"{args.build_folder}.xcodeproj", "-configuration", args.configuration, "-parallelizeTargets"]
        if args.target:
            command.extend(["-scheme", args.target])
        if args.architecture in ("universal", "x64"):
            command.extend(["-destination", "generic/platform=macOS", "ARCHS=arm64 x86_64", "ONLY_ACTIVE_ARCH=NO"])
        elif args.architecture in ("arm64", "x86_64"):
            command.extend(["-arch", args.architecture])
        if args.disable_code_signing:
            command.extend(["CODE_SIGNING_ALLOWED=NO", "CODE_SIGNING_REQUIRED=NO", "CODE_SIGN_IDENTITY=-"])
        run(command, xcode_root)
    elif platform.system() == "Windows":
        solution = build_root / "VisualStudio2022" / f"{args.build_folder}.sln"
        msbuild = shutil.which("msbuild") or shutil.which("MSBuild.exe")
        if not msbuild:
            raise SystemExit("MSBuild is not available; initialise a Visual Studio developer shell first")
        command = [msbuild, str(solution), "/m", f"/p:Configuration={args.configuration}", "/p:Platform=x64"]
        if args.target:
            command.append(f"/t:{args.target}")
        run(command, solution.parent)
    else:
        make_root = build_root / "LinuxMakefile"
        command = ["make", f"CONFIG={args.configuration}", f"-j{os.cpu_count() or 2}"]
        if args.target:
            command.append(args.target)
        run(command, make_root)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
