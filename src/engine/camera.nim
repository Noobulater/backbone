#Written by Matt Nichols
#Modified by Aaron Bentley
import opengl
import globals
import types
import coords/matrix, coords/vector
import physical/entity

var
  pos*,ang*: Vec3
  view*,proj*: Mat4
  active: bool

proc cameraAspect*(aspect: float) =
  proj = perspective(fov = 50.0, aspect = aspect, near = 0.05, far = 10000.0)

proc update*() =
  var pPitch = ang.p
  var pYaw = ang.y
  var pRoll = ang.r
  var pPos = pos
  if (LocalPlayer.viewEntity != nil):
    # let pPos = driver.pos * -1 + driver.matrix.forward() * 0.55 + driver.matrix.up() * 0.4
    pPitch += LocalPlayer.viewEntity.angle[0]
    pYaw += -LocalPlayer.viewEntity.angle[1]
    pPos = LocalPlayer.viewEntity.pos + LocalPlayer.viewEntity.viewOffset
    camera.pos = pPos
  view = identity().rotate(pPitch, vec3(1, 0, 0)) * identity().rotate(pYaw, vec3(0, 1, 0)) * identity().translate(pPos * -1)

  if (LocalPlayer.viewModel.visible) :
    LocalPlayer.viewModel.pos = pPos + view.forward() * 3.0 + view.right() * 1.0 + view.up() * -1.0
    LocalPlayer.viewModel.angle = vec3(pPitch * -1, pYaw * -1, pRoll * -1)
    LocalPlayer.viewModel.calcMatrix()


proc setViewAngle*(p,y,r:float) =
  camera.ang[0] = p
  camera.ang[1] = y
  camera.ang[2] = r
  update()

proc setViewAngle*(p,y:float) =
  setViewAngle(p,y,camera.ang[2])

proc init*() =
  pos = vec3(0,0,0)
  ang = vec3(0,0,0)
  view = identity()
  proj = perspective(fov = 50.0, aspect = scrW/scrH, near = 0.05, far = 10000.0)
  active = true
  update()

proc cameraUniforms*(program: uint32) =
  if (active) :
    update()

  if (program.int != 0):
    glUniformMatrix4fv(glGetUniformLocation(program, "view").int32, 1, false, view.m[0].addr)
    glUniformMatrix4fv(glGetUniformLocation(program, "proj").int32, 1, false, proj.m[0].addr)
    glUniform3f(glGetUniformLocation(program, "camera_pos").int32, pos[0], pos[1], pos[2])
