#written by Aaron Bentley 5/19/15
#Modules
import opengl, glu, globals, math
import parser/bmp, gui/panel
#Files
#import gui
var txtID : GLuint
var pane = newPanel(0,0,100,100)

proc d(x,y,width,height: float) =
  setColor(255, 255, 255, 255)
  trect(x, y, width, height, txtID)
pane.drawFunc = d

#All visible elements
var draws*: seq[proc()] = @[]
proc addDraw*(draw: proc()) =
  draws.add(draw)

proc drawScene*() =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  for i in low(draws)..high(draws):
    draws[i]()

proc init*() =
  loadExtensions()
  glClearColor(0.0, 0.0, 0.0, 1.0)
  glClearDepth(1.0)
  glEnable(GL_TEXTURE_2D)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_DEPTH_TEST)
  glEnable(GL_CULL_FACE)
  txtID = parseBmp("content/notbad.bmp")

proc resized*( width, height: int ) =
  scrW = width
  scrH = height
  glViewport( 0, 0, (GLsizei) width, (GLsizei) height )

proc draw*() =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  panelsDraw()
