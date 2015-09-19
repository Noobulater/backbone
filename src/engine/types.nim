#Written By Aaron Bentley 7/8/15
import sdl2, sdl2/mixer, tables

######################
#########MISC#########
######################
type
  inputCode* = enum
    PRIMARYFIRE, SECONDARYFIRE, RELOAD, FORWARD, BACKWARD, STRAFELEFT, STRAFERIGHT, JUMP, CROUCH

  Colr* = object
    r*,g*,b*,a*: int

  SND* = ref object of RootObj
    playing*: bool
    volume*: cint
    data*: ChunkPtr
    rate*: cint
    format*: uint16
    buffers*: cint
    channels*: cint #internal use
    channel*: cint

  timeObj* = ref object of RootObj
    nextCall*: float
    delay*: float
    call*: proc()
    count*: int #number of times its been executed
    reps*: int #number of times it should be executed

  ######################
  ###VECTORS/MATRICIES##
  ######################
  Quat* = object
    d*: array[4, float]

  Mat4* = object
    m*: array[16, float32]

  Vec3* = object
    d*: array[3, float]
  ######################
  #####STRUCTURES#######
  ######################
  Container* = ref object of RootObj
    inventory*: Inventory
    attached*: PhysObj

  Character* = ref object of Container
    stats*: float #Stats # Characters have stats
    uniqueID*: int # Unique ID for the object
    model*: string
    activeWeapon*: WeaponData #Pointer active equipment

  Player* = ref object of Character
    id*: uint8 # ID of the player
    viewEntity*: Entity
    viewModel*: Model #This is a model that the player will see for their weapon
  ######################
  ######INVENTORY#######
  ######################
  EQSLOTS* = enum
    PRIMARY, SECONDARY, SPECIAL, HEAD, BODY, ARM, LEG, EXTRA1, EXTRA2

  ItemData* = ref object of RootObj
    use*: proc(item: ItemData, data: Container): bool
    remove*: proc(item: ItemData, data: Container)
    drop*: proc(item: ItemData, data: Container)
    name*, description*, model*, extras*: string
    reusable*, temporary*: bool

  #Extras is a string included that will be networked. It is there for adding on
  #Important (probably unique) data that this item will use

  EquipmentData* = ref object of ItemData
    primarySlot*: int
    secondarySlot*: int
    equip*: proc(equip: EquipmentData, data: Container)
    unequip*: proc(equip: EquipmentData, data: Container)

  WeaponData* = ref object of EquipmentData
    fireSound*: SND
    #ammoType, holdType:
    fireRate*, accuracy*, reloadTime*, nextPFire*: float
    damage*, clipSize*, numBullets*, curPClip*: int
    automatic*: bool

    primaryFire*: proc(weapon: WeaponData, data: Container)  # only drays(Vehicles) can fire weapons
    secondaryFire*: proc(weapon: WeaponData, data: Container)
    reload*: proc(weapon: WeaponData, data: Container)  # only drays(Vehicles) can fire weapons
    deploy*: proc(weapon: WeaponData, data: Container)
    holster*: proc(weapon: WeaponData, data: Container)

  Inventory* = ref object of RootObj # This contains info regarding weapons/items
    equipment*: array[0..high(EQSLOTS).int, EquipmentData]
    items*: seq[ItemData]
    slotCount*: int #optional maximum value

  ######################
  ########PARSERS#######
  ######################
  iqmHeader* = object
    magic*: string#magic : array[0..15, char] #the string "INTERQUAKEMODEL\0", 0 terminated
    version* : uint # must be version 1
    filesize*: uint
    flags*: uint
    num_text*, ofs_text*: uint
    num_meshes*, ofs_meshes*: uint
    num_vertexarrays*, num_vertexes*, ofs_vertexarrays*: uint
    num_triangles*, ofs_triangles*, ofs_adjacency*: uint
    num_joints*, ofs_joints*: uint
    num_poses*, ofs_poses*: uint
    num_anims*, ofs_anims*: uint
    num_frames*, num_framechannels*, ofs_frames*, ofs_bounds*: uint
    num_comment*, ofs_comment*: uint
    num_extensions*, ofs_extensions*: uint  # these are stored as a linked list, not as a contiguous array

# ofs_* fields are relative to the beginning of the header
# ofs_* fields must be set to 0 when the particular data is empt

  iqmMesh* = object
    namev*: uint      # unique name for the mesh, if desired
    material*: uint  # set to a name of a non-unique material or texture
    first_vertex*, num_vertexes*: uint
    first_triangle*, num_triangles*: uint
    actualTex*: uint # this is temporary

# all vertex array entries must ordered as defined below, if present
# i.e. position comes before normal comes before ... comes before custom
# where a format and size is given, this means models intended for portable use should use these
# an IQM implementation is not required to honor any other format/size than those recommended
# however, it may support other format/size combinations for these types if it desires
  iqmVertexArray* = object
    form*: uint   # formally known as type, type or custom name
    flags*: uint
    format*: uint # component format
    size*: uint   # number of components
    offset*: uint # offset to array of tightly packed components, with num_vertexes * size total entries

  iqmTriangle* = object
    vertex*: array[0..2, uint]

  iqmAdjacency* = object
    triangle*: array[0..2, uint]

  iqmJoint* = object
    name*: uint
    parent*: int # parent < 0 means this is a root bone
    translate*: array[0..2, float]
    rotate*: array[0..3, float]
    scale*: array[0..2, float]
    # translate is translation <Tx, Ty, Tz>, and rotate is quaternion rotation <Qx, Qy, Qz, Qw> where Qw = -sqrt(max(1 - Qx*Qx - Qy*qy - Qz*qz, 0))
    # rotation is in relative/parent local space
    # scale is pre-scaling <Sx, Sy, Sz>
    # output = (input*scale)*rotation + translation


  iqmPose* = object
    parent*: int # parent < 0 means this is a root bone
    channelmask*: uint # mask of which 9 channels are present for this joint pose
    channeloffset*: array[0..9, float]
    channelscale*: array[0..9, float]
    # channels 0..2 are translation <Tx, Ty, Tz> and channels 3..5 are quaternion rotation <Qx, Qy, Qz, Qw> where Qw = -sqrt(max(1 - Qx*Qx - Qy*qy - Qz*qz, 0))
    # rotation is in relative/parent local space
    # channels 6..8 are scale <Sx, Sy, Sz>
    # output = (input*scale)*rotation + translation

  IQM* = enum # vertex array type
    POSITION     = 0  # float, 3
    TEXCOORD     = 1  # float, 2
    NORMAL       = 2  # float, 3
    TANGENT      = 3  # float, 4
    BLENDINDEXES = 4  # ubyte, 4
    BLENDWEIGHTS = 5  # ubyte, 4
    COLOR        = 6  # ubyte, 4
    # all values up to CUSTOM are reserved for future use
    # any value >= CUSTOM is interpreted as CUSTOM type
    # the value then defines an offset into the string table, where offset = value - CUSTOM
    # this must be a valid string naming the type
    CUSTOM       = 0x10

  cIQM* = enum
    BYTE   = 0
    UBYTE  = 1
    SHORT  = 2
    USHORT = 3
    INT    = 4
    UINT   = 5
    HALF   = 6
    FLOAT  = 7
    DOUBLE = 8
  #frames[] # frames is a big unsigned short array where each group of framechannels components is one frame

  iqmAnim* = object
    name*: uint
    first_frame*, num_frames*: uint
    framerate*: float
    flags*: uint

  iqmBounds* = object
    bbmins*, bbmaxs*: array[0..2, float] # the minimum and maximum coordinates of the bounding box for this animation frame
    xyradius*, radius*: float # the circular radius in the X-Y plane, as well as the spherical radius

#char text[] # big array of all strings, each individual string being 0 terminated
#char comment[]

  extension* = object
    name*: uint
    num_data*, ofs_data*: uint
    ofs_extensions*: uint  # pointer to next extension


# vertex data is not really interleaved, but this just gives examples of standard types of the data arrays
#  vertex = object
#    position: array[0..2, float]
#    texcoord: array[0..1, float]
#    normal: array[0..2, float]
#    tangent: array[0..3, float]
#    blendindices, blendweights, color: array[0..3, uint8]

  iqmData* = object
    h*: iqmHeader
    meshes*: seq[iqmMesh]
    verticies*: seq[float32]
    indicies*: seq[int32]
    normals*: seq[float32]
    texCoords*: seq[float32]
    tangents*: seq[float32]
    blendindexes*: seq[uint8]
    blendweights*: seq[uint8]
    colors*: seq[uint8]

    text*: string

    joints*: seq[iqmJoint]
    poses*: seq[iqmPose]
    anims*: seq[iqmAnim]
    boundries*: iqmBounds

    baseframes*: seq[Mat4]
    inverseframes*: seq[Mat4]
    frames*: seq[Mat4]

  ######################
  #########GLX##########
  ######################
  RenderGroups* = enum
    RENDERGROUP_SKYBOX, RENDERGROUP_WORLD, RENDERGROUP_OPAQUE, RENDERGROUP_BOTH, RENDERGROUP_TRANSPARENT, RENDERGROUP_VIEWMODEL, RENDERGROUP_VIEWMODEL_TRANSPARENT
  Unchecked* {.unchecked.}[T] = array[1, T]

  Resource* = ref object of RootObj

  Program* = ref object of Resource
    handle*: uint32
    uniforms*: Table[string, int32]

  Material* = ref object of Resource
    texture*: uint32
    normal*: uint32
    ambient*: Vec3
    diffuse*: Vec3
    specular*: Vec3
    shine*: float32

  Mesh* = ref object of Resource
    handle*: uint32
    data*: iqmData

    #Final things to be displayed
    outFrame*: seq[Mat4]
    outVerts*, outNorms*: seq[float32]
    # ###Animation Support###
    playRate*: float
    curFrame*: int #current frame to play
    blend*: float
    # #######################
    # internal use
    lastTime*: float
    currentAnim*: int

  ######################
  #######PHYSICAL#######
  ######################
  VoxelManager* = ref object
    chunks*: seq[VoxelChunk]

  Voxel* = ref object
    textureID*: int
    active*: bool

  VoxelChunk* = ref object
    d*: array[50, array[50,  array[50, Voxel]]]
    pos*: Vec3
    matrix*: Mat4
    handle*: int
    size*: int

  TraceData* = object
    origin*, offset*, normal*: Vec3
    dist*: float
    ignore*: seq[PhysObj]

  TraceResult* = object
    origin*, normal*, hitPos*, hitNormal*: Vec3
    hitEnt*: PhysObj
    hit*: bool

  pType* = enum
    pAABB, pOBB, pSPHERE, pCYLINDER, pPOLYGON
    # Type of physics object
    # 1 AABB
    # 2 OBB
    # 3 SPHERE
    # 4 CYLINDER
    # 5 POLYGON
  Particle* = ref object of RootObj # Particles aren't close enough to entities to inherit them
    pos*, scale*: Vec3
    rotation*: float
    vel*: Vec3
    rotVel*: float
    matrix*: Mat4
    #Display
    color*: Colr
    texture*: string
    textID*: int
    lifeTime*: float #how long it will remain visible

  Entity* = ref object of RootObj
    pos*: Vec3
    angle*: Vec3
    scale*: Vec3
    matrix*, rot*: Mat4
    parent*: Entity
    #Basic motion
    angleVel*: Vec3
    vel*: Vec3
    acceleration*: Vec3
    #view Position, for when a player is watching this entity
    viewOffset*: Vec3
    #Whether or not the entity exists (if u don't track it, then it is garbage collected)
    isValid*: bool

  Model* = ref object of Entity
    program*: Program
    material*: Material
    mesh*: Mesh
    meshPath*: string
    renderGroup*: int
    visible*: bool

  colData* = object
    hitPos*, hitNormal*: Vec3
    ent1*,ent2*: PhysObj
    voxel*: Voxel # if it hit a voxel
    intersecting*: bool
    pushDistance*: float

  Damage* = object
    attacker*, victim*: PhysObj
    amount*: int
    origin*, normal*: Vec3

  PhysObj* = ref object of Model
    #Other stuff
    data*: Container # This includes Information about the inventory and ai
    #Common Stats
    health*, maxHealth*: int
    #takeDamage: proc(this: PhysObj, dmginfo: DamageInfo) # when the entity takes damage call this
    #perish: proc(this: PhysObj, dmginfo: Damageinfo) # When the entity dies, call this
    #physics
    impulse*: Vec3 # Impulse is absolute velocity. This will happen, not affected by drag
    mass*: float
    gravity*: float
    friction*: float # Determines how much to decay collisions by
    drag*: float # how quickly an objects velocity decays
    obbc*,lmin*,lmax*: Vec3 # axis aligned bounding box : obbCenter, local min, local max
    physType*: pType
    asleep*: bool # For saving cycles. Its asleep then its doesn't need to be checked
    dynamic*: bool # dynamic will disable any calculation regarding collision/motion
    onGround*: bool
    
  Dray* = ref object of PhysObj # Drays can be armed
    maxSpeed*: float # Regular X/Z motion
    maxLift*: float # Jumping
    shootPos*, shootForward*: Vec3

  ######################
  ########PANELS########
  ######################
  MOUSE* = enum
    NONE, LEFT, RIGHT, MIDDLE, X1, X2

  Panel* = ref object of Rootobj
    x*: float
    y*: float
    width*: float
    height*: float
    textureID*: int #if it has a texture
    paint*: proc(x,y,width,height: float)#this is the function to call to draw it
    doClick*: proc(button: int, pressed: bool, x,y: float)
    doMouseWheel*: proc(x,y,xVel,yVel: float)
    visible*: bool
    crop*: bool # forces content to remain inside the panel
    children*: seq[Panel]
    parent*: Panel

  Screen* = ref object of Rootobj
    pos*,ang*, scale*: Vec3
    matrix*: Mat4
    children*: seq[Panel] #this is the function to call to draw it, happens after rotation
