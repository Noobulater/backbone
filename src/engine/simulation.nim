#Written By Aaron Bentley
#The purpose of this file is to simulate physics, nothing more
import globals, glx, math
import physical/entity
import coords/matrix, coords/vector, physical/model, parser/bmp, parser/iqm
import camera
import timer

proc init*() = #initializes teh physics engine
  var phong = initProgram("phong.vert", "phong.frag")

  let meshes = @[
    #initMesh("content/models/cube.obj", phong.handle),
    initMesh("models/mrfixit.iqm", phong.handle)
  ]

  let mats = @[
    initMaterial("Head.bmp"),
    initMaterial("Body.bmp")
    #initMaterial("content/bmps/rock1.bmp"),
    #initMaterial("content/bmps/rock2.bmp")
  ]

  let theta = random(0.0..(PI * 2))
  let dist = random(40.0..2000.0)
  var het = 0.0
  for i in 1..3:
    var astroid = newModel()
    astroid.setPos(vec3(0.0, -4.0, -5.0 + het))
    astroid.setAngle(vec3(-90.0,0.0,0.0))#vec3(random(0.0..360.0), random(0.0..360.0), random(0.0..360.0)))
    astroid.setAngleVel(vec3(0))
    astroid.program = phong
    astroid.material = mats[random(0..2)]
    astroid.mesh = initMesh("models/mrfixit.iqm", phong.handle)
    astroid.lmin = vec3(-1)
    astroid.lmax = vec3(1)
    #astroid.setScale(vec3(5))
    het += 10
    #if (i > 1) :
    #  astroid.gravity = 1

  var skydome = newModel()
  skydome.program = initProgram("phong.vert", "sky.frag")
  skydome.mesh = initMesh("models/skydome.iqm", skydome.program.handle)
  skydome.material = initMaterial("bmps/sky.bmp", "bmps/sky.bmp")
  skydome.setScale(vec3(500))


proc update*(dt: float) = #dt was the last time it was called
  var curEnt: Entity
  for i in low(entities)..high(entities):
    curEnt = entities[i]
    if (curEnt.gravity != 0) :
      let newGrav = curEnt.vel[1] - curEnt.gravity * dt
      curEnt.setVel(vec3(curEnt.vel[0], newGrav, curEnt.vel[2])) # gravity/drag handle
    if (curEnt.drag != 0) :
      let drag = curEnt.drag * dt
      curEnt.setVel(vec3(curEnt.vel[0]*drag, curEnt.vel[1]*drag, curEnt.vel[2]*drag)) # gravity/drag handle
    # gravity/drag handle

    curEnt.update(dt)
    if (curEnt.lmin != 0.0 or curEnt.lmax != 0.0) :
      for j in low(entities)..high(entities):
        if (entities[j] != curEnt) :
          if (entities[j].lmin != 0.0 or entities[j].lmax != 0.0) :
            if (curEnt.intersect(entities[j])) :
              entities[j].vel[1] = entities[j].vel[1] * -1.0
    #if (entities[1].intersect(entities[0])) :
    #  entities[1].vel = vec3(0.0,1.0,0.0)
