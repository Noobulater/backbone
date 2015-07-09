#Written by Aaron Bentley 6/29/15
#JUST SO YOU KNOW A DRAY IS
# a truck or cart for delivering beer barrels or other heavy loads, especially a low one without sides.
# From dictionary.com
import math
import globals
import engine/types
import physObj
import engine/camera, engine/controls
import engine/coords/vector, engine/coords/matrix
import sdl2/private/keycodes

var drays*: seq[Dray] = @[]

# Sarts the tracking of this entity.
method track*(this: Dray): Dray =
  discard physObj.track(this)
  drays.add(this)
  this

# Stops the tracking of this entity.
method untrack*(this: Dray) =
  drays.delete(drays.get(this))
  procCall physObj.untrack(this)

# Initializes this entity.
method init*(this: Dray): Dray =
  discard physObj.init(this)
  this.maxSpeed = 10.0
  this.maxLift = 5.0
  this.drag = 0.5
  this.gravity = 1.0
  this

proc newDray*(): Dray = Dray().init.track()

method input*(this: Dray, code: inputCode) =
  var newVel = vec3(0)
  case code :
  of PRIMARYFIRE : discard
  of SECONDARYFIRE : discard
  of FORWARD :
    let c = camera.view.forward() * this.maxSpeed
    newVel = vec3(c.x,0.0,c.z)
  of BACKWARD :
    let c = camera.view.forward() * -this.maxSpeed
    newVel = vec3(c.x,0.0,c.z)
  of STRAFELEFT :
    let c = camera.view.right() * -this.maxSpeed
    newVel = vec3(c.x,0.0,c.z)
  of STRAFERIGHT :
    let c = camera.view.right() * this.maxSpeed
    newVel = vec3(c.x,0.0,c.z)
  of JUMP :
    newVel = vec3(0,this.maxLift,0)
  of CROUCH :
    newVel = vec3(0,-this.maxLift,0)

  #this.impulse = newVel

method update*(this: Dray, dt: float) =
  var newVel = vec3(0)
  let
    forward = camera.view.forward()
    right = camera.view.right()
  if (isKeyDown(K_w)) :
    let c = forward * this.maxSpeed
    newVel = newVel + vec3(c.x,0.0,c.z)
  elif (isKeyDown(K_s)) :
    let c = forward * -this.maxSpeed
    newVel = newVel + vec3(c.x,0.0,c.z)
  if (isKeyDown(K_d)) :
    let c = right * this.maxSpeed
    newVel = newVel + vec3(c.x,0.0,c.z)
  elif (isKeyDown(K_a)) :
    let c = right * -this.maxSpeed
    newVel = newVel + vec3(c.x,0.0,c.z)

  if (isKeyDown(K_SPACE)) :
    newVel = newVel + vec3(0.0,this.maxLift,0.0)
  #elif (isKeyDown(K_LCTRL)) :
  #  this.vel[1] = this.vel[1] - this.maxLift

  this.impulse = newVel
  procCall physObj.update(this, dt)
