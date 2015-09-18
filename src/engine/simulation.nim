#Written By Aaron Bentley
#The purpose of this file is to simulate physics, nothing more
import globals, glx, math, opengl
import types
import physical/entity, physical/physObj, physical/model, physical/dray
import coords/matrix, coords/vector
import parser/bmp, parser/iqm
import camera
import timer
import physical/voxel, physical/voxelChunk
import structures/VoxelManager

proc init*() = discard
proc click*() = discard

#######################
# COLLISION DETECTION #
#######################

#AXIS ALIGNED BOUNDING BOX
proc intersectingAABB*(this, that: PhysObj): bool =
  let
    dist1 = (this.lmin + this.pos) - (that.lmax + that.pos)
    dist2 = (that.lmin + that.pos) - (this.lmax + this.pos)
    distance = max(dist1,dist2)
  return (distance.maxValue() < 0)

#Intersecting manager
# This seperates and identifies which rules to use to test intersection
proc intersecting(this, that: PhysObj): colData =
  return colData(willIntersect: false)#intersectingAABB(this, that)


proc queryVoxels*(lmin,lmax: Vec3): bool =
  #return true if there is an active voxel in here
  let
    xstart = lmin.x.int
    ystart = lmin.y.int
    zstart = lmin.z.int
    xrange = (lmax.x - lmin.x).int
    yrange = (lmax.y - lmin.y).int
    zrange = (lmax.z - lmin.z).int

  for x in xstart..(xstart + xrange) :
    for y in ystart..(ystart + yrange) :
      for z in zstart..(zstart + zrange) :
        if (x >= 0 and y >= 0 and z >= 0) :
          if (worldData[x,y,z].getActive()) :
            return true
  return false

######################
proc update*(dt: float) = #dt was the last time it was called
  var curEnt: PhysObj
  for i in low(physObjs)..high(physObjs) :
    curEnt = physObjs[i]
    if (curEnt.isValid) :
      let pos = curEnt.pos
      let this = curEnt

      #THIS STEP ACCOUNTS FOR VELOCITY/TUNNELING ISSUE
      #Essentially this traces the path and progresses the object
      #to the point of the contact. Then it will collide
      let projPos = pos + this.vel * dt
      let
        norm = this.vel.normal()
        dist = distance(pos, projPos)

      # break this velocity into discrete steps
      #TODO: make the discrete steps dependent on
      #the size of the object being compared
      for i in 0..dist.int :
        let
          origin = pos + norm * i.float
          lmin = origin + this.lmin
          lmax = origin + this.lmax
        if (queryVoxels(lmin,lmax)) :
          #Collision Response here
          this.pos[1] = (origin.y.int + 1).float
          if (this.vel[1] < 0) :
            this.vel[1] = 0
          break
        else :
          #calculate gravity
          if (this.gravity != 0) :
            this.vel[1] = this.vel[1] - this.gravity * dt # gravity/drag handle
            # gravity/drag handle

      this.pos = pos + this.vel * dt + this.acceleration * dt
      this.angle = this.angle + this.angleVel * dt
      curEnt.update(dt) # Updates the matrix





#let
#  projPos = this.pos + dt * this.vel
#var
#  ystart = this.pos.y.int
#  yrange = (this.pos.y - projPos.y).int

#ystart = min(yrange, ystart)
#yrange = max(yrange, ystart)

#for y in ystart..(ystart + yrange) :
#  if (this.pos.x >= 0 and y >= 0 and this.pos.z >= 0) :
#    if (mapChunk.d[this.pos.x.int][y][this.pos.z.int].getActive()) :
#      echo(ystart, " ", yrange)
#      echo("collided on path : ", y)
#      this.pos[1] = (y + 1).float
#      this.vel[1] = 0
#      break
proc intRayOBB*(t: TraceData, that: PhysObj): colData =
  result = colData(hitPos: t.offset, ent1: that, ent2: that, willIntersect: false, pushDistance : 100000)
  return result

proc traceRay*(trace: TraceData): TraceResult =
  result = TraceResult()

proc traceRay*(origin, normal: Vec3, dist: float): TraceResult =
  # parameters are faster
  return traceRay(TraceData(origin: origin, offset: origin + normal * dist, normal: normal, dist: dist))
