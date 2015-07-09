#Written by Aaron Bentley 5/27/15
import opengl, math
import globals
import engine/types
import surface
import engine/coords/matrix, engine/coords/vector

var sManager: seq[Screen] # screens that display panels
var mainScreen*: Screen

proc default(): proc(x,y,width,height: float) =
  return proc(x,y,width,height: float) =
    setColor(255, 255, 255, 255)
    rect(x, y, width, height)

proc defaultClick(): proc(button: int, pressed: bool, x,y: float) =
  return proc(button: int, pressed: bool, x,y: float) =
    echo("Clicked")

proc newPanel*(x,y,width,height: float): Panel =
  result = Panel()
  result.x = x
  result.y = y
  result.width = width
  result.height = height
  result.visible = true
  result.textureID = 0
  result.crop = true

  result.drawFunc = default()
  result.doClick =  defaultClick()
  result.children = @[]
  mainScreen.children.add(result)

proc newPanel*(x,y,width,height: float, parent: Panel): Panel =
  result = Panel()
  result.x = x
  result.y = y
  result.width = width
  result.height = height
  result.visible = true
  result.textureID = 0
  result.crop = true

  result.drawFunc = default()
  result.doClick =  defaultClick()
  result.children = @[]
  result.parent = parent
  parent.children.add(result)

######################
#######SCREENS########
######################

# Recalculates the transform matrix.
method calcMatrix*(this: Screen) =
  this.matrix = identity()
  this.matrix = this.matrix.translate(this.pos)
  this.matrix = this.matrix.scale(this.scale)
  this.matrix = this.matrix.rotate(this.ang[2], vec3(0, 0, 1))
  this.matrix = this.matrix.rotate(this.ang[1], vec3(0, 1, 0))
  this.matrix = this.matrix.rotate(this.ang[0], vec3(1, 0, 0))

# Sets the pos of the screen
method setPos*(this: Screen, v: Vec3) =
  this.pos = v
  this.calcMatrix()

# Sets the angle of the screen
method setAngle*(this: Screen, a: Vec3) =
  this.ang = a
  this.calcMatrix()

# Sets the angle of the screen
method setScale*(this: Screen, a: Vec3) =
  this.scale = a
  this.calcMatrix()

# This creates a new screen. Screens are just entities in the world that project
# Their children's draw code onto their location
proc newScreen*(xPos,yPos,zPos,pitch,yaw,roll: float): Screen =
  result = Screen()
  # Entities handle a ton of matrix calculation, might as well just use them
  result.setPos(vec3(xPos, yPos, zPos))
  result.setAngle(vec3(pitch, yaw, roll))
  result.setScale(vec3(1,1,1))
  result.children = @[] # no panels currently

proc newScreen*(pos, ang: Vec3): Screen =
  return newScreen(pos.x, pos.y, pos.z, ang.p, ang.y, ang.r)

mainScreen = newScreen(0.0, 0.0, 0.0,  0.0, 0.0, 0.0)

proc dive(cPanel: Panel) =
  var cur: Panel
  if (cPanel.crop) :
    glScissor(GLint(cPanel.x), GLint(cPanel.y),  GLsizei(cPanel.width), GLsizei(cPanel.height))

  for i in low(cPanel.children)..high(cPanel.children):
    cur = cPanel.children[i]
    if (cur.visible) :
      surface.setCurPos(cPanel.x + cur.x, cPanel.y + cur.y)
      cur.drawFunc(cur.x, cur.y, cur.width, cur.height)

proc dive(cScreen: Screen) = #Dive because its going to do a depth first call order
  var cur: Panel
  for i in low(cScreen.children)..high(cScreen.children):
    cur = cScreen.children[i]
    surface.setCurPos(cur.x, cur.y)
    cur.drawFunc(cur.x, cur.y, cur.width, cur.height)
    cur.dive()

proc getAbsoluteX*(cPanel: Panel): float =
  if (cPanel.parent == nil) :
    return 0.0
  else :
    return cPanel.parent.x + getAbsoluteX(cPanel.parent)

proc getAbsoluteY*(cPanel: Panel): float =
  if (cPanel.parent == nil) :
    return 0.0
  else :
    return cPanel.parent.y + getAbsoluteY(cPanel.parent)

var pixelArray: array[0..3,GLfloat]
proc collide(cPanel: Panel, x,y: float): bool = #tests whether or not a panel has been clicked on
  pixelArray[0] = 0
  pixelArray[1] = 0
  pixelArray[2] = 0
  pixelArray[3] = 0

  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

  setColor(69,96,59,255)
  surface.setCurPos(getAbsoluteX(cPanel), getAbsoluteY(cPanel))
  rect(cPanel.x,cPanel.y,cPanel.width,cPanel.height)
  setColor(255,255,255,255)

  glReadPixels((GLint) x,(GLint)(scrH.float-y-1), (GLsizei) 1,(GLsizei) 1, GL_RGBA, cGL_FLOAT, addr pixelArray[0])

  if (pixelArray[0]*255 == 69 and pixelArray[1]*255 == 96 and pixelArray[2]*255 == 59) :
    return true
  return false

proc drawPrep() =
  glUseProgram(0) # make sure we don't mess with the custom shader
  glEnable(GL_SCISSOR_TEST)
  glDisable(GL_TEXTURE_2D)
  glDisable(GL_CULL_FACE)
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity()
  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity()

proc drawCleanup() =
  glEnable(GL_CULL_FACE)
  glEnable(GL_TEXTURE_2D)
  glDisable(GL_SCISSOR_TEST)

proc panelsDraw*() =
  drawPrep()
  mainScreen.dive()

  #var cScreen: Screen # current Screen
  #for i in low(sManager)..high(sManager):
  #  cScreen = sManager[i]
    #glMatrixMode(GL_PROJECTION)
    #glLoadIdentity()
    #glLoadMatrixf(camera.proj.m[0].addr)

    #glMatrixMode(GL_MODELVIEW)
    #glLoadIdentity()

    #glLoadMatrixf(cScreen.matrix.m[0].addr)
    #cScreen.dive()
  drawCleanup()

#Panel I/O
proc checkCollision(cPanel: Panel, x,y: float): Panel =
  if (cPanel.children.len > 0) :
    var cur: Panel
    for i in low(cPanel.children)..high(cPanel.children):
      cur = cPanel.children[i]
      if (cur.collide(x,y)) :
        return checkCollision(cur,x,y)
  return cPanel

proc panelsMouseInput*(button: int, pressed: bool, x,y:float) =
  var
    cur: Panel
    xCoords, yCoords: float
    xMin,xMax: float
    yMin,yMax: float
  drawPrep()
  glDisable(GL_SCISSOR_TEST)
  for i in low(mainScreen.children)..high(mainScreen.children):
    cur = mainScreen.children[i]
    if (cur.collide(x,y)) :
      checkCollision(cur,x,y).doClick(button, pressed, x,y) # call the do click


  #var cScreen: Screen
  #var pro = perspective(fov = 50.0, aspect = (scrW/scrH).float, near = 0.05, far = inf)
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

  drawCleanup()

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
