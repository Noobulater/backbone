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

proc init*() =
  worldShader = initProgram("phong.vert", "phong.frag")
  defMaterial = initMaterial("materials/models/terrain/grass.bmp")

  baseVoxel = initCubeMesh(worldShader.handle, 1.0).handle.int
  worldData = newVoxelManager()
  worldData.init()

  var mapChunk = newVoxelChunk()
  mapChunk.matrix = identity().translate(vec3(0,0,0))
  mapChunk.init()
  mapChunk.rebuild()

  worldData.chunks = mapChunk
  #for x in 0..high(mapChunk.d) :
  #  for y in 0..high(mapChunk.d[x]) :
  #    if (y == 0) :
  #      for z in 0..high(mapChunk.d[x][y]) :
  #        mapChunk.d[x][y][z].setActive(true)

    #simple(5, proc() = brick1.vel = vec3(0,-5000,0))
    #simple(5.15, proc() = brick1.vel = vec3(0,60,0))

  skyShader = initProgram("phong.vert", "sky.frag")
  discard loadSkyBox("materials/skyboxes/test/skybox")

  addDraw(RENDERGROUP_WORLD.int, worldDraw)

  worldInit = true
