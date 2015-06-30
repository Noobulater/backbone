#Written by Aaron Bentley 6/29/15
#JUST SO YOU KNOW A DRAY IS
# a truck or cart for delivering beer barrels or other heavy loads, especially a low one without sides.
# From dictionary.com
import opengl, math, strutils
import globals, physObj
import engine/glx, engine/camera
import engine/coords/vector, engine/coords/matrix
import engine/parser/iqm

type
  Dray* = ref object of PhysObj
    #view Position
    viewPos*: vec3()


var drays*: seq[Dray] = @[]

# Sarts the tracking of this entity.
method track*(this: Dray): Dray =
  discard physObjs.track(this)
  drays.add(this)
  this

# Stops the tracking of this entity.
method untrack*(this: Dray) =
  physObj.untrack(this)
  drays.delete(drays.get(this))

# Initializes this entity.
method init*(this: Dray): Dray =
  discard physObj.init(this)
  this.viewPos = vec3(0.0,0.0,0.0) # Will be the position a controller views from
  this

proc newDray*(): Dray = Dray().init.track()
