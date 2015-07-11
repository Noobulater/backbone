#Written by Aaron Bentley 6/10/15
import strutils
import globals
import engine/coords/vector
import engine/types
import engine/simulation
import engine/physical/entity
import engine/physical/model
import engine/physical/physObj
import engine/physical/dray
import inventory
import engine/audio

########################
#####DEFAULT ITEMS######
########################
proc def_UseItem*(item: ItemData, data: Container): bool =
  return item.reusable

proc def_RemoveItem*(item: ItemData, data: Container) = discard

proc def_DropItem*(item: ItemData, data: Container) =
  let entity = Dray(data.attached)
  if (entity != nil) :
    let dropItem = newPhysObj()
    dropItem.setModel(item.model)
    dropItem.lmin = vec3(-0.1)
    dropItem.lmax = vec3(0.1)
    dropItem.pos = entity.shootPos + entity.shootForward * 2

########################
###DEFAULT EQUIPMENT####
########################
#Called before it is swapped out

proc def_EQUse(item: ItemData, data: Container): bool =
  let inventory = data.inventory
  let equip = EquipmentData(item)
  let isEquipped = inventory.findEquip(equip)
  #if unequiped, then we need to equip it
  if (isEquipped < 0) :
    let equipped = inventory.getEQSlot(equip.primarySlot)
    equip.equip(equip, data)
    inventory.swapEQSlots(equip.primarySlot, inventory.findItem(item))
    if (equipped != nil) :
      equipped.unEquip(equipped, data)
  else: #it is equiped, we need to unequip it
    let equipped = inventory.getEQSlot(equip.primarySlot)

    let openSlot = inventory.hasRoom()
    if (openSlot >= 0): # open slots don't need to be unequipped
      inventory.swapEQSlots(isEquipped, openSlot)
      equip.unEquip(equip, data)
    #else:
    #  user:getInventory().dropItem( nil, public )

# Called right before it is moved in
proc def_Equip*(equip: EquipmentData, data: Container) = discard

#This is called after the item has been moved out
proc def_UnEquip*(equip: EquipmentData, data: Container) = discard

########################
#####DEFAULT WEAPONS####
########################
proc def_CanPFire*(weapon: WeaponData, data: Container): bool =
  return (weapon.curPClip > 0 and weapon.nextPFire <= curTime())

let Sound = Sound("sound/mini-1.wav")
proc def_PrimaryFire*(weapon: WeaponData, data: Container) =
  if (def_CanPFire(weapon, data)) :#this.canPFire()
    let entity = Dray(data.attached)
    if (entity != nil) :
      var trace = TraceData()
      trace.origin = entity.pos + entity.shootPos
      trace.normal = entity.shootForward
      trace.dist = 100
      trace.offset = trace.origin + trace.normal * trace.dist
      trace.ignore = @[PhysObj(drays[0])]

      let tr = traceRay(trace)
      if (tr.hit) :
        tr.hitEnt.takeDamage(Damage(amount: weapon.damage, origin: tr.hitPos, normal: tr.normal))
        Sound.play()
        weapon.curPClip = weapon.curPClip - 1

proc def_Reload*(weapon: WeaponData, data: Container) =
  if (weapon.clipSize <= 0): return #it has unlimited ammo, you cant reload it

  var pool = newSeq[int]()
  let items = data.inventory.items
  for i in 0..high(items):
    let item = items[i]
    if (item != nil): #and item.getClass() == this.getAmmoType()):
      pool.add(i) # save the index because we will be comparing

  var removePool = weapon.clipSize - weapon.curPClip

  for i in 0..high(pool):
    let slot = pool[i]
    let item = items[slot]
    if (removePool > 0):
      let ammo = parseInt(item.extras) or 0
      if (removePool >= ammo):
        weapon.curPClip = weapon.curPClip + ammo
        removePool = removePool - ammo
        #if (SERVER):
        discard data.inventory.removeItem(slot)
      else :
        let ammoLeft = ammo - removePool
        weapon.curPClip = weapon.curPClip + removePool
        item.extras = intToStr(ammoLeft)
        break

#CONVIENCE FUNCTIONS
proc newItem*(): ItemData =
  result = ItemData()
  result.use = def_UseItem
  result.remove = def_RemoveItem
  result.drop = def_DropItem

proc newEquipment*(): EquipmentData =
  result = EquipmentData()
  result.use = def_EQUse
  result.remove = def_RemoveItem
  result.drop = def_DropItem
  result.equip = def_Equip
  result.unequip = def_UnEquip

proc newWeapon*(): WeaponData =
  result = WeaponData()
  result.use = def_EQUse
  result.remove = def_RemoveItem
  result.drop = def_DropItem
  result.equip = def_Equip
  result.unequip = def_UnEquip
  result.primaryFire = def_primaryFire
  result.reload = def_Reload
