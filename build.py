# This file is used to build the project. Do not modify.
from pydust.build import build
# import sys
# from pydust import buildzig
# def build():
#     """The main entry point from Poetry's build script."""
#     buildzig.zig_build(["install", f"-Dpython-exe={sys.executable}", "-Doptimize=Debug"])
#     # buildzig.zig_build(["install", f"-Dpython-exe={sys.executable}", "-Doptimize=ReleaseSafe"])
build()
