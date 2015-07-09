#Written by Aaron Bentley 6/29/15
import globals
import engine/types
import model, entity
import engine/coords/vector
import engine/structures/container

var physObjs*: seq[PhysObj] = @[]

# Starts the tracking of this entity.
method track*(this: PhysObj): PhysObj =
  discard model.track(this)
  physObjs.add(this)
  this

# Stops the tracking of this entity.
method untrack*(this: PhysObj) =
  physObjs.delete(physObjs.get(this))
  procCall model.untrack(this)

# For when the entity runs out of health
method perish*(this: PhysObj, dmginfo: Damage) =
  this.untrack()

#For when the entity takes damage
method takeDamage*(this: PhysObj, dmginfo: Damage) =
  this.health = this.health - dmginfo.amount
  if (this.health <= 0):
    #this.perish(dmginfo)
    this.untrack()

method takeDamage*(this: PhysObj, amount: int) =
  let dmginfo = Damage(amount : amount)
  this.takeDamage(dmginfo)

# Initializes this entity.
method init*(this: PhysObj): PhysObj =
  discard model.init(this)
  this.health = 100
  this.maxHealth = 100
  this.mass = 1.0
  this.gravity = 0
  this.drag = 0
  this.physType = pOBB
  #this.perish = perish
  #this.takeDamage = takeDamage
  this.dynamic = true
  this.asleep = false
  this

method update*(this: PhysObj, dt: float) =
  if (this.dynamic) :
    if (this.drag != 0) :
      let drag = this.drag * dt
      this.vel = this.vel - vec3(this.vel[0]*drag, this.vel[1]*drag, this.vel[2]*drag) # gravity/drag handle
    if (this.gravity != 0) :
      this.vel[1] = this.vel[1] - this.gravity * dt # gravity/drag handle
    # gravity/drag handle

    if (this.impulse[0] != 0) :
      if ((this.vel[0] + this.impulse[0]) < 0) :
        this.vel[0] = clampHigh(this.vel[0], this.impulse[0])
      else :
        this.vel[0] = clampLow(this.vel[0], this.impulse[0])

    if (this.impulse[1] != 0) :
      if ((this.vel[1] + this.impulse[1]) < 0) :
        this.vel[1] = clampHigh(this.vel[1], this.impulse[1])
      else :
        this.vel[1] = clampLow(this.vel[1], this.impulse[1])
    if (this.impulse[2] != 0) :
      if ((this.vel[2] + this.impulse[2]) < 0) :
        this.vel[2] = clampHigh(this.vel[2], this.impulse[2])
      else :
        this.vel[2] = clampLow(this.vel[2], this.impulse[2])

    this.pos = this.pos + this.vel * dt
    this.angle = this.angle + this.angleVel * dt
  this.calcMatrix()

method collide*(this: PhysObj, cData: colData) =
  if (this.dynamic) : #will respond to collisions
    # Unstick before we do collision
    this.pos = this.pos + cData.pushAxis * cData.pushDistance
    let
      ent1 = cData.ent1
      ent2 = cData.ent2
      v1 = ent1.vel
      v2 = ent2.vel
      m1 = ent1.mass
      m2 = ent2.mass
      d = m1 + m2
    if (ent1 == this) :
      this.vel = ((v1 * ((m1 - m2)/(d)).float + v2 * ((2.0 * m2)/(d)).float))
      this.vel = this.vel - cData.pushAxis * this.vel
      this.angleVel = vec3(0)
    else:
      this.vel = (v1 * ((2.0 * m1)/(d)).float - v2 * ((m1 - m2)/(d)).float) * -1.0
      this.angleVel = vec3(0)

method setGravity*(this: PhysObj, g: float) =
  this.gravity = g

method setDrag*(this: PhysObj, d: float) =
  this.drag = d

proc newPhysObj*(): PhysObj = PhysObj().init.track()
