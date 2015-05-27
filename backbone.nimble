[Package]
name          = "newatoad"
version       = "0.1.0"
author        = "Aaron Bentley"
description   = "Aarons game"
license       = "its all mine"

bin = "src/main"

[Deps]
Requires: """
  nim >= 0.10.0
  sdl2 >= 1.0
  opengl >= 1.0
"""
