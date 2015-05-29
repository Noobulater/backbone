#Written by Matt Nichols
import globals
import engine/coords/matrix, engine/coords/vector

type
  Entity* = ref object of RootObj
    pos*: Vec3

    angle*: Vec3

    scale*: Vec3
    matrix*: Mat4
    parent*: Entity
    #physics
    angleVel*: Vec3
    vel*: Vec3
    gravity*: float
    drag*: float # how quickly an objects velocity decays
    lmin*,lmax*: Vec3 # axis aligned bounding box : local min, local max

var entities* = newSeq[Entity]()

proc newEntity*(): Entity = Entity()

# Sarts the tracking of this entity.
method track*(this: Entity): Entity =
  entities.add(this)
  this

# Stops the tracking of this entity.
method untrack*(this: Entity) =
  entities.delete(entities.get(this))

# Recalculates the transform matrix.
method calcMatrix*(this: Entity) =
  this.matrix = identity()
  this.matrix = this.matrix.translate(this.pos)
  this.matrix = this.matrix.scale(this.scale)
  this.matrix = this.matrix.rotate(this.angle[2], vec3(0, 0, 1))
  this.matrix = this.matrix.rotate(this.angle[1], vec3(0, 1, 0))
  this.matrix = this.matrix.rotate(this.angle[0], vec3(1, 0, 0))

# Sets the pos of the entity
method setPos*(this: Entity, v: Vec3) =
  this.pos = v
  this.calcMatrix()

method setVel*(this: Entity, v: Vec3) =
  this.vel = v

# Sets the angle of the entity
method setAngle*(this: Entity, a: Vec3) =
  this.angle = a
  this.calcMatrix()

method setAngleVel*(this: Entity, a: Vec3) =
  this.angleVel = a

# Sets the scale of the entity
method setScale*(this: Entity, s: Vec3) =
  this.scale = s
  this.calcMatrix()

method update*(this: Entity, dt: float) =
  this.pos = this.pos + this.vel * dt
  this.angle = this.angle + this.angleVel * dt
  this.calcMatrix()

# Initializes this entity.
method init*(this: Entity): Entity =
  this.pos = vec3(0, 0, 0)
  this.vel = vec3(0, 0, 0)
  this.angle = vec3(0, 0, 0)
  this.angleVel = vec3(0, 0, 0)
  this.scale = vec3(1, 1, 1)
  this.gravity = 0
  this.drag = 0
  this.calcMatrix()
  this

method setGravity*(this: Entity, g: float) =
  this.gravity = g

method setDrag*(this: Entity, d: float) =
  this.drag = d

method intersect*(this, that:Entity): bool =
  let
    #min = this.lmin + this.pos
    #max = this.lmax + this.pos
    #tmin = that.lmin + that.pos
    #tmax = that.lmax + that.pos
    dist1 = (this.lmin + this.pos) - (that.lmax + that.pos)
    dist2 = (that.lmin + that.pos) - (this.lmax + this.pos)
    distance = max(dist1,dist2)
    #maxValue = distance.maxValue()
  return (distance.maxValue() < 0)
