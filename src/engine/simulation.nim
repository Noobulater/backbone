#Written By Aaron Bentley
#The purpose of this file is to simulate physics, nothing more
import globals, glx, math, opengl
import physical/entity, physical/model, physical/physObj, physical/dray
import coords/matrix, coords/vector
import physical/colData, parser/bmp, parser/iqm
import physical/voxel
import camera
import timer

#var vox = newVoxel()
proc init*() = #initializes teh physics engine
  var phong = initProgram("phong.vert", "phong.frag")

  let theta = random(0.0..(PI * 2))
  let dist = random(40.0..2000.0)
  #vox.program = phong

  var astroid = newDray()
  astroid.setPos(vec3(0.0,8.0,2.0))
  #astroid.setAngleVel(vec3(3.0,0.0,0.0))
  #astroid.setVel(vec3(0.0,-1.0,0.0))
  astroid.viewOffset = vec3(0.0,0.0,0.0)
  astroid.mass = 2.0
  astroid.program = phong
  astroid.setModel("models/cube.iqm")
  astroid.material = initMaterial("materials/models/cube/Material.bmp")
  astroid.lmin = vec3(-1)
  astroid.lmax = vec3(1)

  camera.viewEntity = astroid

  var block1 = newPhysObj()
  block1.setPos(vec3(0.0,5.0,5.0))
  block1.setAngleVel(vec3(57.0,23.0,12.0))
  block1.setVel(vec3(0.0,-1.0,0.0))
  block1.viewOffset = vec3(0.0,0.0,0.0)
  block1.mass = 2.0
  block1.gravity = 1.0
  block1.program = phong
  block1.setModel("models/cube.iqm")
  block1.material = initMaterial("materials/models/cube/Material.bmp")
  block1.lmin = vec3(-1)
  block1.lmax = vec3(1)

  #quit()
  var brick = newPhysObj()
  brick.setPos(vec3(0.0,0.0,0.0))
  brick.setAngle(vec3(0.0,0.0,0.0))
  #brick.setAngleVel(vec3(62.0,4.0,1.0))
  brick.setVel(vec3(0.0,0.0,0.0))
  brick.program = phong
  brick.mass = 1.0
  brick.setModel("models/cube.iqm")
  brick.material = initMaterial("materials/models/cube/Material.bmp")
  brick.lmin = vec3(-5.0, -0.2, -5.0)
  brick.lmax = vec3(5.0, 0.2, 5.0)
  brick.scale = vec3(5.0, 0.2, 5.0)

  var skydome = newModel()
  skydome.program = initProgram("phong.vert", "sky.frag")
  skydome.setModel("models/skydome.iqm")
  skydome.material = initMaterial("bmps/sky.bmp", "bmps/sky.bmp")
  skydome.setScale(vec3(500))


#######################
# COLLISION DETECTION #
#######################
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
    aMin = 10000.0 # should be float.max but i dont know how to do that in nim
    aMax = -10000.0 # should be float.min but i dont know how to do that in nim
    bMin = 10000.0
    bMax = -10000.0

  # Define two intervals, a and b. Calculate their min and max values
  for i in 0..7 :
    let aDist = aCorners[i].dot(axis)
    if (aDist < aMin) :
     aMin = aDist
    if (aDist > aMax) :
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
      else :
        cData.pushDistance = -1 * (sumSpan - longSpan)
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
                                  if (once) :
                                    echo(c.pushAxis)
                                    echo(c.pushDistance)
                                    once = false
                                    #echo(c.hitPos)
                                    #simple(1, proc() = camera.pos = c.hitPos)
                                  #  simple(2, proc() = camera.pos = bCorners[1])
                                  #  simple(3, proc() = camera.pos = bCorners[2])
                                  #  simple(4, proc() = camera.pos = bCorners[3])
                                  #  simple(5, proc() = camera.pos = bCorners[4])
                                  #  simple(6, proc() = camera.pos = bCorners[5])
                                  #  simple(7, proc() = camera.pos = bCorners[6])
                                  #  simple(8, proc() = camera.pos = bCorners[7])
                                  c.intersecting = true
                                  return c
  c.intersecting = false
  return c


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
                let
                  v1 = curEnt.vel
                  v2 = physObjs[j].vel
                  m1 = curEnt.mass
                  m2 = physObjs[j].mass
                  d = m1 + m2
                curEnt.vel = vec3(0)#(v1 * ((m1 - m2)/(d)).float + v2 * ((2.0 * m2)/(d)).float) * -1.0
                curEnt.angleVel = vec3(0)
                physObjs[j].vel = vec3(0)#v1 * ((2.0 * m1)/(d)).float - v2 * ((m1 - m2)/(d)).float
                physObjs[j].angleVel = vec3(0)
                #if (curEnt.gravity > 0) :
                  #echo(cData.pushDistance)
                curEnt.pos = curEnt.pos + cData.pushAxis * cData.pushDistance
                #curEnt.angleVel = curEnt.angleVel * -1
    curEnt.update(dt) # move the object
    #if (physObjs[1].intersect(physObjs[0])) :
    #  physObjs[1].vel = vec3(0.0,1.0,0.0)
