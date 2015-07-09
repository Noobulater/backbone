#Written by Aaron Bentley 7/4/15
import globals, glx, math, opengl
import engine/types
import physical/entity, physical/model, physical/physObj, physical/dray
import coords/matrix, coords/vector
import parser/bmp, parser/iqm
import camera

proc init*() =
  var phong = initProgram("phong.vert", "phong.frag")

  var block1 = newPhysObj()
  block1.setPos(vec3(0.0,15.0,0.0))
  block1.setAngle(vec3(0.0,0.0,0.0))
  #block1.setAngleVel(vec3(34.0,0.0,0.0))
  #block1.setVel(vec3(2.0,-1.0,1.0))
  block1.viewOffset = vec3(0.0,0.0,0.0)
  block1.mass = 4.0
  block1.program = phong
  block1.setModel("models/cube.iqm")
  block1.material = initMaterial("materials/models/cube/Material.bmp")
#  block1.setModel("models/gun.iqm")
#  block1.material = initMaterial("materials/models/gun/Text_1.bmp")
  block1.lmin = vec3(-1)
  block1.lmax = vec3(1)
  #block1.gravity = 1.0
  #block1.drag = 1.0

  var brick = newPhysObj()
  brick.setPos(vec3(0.0,0.0,0.0))
  brick.setAngle(vec3(0.0,0.0,0.0))
  #brick.setAngleVel(vec3(62.0,4.0,1.0))
  brick.setVel(vec3(0.0,0.0,0.0))
  brick.program = phong
  brick.mass = 1.0
  brick.setModel("models/unitcube.iqm")
  brick.material = initMaterial("materials/models/terrain/grass.bmp")
  brick.lmin = vec3(-15.0, -0.2, -15.0)
  brick.lmax = vec3(15.0, 0.2, 15.0)
  brick.scale = vec3(15.0, 0.2, 15.0)
  brick.dynamic = false
  for i in low(brick.mesh.data.texCoords)..high(brick.mesh.data.texCoords) :
    brick.mesh.data.texCoords[i] = brick.mesh.data.texCoords[i] * 0.25

  var ang = 0.0
  for i in 0..2 :
    var wall = newPhysObj()
    wall.setPos(vec3(15.0 + -15.0 * ((i + 1) mod 2).float,4.0,15.0 * ((i - 1) mod 2).float))
    wall.setAngle(vec3(0.0,ang,0.0))
    wall.setVel(vec3(0.0,0.0,0.0))
    wall.program = phong
    wall.mass = 1.0
    wall.setModel("models/unitcube.iqm")
    wall.material = initMaterial("materials/models/terrain/rock2.bmp")
    wall.lmin = vec3(-15.0, -4.0, -1.0)
    wall.lmax = vec3(15.0, 4.0, 1.0)
    wall.scale = vec3(15.0, 4.0, 1.0)
    wall.dynamic = false
    ang = ang + 90.0

  var wall = newPhysObj()
  wall.setPos(vec3(-15.0,4.0,0.0))
  wall.setAngle(vec3(0.0,ang,0.0))
  wall.setVel(vec3(0.0,0.0,0.0))
  wall.program = phong
  wall.mass = 1.0
  wall.setModel("models/unitcube.iqm")
  wall.material = initMaterial("materials/models/terrain/rock2.bmp")
  wall.lmin = vec3(-15.0, -4.0, -1.0)
  wall.lmax = vec3(15.0, 4.0, 1.0)
  wall.scale = vec3(15.0, 4.0, 1.0)
  wall.dynamic = false

  var skydome = newModel()
  skydome.program = initProgram("phong.vert", "sky.frag")
  skydome.setModel("models/skydome.iqm")
  skydome.material = initMaterial("bmps/sky.bmp", "bmps/sky.bmp")
  skydome.setScale(vec3(500))
