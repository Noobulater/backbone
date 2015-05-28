import opengl

###########################
######SURFACE STUFF########
###########################
# Surface is responsible for interacting with opengl
# and abstracting much of the drawing procedure so that
# there isn't any need to consider issues like z-fighting
# and other things of the nature

# actual Drawing functions
var # surface uses one draw color, it minimizes alot of calculation
  dRed = 1.0
  dGreen = 1.0
  dBlue = 1.0
  dAlpha = 1.0

proc setColor*( r,g,b,a: int ) =
  dRed = (r/255).float
  dGreen = (g/255).float
  dBlue = (b/255).float
  dAlpha = (a/255).float

proc setColor*( r,g,b,a: float ) =
  dRed = r
  dGreen = g
  dBlue = b
  dAlpha = a

# proc used to draw a rectangle
proc rect*( x,y,width,height: float ) =
  glBegin(GL_QUADS)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x, y, 0 )

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x, y + height, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x + width, y + height, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x + width, y, 0)

  glEnd()

# proc used to draw a rectangle
proc orect*( x,y,width,height: float ) =
  glBegin(GL_LINE_LOOP)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x, y, 0 )

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x, y + height, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x + width, y + height, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glVertex3f( x + width, y, 0)

  glEnd()

#Textured Rect
proc trect*( x,y,width,height: float,textureID: GLuint ) =
  glEnable(GL_TEXTURE_2D)
  glBindTexture(GL_TEXTURE_2D, textureID)

  glBegin(GL_QUADS)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glTexCoord2f( 1,1 )
  glVertex3f( x, y, 0 )

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glTexCoord2f( 1,0 )
  glVertex3f( x, y + height, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glTexCoord2f( 0,0 )
  glVertex3f( x + width, y + height, 0)

  glColor4f( dRed, dGreen, dBlue, dAlpha )
  glTexCoord2f( 0,1 )
  glVertex3f( x + width, y, 0)

  glEnd()
  glDisable(GL_TEXTURE_2D)
