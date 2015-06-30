import globals
import engine/coords/vector
import engine/physical/entity

type
  colData* = object
    hitPos*: Vec3
    ent1*,ent2*: Entity
    intersecting*: bool
