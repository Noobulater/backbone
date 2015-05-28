#Written by Aaron Bentley 5/27/15
import opengl, math
import globals
import surface
import engine/coords/matrix, engine/coords/vector
######################
########PANELS########
######################
#GLOBAL STUFF (but local to this file)
#FORWARD DECLARATIONS
type
  panel* = ref object of Rootobj
    x*: float
    y*: float
    width*: float
    height*: float
    textureID*: int #if it has a texture
    drawFunc*: proc(x,y,width,height: float)#this is the function to call to draw it
    doClick*: proc(button: int, pressed: bool, x,y: float)
    visible*: bool
    children*: seq[panel]
    parent*: panel

  screen* = ref object of Rootobj
    pos*,ang*, scale*: Vec3
    matrix: Mat4
    children*: seq[panel] #this is the function to call to draw it, happens after rotation

var sManager: seq[screen] # screens that display panels
var mainScreen*: screen

proc default(): proc(x,y,width,height: float) =
  return proc(x,y,width,height: float) =
    setColor(255, 255, 255, 255)
    rect(x, y, width, height)

proc defaultClick(): proc(button: int, pressed: bool, x,y: float) =
  return proc(button: int, pressed: bool, x,y: float) =
    echo("Clicked")

proc newPanel*(x,y,width,height: float): panel =
  result = panel()
  result.x = x/(scrW/2) - 1
  result.y = y/(scrH/2) - 1 # corrects it so that the origin is the top left
  result.width = width/(scrW/2)
  result.height = height/(scrH/2)
  result.visible = true
  result.textureID = 0

  result.drawFunc = default()
  result.doClick =  defaultClick()
  result.children = @[]
  mainScreen.children.add(result)

######################
#######SCREENS########
######################

# Recalculates the transform matrix.
method calcMatrix*(this: screen) =
  this.matrix = identity()
  this.matrix = this.matrix.translate(this.pos)
  this.matrix = this.matrix.scale(this.scale)
  this.matrix = this.matrix.rotate(this.ang[2], vec3(0, 0, 1))
  this.matrix = this.matrix.rotate(this.ang[1], vec3(0, 1, 0))
  this.matrix = this.matrix.rotate(this.ang[0], vec3(1, 0, 0))

# Sets the pos of the screen
method setPos*(this: screen, v: Vec3) =
  this.pos = v
  this.calcMatrix()

# Sets the angle of the screen
method setAngle*(this: screen, a: Vec3) =
  this.ang = a
  this.calcMatrix()

# Sets the angle of the screen
method setScale*(this: screen, a: Vec3) =
  this.scale = a
  this.calcMatrix()

# This creates a new screen. Screens are just entities in the world that project
# Their children's draw code onto their location
proc newScreen*(xPos,yPos,zPos,pitch,yaw,roll: float): screen =
  result = screen()
  # Entities handle a ton of matrix calculation, might as well just use them
  result.setPos(vec3(xPos, yPos, zPos))
  result.setAngle(vec3(pitch, yaw, roll))
  result.setScale(vec3(1,1,1))
  result.children = @[] # no panels currently

proc newScreen*(pos, ang: Vec3): screen =
  return newScreen(pos.x, pos.y, pos.z, ang.p, ang.y, ang.r)

mainScreen = newScreen(0.0, 0.0, 0.0,  0.0, 0.0, 0.0)

proc dive(cPanel: panel) =
  var cur: panel
  for i in low(cPanel.children)..high(cPanel.children):
    cur = cPanel.children[i]
    if (cur.visible) :
      cur.drawFunc( cur.x, cur.y, cur.width, cur.height )
      glTranslatef(0,0,0.0001) # push the next panel back a bit to stop z fighting

proc dive(cScreen: screen) = #Dive because its going to do a depth first call order
  var cur: panel
  for i in low(cScreen.children)..high(cScreen.children):
    cur = cScreen.children[i]
    cur.drawFunc(cur.x, cur.y, cur.width, cur.height)
    cur.dive()

var pixelArray: array[0..3,GLfloat]
proc collide(cPanel: panel, x,y: float): bool = #tests whether or not a panel has been clicked on
  pixelArray[0] = 0
  pixelArray[1] = 0
  pixelArray[2] = 0
  pixelArray[3] = 0

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  setColor(69,96,59,255)
  rect(cPanel.x,cPanel.y,cPanel.width,cPanel.height)
  setColor(255,255,255,255)

  glReadPixels((GLint) x,(GLint)(scrH.float-y-1), (GLsizei) 1,(GLsizei) 1, GL_RGBA, cGL_FLOAT, addr pixelArray[0])
  if (pixelArray[0]*255 == 69 and pixelArray[1]*255 == 96 and pixelArray[2]*255 == 59) :
    return true
  return false

proc panelsDraw*() =
  #glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  glUseProgram(0) # make sure we don't mess with the custom shader
  glDisable(GL_TEXTURE_2D)
  glDisable(GL_CULL_FACE)
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity()
  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity()
  mainScreen.dive()

  var cScreen: screen # current Screen
  for i in low(sManager)..high(sManager):
    cScreen = sManager[i]
    #glMatrixMode(GL_PROJECTION)
    #glLoadIdentity()
    #glLoadMatrixf(camera.proj.m[0].addr)

    #glMatrixMode(GL_MODELVIEW)
    #glLoadIdentity()

    #glLoadMatrixf(cScreen.matrix.m[0].addr)
    #cScreen.dive()
  glEnable(GL_CULL_FACE)
  glEnable(GL_TEXTURE_2D)

#Panel I/O
proc panelsMouseInput*(button: int, pressed: bool, x,y:float) =
  var
    cur: panel
    xCoords, yCoords: float
    xMin,xMax: float
    yMin,yMax: float
  glUseProgram(0) # make sure we don't mess with the custom shader
  glDisable(GL_TEXTURE_2D)
  glDisable(GL_CULL_FACE)
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity()
  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity()
  for i in low(mainScreen.children)..high(mainScreen.children):
    cur = mainScreen.children[i]
    if (cur.collide(x,y)) :
      cur.doClick(button, pressed, x,y) # call the do click
      break

  #var cScreen: screen
  #var pro = perspective(fov = 50.0, aspect = (scrW/scrH).float, near = 0.05, far = 10000.0)
  #for i in low(sManager)..high(sManager):
  #  cScreen = sManager[i]
  #  glMatrixMode(GL_PROJECTION)
  #  glLoadIdentity()
    #glLoadMatrixf(camera.proj.m[0].addr)

  #  glMatrixMode(GL_MODELVIEW)
  #  glLoadIdentity()

    #var result = (camera.view * cScreen.matrix)
  #  glLoadMatrixf(cScreen.matrix.m[0].addr)

    #cheaper method is just compare pixels
  #  for i in low(cScreen.children)..high(cScreen.children):
  #    cur = cScreen.children[i]
  #    if (cur.collide(x,y)) :
  #      cur.doClick( button, pressed, x,y ) # call the do click
  #      break

  glEnable(GL_CULL_FACE)
  glEnable(GL_TEXTURE_2D)

    #take screen coords, convert them to real word coordinates
    #no
    #xCoords = x / (scrW.float/2) - 1
    #yCoords = y / (-scrH.float/2) + 1 # corrects it so that the origin is the top left
    #for i in low(curS.children)..high(curS.children):
    #  cur = curS.children[i]
    #  if (cur.visible) :
    #    xMin = cur.x
    #    xMax = xMin + cur.width
    #    if ( xMin <= xCoords and xMax >= xCoords ) : #check if its within the panel's x
    #      yMax = cur.y
    #      yMin = yMax - cur.height
    #      if ( yCoords >= yMin and yCoords <= yMax ) : #check if its within the panel's y
    #        cur.doClick( button, pressed, x,y ) # call the do click
