#Written by Matt Nichols
#Contributions by Aaron Bentley
import opengl
import globals
import engine/types, engine/glx
import engine/coords/matrix, engine/coords/vector
import engine/camera
import engine/scene

var pMesh: Mesh # Really didnt want to do this, but its the only way i can get working

method calcMatrix(this: Particle) = #this matrix always needs to face the LocalPlayer
  let
    look = normal(camera.pos - this.pos)
    right = cross(camera.view.up(), look * -1.0)
    up = cross(look, right * -1.0)

  #To make this cheaper, you can save the rotation matrix
  this.matrix = identity()
  this.matrix = this.matrix.translate(this.pos)
  this.matrix.m[0] = right.x
  this.matrix.m[1] = right.y
  this.matrix.m[2] = right.z

  this.matrix.m[4] = up.x
  this.matrix.m[5] = up.y
  this.matrix.m[6] = up.z

  this.matrix.m[8] = look.x
  this.matrix.m[9] = look.y
  this.matrix.m[10] = look.z
  this.matrix = this.matrix.rotate(this.rotation, vec3(0,0,1))
  this.matrix = this.matrix.scale(this.scale)
  #this.matrix = this.matrix.rotate(camera.ang.p * 1.0, vec3(1,0,0))
  #this.matrix = this.matrix.rotate(camera.ang.y * 1.0 - 90.0, vec3(0,1,0))
  #this.matrix = this.matrix.rotate(camera.ang.r * 1.0, vec3(0,0,1))
  #this.matrix = this.matrix.scale(this.scale)

# Initializes this Particle. This means it will begin drawing
method init*(this: Particle): Particle =
  this.pos = vec3(0, 0, 0)
  this.vel = vec3(0, 0, 0)
  this.rotation = 0
  this.rotVel = 1
  this.scale = vec3(1, 1, 1)
  this.calcMatrix()
  this

method draw*(this: Particle) =
  this.calcMatrix()
  worldShader.use()
  glUniformMatrix4fv(glGetUniformLocation(worldShader.handle, "model").int32, 1, false, this.matrix.m[0].addr)
  cameraUniforms(worldShader.handle)
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, GLuint(this.textID))
  pMesh.use()
  this.rotation = this.rotation + this.rotVel
  #glBegin(GL_QUADS)

  #glColor4f(this.color.r.float/255.0, this.color.g.float/255.0, this.color.b.float/255.0, this.color.a.float/255.0)
  #glColor4f(1.0,1.0,1.0,1.0)
  #glTexCoord2f(0,1)
  #glVertex3f(0.5, 0.5, 0)

  #glTexCoord2f(0,0)
  #glVertex3f(-0.5, 0.5, 0)

  #glTexCoord2f(1,0)
  #glVertex3f(-0.5, -0.5, 0)

  #glTexCoord2f(1,1)
  #glVertex3f(0.5, -0.5, 0)

  #glEnd()

proc newParticle*(textID: GLuint, pos: Vec3, rotation: float): Particle =
  result = Particle()
  result.pos = pos
  result.vel = vec3(0, 0, 0)
  result.rotation = rotation
  result.rotVel = 0
  result.scale = vec3(1, 1, 1)
  result.lifeTime = 0.25
  result.textID = textID.int
  result.calcMatrix()
  if (pMesh == nil):
    pMesh = initMesh("models/particle.iqm", worldShader.handle)

proc spawn*(this: Particle, rGroup: int) =
  let spawnTime = curTime() + this.lifeTime

  proc draw(): bool =
    if (spawnTime <= curTime()) :
      return false
    this.draw()
    return true
  scene.addDraw(rGroup, draw)


proc spawn*(this: Particle) = spawn(this, RENDERGROUP_TRANSPARENT.int)
