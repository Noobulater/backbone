#Written by Aaron Bentley 7/4/128
import globals, glx, math, opengl
import engine/types
import physical/entity, physical/model, physical/physObj, physical/dray
import coords/matrix, coords/vector
import parser/bmp, parser/iqm
import camera, skybox
import timer

proc init*() =
  worldShader = initProgram("phong.vert", "phong.frag")
  defMaterial = initMaterial("materials/models/terrain/grass.bmp")

  #var block1 = newPhysObj()
  #block1.setPos(vec3(0.0,128.0,0.0))
  #block1.setAngle(vec3(0.0,0.0,0.0))
  #block1.setAngleVel(vec3(364,0.0,0.0))
  #block1.setVel(vec3(2.0,-1.0,1.0))
  #block1.viewOffset = vec3(0.0,0.0,0.0)
  #block1.mass = 64
  #block1.setModel("models/cube.iqm")
  #block1.material = initMaterial("materials/models/cube/Material.bmp")
  #block1.setModel("models/mrfixit.iqm")
  #block1.material = initMaterial("materials/models/gun/Text_1.bmp")
  #block1.lmin = vec3(0)
  #block1.lmax = vec3(0)
  #block1.gravity = 1.0
  #block1.drag = 1.0
  #camera.viewEntity = block1

  if (true) :
    var brick = newPhysObj()
    brick.setPos(vec3(0.0,0.0,0.0))
    brick.setAngle(vec3(0.0,0.0,0.0))
    #brick.setAngleVel(vec3(62.0,64,1.0))
    brick.setVel(vec3(0.0,0.0,0.0))
    brick.mass = 1.0
    brick.mesh = initCubeMesh(worldShader.handle, 1.0)
    brick.material = initMaterial("materials/models/terrain/rock2.bmp","materials/models/terrain/rock2_normal.bmp")
    brick.lmin = vec3(-1.0)
    brick.lmax = vec3(1.0)
    brick.dynamic = false

    var brick1 = newPhysObj()
    brick1.setPos(vec3(0.0,8.0,0.0))
    brick1.setAngle(vec3(0.0,0.0,0.0))
    #brick.setAngleVel(vec3(62.0,64,1.0))
    brick1.setVel(vec3(0.0,0.0,0.0))
    brick1.mass = 1.0
    brick1.mesh = initCubeMesh(worldShader.handle, 1.0)
    brick1.material = initMaterial("materials/models/terrain/grass.bmp")
    brick1.lmin = vec3(-1.0)
    brick1.lmax = vec3(1.0)


    simple(5, proc() = brick1.vel = vec3(0,-5000,0))
    simple(5.15, proc() = brick1.vel = vec3(0,60,0))

  if (false) :
    var rock1 = newModel()
    rock1.setPos(vec3(12.0,-2.0,23.0))
    rock1.setAngle(vec3(0.0,0.0,0.0))
    rock1.setModel("models/nature/rock1.iqm")
    rock1.material = defMaterial

    var rock2 = newModel()
    rock2.setPos(vec3(83.0,50.0,50.0))
    rock2.setAngle(vec3(0.0,0.0,0.0))
    rock2.setModel("models/guns/knife.iqm")
    rock2.material = defMaterial
    rock2.setScale(vec3(10.0))

    var oildrum1 = newModel(RENDERGROUP_BOTH.int)
    oildrum1.setPos(vec3(33.0,-2.0,55.0))
    oildrum1.setAngle(vec3(0.0,0.0,0.0))
    oildrum1.setModel("models/industrial/chainlink_01.iqm")
    oildrum1.material = defMaterial

    var brick = newPhysObj()
    brick.setPos(vec3(0.0,-112.0,0.0))
    brick.setAngle(vec3(0.0,0.0,0.0))
    #brick.setAngleVel(vec3(62.0,64,1.0))
    brick.setVel(vec3(0.0,0.0,0.0))
    brick.mass = 1.0
    brick.mesh = initCubeMesh(worldShader.handle, 0.25)
    brick.material = initMaterial("materials/models/terrain/grass.bmp")
    brick.lmin = vec3(-128.0 * 4, -2.0, -128.0 * 4)
    brick.lmax = vec3(128.0 * 4, 2.0, 128.0 * 4)
    brick.scale = vec3(128.0 * 4, 2.0, 128.0 * 4)
    brick.dynamic = false

    var ang = 0.0
    for i in 0..2 :
      var wall = newPhysObj()
      wall.setPos(vec3(128.0 * 4 + -128.0 * 4 * ((i + 1) mod 2).float,2.0,128.0 * 4 * ((i - 1) mod 2).float))
      wall.setAngle(vec3(0.0,ang,0.0))
      wall.setVel(vec3(0.0,0.0,0.0))
      wall.mass = 1.0
      wall.mesh = initCubeMesh(worldShader.handle, 1.0)
      wall.material = initMaterial("materials/models/terrain/rock2.bmp","materials/models/terrain/rock2_normal.bmp")
      wall.lmin = vec3(-128.0 * 4, -128.0, -1.0)
      wall.lmax = vec3(128.0 * 4, 128.0, 1.0)
      wall.scale = vec3(128.0 * 4, 128.0, 1.0)
      wall.dynamic = false
      ang = ang + 90.0

    var wall = newPhysObj()
    wall.setPos(vec3(-128.0 * 4,2.0,0.0))
    wall.setAngle(vec3(0.0,ang,0.0))
    wall.setVel(vec3(0.0,0.0,0.0))
    wall.mass = 1.0
    wall.mesh = initCubeMesh(worldShader.handle, 1.0)
    wall.material = initMaterial("materials/models/terrain/rock2.bmp","materials/models/terrain/rock2_normal.bmp")
    wall.lmin = vec3(-128.0 * 4, -128.0, -1.0)
    wall.lmax = vec3(128.0 * 4, 128.0, 1.0)
    wall.scale = vec3(128.0 * 4, 128.0, 1.0)
    wall.dynamic = false

  #var skydome = newModel()
  #skydome.program = initProgram("phong.vert", "sky.frag")
  #skydome.setModel("models/skydome.iqm")
  #skydome.material = initMaterial("bmps/sky.bmp")
  #skydome.setScale(vec3(500))

  skyShader = initProgram("phong.vert", "sky.frag")
  discard loadSkyBox("materials/skyboxes/test/skybox")
  worldInit = true
