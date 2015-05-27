import opengl

type
  Voxel* = object
    v: array[0..15, float]

    i: array[0..5, uint8]

proc newVoxel*():Voxel = Voxel()
proc newVoxel*(s: int): Voxel =
  result = newVoxel()
  result.v = [1.0'f32, -1.0, 0.0,
              -1.0, 1.0, 0.0,
              1.0, 1.0, 1.0,
              1.0, -1.0, 0.0]
  result.i = [0,1,2, 0,2,3]
