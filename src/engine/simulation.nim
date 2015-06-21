#Written By Aaron Bentley
#The purpose of this file is to simulate physics, nothing more
import globals, glx, math, opengl
import physical/entity
import coords/matrix, coords/vector, physical/model, parser/bmp, parser/iqm
import camera
import timer

proc init*() = #initializes teh physics engine
  var phong = initProgram("phong.vert", "phong.frag")

  let theta = random(0.0..(PI * 2))
  let dist = random(40.0..2000.0)

  #quit()
  var astroid = newModel()
  astroid.setPos(vec3(0.0,2.0,0.0))
  astroid.setAngleVel(vec3(35.0,32.0,60.0))
  astroid.program = phong
  astroid.setModel("models/cube.iqm")
  astroid.material = initMaterial("materials/models/cube/Material.bmp")
  #astroid.lmin = vec3(-2.0,-0.2,-2.0)
  #astroid.lmax = vec3(2.0,0.2,2.0)
  #astroid.setScale(vec3(2.0,0.2,2.0))

  astroid = newModel()
  astroid.setPos(vec3(5.0, 2.0, 0.0))
  astroid.setAngle(vec3(90.0,21.0,0.0))#vec3(random(0.0..360.0), random(0.0..360.0), random(0.0..360.0)))
  astroid.setAngleVel(vec3(5.0,10.0,20.0))
  astroid.setVel(vec3(-0.3,0.0,0.0))
  astroid.program = phong
  astroid.setModel("models/cube.iqm")
  astroid.material = initMaterial("materials/models/cube/Material.bmp")
  #astroid.gravity = 0.5
  #astroid.setScale(vec3(5))

  astroid = newModel()
  astroid.setPos(vec3(0.0, -8.0, 0.0))
  astroid.program = phong
  astroid.setModel("models/cube.iqm")
  astroid.material = initMaterial("materials/models/cube/Material.bmp")
  astroid.lmin = vec3(0)
  astroid.lmax = vec3(0)
  astroid.setScale(vec3(5.0,0.2,5.0))

  var skydome = newModel()
  skydome.program = initProgram("phong.vert", "sky.frag")
  skydome.setModel("models/skydome.iqm")
  skydome.material = initMaterial("bmps/sky.bmp", "bmps/sky.bmp")
  skydome.setScale(vec3(500))
  skydome.lmin = vec3(0)
  skydome.lmax = vec3(0)

#######################
# COLLISION DETECTION #
#######################

#AXIS ALIGNED BOUNDING BOX
proc intersect*(this, that:Entity): bool =
  let
    dist1 = (this.lmin + this.pos) - (that.lmax + that.pos)
    dist2 = (that.lmin + that.pos) - (this.lmax + this.pos)
    distance = max(dist1,dist2)
  return (distance.maxValue() < 0)

#ORIENTED BOUNDING BOX
proc checkAxis*(aCorners, bCorners: array[0..7, Vec3], norm: Vec3): bool =
  #Handles the cross product = {0,0,0} case
  if(norm == 0.0) :
    return true

  var
    aMin = 10000.0 # should be float.max but i dont know how to do that in nim
    aMax = -10000.0 # should be float.min but i dont know how to do that in nim
    bMin = 10000.0
    bMax = -10000.0

  # Define two intervals, a and b. Calculate their min and max values
  for i in 0..7 :
    let aDist = aCorners[i].dot(norm)
    if (aDist < aMin) :
     aMin = aDist
    if (aDist > aMax) :
     aMax = aDist
    let bDist = bCorners[i].dot(norm)
    if (bDist < bMin) :
     bMin = bDist
    if (bDist > bMax) :
     bMax = bDist

  # One-dimensional intersection test between a and b
  let longSpan = max(aMax,bMax) - min(aMin,bMin)
  let sumSpan = (aMax - aMin) + (bMax - bMin)

  return longSpan < sumSpan # Change this to <= if you want the case were they are touching but not overlapping, to count as an intersection

proc intersectingOBB(this, that: Entity): bool =
  #We will be working in local space, and THIS will be at our origin
  let
    offset = that.pos - this.pos
    thisMin = this.lmin + this.obbc
    thisMax = this.lmax + this.obbc
    thatMin = that.lmin + that.obbc
    thatMax = that.lmax + that.obbc

  var
    aCorners: array[0..7, Vec3]
    bCorners: array[0..7, Vec3]
    aRot = this.rot
    bRot = that.rot

  #now we need to map each point onto each plane
  let
    av0 = vec3(thisMin.x, thisMin.y, thisMin.z)
    av1 = vec3(thisMin.x, thisMin.y, thisMax.z)
    av2 = vec3(thisMin.x, thisMax.y, thisMax.z)
    av3 = vec3(thisMin.x, thisMax.y, thisMin.z)
    av4 = vec3(thisMax.x, thisMax.y, thisMax.z)
    av5 = vec3(thisMax.x, thisMax.y, thisMin.z)
    av6 = vec3(thisMax.x, thisMin.y, thisMin.z)
    av7 = vec3(thisMax.x, thisMin.y, thisMax.z)

    bv0 = vec3(thatMin.x, thatMin.y, thatMin.z)
    bv1 = vec3(thatMin.x, thatMin.y, thatMax.z)
    bv2 = vec3(thatMin.x, thatMax.y, thatMax.z)
    bv3 = vec3(thatMin.x, thatMax.y, thatMin.z)
    bv4 = vec3(thatMax.x, thatMax.y, thatMax.z)
    bv5 = vec3(thatMax.x, thatMax.y, thatMin.z)
    bv6 = vec3(thatMax.x, thatMin.y, thatMin.z)
    bv7 = vec3(thatMax.x, thatMin.y, thatMax.z)

  aCorners[0] = aRot * av0
  aCorners[1] = aRot * av1
  aCorners[2] = aRot * av2
  aCorners[3] = aRot * av3
  aCorners[4] = aRot * av4
  aCorners[5] = aRot * av5
  aCorners[6] = aRot * av6
  aCorners[7] = aRot * av7

  bCorners[0] = bRot * bv0 + offset
  bCorners[1] = bRot * bv1 + offset
  bCorners[2] = bRot * bv2 + offset
  bCorners[3] = bRot * bv3 + offset
  bCorners[4] = bRot * bv4 + offset
  bCorners[5] = bRot * bv5 + offset
  bCorners[6] = bRot * bv6 + offset
  bCorners[7] = bRot * bv7 + offset

  let
    aX = aRot * vec3(1,0,0)#bRot.forward() #b's local X axis
    aY = aRot * vec3(0,1,0)# bRot.up() #b's local Y Axis
    aZ = aRot * vec3(0,0,1)#bRot.side() #b's local Z Axis
    bX = bRot * vec3(1,0,0)#bRot.forward() #b's local X axis
    bY = bRot * vec3(0,1,0)# bRot.up() #b's local Y Axis
    bZ = bRot * vec3(0,0,1)#bRot.side() #b's local Z Axis

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

  if (checkAxis(aCorners, bCorners, aX)) :
    if (checkAxis(aCorners, bCorners, aY)) :
      if (checkAxis(aCorners, bCorners, aZ)) :
        if (checkAxis(aCorners, bCorners, bX)) :
          if (checkAxis(aCorners, bCorners, bY)) :
            if (checkAxis(aCorners, bCorners, bZ)) :
              if (checkAxis(aCorners, bCorners, cXX)) :
                if (checkAxis(aCorners, bCorners, cYY)) :
                  if (checkAxis(aCorners, bCorners, cZZ)) :
                    if (checkAxis(aCorners, bCorners, cXY)) :
                      if (checkAxis(aCorners, bCorners, cXZ)) :
                        if (checkAxis(aCorners, bCorners, cYX)) :
                            if (checkAxis(aCorners, bCorners, cYZ)) :
                              if (checkAxis(aCorners, bCorners, cZX)) :
                                if (checkAxis(aCorners, bCorners, cZY)) :
                                  return true
  return false
#######################

proc update*(dt: float) = #dt was the last time it was called
  var curEnt: Entity
  for i in low(entities)..high(entities) :
    curEnt = entities[i]
    if (curEnt.gravity != 0) :
      let newGrav = curEnt.vel[1] - curEnt.gravity * dt
      curEnt.setVel(vec3(curEnt.vel[0], newGrav, curEnt.vel[2])) # gravity/drag handle
    if (curEnt.drag != 0) :
      let drag = curEnt.drag * dt
      curEnt.setVel(vec3(curEnt.vel[0]*drag, curEnt.vel[1]*drag, curEnt.vel[2]*drag)) # gravity/drag handle
    # gravity/drag handle
    #Now check collision
    if (curEnt.lmin != 0.0 or curEnt.lmax != 0.0) : # no collisons, dont bother
      if (curEnt.vel != 0.0 or curEnt.angleVel != 0.0) :
        for j in low(entities)..high(entities) :
          if (i != j) :
            if (entities[j].lmin != 0.0 or entities[j].lmax != 0.0) :
              if (intersectingOBB(curEnt, entities[j])) :
                echo("collied")
                echo(curEnt.pos)
                echo(entities[j].pos)
                curEnt.setVel(vec3(0))
                #curEnt.setAngleVel(vec3(0))
                entities[j].setVel(vec3(0))
                #entities[j].setAngleVel(vec3(0))

    curEnt.update(dt) # move the object
    #if (entities[1].intersect(entities[0])) :
    #  entities[1].vel = vec3(0.0,1.0,0.0)
