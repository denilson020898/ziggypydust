# This file is used to build the project. Do not modify.
# from pydust.build import build

import sys
from pydust import buildzig
import os

BUILD = os.environ.get("OPTIMIZE", "Debug")

def build(optimize):
    """The main entry point from Poetry's build script."""
    buildzig.zig_build(["install", f"-Dpython-exe={sys.executable}", f"-Doptimize={optimize}"])

print(f"### Build target : {BUILD}")
build(BUILD)
