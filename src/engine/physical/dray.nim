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

method remove*(this: Dray) =
  physObj.remove(this)
  this.untrack()

# Initializes this entity.
method init*(this: Dray): Dray =
  discard physObj.init(this)
  this.maxSpeed = 100.0
  this.maxLift = 100.0
  this.drag = 0.5
  this.gravity = 300.0
  this

proc newDray*(): Dray = Dray().init.track()

method input*(this: Dray, code: inputCode) =
  var newVel = vec3(0)
  let owner = Character(this.data)
  if (owner == LocalPlayer and owner.activeWeapon != nil) :
    case code :
    of PRIMARYFIRE :
      discard
      #owner.activeWeapon.primaryFire(owner.activeWeapon, owner)
    of SECONDARYFIRE : discard
    of RELOAD :
      owner.activeWeapon.reload(owner.activeWeapon, owner)
    else: discard

method update*(this: Dray, dt: float) =
  var newVel = vec3(0)
  let
    forward = camera.view.forward()
    xzForward = normal(vec3(forward.x, 0, forward.z))
    right = camera.view.right()
  if (isKeyDown(K_w)) :
    let c = xzForward * this.maxSpeed
    newVel = newVel + vec3(c.x,0.0,c.z)
  elif (isKeyDown(K_s)) :
    let c = xzForward * -this.maxSpeed
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
  this.shootForward = forward
  this.vel[0] = newVel[0]
  this.vel[2] = newVel[2]
  this.impulse[1] = newVel[1]
  procCall physObj.update(this, dt)
