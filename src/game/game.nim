#Written By Aaron Bentley 7/9/15
import globals
import engine/types
import engine/structures/details/inventory
import engine/structures/player
import engine/timer
import gui/inv, gui/hud
import engine/structures/details/itemUses

proc spawn() =
  discard LocalPlayer.spawn()

proc init*() =
  simple(4, spawn)
  #Lets setup inventory
  var item1 = newItem()
  item1.name = "Item 1"
  item1.description = "that thing"

  var item2 = newItem()
  item2.name = "Item 2"
  item2.description = "that thing"

  var item3 = newWeapon()
  item3.name = "WEP 1"
  item3.description = "that thing"
  item3.clipSize = 3
  item3.curPClip = 3
  item3.model = "models/guns/thompson.iqm"
  discard LocalPlayer.inventory.addItem(item1)
  discard LocalPlayer.inventory.addItem(item2)
  discard LocalPlayer.inventory.addItem(item3)
  #discard LocalPlayer.inventory.addItem(item3)
  #discard LocalPlayer.inventory.addItem(item3)
  discard item3.use(ItemData(item3), LocalPlayer)
  hud.init()

proc update*(dt: float) =
  discard
