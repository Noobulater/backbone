#Written By Aaron Bentley 6-7-15
import globals
import engine/types
import character

var players* = newSeq[Player]()

# Starts the tracking of this
method track*(this: Player): Player =
  discard character.track(this)
  players.add(this)
  this

# Stops the tracking of this
method untrack*(this: Player) =
  players.delete(players.get(this))
  procCall character.untrack(this)

# Initializes this
method init*(this: Player): Player =
  discard character.init(this)
  this

proc newPlayer*(): Player = Player().init.track()

proc initLocalPlayer*() =
  LocalPlayer = newPlayer()

method spawn*(this: Player): Dray =
  LocalPlayer.viewEntity = Entity(character.spawn(this))
  return Dray(LocalPlayer.viewEntity)
