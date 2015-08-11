# IQM: Inter-Quake Model format
# version 1: April 20, 2010

# all data is little endian
import opengl, streams
import engine/types
import engine/coords/quat, engine/coords/matrix, engine/coords/vector

let
  IQM_MAGIC = "INTERQUAKEMODEL" & '\0'
  IQM_VERSION = 2
  rot = mat4([1,0,0,0,
  0,0,1,0,
  0,1,0,0,
  0,0,0,1])

proc iqmLoadHeader(fs: FileStream): iqmHeader =
  result.magic = ""
  for i in 0..15: #low(result.magic)..high(result.magic) :
    result.magic = result.magic & fs.readChar()

  result.version = fs.readInt32().uint
  result.filesize = fs.readInt32().uint
  result.flags = fs.readInt32().uint
  result.num_text = fs.readInt32().uint
  result.ofs_text = fs.readInt32().uint
  result.num_meshes = fs.readInt32().uint
  result.ofs_meshes = fs.readInt32().uint

  result.num_vertexarrays = fs.readInt32().uint
  result.num_vertexes = fs.readInt32().uint
  result.ofs_vertexarrays = fs.readInt32().uint

  result.num_triangles = fs.readInt32().uint
  result.ofs_triangles = fs.readInt32().uint
  result.ofs_adjacency = fs.readInt32().uint

  result.num_joints = fs.readInt32().uint
  result.ofs_joints = fs.readInt32().uint
  result.num_poses = fs.readInt32().uint
  result.ofs_poses = fs.readInt32().uint
  result.num_anims = fs.readInt32().uint
  result.ofs_anims = fs.readInt32().uint

  result.num_frames = fs.readInt32().uint
  result.num_framechannels = fs.readInt32().uint
  result.ofs_frames = fs.readInt32().uint
  result.ofs_bounds = fs.readInt32().uint
  result.num_comment = fs.readInt32().uint
  result.ofs_comment = fs.readInt32().uint
  result.num_extensions = fs.readInt32().uint
  result.ofs_extensions = fs.readInt32().uint # these are stored as a linked list, not as a contiguous array

proc loadVAO(fs: FileStream, data: var iqmData): bool = #VAO -> Vertex Array Object
  # SO, NOW WE ARE AT THE VERTEX ARRAY OBJECT
  # WE NEED TO COLLECT AN ARRAY OF VERTEXARRAY OBJECTS
  # THERE IS A VARIABLE AMOUNT OF THEM.
  # We could potentially use all this data, so lets initialize it all so we have space
  data.verticies = newSeq[float32](data.h.num_vertexes.int*3)
  data.indicies = newSeq[int32](data.h.num_triangles.int*3)
  data.normals = newSeq[float32](data.h.num_vertexes.int*3)
  data.texCoords = newSeq[float32](data.h.num_vertexes.int*2)
  data.tangents = newSeq[float32](data.h.num_vertexes.int*4)

  data.blendindexes = newSeq[uint8](data.h.num_vertexes.int*4)
  data.blendweights = newSeq[uint8](data.h.num_vertexes.int*4)
  data.colors = newSeq[uint8](data.h.num_vertexes.int*4)

  #jump to the vertex arrays
  fs.setPosition(data.h.ofs_vertexarrays.int)
  var
    curPosition = fs.getPosition()
    va = iqmVertexArray()

  for j in 1..data.h.num_vertexarrays.int :
    va.form = fs.readInt32().uint
    va.flags = fs.readInt32().uint
    va.format = fs.readInt32().uint
    va.size = fs.readInt32().uint
    va.offset = fs.readInt32().uint
    curPosition = fs.getPosition()

    case va.form :
    of IQM.POSITION.uint :
      if (va.format.int != cIQM.FLOAT.int or va.size.int != 3) :
        echo("ERROR: POSITIONS MALFORMED")
        return false
      #Jump to Vertexes
      fs.setPosition(va.offset.int)
      for i in 0..((data.h.num_vertexes.int)*3)-1 :
        data.verticies[i] = fs.readFloat32()
      fs.setPosition(curPosition)

    of IQM.TEXCOORD.uint :
      if (va.format.int != cIQM.FLOAT.int or va.size.int != 2) :
        echo("ERROR: TEXCOORDS MALFORMED")
        return false
      #Jump to Tex Coords
      fs.setPosition(va.offset.int)
      for i in 0..((data.h.num_vertexes.int)*2)-1 :
        data.texCoords[i] = fs.readFloat32()
      fs.setPosition(curPosition)

    of IQM.NORMAL.uint :
      if (va.format.int != cIQM.FLOAT.int or va.size.int != 3) :
        echo("ERROR: NORMALS MALFORMED")
        return false
      #Jump to Normals
      fs.setPosition(va.offset.int)
      for i in 0..((data.h.num_vertexes.int)*3)-1 :
        data.normals[i] = fs.readFloat32()
      fs.setPosition(curPosition)

    of IQM.TANGENT.uint :
      if (va.format.int != cIQM.FLOAT.int or va.size.int != 4) :
        echo("ERROR: TANGENTS MALFORMED")
        return false
      #Jump to Tangents
      fs.setPosition(va.offset.int)
      for i in 0..((data.h.num_vertexes.int)*4)-1 :
        data.tangents[i] = fs.readFloat32()
      fs.setPosition(curPosition)
    of IQM.BLENDINDEXES.uint :
      if (va.format.int != cIQM.UBYTE.int or va.size.int != 4) :
        echo("ERROR: BLENDINDEXES MALFORMED")
        return false
      #Jump to BlendINDEXES
      fs.setPosition(va.offset.int)
      for i in 0..((data.h.num_vertexes.int)*4)-1 :
        data.blendindexes[i] = fs.readInt8().uint8
      fs.setPosition(curPosition)
    of IQM.BLENDWEIGHTS.uint :
      if (va.format.int != cIQM.UBYTE.int or va.size.int != 4) :
        echo("ERROR: BLENDWEIGHTS MALFORMED")
        return false
      #Jump to blendweights
      fs.setPosition(va.offset.int)
      for i in 0..((data.h.num_vertexes.int)*4)-1 :
        data.blendweights[i] = fs.readInt8().uint8
      fs.setPosition(curPosition)
    of IQM.COLOR.uint :
      if(va.format.int != cIQM.UBYTE.int or va.size.int != 4) :
        echo("ERROR: COLORS MALFORMED")
        return false
      #Jump to colors
      fs.setPosition(va.offset.int)
      for i in 0..((data.h.num_vertexes.int)*4)-1 :
        data.colors[i] = fs.readInt8().uint8
      fs.setPosition(curPosition)
    else :
      discard

  return true #success

proc loadTris(fs: FileStream, data: var iqmData) =
  fs.setPosition(data.h.ofs_triangles.int)
  for i in 0..data.h.num_triangles.int*3-1 :
    data.indicies[i] = fs.readInt32()

proc loadMeshes(fs: FileStream, data: var iqmData) =
  let n = data.h.num_meshes.int #number of meshs
  data.meshes = newSeq[iqmMesh](n) #initialize it here to save cycles
  # there could be some vertex corruption, so if that is teh case we don't want
  # to initialize for nothing

  fs.setPosition(data.h.ofs_meshes.int)
  for i in 0..(n-1) :
    data.meshes[i] = iqmMesh()
    data.meshes[i].namev = fs.readInt32().uint
    data.meshes[i].material = fs.readInt32().uint
    data.meshes[i].first_vertex = fs.readInt32().uint
    data.meshes[i].num_vertexes = fs.readInt32().uint
    data.meshes[i].first_triangle = fs.readInt32().uint
    data.meshes[i].num_triangles = fs.readInt32().uint

proc loadText(fs: FileStream, data: var iqmData) =
  # initialize our data
  data.text = ""
  let n = data.h.num_text.int #number of meshs

  fs.setPosition(data.h.ofs_text.int)
  for i in 0..(n-1) :
    data.text = data.text & fs.readChar()

proc loadBoundries(fs: FileStream, data: var iqmData) =
  # initialize our data
  data.boundries = iqmBounds()
  if (data.h.num_frames.int > 0) : #iqm won't calculate bounding boxes for static objects
    fs.setPosition(data.h.ofs_bounds.int)
    data.boundries.bbmins[0] = fs.readFloat32()
    data.boundries.bbmins[1] = fs.readFloat32()
    data.boundries.bbmins[2] = fs.readFloat32()

    data.boundries.bbmaxs[0] = fs.readFloat32()
    data.boundries.bbmaxs[1] = fs.readFloat32()
    data.boundries.bbmaxs[2] = fs.readFloat32()

    data.boundries.xyradius = fs.readFloat32()
    data.boundries.radius = fs.readFloat32()

  else : # so we will
    var
      minX = 0.0
      minY = 0.0
      minZ = 0.0
      maxX = 0.0
      maxY = 0.0
      maxZ = 0.0
    for i in 0..((data.h.num_vertexes.int*3)-1) :
      if (data.verticies[i*3+0] < minX) :
        minX = data.verticies[i*3+0]
      if (data.verticies[i*3+1] < minY) :
        minY = data.verticies[i*3+1]
      if (data.verticies[i*3+2] < minZ) :
        minZ = data.verticies[i*3+2]

      if (data.verticies[i*3+0] > maxX) :
        maxX = data.verticies[i*3+0]
      if (data.verticies[i*3+1] > maxY) :
        maxY = data.verticies[i*3+1]
      if (data.verticies[i*3+2] > maxZ) :
        maxZ = data.verticies[i*3+2]
    data.boundries.bbmins[0] = minX
    data.boundries.bbmins[1] = minY
    data.boundries.bbmins[2] = minZ

    data.boundries.bbmaxs[0] = maxX
    data.boundries.bbmaxs[1] = maxY
    data.boundries.bbmaxs[2] = maxZ

proc loadIQM(fs: FileStream, data: var iqmData): bool =
  if (not loadVAO(fs, data)) :
    return false
  # the following don't have any error checking
  loadText(fs, data)
  loadMeshes(fs, data) # do this after vertexes because less cylces if data corrupted
  loadTris(fs, data)
  loadBoundries(fs, data)
  return true
  #We are at the start of the triangles now

proc loadJoints(fs: FileStream, data: var iqmData) =
  #Initialize our data
  data.joints = newSeq[iqmJoint](data.h.num_joints)

  let n = data.h.num_joints.int #number of meshes
  fs.setPosition(data.h.ofs_joints.int)
  for i in 0..(n-1) :
    data.joints[i] = iqmJoint()
    data.joints[i].name = fs.readInt32().uint
    data.joints[i].parent = fs.readInt32().int
    for j in 0..2 :
      data.joints[i].translate[j] = fs.readFloat32()
    for j in 0..3 :
      data.joints[i].rotate[j] = fs.readFloat32()
    for j in 0..2 :
      data.joints[i].scale[j] = fs.readFloat32()

    let
      r = quat(data.joints[i].rotate)
      t = vec3(data.joints[i].translate)
      s = vec3(data.joints[i].scale)
    data.baseframes[i] = rot * mat4(r.normal(), t, s) * rot
    data.inverseframes[i] = data.baseframes[i].inverse()

    if (data.joints[i].parent >= 0) :
      data.baseframes[i] = data.baseframes[data.joints[i].parent] * data.baseframes[i]
      data.inverseframes[i] = data.inverseframes[i] * data.inverseframes[data.joints[i].parent]

proc loadPoses(fs: FileStream, data: var iqmData) =
  # initialize our data
  data.poses = newSeq[iqmPose](data.h.num_poses)
  let n = data.h.num_poses.int #number of meshes
  fs.setPosition(data.h.ofs_poses.int)
  for i in 0..(n-1) :
    data.poses[i] = iqmPose()
    data.poses[i].parent = fs.readInt32()
    data.poses[i].channelmask = fs.readInt32().uint
    for j in 0..9 :
      data.poses[i].channeloffset[j] = fs.readFloat32()
    for j in 0..9 :
      data.poses[i].channelscale[j] = fs.readFloat32()

proc reCalcAnims(fs: FileStream, data: var iqmData) =
  var
    p: iqmPose
    rotate: Quat
    translate, scale: Vec3

  fs.setPosition(data.h.ofs_frames.int)
  var count  = 0
  for i in 0..(data.h.num_frames.int-1) :
    for j in 0..(data.h.num_poses.int-1) :
      p = data.poses[j]
      translate[0] = p.channeloffset[0]
      translate[1] = p.channeloffset[1]
      translate[2] = p.channeloffset[2]
      rotate[0] = p.channeloffset[3]
      rotate[1] = p.channeloffset[4]
      rotate[2] = p.channeloffset[5]
      rotate[3] = p.channeloffset[6]
      scale[0] = p.channeloffset[7]
      scale[1] = p.channeloffset[8]
      scale[2] = p.channeloffset[9]

      if (p.channelmask.int and 0x01).bool :
         translate[0] = translate[0] + fs.readInt16().uint16.float * p.channelscale[0]
      if (p.channelmask.int and 0x02).bool :
        translate[1] = translate[1] + fs.readInt16().uint16.float * p.channelscale[1]
      if (p.channelmask.int and 0x04).bool :
        translate[2] = translate[2] + fs.readInt16().uint16.float * p.channelscale[2]
      if (p.channelmask.int and 0x08).bool :
        rotate[0] = rotate[0] + fs.readInt16().uint16.float * p.channelscale[3]
      if (p.channelmask.int and 0x10).bool :
        rotate[1] = rotate[1] + fs.readInt16().uint16.float * p.channelscale[4]
      if (p.channelmask.int and 0x20).bool :
        rotate[2] = rotate[2] + fs.readInt16().uint16.float * p.channelscale[5]
      if (p.channelmask.int and 0x40).bool :
        rotate[3] = rotate[3] + fs.readInt16().uint16.float * p.channelscale[6]
      if (p.channelmask.int and 0x80).bool :
        scale[0] = scale[0] + fs.readInt16().uint16.float * p.channelscale[7]
      if (p.channelmask.int and 0x100).bool :
        scale[1] = scale[1] + fs.readInt16().uint16.float * p.channelscale[8]
      if (p.channelmask.int and 0x200).bool :
        scale[2] = scale[2] + fs.readInt16().uint16.float * p.channelscale[9]

      let m = rot * mat4(rotate.normal(), translate, scale) * rot
      let index = i*data.h.num_poses.int + j
      if(p.parent >= 0) :
        data.frames[index] = data.baseframes[p.parent] * m * data.inverseframes[j]
      else :
        data.frames[index] = m * data.inverseframes[j]

proc loadIQMAnims(fs: FileStream, data: var iqmData): bool =
  # init
  if (data.h.num_poses.int != data.h.num_joints.int) :
    return false
  data.anims = newSeq[iqmAnim](data.h.num_anims)
  let n = data.h.num_anims.int #number of meshs
  fs.setPosition(data.h.ofs_anims.int)
  for i in 0..(n-1) :
    data.anims[i] = iqmAnim()
    data.anims[i].name = fs.readInt32().uint
    data.anims[i].first_frame = fs.readInt32().uint
    data.anims[i].num_frames = fs.readInt32().uint
    data.anims[i].framerate = fs.readFloat32()
    data.anims[i].flags = fs.readInt32().uint
  data.baseframes = newSeq[Mat4](data.h.num_joints)
  data.inverseframes = newSeq[Mat4](data.h.num_joints)
  data.frames = newSeq[Mat4](data.h.num_frames.int*data.h.num_poses.int)
  loadJoints(fs, data)
  loadPoses(fs, data)
  #OKAY, now we need to correct the animations and adjust for scale
  #and things of the like
  #We might use reCalcAnims in realtime, so we don't want
  #to initialize ^ in the function, it would be redundant
  reCalcAnims(fs, data)

  return true

var lastPath = ""
var lastParsed = iqmData()

proc parseIQM*(filePath: string): iqmData =
  var file: File
  if (lastPath == filePath) :
    return lastParsed

  if (open(file, "content/" & filePath)) :
    var
      fs = newFileStream(file)
      data: iqmData
      header = iqmLoadHeader(fs)

    #MODEL ERRORS
    if (header.version.int != IQM_VERSION) :
      echo("ERROR: <" & filePath & "> INCORRECT IQM VERSION")
      return iqmData()
    if (header.magic != IQM_MAGIC) :
      echo("ERROR: <" & filePath & "> HEADER FAILED MAGIC CHECK")
      return iqmData()
    if (header.filesize.int > (16 shl 20)) :
      echo("ERROR: <" & filePath & "> FILE SIZE EXCEEDS MAX")
      return iqmData()
    #data.boundries = newSeq[bounds](data.h.num_anims)
    # initialize it after we have checked to make sure that
    # no errors exist in the header
    data = iqmData()
    data.h = header
    if (header.num_meshes.int > 0 and not loadIQM(fs, data) ) :
      echo("ERROR: <" & filePath & "> ERROR LOADING MESHES")
      return iqmData()
    if (header.num_anims.int > 0 and not loadIQMAnims(fs, data)) :
      echo("ERROR: <" & filePath & "> NO BASE ANIM")
      return iqmData()



    #CORRECTS THE DATA SO THAT IT MESHES WITH OPENGL
    #if (filePath == "models/mrfixit.iqm") :
    var tempY: float
    for i in 0..(header.num_vertexes.int-1) :
      tempY = data.verticies[i*3 + 1]
      data.verticies[i*3 + 1] = data.verticies[i*3 + 2]
      data.verticies[i*3 + 2] = tempY

      tempY = data.normals[i*3 + 1]
      data.normals[i*3 + 1] = data.normals[i*3 + 2]
      data.normals[i*3 + 2] = tempY

      tempY = data.tangents[i*4 + 1]
      data.tangents[i*4 + 1] = data.tangents[i*4 + 2]
      data.tangents[i*4 + 2] = tempY

      reCalcAnims(fs, data)

    close(fs)


    lastPath = filePath
    lastParsed = data

    return data

  echo("ERROR: " & filePath & " file not found")
  return iqmData()

proc convertIQM(filePath: string) =
  var data = parseIQM(filePath)


#discard parseIQM("content/mrfixit.iqm")
