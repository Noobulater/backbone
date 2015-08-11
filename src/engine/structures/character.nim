#Written By Aaron Bentley 6-7-15
import globals
import engine/types
import container
import engine/physical/model
import engine/physical/physObj
import engine/physical/dray
import engine/coords/vector

var characters* = newSeq[Character]()

# Starts the tracking of this
method track*(this: Character): Character =
  discard container.track(this)
  characters.add(this)
  this

# Stops the tracking of this
method untrack*(this: Character) =
  characters.delete(characters.get(this))
  procCall container.untrack(this)

# Initializes this
method init*(this: Character): Character =
  discard container.init(this)
  this.model = "models/crates/crate.iqm"
  this

proc spawn*(this: Character): Dray =
  if (this.attached != nil) :
    this.attached.remove() # cleanup the old entity
  this.attached = newDray()
  this.attached.setModel(this.model)
  this.attached.lmin = vec3(-1)
  this.attached.lmax = vec3(1)
  this.attached.data = this
  this.attached.viewOffset = vec3(0.0, 64.0, 0.0)
  this.attached.pos = this.attached.pos
  return Dray(this.attached)

proc newCharacter*(): Character = Character().init.track()
