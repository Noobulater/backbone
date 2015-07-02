#Written By Aaron Bentley 7/1/15
import sdl2, sdl2/private/keycodes
import globals

var keyStates = getKeyboardState()

proc isKeyDown*(keyCode: cint) : bool =
  return (keyStates[getScancodeFromKey(keyCode).int] == 1)
