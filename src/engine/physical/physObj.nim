#Written by Aaron Bentley 6/29/15
import globals, model, entity
import engine/coords/vector

type
  PhysObj* = ref object of Model
    #physics
    impulse*: Vec3 # Impulse is absolute velocity. This will happen, not affected by drag
    mass*: float
    gravity*: float
    drag*: float # how quickly an objects velocity decays
    obbc*,lmin*,lmax*: Vec3 # axis aligned bounding box : obbCenter, local min, local max
    physType*: pType

var physObjs*: seq[PhysObj] = @[]

# Sarts the tracking of this entity.
method track*(this: PhysObj): PhysObj =
  discard model.track(this)
  physObjs.add(this)
  this

# Stops the tracking of this entity.
method untrack*(this: PhysObj) =
  model.untrack(this)
  models.delete(models.get(this))

# Initializes this entity.
method init*(this: PhysObj): PhysObj =
  discard model.init(this)
  this.mass = 1.0
  this.gravity = 0
  this.drag = 0
  this.physType = pOBB
  this

method update*(this: PhysObj, dt: float) =
  if (this.gravity != 0) :
    this.vel[1] = this.vel[1] - this.gravity * dt # gravity/drag handle
  if (this.drag != 0) :
    let drag = this.drag * dt
    this.vel = this.vel - vec3(this.vel[0]*drag, 0.0, this.vel[2]*drag) # gravity/drag handle
  # gravity/drag handle


  if (this.impulse != 0) :
    if ((this.vel[0] + this.impulse[0]) < 0) :
      this.vel[0] = clampHigh(this.vel[0], this.impulse[0])
    else :
      this.vel[0] = clampLow(this.vel[0], this.impulse[0])

    if ((this.vel[1] + this.impulse[1]) < 0) :
      this.vel[1] = clampHigh(this.vel[1], this.impulse[1])
    else :
      this.vel[1] = clampLow(this.vel[1], this.impulse[1])

    if ((this.vel[2] + this.impulse[2]) < 0) :
      this.vel[2] = clampHigh(this.vel[2], this.impulse[2])
    else :
      this.vel[2] = clampLow(this.vel[2], this.impulse[2])

  this.pos = this.pos + this.vel * dt
  this.angle = this.angle + this.angleVel * dt
  this.calcMatrix()

method setGravity*(this: PhysObj, g: float) =
  this.gravity = g

method setDrag*(this: PhysObj, d: float) =
  this.drag = d

proc newPhysObj*(): PhysObj = PhysObj().init.track()
