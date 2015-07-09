#Written by Matt Nichols
#Contributions by Aaron Bentley
import globals
import engine/types
import engine/coords/matrix, engine/coords/vector

var entities* = newSeq[Entity]()

proc newEntity*(): Entity = Entity()

# Starts the tracking of this entity.
method track*(this: Entity): Entity =
  this.isValid = true
  entities.add(this)
  this

# Stops the tracking of this entity.
method untrack*(this: Entity) =
  this.isValid = false
  entities.delete(entities.get(this))

# Recalculates the transform matrix.
method calcMatrix*(this: Entity) =
  this.rot = identity()
  this.rot = this.rot.rotate(this.angle[2], vec3(0, 0, 1))
  this.rot = this.rot.rotate(this.angle[1], vec3(0, 1, 0))
  this.rot = this.rot.rotate(this.angle[0], vec3(1, 0, 0))
  this.matrix = identity()
  this.matrix = this.matrix.translate(this.pos)
  this.matrix = this.matrix * this.rot
  this.matrix = this.matrix.scale(this.scale)

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
  this.angle = vec3(0, 0, 0)
  this.scale = vec3(1, 1, 1)
  this.vel = vec3(0, 0, 0)
  this.angleVel = vec3(0, 0, 0)
  this.viewOffset = vec3(0.0,0.0,0.0) # Will be the position a controller views from
  this.calcMatrix()
  this

method getForward*(this: Entity): Vec3 = return this.rot * vec3(1,0,0)
method getUp*(this: Entity): Vec3 = return this.rot * vec3(0,1,0)
method getRight*(this: Entity): Vec3 = return this.rot * vec3(0,0,1)
