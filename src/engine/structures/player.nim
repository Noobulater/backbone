#Written By Aaron Bentley 6-7-15
import globals
import engine/types
import character

type
  Player* = ref object of Character
    id*: uint8 # ID of the player

var players* = newSeq[Player]()

# Starts the tracking of this entity.
method track*(this: Player): Player =
  discard model.track(this)
  players.add(this)
  this

# Stops the tracking of this entity.
method untrack*(this: Player) =
  players.delete(players.get(this))
  procCall character.untrack(this)
