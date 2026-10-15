#!/usr/bin/env python3
from __future__ import annotations

import argparse
import xml.etree.ElementTree as ET
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description="Print the version from a JUCE project file.")
    parser.add_argument("project", type=Path)
    args = parser.parse_args()
    root = ET.parse(args.project).getroot()
    version = root.attrib.get("version", "").strip()
    if not version:
        parser.error(f"{args.project} has no version attribute")
    print(version)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
