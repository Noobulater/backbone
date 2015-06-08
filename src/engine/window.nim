#Written by Aaron Bentley 5/19/15
#Modules
import sdl2, opengl, glu, math
import parser/iqm

#Files
import globals
import camera, audio, timer, glx, simulation
import gui/panel
import coords/matrix, coords/vector
import parser/bmp
import gui/surface

proc resized(width, height: int) =
  scrW = width
  scrH = height
  glViewport(0, 0, (GLsizei) width, (GLsizei) height)
  cameraAspect(width.float / height.float)

var
  window: WindowPtr
  context: GLContextPtr

var dt: float

# Frame rate limiter
let targetFramePeriod: uint32 = 20 # 20 milliseconds corresponds to 50 fps
var frameTime: uint32 = 0
proc limitFrameRate() =
  let now = getTicks()
  if frameTime > now:
    delay(frameTime - now) # Delay to maintain steady frame rate
  frameTime += targetFramePeriod

var txtId: GLuint
proc init*() =
  #created
  discard sdl2.init(INIT_EVERYTHING)
  window = createWindow(windowTitle, 500, 100, (cint) scrW, (cint) scrH, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
  context = window.glCreateContext()
  loadExtensions()
  glClearColor(0.0, 0.0, 0.0, 1.0)
  glClearDepth(1.0)
  glEnable(GL_TEXTURE_2D)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_DEPTH_TEST)
  glEnable(GL_CULL_FACE)
  glFrontFace(GL_CW)
  txtId = parseBmp("bmps/notbadd.bmp")
  dt = 0.0

  simulation.init()
  camera.init()

  resized(scrW, scrH)

proc update(dt: float) =
  timer.update(dt)
  audio.update(dt)
  simulation.update(dt)

var z = newPanel(0,0,100,100)
let sound = Sound("sound/whatayabuyin.wav")

proc buy(button: int, pressed: bool, x,y: float) =
  sound.play()
z.doClick = buy

proc drurr(x,y,width,height: float) =
  setColor(255, 255, 255, 255)
  trect(x, y, width, height, txtId)

z.drawFunc = drurr

proc display() =
  drawScene()
  panelsDraw()

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
let camSpeed = 50.0
proc mouseMotion( evt: MouseMotionEventPtr ) =
  #Uint8 type;
  #Uint8 state;
  #Uint16 x, y;
  #Sint16 xrel, yrel;
  #discard
  #ShowCursor(mainmenu.cursor)
  #if (not mainmenu.cursor):
  setViewAngle(max(min(camera.ang.p + evt.yrel.float * camSpeed * dt, 89.9), -89.9), camera.ang.y + evt.xrel.float * camSpeed * dt)

#Handles Single Key Input
proc keyInput( evt: KeyboardEventPtr ) =
  #var action = ""
  #case evt.kind
  #of KeyDown: action = "start"
  #of KeyUp: action = "stop"
  #else: action = "else"
  case evt.keysym.sym
  of K_W: camera.pos = vec3(camera.pos[0] + 1.0, camera.pos[1], camera.pos[2])
  of K_S: camera.pos = vec3(camera.pos[0] - 1.0, camera.pos[1], camera.pos[2])
  of K_A: camera.pos = vec3(camera.pos[0], camera.pos[1], camera.pos[2] + 1.0)
  of K_D: camera.pos = vec3(camera.pos[0], camera.pos[1], camera.pos[2] - 1.0)
  of K_SPACE: camera.pos = vec3(camera.pos[0], camera.pos[1] + 1.0, camera.pos[2])
  of K_LCTRL: camera.pos = vec3(camera.pos[0], camera.pos[1] - 1.0, camera.pos[2])
  else : discard
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
  var
    evt = sdl2.defaultEvent
    lastTime = 0.uint32

  while alive:

    dt = (getTicks() - lastTime).float / 1000.0
    lastTime = getTicks()

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

    update(dt)
    display()
    limitFrameRate()

    window.glSwapWindow()
