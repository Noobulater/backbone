#Written by Aaron Bentley 6/29/15
import globals
import engine/types
import model, entity
import engine/coords/vector

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

method remove*(this: PhysObj) =
  if (this.data != nil) :
    this.data.attached = nil #detatch from the object
  this.untrack()

# For when the entity runs out of health
method perish*(this: PhysObj, dmginfo: Damage) =
  this.remove()

#For when the entity takes damage
method takeDamage*(this: PhysObj, dmginfo: Damage) =
  this.health = this.health - dmginfo.amount
  if (this.health <= 0):
    #this.perish(dmginfo)
    this.remove()

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
  this.friction = 0.5
  this.drag = 0
  this.physType = pOBB
  #this.perish = perish
  #this.takeDamage = takeDamage
  this.dynamic = true
  this.asleep = false
  this

method update*(this: PhysObj, dt: float) =
  this.calcMatrix()

method collide*(this: PhysObj, cData: colData) =
  if (this.dynamic) : #will respond to collisions
    # Unstick before we do collision
    this.pos = this.pos + cData.hitNormal * cData.pushDistance
    let
      ent1 = cData.ent1
      ent2 = cData.ent2
      v1 = ent1.vel
      v2 = ent2.vel
      m1 = ent1.mass
      m2 = ent2.mass
      d = m1 + m2
    if (ent1 == this) :
      #this.vel = ((v1 * ((m1 - m2)/(d)).float + v2 * ((2.0 * m2)/(d)).float)) * -1.0
      #this.vel = this.vel - cData.pushAxis * this.vel
      this.vel = this.friction * (this.vel - (cData.hitNormal * this.vel.dot(cData.hitNormal)) * 2)
      this.angleVel = vec3(0)
    #else:
      #this.vel = (v1 * ((2.0 * m1)/(d)).float - v2 * ((m1 - m2)/(d)).float) * -1.0
      #this.angleVel = vec3(0)

method setGravity*(this: PhysObj, g: float) =
  this.gravity = g

method setDrag*(this: PhysObj, d: float) =
  this.drag = d

method solid*(this: PhysObj): bool =
  return (this.lmin != 0.0 or this.lmax != 0.0)

proc newPhysObj*(): PhysObj = PhysObj().init.track()
