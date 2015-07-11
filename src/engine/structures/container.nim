#Written By Aaron Bentley 6-7-15
import globals
import engine/types
import details/inventory
import engine/physical/physObj

var containers* = newSeq[Container]()

# Starts the tracking of this
method track*(this: Container): Container =
  containers.add(this)
  this

# Stops the tracking of this
method untrack*(this: Container) =
  containers.delete(containers.get(this))

# Initializes this
method init*(this: Container): Container =
  this.inventory = newInventory()
  this

proc newContainer*(): Container = Container().init.track()
