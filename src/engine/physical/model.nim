#Written by Matt Nichols
#Contributions from Aaron Bentley
import opengl, math, strutils
import globals, entity
import engine/types
import engine/glx, engine/camera
import engine/coords/vector, engine/coords/matrix
import engine/parser/iqm

var models*: seq[Model] = @[]

method draw*(this: Model) =
  this.program.use()
  glUniformMatrix4fv(glGetUniformLocation(this.program.handle, "model").int32, 1, false, this.matrix.m[0].addr)
  cameraUniforms(this.program.handle)
  this.material.use(this.program)
  this.mesh.use()

# Starts the tracking of this entity.
method track*(this: Model): Model =
  discard entity.track(this)
  models.add(this)

  proc tempDraw(): bool =
    if (this.isValid) :
      this.draw()
    return this.isValid

  addDraw(tempDraw)
  this

# Stops the tracking of this entity.
method untrack*(this: Model) =
  models.delete(models.get(this))
  procCall entity.untrack(this)

method setModel*(this: Model, filePath: string) =
  if (find(filePath, ".iqm") > 0) :
    this.mesh = initMesh(filePath, this.program.handle)
    this.meshPath = filePath
  else :
    echo("ERROR: MODEL NOT FOUND")

# Initializes this entity.

method init*(this: Model): Model =
  discard entity.init(this)
  this.program = worldShader
  this.material = defMaterial
  this

#method update*(this: Model, dt: float) =
  #procCall entity.update(this, dt)

proc newModel*(): Model = Model().init.track()
