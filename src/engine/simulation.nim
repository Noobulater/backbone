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
  return colData(intersecting: false)#intersectingAABB(this, that)


proc queryVoxels*(lmin,lmax: Vec3): colData =
  #return true if there is an active voxel in here
  let
    xstart = round(lmin.x).int
    ystart = round(lmin.y).int
    zstart = round(lmin.z).int
    xrange = round(lmax.x).int
    yrange = round(lmax.y).int
    zrange = round(lmax.z).int
  for y in ystart..(yrange) :
    for x in xstart..(xrange) :
      for z in zstart..(zrange) :
        let vox = worldData[x,y,z]
        if (vox.getActive()) :
          return colData(intersecting : true, voxel : vox, hitPos : vec3(x,y,z))
  return colData(intersecting : false)

let priority = [1,0,2]
proc detectCollision(this: PhysObj, lastPos: Vec3): bool =
  let
    origin = this.pos
    lmin = this.lmin + origin
    lmax = this.lmax + origin
    obbc = (this.lmax - this.lmin) * (1.0/2.0)

  var result = queryVoxels(lmin,lmax)
  if (result.intersecting) :
    #Collision Response here
    var normPos = lastPos #+ obbc # for calculating the normal

    #lastPos - result.hitPos

    result.hitNormal = ((normPos) - result.hitPos).normal()

    let maxv = absMaxValue(result.hitNormal)
    #echo("pos : ", this.pos)
    #echo("lastPos : ", lastPos)
    #echo("normal : ", result.hitNormal)
    #echo("hitpos : ", result.hitPos)
    for m in 0..2 :
      let
        j = priority[m]
      if (abs(result.hitNormal[j]) >= maxv) :
        let
          voxMin = result.hitPos[j] + -0.5
          voxMax = result.hitPos[j] + 0.5
        if (result.hitNormal[j] >= 0) :
          result.hitNormal[j] = 1
          if (this.acceleration.normal()[j] < 0) :
            this.acceleration[j] = max(0, this.acceleration[j])
          if (this.vel.normal()[j] < 0) :
            this.vel[j] = max(0, this.vel[j])

          let pen = voxMax - (lmin)[j]
          this.pos[j] = origin[j] + pen + 0.0005
        else :
          result.hitNormal[j] = -1
          if (this.acceleration.normal()[j] > 0) :
            this.acceleration[j] = min(0, this.acceleration[j])
          if (this.vel.normal()[j] > 0) :
            this.vel[j] = min(0, this.vel[j])

          let pen = (lmax)[j] - voxMin
          this.pos[j] = origin[j] - pen - 0.0005
        break

    return detectCollision(this, lastPos)

  return result.intersecting

######################
proc update*(dt: float) = #dt was the last time it was called
  var this: PhysObj
  for i in low(physObjs)..high(physObjs) :
    this = physObjs[i]
    if (this.isValid) :
      let pos = this.pos #+ vec3(0.0,0.05,0.0) # treats it as if he is floating
      #THIS STEP ACCOUNTS FOR VELOCITY/TUNNELING ISSUE
      #Essentially this traces the path and progresses the object
      #to the point of the contact. Then it will collide

      let min = vec3(this.lmin.x + this.pos.x, this.pos.y + this.lmin.y - 0.2,this.lmin.z + this.pos.z)
      let max = vec3(this.lmax.x + this.pos.x, this.pos.y + this.lmin.y, this.lmax.z + this.pos.z)
      this.onGround = queryVoxels(min,max).intersecting

      if (not this.onGround) :
        #calculate gravity
        if (this.gravity != 0) :
          this.vel[1] = this.vel[1] - this.gravity * dt # gravity/drag handle

      let
        movement = this.vel * dt + this.acceleration * dt
        projPos = pos + movement
        norm = movement.normal()
        dist = distance(pos, projPos)
          # gravity/drag handle      #echo(norm)

      # break this velocity into discrete steps
      #TODO: make the discrete steps dependent on
      #the size of the object being compared
      #echo("===============")
      for i in 0..(10) :
        #move the entity a percentage along its velocity
        this.pos = pos + norm * (dist * i.float/10.0)
        if (detectCollision(this, pos)) :
          # we found a collision, wasted time to keep going
          break

      #this.pos = this.pos + this.vel * dt + this.acceleration * dt
      #this should really be in teh projection loop, but its wasted cycles
      this.angle = this.angle + this.angleVel * dt

      this.update(dt) # Updates the matrix




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
  result = colData(hitPos: t.offset, ent1: that, ent2: that, intersecting: false, pushDistance : 100000)
  return result

proc traceRay*(trace: TraceData): TraceResult =
  result = TraceResult()

proc traceRay*(origin, normal: Vec3, dist: float): TraceResult =
  # parameters are faster
  return traceRay(TraceData(origin: origin, offset: origin + normal * dist, normal: normal, dist: dist))
