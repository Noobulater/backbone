#Written By Aaron Bentley 7/9/15
import globals
import engine/types
import engine/structures/details/inventory
import engine/structures/player
import gui/inv, gui/hud
import engine/structures/details/itemUses

proc init*() =
  discard LocalPlayer.spawn()
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
  discard LocalPlayer.inventory.addItem(item1)
  discard LocalPlayer.inventory.addItem(item2)
  #discard LocalPlayer.inventory.addItem(item3)
  #discard LocalPlayer.inventory.addItem(item3)
  LocalPlayer.inventory.equipment[0] = item3
  hud.init()

proc update*(dt: float) =
  discard
