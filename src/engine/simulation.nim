#Written By Aaron Bentley
#The purpose of this file is to simulate physics, nothing more
import globals, glx, math, opengl
import types
import physical/entity, physical/physObj, physical/model
import coords/matrix, coords/vector
import parser/bmp, parser/iqm
import camera
import timer

var skydome: Model
proc init*() =
  skydome = newModel()
  skydome.program = initProgram("phong.vert", "phong.frag")
  skydome.setModel("models/cube.iqm")
  skydome.material = initMaterial("materials/models/cube/Material.bmp")
  skydome.setScale(vec3(0.1))
  #initializes teh physics engine

#######################
# COLLISION DETECTION #
#######################

proc minmaxAxis(axis: Vec3, vectors: varargs[Vec3]): array[0..1, float] =
  var
    aMin = Inf # should be float.max but i dont know how to do that in nim
    aMax = NegInf # should be float.min but i dont know how to do that in nim
  # Define two intervals, a and b. Calculate their min and max values
  for i in 0..high(vectors) :
    let aDist = vectors[i].dot(axis)
    if (aDist < aMin) :
      aMin = aDist
    if (aDist > aMax) :
      aMax = aDist
  return [aMin, aMax]

proc getBoxExtents(this: PhysObj): array[0..7, Vec3] =
  #We will be working in local space, and THIS will be at our origin
  let
    thisMin = this.lmin + this.obbc
    thisMax = this.lmax + this.obbc
    pos = this.pos

  var rot = this.rot
  if (this.physType == pAABB) :
    return [
      vec3(thisMin.x, thisMin.y, thisMin.z) + pos,
      vec3(thisMin.x, thisMin.y, thisMax.z) + pos,
      vec3(thisMin.x, thisMax.y, thisMax.z) + pos,
      vec3(thisMin.x, thisMax.y, thisMin.z) + pos,
      vec3(thisMax.x, thisMax.y, thisMax.z) + pos,
      vec3(thisMax.x, thisMax.y, thisMin.z) + pos,
      vec3(thisMax.x, thisMin.y, thisMin.z) + pos,
      vec3(thisMax.x, thisMin.y, thisMax.z) + pos,
    ]
  else :
    return [
      rot * vec3(thisMin.x, thisMin.y, thisMin.z) + pos,
      rot * vec3(thisMin.x, thisMin.y, thisMax.z) + pos,
      rot * vec3(thisMin.x, thisMax.y, thisMax.z) + pos,
      rot * vec3(thisMin.x, thisMax.y, thisMin.z) + pos,
      rot * vec3(thisMax.x, thisMax.y, thisMax.z) + pos,
      rot * vec3(thisMax.x, thisMax.y, thisMin.z) + pos,
      rot * vec3(thisMax.x, thisMin.y, thisMin.z) + pos,
      rot * vec3(thisMax.x, thisMin.y, thisMax.z) + pos,
    ]

#AXIS ALIGNED BOUNDING BOX
proc intersectingAABB*(this, that: PhysObj): bool =
  let
    dist1 = (this.lmin + this.pos) - (that.lmax + that.pos)
    dist2 = (that.lmin + that.pos) - (this.lmax + this.pos)
    distance = max(dist1,dist2)
  return (distance.maxValue() < 0)

#ORIENTED BOUNDING BOX
proc checkAxis*(aCorners, bCorners: array[0..7, Vec3], axis: Vec3, cData: var colData): bool =
  #Handles the cross product = {0,0,0} case
  if(axis == 0.0) :
    return true

  var
    aMin = Inf # should be float.max but i dont know how to do that in nim
    aMax = NegInf # should be float.min but i dont know how to do that in nim
    bMin = Inf
    bMax = NegInf
    minCorn = 0
    maxCorn = 0
  # Define two intervals, a and b. Calculate their min and max values
  for i in 0..7 :
    let aDist = aCorners[i].dot(axis)
    if (aDist < aMin) :
      minCorn = i
      aMin = aDist
    if (aDist > aMax) :
      maxCorn = i
      aMax = aDist
    let bDist = bCorners[i].dot(axis)
    if (bDist < bMin) :
     bMin = bDist
    if (bDist > bMax) :
     bMax = bDist

  # One-dimensional intersection test between a and b
  let longSpan = max(aMax,bMax) - min(aMin,bMin)
  let sumSpan = (aMax - aMin) + (bMax - bMin)

  if (longSpan < sumSpan) : # Change this to <= if you want the case were they are touching but not overlapping, to count as an intersection
    if (abs(cData.pushDistance) > abs(sumSpan - longSpan)) : # We may want to push them apart after intersection
      if (bMax < aMax) :
        cData.pushDistance = sumSpan - longSpan
        cData.hitPos = aCorners[minCorn]
      else :
        cData.pushDistance = -1 * (sumSpan - longSpan)
        cData.hitPos = aCorners[maxCorn]
      cData.pushAxis = axis
    return true
  return false

var once = true
proc intOBBOBB(this, that: PhysObj): colData =
  var c = colData(hitPos: this.pos, ent1: this, ent2: this, intersecting: false, pushDistance : 100000)
  let
    aCorners = getBoxExtents(this)
    bCorners = getBoxExtents(that)
    aX = this.getForward()#b's local X axis
    aY = this.getUp()#b's local Y Axis
    aZ = this.getRight()#b's local Z Axis
    bX = that.getForward()#b's local X axis
    bY = that.getUp()#b's local Y Axis
    bZ = that.getRight()#b's local Z Axis

  let
    #each plane we need to check, if one of these fails, we are done ( yay )
    cXX = aX.cross(bX)
    cXY = aX.cross(bY)
    cXZ = aX.cross(bZ)
    cYX = aY.cross(bX)
    cYY = aY.cross(bY)
    cYZ = aY.cross(bZ)
    cZX = aZ.cross(bX)
    cZY = aZ.cross(bY)
    cZZ = aZ.cross(bZ)
  #echo("-------")
  if (checkAxis(aCorners, bCorners, aX, c)) :
    if (checkAxis(aCorners, bCorners, aY, c)) :
      if (checkAxis(aCorners, bCorners, aZ, c)) :
        if (checkAxis(aCorners, bCorners, bX, c)) :
          if (checkAxis(aCorners, bCorners, bY, c)) :
            if (checkAxis(aCorners, bCorners,bZ, c)) :
              if (checkAxis(aCorners, bCorners, cXX, c)) :
                if (checkAxis(aCorners, bCorners, cYY, c)) :
                  if (checkAxis(aCorners, bCorners, cZZ, c)) :
                    if (checkAxis(aCorners, bCorners, cXY, c)) :
                      if (checkAxis(aCorners, bCorners, cXZ, c)) :
                        if (checkAxis(aCorners, bCorners, cYX, c)) :
                            if (checkAxis(aCorners, bCorners, cYZ, c)) :
                              if (checkAxis(aCorners, bCorners, cZX, c)) :
                                if (checkAxis(aCorners, bCorners, cZY, c)) :
                                  #if (once) :
                                    #once = false
                                    #echo(c.hitPos)
                                    #simple(1, proc() = camera.pos = c.hitPos)
                                  #  simple(2, proc() = camera.pos = bCorners[1])
                                  #  simple(3, proc() = camera.pos = bCorners[2])
                                  #  simple(4, proc() = camera.pos = bCorners[3])
                                  #  simple(5, proc() = camera.pos = bCorners[4])
                                  #  simple(6, proc() = camera.pos = bCorners[5])
                                  #  simple(7, proc() = camera.pos = bCorners[6])
                                  #  simple(8, proc() = camera.pos = bCorners[7])


                                  #We have our minimum seperating axis, lets calculate the hit position
                                  c.hitPos = c.hitPos #+ (aX * c.pushDistance + aY * c.pushDistance + aZ * c.pushDistance) * (1/3)
                                  c.intersecting = true
                                  return c
  c.intersecting = false
  return c

proc traceCheckAxis*(origin, offset: Vec3, aCorners: array[0..7, Vec3], axis: Vec3, cData: var colData): bool =
  #Handles the cross product = {0,0,0} case
  if(axis == 0.0) :
    return true

  var
    tMin = Inf # should be float.max but i dont know how to do that in nim
    tMax = NegInf # should be float.min but i dont know how to do that in nim
    aMin = Inf
    aMax = NegInf
    t1 = origin.dot(axis)
    t2 = offset.dot(axis)
  # Define two intervals, a and b. Calculate their min and max values

  if (t1 < t2) :
    tMin = t1
    tMax = t2
  else :
    tMin = t2
    tMax = t1

  for i in 0..7 :
    let aDist = aCorners[i].dot(axis)
    if (aDist < aMin) :
     aMin = aDist
    if (aDist > aMax) :
     aMax = aDist

  # One-dimensional intersection test between a and b

  let longSpan = max(tMax,aMax) - min(tMin,aMin)
  let sumSpan = (tMax - tMin) + (aMax - aMin)

  return (longSpan <= sumSpan)

proc intRayOBB*(t: traceData, that: PhysObj): colData =
  result = colData(hitPos: t.offset, ent1: that, ent2: that, intersecting: false, pushDistance : 100000)
  # THIS IS TEMPORARY, ITS A BIT EXPENSIVE BECAUSE IT PERFORMS THE OBB CALCULATIONS
  # INSTEAD OF USING THE AABB TACTICS
  var
    origin = t.origin
    offset = t.offset
    normal = t.normal
    dist = t.dist

  #TODO: Use AABB test not OBB Seperating axis theorem
  #TODO: Remove this and replace it with AABB variables
  #Check to see if there is a seperating axis
  #Since we already did the work to make it AABB, we need to
  #Check it as if it is colliding as a degenerate AABB
  #OBBs have three principle axes, the default x,y,z
  let
    aCorners = getBoxExtents(that)
    aX = that.getForward() #a's local X axis
    aY = that.getUp() #a's local Y Axis
    aZ = that.getRight() #a's local Z Axis
    cXR = aX.cross(normal)
    cYR = aY.cross(normal)
    cZR = aZ.cross(normal)
  if (traceCheckAxis(origin, offset, aCorners, aX, result)) :
    if (traceCheckAxis(origin, offset, aCorners, aY, result)) :
      if (traceCheckAxis(origin, offset, aCorners, aZ, result)) :
        if (traceCheckAxis(origin, offset, aCorners, cXR, result)) :
          if (traceCheckAxis(origin, offset, aCorners, cYR, result)) :
            if (traceCheckAxis(origin, offset, aCorners, cZR, result)) :
              if (traceCheckAxis(origin, offset, aCorners, normal, result)) :
                var
                  tmin = NegInf # Need this to be the -MIN_FLOAT VALUE
                  tmax = dist
                #We have to convert to AABB because there isn't a simple way to ray trace an OBB
                # Tranforms it back to local (relative to object) space
                let
                  inverse = that.rot.inverse()
                  min = that.lmin
                  max = that.lmax
                origin = inverse * (origin - that.pos)
                offset = inverse * (offset - that.pos)
                normal = normal(offset - origin)

                for i in 0..2 :
                  if (abs(normal[i]) < 0.0001) :
                    if (origin[i] < min[i] and max[i] > origin[i] ) :
                      result.intersecting = false
                      return result
                  else :
                    var
                      ood = 1.0 / normal[i]

                      t1 = (min[i] - origin[i]) * ood
                      t2 = (max[i] - origin[i]) * ood
                    if (t1 > t2) :
                      t1 = (max[i] - origin[i]) * ood
                      t2 = (min[i] - origin[i]) * ood

                    if (t1 > tmin) :
                      tmin = t1
                    if (t2 > tmax) :
                      tmax = t2

                    if (tmin > tmax) :
                      result.intersecting = false
                      return result
                result.hitPos = t.origin + t.normal * tmin
                result.intersecting = true
                return result
  return result

proc traceRay*(trace: traceData): traceResult =
  result = traceResult()
  result.hitPos = trace.offset
  var minDist = trace.dist
  for i in low(physObjs)..high(physObjs) :
    let res = intRayOBB(trace, physObjs[i])
    if (res.intersecting) :
      let dist = distance(trace.origin, res.hitPos)
      if (dist < minDist) :
        minDist = dist
        result.origin = trace.origin
        result.normal = trace.normal
        result.hitEnt = physObjs[i]
        result.hitPos = res.hitPos
        result.hit = true

proc traceRay*(origin, normal: Vec3, dist: float): traceResult = # parameters are faster
  return traceRay(traceData(origin: origin, offset: origin + normal * dist, normal: normal, dist: dist))

proc click*() =
  let trace = traceRay(camera.pos, camera.view.forward(), 10)
  if (trace.hit) :
    skyDome.setPos(trace.hitPos)
    #trace.hitEnt.takeDamage(Damage(amount: 200, origin: trace.hitPos, normal: trace.normal))

#Intersecting manager
# This seperates and identifies which rules to use to test intersection
proc intersecting(this, that: PhysObj): colData =
  if (this.physType == pAABB and that.physType == pAABB) :
    return colData(intersecting: false)#intersectingAABB(this, that)
  elif (this.physType == pOBB and that.physType == pOBB) :
    return intOBBOBB(this, that)
  elif (this.physType == pPOLYGON and that.physType == pPOLYGON) :
    return colData(intersecting: false)
  return colData(intersecting: false)

#######################
proc update*(dt: float) = #dt was the last time it was called
  #vox.draw()
  var curEnt: PhysObj
  for i in low(physObjs)..high(physObjs) :
    curEnt = physObjs[i]
    # Now check collision

    if (curEnt.lmin != 0.0 or curEnt.lmax != 0.0) : # no collisons, dont bother
      if (curEnt.vel != 0.0 or curEnt.angleVel != 0.0) :
        for j in low(physObjs)..high(physObjs) :
          if (i != j) :
            if (physObjs[j].lmin != 0.0 or physObjs[j].lmax != 0.0) :
              let cData = intersecting(curEnt, physObjs[j])
              if (cData.intersecting) :
                curEnt.collide(cData)
                physObjs[j].collide(cData)
                #if (curEnt.gravity > 0) :
                  #echo(cData.pushDistance)

                #echo(cData.hitPos)
                #if (once) :
                  #once = false
                  #camera.pos = cData.hitPos + cData.pushAxis * cData.pushDistance
                #curEnt.angleVel = curEnt.angleVel * -1
    curEnt.update(dt) # move the object
    #if (physObjs[1].intersect(physObjs[0])) :
    #  physObjs[1].vel = vec3(0.0,1.0,0.0)
