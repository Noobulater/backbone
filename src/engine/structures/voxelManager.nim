#Written By Aaron Bentley September 18th 2015
import globals
import opengl
import engine/types
import engine/coords/matrix, engine/coords/vector
import engine/glx, engine/camera
import engine/physical/voxel, engine/physical/voxelChunk

let chunkSize = 50*50

proc `[]`*(v: VoxelManager, x,y,z: int): Voxel = return v.chunks[x,y,z]
proc `[]`*(v: VoxelManager, x,y,z: float): Voxel = v[x.int,y.int,z.int]

#Note this is the proc for initializing the WORLD object, not the init hook
#Dont mistake it with the below init call
method init*(v: VoxelManager) = discard
  #v.chunks = @[@[@[]]] #initalizes it

method draw*(v: VoxelManager): bool =
  draw(v.chunks)
  return false

proc newVoxelManager*(): VoxelManager = return VoxelManager()
