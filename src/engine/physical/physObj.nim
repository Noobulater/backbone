#Written by Aaron Bentley 6/29/15
import opengl, math, strutils
import globals, model
import engine/glx, engine/camera
import engine/coords/vector, engine/coords/matrix
import engine/parser/iqm

type
  PhysObj* = ref object of Model
    #physics
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

#method update*(this: Model, dt: float) =
#   procCall entity.update(this, dt)

method setGravity*(this: PhysObj, g: float) =
  this.gravity = g

method setDrag*(this: PhysObj, d: float) =
  this.drag = d

proc newPhysObj*(): PhysObj = PhysObj().init.track()
