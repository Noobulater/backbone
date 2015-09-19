#Written By Aaron Bentley September 18th 2015
import globals
import opengl
import engine/types
import engine/coords/matrix, engine/coords/vector
import engine/glx, engine/camera
import engine/physical/voxel, engine/physical/voxelChunk

let chunkSize = 50*50

proc `[]`*(v: VoxelManager, x,y,z: int): Voxel =
  if x < 50 and z < 50 :
    #translate to chunk space
    let
      xi = abs(v.chunks[3].pos.x.int - x)
      yi = abs(v.chunks[3].pos.y.int - y)
      zi = abs(v.chunks[3].pos.z.int - z)
    return v.chunks[3][xi,yi,zi]
  elif x < 50 and z >= 50 :
    let
      xi = abs(x - v.chunks[2].pos.x.int)
      yi = abs(y - v.chunks[2].pos.y.int)
      zi = abs(z - v.chunks[2].pos.z.int)
    return v.chunks[2][xi,yi,zi]
  elif x >= 50 and z < 50 :
    let
      xi = abs(x - v.chunks[1].pos.x.int)
      yi = abs(y - v.chunks[1].pos.y.int)
      zi = abs(z - v.chunks[1].pos.z.int)
    return v.chunks[1][xi,yi,zi]
  elif x >= 50 and z >= 50 :
    let
      xi = abs(x - v.chunks[0].pos.x.int)
      yi = abs(y - v.chunks[0].pos.y.int)
      zi = abs(z - v.chunks[0].pos.z.int)
    return v.chunks[0][xi,yi,zi]


proc `[]`*(v: VoxelManager, x,y,z: float): Voxel = v[x.int,y.int,z.int]

#Note this is the proc for initializing the WORLD object, not the init hook
#Dont mistake it with the below init call
method init*(v: VoxelManager) =
  v.chunks = newSeq[VoxelChunk](4) #initalizes it

method draw*(v: VoxelManager): bool =
  for i in 0..high(v.chunks) :
    draw(v.chunks[i])
  return false

proc newVoxelManager*(): VoxelManager = return VoxelManager()
