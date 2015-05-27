# IQM: Inter-Quake Model format
# version 1: April 20, 2010

# all data is little endian
#INCOMPLETE FILES
type
  header = object
    char magic[16] #the string "INTERQUAKEMODEL\0", 0 terminated
    uint version # must be version 1
    uint filesize
    uint flags
    uint num_text, ofs_text
    uint num_meshes, ofs_meshes
    uint num_vertexarrays, num_vertexes, ofs_vertexarrays
    uint num_triangles, ofs_triangles, ofs_adjacency
    uint num_joints, ofs_joints
    uint num_poses, ofs_poses
    uint num_anims, ofs_anims
    uint num_frames, num_framechannels, ofs_frames, ofs_bounds
    uint num_comment, ofs_comment
    uint num_extensions, ofs_extensions # these are stored as a linked list, not as a contiguous array

# ofs_* fields are relative to the beginning of the header
# ofs_* fields must be set to 0 when the particular data is empt

  mesh = object
    uint name     # unique name for the mesh, if desired
    uint material # set to a name of a non-unique material or texture
    uint first_vertex, num_vertexes
    uint first_triangle, num_triangles

# all vertex array entries must ordered as defined below, if present
# i.e. position comes before normal comes before ... comes before custom
# where a format and size is given, this means models intended for portable use should use these
# an IQM implementation is not required to honor any other format/size than those recommended
# however, it may support other format/size combinations for these types if it desires

  vertexType = enum # vertex array type
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


  dataType = enum # vertex array format
    BYTE   = 0
    UBYTE  = 1
    SHORT  = 2
    USHORT = 3
    INT    = 4
    UINT   = 5
    HALF   = 6
    FLOAT  = 7
    DOUBLE = 8

  vertexarray = object
    type: uint   # type or custom name
    flags: uint
    format: uint # component format
    size: uint   # number of components
    offset: uint # offset to array of tightly packed components, with num_vertexes * size total entries

  triangle = object
    vertex: array[0..2, uint]

  adjacency = object
    triangle: array[0..2, uint]


  joint = object
    name: uint
    parent: int # parent < 0 means this is a root bone
    translate, rotate, scale: array[0..2, float]
    # translate is translation <Tx, Ty, Tz>, and rotate is quaternion rotation <Qx, Qy, Qz, Qw> where Qw = -sqrt(max(1 - Qx*Qx - Qy*qy - Qz*qz, 0))
    # rotation is in relative/parent local space
    # scale is pre-scaling <Sx, Sy, Sz>
    # output = (input*scale)*rotation + translation


  pose = object
    parent: int # parent < 0 means this is a root bone
    channelmask: uint # mask of which 9 channels are present for this joint pose
    channeloffset,channelscale: array[0..8, float]
    # channels 0..2 are translation <Tx, Ty, Tz> and channels 3..5 are quaternion rotation <Qx, Qy, Qz, Qw> where Qw = -sqrt(max(1 - Qx*Qx - Qy*qy - Qz*qz, 0))
    # rotation is in relative/parent local space
    # channels 6..8 are scale <Sx, Sy, Sz>
    # output = (input*scale)*rotation + translation


  frames[] # frames is a big unsigned short array where each group of framechannels components is one frame

struct anim
{
    uint name
    uint first_frame, num_frames
    float framerate
    uint flags
}

enum
{
    ANIM_LOOP = 1<<0
}

struct bounds
{
    float bbmins[3], bbmaxs[3] # the minimum and maximum coordinates of the bounding box for this animation frame
    float xyradius, radius # the circular radius in the X-Y plane, as well as the spherical radius
}

char text[] # big array of all strings, each individual string being 0 terminated
char comment[]

struct extension
{
    uint name
    uint num_data, ofs_data
    uint ofs_extensions # pointer to next extension
}

# vertex data is not really interleaved, but this just gives examples of standard types of the data arrays
struct vertex
{
    float position[3], texcoord[2], normal[3], tangent[4]
    uchar blendindices[4], blendweights[4], color[4]
}
