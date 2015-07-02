import globals
import engine/coords/vector
import engine/physical/physObj

type
  colData* = object
    hitPos*: Vec3
    ent1*,ent2*: PhysObj
    intersecting*: bool
    pushDistance*: float
    pushAxis*: Vec3 # unsticking the collision
