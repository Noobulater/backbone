#Written by Aaron Bentley 7/4/128
import globals, glx, math, opengl
import engine/types
import physical/entity, physical/model, physical/physObj, physical/dray
import physical/voxel, physical/voxelChunk
import structures/VoxelManager
import coords/matrix, coords/vector
import parser/bmp, parser/iqm
import camera, skybox
import timer
import scene

proc worldDraw(): bool = return draw(worldData)

proc iterate() =
  var staggar = 5.0
  for i in 0..49 :
    for j in 0..49 :
      if (worldData[j-25,2,i-25].getActive()) :
        let x = j -25
        let z = i -25
        simple(staggar, proc() = camera.pos = vec3(x,2 + 1,z) )
        staggar = staggar + 1.0
        echo(staggar)

proc init*() =
  worldShader = initProgram("phong.vert", "phong.frag")
  defMaterial = initMaterial("materials/models/terrain/grass.bmp")

  baseVoxel = initCubeMesh(worldShader.handle, 1.0).handle.int
  worldData = newVoxelManager()
  worldData.init()

  for i in 0..3 :
    var mapChunk = newVoxelChunk()
    mapChunk.init()
    mapChunk.rebuild()
    case (i) :
    of 0:
      mapChunk.pos = vec3(50,0,50)
    of 1:
      mapChunk.pos = vec3(50,0,0)
    of 2:
      mapChunk.pos = vec3(0,0,50)
    else :
      mapChunk.pos = vec3(0,0,0)
    mapChunk.matrix = identity().translate(mapChunk.pos)
    worldData.chunks[i] = mapChunk

  #iterate()
  #for x in 0..high(mapChunk.d) :
  #  for y in 0..high(mapChunk.d[x]) :
  #    if (y == 0) :
  #      for z in 0..high(mapChunk.d[x][y]) :
  #        mapChunk.d[x][y][z].setActive(true)

    #simple(5, proc() = brick1.vel = vec3(0,-5000,0))
    #simple(5.15, proc() = brick1.vel = vec3(0,60,0))

  #var brick2 = newPhysObj()
  #brick.setPos(vec3(2.5,2.5,-4.5))
  #brick2.setPos(vec3(2,6,6))
  #brick2.setAngle(vec3(0.0,0.0,0.0))
  #simple(5, proc() = brick2.setVel(vec3(0.0,-1.0,0.0)))
  #brick2.setModel("models/crates/crate.iqm")
  #brick2.material = initMaterial("materials/models/terrain/grass.bmp")
  #brick2.lmin = vec3(-0.48)
  #brick2.lmax = vec3(0.48)
  #brick2.scale = vec3(0.5)

  skyShader = initProgram("phong.vert", "sky.frag")
  discard loadSkyBox("materials/skyboxes/test/skybox")

  addDraw(RENDERGROUP_WORLD.int, worldDraw)

  worldInit = true
