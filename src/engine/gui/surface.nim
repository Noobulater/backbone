import opengl, sdl2, sdl2/ttf, globals
import engine/types
###########################
######SURFACE STUFF########
###########################
# Surface is responsible for interacting with opengl,SDL
# and abstracting much of the drawing procedure so that
# there isn't any need to consider issues like z-fighting
# and other things of the nature

# actual Drawing functions

discard ttfInit()

var # surface uses one draw color, it minimizes alot of calculation
  dRed = 1.0
  dGreen = 1.0
  dBlue = 1.0
  dAlpha = 1.0
  curX = 0.0
  curY = 0.0
  curFont: FontPtr
  curText = "The Quick Brown Fox Jumps Over The Lazy Dog"
  textWidth, textHeight: int
  txtID: GLuint

proc setColor*(r,g,b,a: int) =
  dRed = (r/255).float
  dGreen = (g/255).float
  dBlue = (b/255).float
  dAlpha = (a/255).float

proc setColor*(r,g,b,a: float) =
  dRed = r
  dGreen = g
  dBlue = b
  dAlpha = a

proc setColor*(color: Colr) = setColor(color.r, color.g, color.b, color.a)

proc setCurPos*(x,y:float) =
  curX = x
  curY = y

proc setCurPos*(x,y:int) = setCurPos(x.float, y.float)

proc loadFont*(fontName: string, fontSize, fontStyle, fontOutline: cint ) =
  curFont = openFont(cstring("content/fonts/" & fontName), fontSize)
  setFontStyle(curFont, fontStyle)
  setFontOutline(curFont, fontOutline)

proc loadFont*(fontName: string, fontSize: cint) =
  loadFont(fontName, fontSize, TTF_STYLE_NORMAL, 0)

proc loadFont*(fontName: string, fontSize, fontStyle: cint) =
  loadFont(fontName, fontSize, fontStyle, 0)

proc styleFont*(styleType: string) =
  case styleType :
  of "none" :
    setFontStyle(curFont, TTF_STYLE_NORMAL)
  of "normal" :
    echo("fail")
    setFontStyle(curFont, TTF_STYLE_NORMAL)
  of "bold" :
    setFontStyle(curFont, TTF_STYLE_BOLD)

proc setFontOutline*(fontOutline: cint) =
  setFontOutline(curFont, fontOutline)

var once = true

proc setText*(text: string) =
  if (once) :
    glGenTextures(1, addr txtID)
    once = false
  if (curText != text) :
    curText = text

    var color: sdl2.Color
    color.r = (255).uint8
    color.g = (255).uint8
    color.b = (255).uint8
    color.a = (255).uint8

    var sP = renderTextBlended(curFont, curText, color)
    var sur = sP[]

    textWidth = sur.w
    textHeight = sur.h

    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D, txtID)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, sur.w, sur.h, 0, GL_BGRA, GL_UNSIGNED_BYTE, sur.pixels)

    FreeSurface(sP)

proc getText*(): string = curText
proc getTextWidth*(): int = textWidth
proc getTextHeight*(): int = textHeight

loadFont("Trebuchet.ttf", 24) # trebuchet is the default font. It looks awesome

# proc used to draw a rectangle
proc rect*(x,y,width,height: float) =
  glTranslatef(0,0,-0.00001) # push this rect back just slightly to avoid z fighting
  glBegin(GL_QUADS)

  glColor4f(dRed, dGreen, dBlue, dAlpha)
  glVertex3f((curX + x)/(scrW/2) - 1.0, (curY + y)/(scrH/2) - 1.0, 0)

  glColor4f(dRed, dGreen, dBlue, dAlpha)
  glVertex3f((curX + x)/(scrW/2) - 1.0, (curY + y + height)/(scrH/2) - 1.0, 0)

  glColor4f(dRed, dGreen, dBlue, dAlpha)
  glVertex3f((curX + x + width)/(scrW/2) - 1.0, (curY + y + height)/(scrH/2) - 1.0, 0)

  glColor4f(dRed, dGreen, dBlue, dAlpha)
  glVertex3f((curX + x + width)/(scrW/2) - 1.0, (curY + y)/(scrH/2) - 1.0, 0)

  glEnd()


proc rect*(x,y,width,height: int) = rect(x.float, y.float, width.float, height.float)
proc rect*(x,y: int, width,height: float) = rect(x.float, y.float, width.float, height.float)
proc rect*(x,y: float, width,height: int) = rect(x.float, y.float, width.float, height.float)

# proc used to draw a rectangle
proc orect*(x,y,width,height: float) =
  glTranslatef(0,0,-0.00001) # push this rect back just slightly to avoid z fighting
  glBegin(GL_LINE_LOOP)
  #There are random offsets in here to fit this to a RECT. Makes outlining convient
  glColor4f(dRed, dGreen, dBlue, dAlpha)
  glVertex3f((curX + x + 1.0)/(scrW/2) - 1.0, (curY + y)/(scrH/2) - 1.0, 0)

  glColor4f(dRed, dGreen, dBlue, dAlpha)
  glVertex3f((curX + x)/(scrW/2) - 1.0, (curY + y + height)/(scrH/2) - 1.0, 0)

  glColor4f(dRed, dGreen, dBlue, dAlpha)
  glVertex3f((curX + x + width)/(scrW/2) - 1.0, (curY + y + height)/(scrH/2) - 1.0, 0)

  glColor4f(dRed, dGreen, dBlue, dAlpha)
  glVertex3f((curX + x + width + 1.0)/(scrW/2) - 1.0, (curY + y + 1.0)/(scrH/2) - 1.0, 0)

  glEnd()

proc orect*(x,y,width,height: int) = orect(x.float, y.float, width.float, height.float)
proc orect*(x,y: int, width,height: float) = orect(x.float, y.float, width.float, height.float)
proc orect*(x,y: float, width,height: int) = orect(x.float, y.float, width.float, height.float)

#Textured Rect
proc trect*(x,y,width,height: float,textureID: GLuint) =
  glTranslatef(0,0,-0.00001) # push this rect back just slightly to avoid z fighting
  glEnable(GL_TEXTURE_2D)
  glBindTexture(GL_TEXTURE_2D, textureID)

  glBegin(GL_QUADS)

  glColor4f(dRed, dGreen, dBlue, dAlpha)
  glTexCoord2f(0,1)
  glVertex3f((curX + x)/(scrW/2) - 1.0, (curY + y)/(scrH/2) - 1.0, 0)

  glColor4f(dRed, dGreen, dBlue, dAlpha)
  glTexCoord2f(0,0)
  glVertex3f((curX + x)/(scrW/2) - 1.0, (curY + y + height)/(scrH/2) - 1.0, 0)

  glColor4f(dRed, dGreen, dBlue, dAlpha)
  glTexCoord2f(1,0)
  glVertex3f((curX + x + width)/(scrW/2) - 1.0, (curY + y + height)/(scrH/2) - 1.0, 0)

  glColor4f(dRed, dGreen, dBlue, dAlpha)
  glTexCoord2f(1,1)
  glVertex3f((curX + x + width)/(scrW/2) - 1.0, (curY + y)/(scrH/2) - 1.0, 0)

  glEnd()
  glDisable(GL_TEXTURE_2D)

#Draw Text
proc text*(x,y,width,height: float) =
  glTranslatef(0,0,-0.00001) # push this rect back just slightly to avoid z fighting
  glEnable(GL_TEXTURE_2D)
  glBindTexture(GL_TEXTURE_2D, txtID)

  glBegin(GL_QUADS)

  glColor4f(dRed, dGreen, dBlue, dAlpha)
  glTexCoord2f(0,1)
  glVertex3f((curX + x)/(scrW/2) - 1.0, (curY + y)/(scrH/2) - 1.0, 0)

  glColor4f(dRed, dGreen, dBlue, dAlpha)
  glTexCoord2f(0,0)
  glVertex3f((curX + x)/(scrW/2) - 1.0, (curY + y + height)/(scrH/2) - 1.0, 0)

  glColor4f(dRed, dGreen, dBlue, dAlpha)
  glTexCoord2f(1,0)
  glVertex3f((curX + x + width)/(scrW/2) - 1.0, (curY + y + height)/(scrH/2) - 1.0, 0)

  glColor4f(dRed, dGreen, dBlue, dAlpha)
  glTexCoord2f(1,1)
  glVertex3f((curX + x + width)/(scrW/2) - 1.0, (curY + y)/(scrH/2) - 1.0, 0)

  glEnd()
  glDisable(GL_TEXTURE_2D)

proc text*(x,y: float) = text(x,y,textWidth.float, textHeight.float)
proc text*(x,y: int) = text(x.float, y.float)

proc drawText*(txt: string, x,y:float, color: Colr) =
  setColor(color)
  setText(txt)
  text(x,y)

proc drawText*(txt: string, x,y:float, color: Colr, oColor: Colr) =
  setColor(oColor)
  setText(txt)
  let outlineSize = 1
  for i in 1..outlineSize :
    text(x+i.float,y.float)
    text(x.float,y+i.float)
    text(x-i.float,y.float)
    text(x.float,y-i.float)
    text(x+i.float,y+i.float)
    text(x-i.float,y-i.float)
    text(x+i.float,y-i.float)
    text(x-i.float,y+i.float)
  drawText(txt,x,y,color)
