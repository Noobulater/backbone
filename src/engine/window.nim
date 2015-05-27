#Written by Aaron Bentley 5/19/15
#Modules
import sdl2

#Files
import globals
import display, timer, sound
import gui/panel

var
  window: WindowPtr
  context: GLContextPtr

proc init*() =
  #created
  discard sdl2.init(INIT_EVERYTHING)
  window = createWindow(windowTitle, 500, 100, (cint) scrW, (cint) scrH, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
  context = window.glCreateContext()
  display.init()
  resized( scrW, scrH )

proc update() =
  timer.update()
  sound.update()

proc display() =
  display.draw()

#Handles Mouse Button Input ( LeftMouse, RightMouse, doesn't handle Mousewheel )
proc mouseInput( evt: MouseButtonEventPtr ) =
  # handle all the SDL enums in this handler, that way we don't have to include
  # SDL2 in every file we want to manipulate/utilize input

  var b: int # contains the button code

  case evt.button :
  of ButtonLeft : b = 0
  of ButtonRight : b = 1
  of ButtonMiddle : b = 2
  of ButtonX1 : b = 3
  of ButtonX2 : b = 4
  else : b = 5 # unrecognized input

  if (evt.kind == MouseButtonUp):
    panelsMouseInput( b, true, evt.x.float, evt.y.float )

  #we might not even need type, but i wrote it out anyways. pressing delete is alot easier

proc mouseMotion( evt: MouseMotionEventPtr ) =
  #Uint8 type;
  #Uint8 state;
  #Uint16 x, y;
  #Sint16 xrel, yrel;
  discard
  #ShowCursor(mainmenu.cursor)
  #if (not mainmenu.cursor):
  #  cameraEye(camera.pos, max(min(camera.pitch + evt.yrel.float, 89.9), -89.9), camera.yaw + evt.xrel.float)

#Handles Single Key Input
proc keyInput( evt: KeyboardEventPtr ) =
  discard
  #var action = ""
  #case evt.kind
  #of KeyDown: action = "start"
  #of KeyUp: action = "stop"
  #else: action = "else"
  #case evt.keysym.sym
  #of K_W: simulator.controlInput("forward", action)
  #of K_S: simulator.controlInput("back", action)
  #of K_A: simulator.controlInput("left", action)
  #of K_D: simulator.controlInput("right", action)
  #of K_UP: simulator.controlInput("up", action)
  #of K_DOWN: simulator.controlInput("down", action)
  #of K_LEFT: simulator.controlInput("roll_left", action)
  #of K_RIGHT: simulator.controlInput("roll_right", action)
  #else: simulator.controlInput("else", action)

  #if evt.keysym.sym == K_SPACE:
  #  if (action == "stop"):
  #    mainmenu.cursor = not mainmenu.cursor

  #if evt.keysym.sym == K_ESCAPE:
  #  mainmenu.pullup()

proc run*() =
  #running
  var evt = sdl2.defaultEvent
  while alive:
    while pollEvent(evt):
      if evt.kind == QuitEvent:
        alive = false
        break
      if evt.kind == WindowEvent:
        var windowEvent = cast[WindowEventPtr](addr(evt))
        if windowEvent.event == WindowEvent_Resized:
          let newWidth = windowEvent.data1
          let newHeight = windowEvent.data2
          resized( newWidth, newHeight )
      if evt.kind == KeyDown or evt.kind == KeyUp:
        keyInput(evt.key)
      if evt.kind == MouseButtonDown or evt.kind == MouseButtonUp:
        mouseInput(evt.button)
      if evt.kind == MouseMotion:
        mouseMotion(evt.motion)
    update()
    display()
    window.glSwapWindow()