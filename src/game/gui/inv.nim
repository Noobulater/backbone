import globals
import engine/types
import engine/structures/details/inventory
import engine/gui/surface, engine/gui/panel
import engine/structures/details/itemUses

proc buildPanels*() = #Builds a temp inventory
  loadFont("Trebuchet.ttf", 12)
  #proc doClick(button: int, pressed: bool, x,y: float) =

  let items = LocalPlayer.inventory.items
  for i in 0..high(LocalPlayer.inventory.items) :
    let item = items[i]
    var txt = "empty"
    let id = i
    let y = 60.0 + (60 * i).float
    var pane = newPanel(scrW.float - 60.0,y,50.0,50.0)

    proc drawBox(x,y,width,height: float) =
        setColor(0, 0, 0, 255)
        rect(0.0, 0.0, width, height)

        setColor(255, 255, 255, 55)
        rect(2.0, 2.0, width-4, height-4)
        if (LocalPlayer.inventory.items[id] != nil) :
          txt = LocalPlayer.inventory.items[id].name
        else:
          txt = "empty"
        drawText(txt, 10.0,10.0, Color(255,255,255,255), Color(0,0,0,255))

    proc clickBox(button: int, released: bool, x,y: float) =
      if (released):
        if (LocalPlayer.inventory.items[id] != nil) :
          discard LocalPlayer.inventory.items[id].use(LocalPlayer.inventory.items[id], LocalPlayer)

    pane.paint = drawBox
    pane.doClick = clickBox

  let equipment = LocalPlayer.inventory.equipment
  for i in 0..high(equipment) :
    let eq = equipment[i]
    if (eq != nil) :
      let y = 60.0 + (60 * i).float
      var pane = newPanel(10.0,y,50.0,50.0)

      proc gen(txt: string): proc(x,y,width,height: float) =
        return proc(x,y,width,height: float) =
          if (LocalPlayer.inventory.findEquip(eq) >= 0):
            setColor(0, 0, 0, 255)
          else:
            setColor(255, 0, 0, 255)
          rect(0.0, 0.0, width, height)

          setColor(255, 255, 255, 55)
          rect(2.0, 2.0, width-4, height-4)

          drawText(txt, 10.0,10.0, Color(255,255,255,255), Color(0,0,0,255))
      proc clickBox(button: int, released: bool, x,y: float) =
        if (released):
          discard eq.use(eq, LocalPlayer)

      pane.paint = gen(eq.name)
      pane.doClick = clickBox
  discard
