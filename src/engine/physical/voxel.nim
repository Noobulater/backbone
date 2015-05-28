import opengl
import entity

type
  Voxel* = object of Entity
    v*: array[0..11, float]

    i*: array[0..5, int]

proc newVoxel*(): Voxel =
  result = Voxel()
  result.v = [1.0, -1.0, 0.0,
              -1.0, 1.0, 0.0,
              1.0, 1.0, 1.0,
              1.0, -1.0, 0.0]
  result.i = [0,1,2, 0,2,3]
