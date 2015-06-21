import opengl, math, strutils
import globals, entity
import engine/glx, engine/camera
import engine/coords/vector, engine/coords/matrix
import engine/parser/iqm

type Model* = ref object of Entity
  program*: Program
  material*: Material
  mesh*: Mesh
  meshPath*: string

var models*: seq[Model] = @[]

method draw*(this: Model) =
  this.program.use()
  glUniformMatrix4fv(glGetUniformLocation(this.program.handle, "model").int32, 1, false, this.matrix.m[0].addr)
  cameraUniforms(this.program.handle)
  this.material.use(this.program)
  this.mesh.use()


# Sarts the tracking of this entity.
method track*(this: Model): Model =
  discard entity.track(this)
  models.add(this)
  addDraw(proc() = this.draw())
  this

# Stops the tracking of this entity.
method untrack*(this: Model) =
  entity.untrack(this)
  models.delete(models.get(this))

method setModel*(this: Model, filePath: string) =
  if (find(filePath, ".iqm") > 0) :
    this.mesh = initMesh(filePath, this.program.handle)
    this.meshPath = filePath
    let data = this.mesh.data
    this.obbc = vec3(0)
    this.lmin = vec3(data.boundries.bbmins[0],data.boundries.bbmins[1],data.boundries.bbmins[2])
    this.lmax = vec3(data.boundries.bbmaxs[0],data.boundries.bbmaxs[1],data.boundries.bbmaxs[2])
  else :
    echo("ERROR: MODEL NOT FOUND")


# Initializes this entity.
method init*(this: Model): Model =
  discard entity.init(this)
  this


# Initializes this entity.
method init*(this: Model, filePath: string): Model =
  discard this.init()
  this.setModel(filePath)
  this

#method update*(this: Model, dt: float) =
#   procCall entity.update(this, dt)

proc newModel*(): Model = Model().init.track()
proc newModel*(filePath: string): Model = Model().init(filePath).track()
