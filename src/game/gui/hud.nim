import globals
import engine/types
import engine/gui/surface, engine/gui/panel

proc shouldDraw(): bool =
  if (LocalPlayer.attached != nil) :
    return true

proc init*() =
  var healthBar = newPanel(10, 10, 200, 40)

  proc draw(x,y,width,height: float) =
    if (not shouldDraw()) : return

    setColor(55,55,55,255)
    rect(0,0,width,height)

    setColor(0,0,0,155)
    orect(0,0,width,height)

    let percent = LocalPlayer.attached.health/LocalPlayer.attached.maxHealth
    let g = (255*percent).int
    let r = (255*(1-percent)).int
    setColor(r,g,0,155)
    rect(0,0,width*percent,height)

    setColor(0,0,0,155)
    orect(0,0,width*percent,height)

  healthBar.paint = draw
