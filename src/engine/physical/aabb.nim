#Written By Aaron Bentley
#Axis Aligned Bounding Box class
import engine/coords/matrix, engine/coords/vector

type
  AABB* = ref object of RootObj


proc newBoundingBox*():AABB = AABB()

method init(this: AABB):AABB =
  result = newBoundingBox()
  lmin = vec3(0)
  lmax = vec3(0)

method intersectAABB(this, that:AABB): bool =
  let minDist = this.min - this.max
  let maxDist = this.max - this.min
  let dist = max(minDist,maxDist).MaxValue

  return (dist < 0)
