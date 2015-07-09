
type
  itemData* = ref object of RootObj
    ownerID*: int
    use*: proc(this: Container, entity: PhysObj)
    remove*: proc(this: Container, entity: PhysObj)
    drop*: proc(this: Container)
    name*, description*, model*, extras: string
  	reusable*, temporary*: bool

  #Extras is a string included that will be networked. It is there for adding on
  #Important (probably unique) data that this item will use

  equipmentData* = ref object of itemData
    ownerID*: int
    use*: proc(this: Container, entity: PhysObj)
    remove*: proc(this: Container, entity: PhysObj)
    drop*: proc(this: Container)
    name*, description*, model*, extras: string
    reusable*, temporary*: bool
