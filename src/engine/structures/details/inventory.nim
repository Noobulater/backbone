#Written By Aaron Bentley 6-7-15
import globals
import engine/types

let maxSlots = 3

var inventories* = newSeq[Inventory]()

# Starts the tracking of this
method track*(this: Inventory): Inventory =
  this

# Stops the tracking of this
method untrack*(this: Inventory) =
  inventories.delete(inventories.get(this))

# Initializes
method init*(this: Inventory): Inventory =
  this.slotCount = maxSlots
  this.items = newSeq[ItemData](this.slotCount)
  this

proc newInventory*(): Inventory = Inventory().init.track()

#Inventory functionality
# getSlot will return what is in the slot
method getSlot*(this: Inventory, slot: int): ItemData =
  return this.items[slot]

#Set slot is how we add new stuff to the sequence
method setSlot*(this: Inventory, slot: int, item: ItemData) =
  this.items[slot] = item
  #if (SERVER && owner:IsPlayer()) :
  #  networkItemSlot(uniqueID, slot, itemData, owner)

method setEQSlot*(this: Inventory, slot: int, equip: EquipmentData) =
  this.equipment[slot] = equip
  #if (SERVER && owner:IsPlayer()) :
  #  networkItemSlot(uniqueID, slot, itemData, owner)

method swapSlots*(this: Inventory, slotTo, slotFrom: int) =
  if (slotTo != slotFrom): # if the slots are the same don't bother
    #Swap the items
    let swapItem = this.getSlot(slotFrom)
    let item = this.getSlot(slotTo)
    this.setSlot(slotTo, swapItem)
    this.setSlot(slotFrom, item)

method getEQSlot*(this: Inventory, slot: int): EquipmentData = return this.equipment[slot]

method swapEQSlots*(this: Inventory, eqSlot, slotFrom: int) =
  let swapItem = this.getSlot(slotFrom)
  let eqItem = this.getEQSlot(eqSlot)
  this.setSlot(slotFrom, ItemData(eqItem))
  this.setEQSlot(eqSlot, EquipmentData(swapItem))

#Is there an empty space?
#Yes> Return the open slot No> return -1
method hasRoom*(this: Inventory): int =
  for i in 0..high(this.items):
    if (this.items[i] == nil):
      return i
  return -1 # we use -1 instead of nil

#return the slot number of the item
method findItem*(this: Inventory, wantedItem: ItemData): int =
  for i in 0..high(this.items):
    if (this.items[i] == wantedItem) :
      return i
  echo("Inventory: itemData was not found")
  return -1

method findEquip*(this: Inventory, wantedItem: EquipmentData): int =
  for i in 0..high(this.equipment):
    if (this.equipment[i] == wantedItem) :
      return i
  return -1

method addItem*(this: Inventory, newItem: ItemData): bool = #whether its successful or not
  let openSlot = this.hasRoom()
  if (openSlot < 0) :
    echo("Inventory: Full")
    return false
  this.setSlot(openSlot, newItem)
  return true

method removeItem*(this: Inventory, removeSlot: int): bool =
  if (this.getSlot(removeSlot) != nil) :
    this.setSlot(removeSlot, nil)
    return true
  #if (removeSlot) :
  #
  #else :
  #  for slot, itemData in pairs(this.items):
  #    if (removeItemData != 0 && itemData == removeItemData) :
  #      setSlot(slot, 0)
  #      return true
  return false


method useItem*(this: Inventory, useSlot: int): bool =
  #if (useSlot) :
  let useItemData = this.getSlot(useSlot)
  if (useItemData != nil) :
    if (not useItemData.reusable) :
      this.setSlot(useSlot, nil)
    #useItemData.use(owner)
    return true
#  else :
#    for slot, itemData in pairs(inventory):
#      if (useItemData != 0 && getSlot(slot) == useItemData) :
#        hook.Call("ItemUsed", GAMEMODE, public, getSlot(slot), owner)
#        if (!useItemData.getReusable()) :
#          setSlot(slot, 0)
#        useItemData.use(owner)
#        return true
  return false


method dropItem*(this: Inventory, dropSlot: int): bool =
  #if (dropSlot) :
    let dropItemData = this.getSlot(dropSlot)
    if (dropItemData != nil) :
      #hook.Call("ItemDropped", GAMEMODE, public, getSlot(dropSlot))
      this.setSlot(dropSlot, nil)
      #dropItemData.drop(owner)
      return true
  #else
  #  for slot, itemData in pairs(inventory):
  #    if (dropItemData != 0 &&  getSlot(slot) == dropItemData) :
  #      hook.Call("ItemDropped", GAMEMODE, public, getSlot(slot))
  #      setSlot(slot, 0)
  #      dropItemData.drop(owner)
  #      if (slot < 0) :
  #        dropItemData.unEquip(owner)
  #      return true
  #return false

#Dynamic Slot Management
#method removeSlot*(this: Inventory, slot: int) =
#  let itemData = getSlot(slot)
#  if (itemData != nil) :
#    if (!addItem(itemData)) :
#      itemData.drop(owner)
#  table.remove(inventory, slot)
#  if (SERVER && owner:IsPlayer()) :
#    networkRemoveSlot(uniqueID, slot, owner)
#
#method addSlot()
#  local slot = table.Count(inventory)
#  setSlot(slot, 0)
#
#method getItems(this: Inventory):
#  return this.items
#
#method findItemClass(itemClass)
#  for i in 0..high(inventory.items):
#    if (item != 0 && item.getClass() == itemClass) :
#      return key
#  echo("Inventory: itemClass was not found")
#  return nil
