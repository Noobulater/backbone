#Written By Aaron Bentley 6-7-15
import globals
import engine/types
import container

var characters* = newSeq[Character]()

# Starts the tracking of this entity.
method track*(this: Character): Character =
  discard container.track(this)
  characters.add(this)
  this

# Stops the tracking of this entity.
method untrack*(this: Character) =
  characters.delete(characters.get(this))
  procCall container.untrack(this)
