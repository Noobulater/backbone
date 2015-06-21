#Written by Matt Nichols
import os, times, math, tables, strutils
import opengl, glu
import globals
import coords/matrix, coords/vector, coords/quat, pointer_arithm
import parser/bmp, parser/iqm

# CONVIENCIENCE FUNCTIONS
proc bufferArray*(): uint32 =
  glGenVertexArrays(1, result.addr)
  glBindVertexArray(result)

# Buffers the given data to a VAO and returns it
proc buffer*(kind: GLenum, size: GLsizeiptr, data: ptr): uint32 =
  glGenBuffers(1, result.addr)
  glBindBuffer(kind, result)
  glBufferData(kind, size, data, GL_STATIC_DRAW);

proc attrib*(pos: uint32, size: GLint, kind: GLenum) =
  glEnableVertexAttribArray(pos)
  glVertexAttribPointer(pos, size, kind, false, 0'i32, nil)

proc attrib*(pos: uint32, size: GLint, kind: GLenum, data: ptr) =
  glEnableVertexAttribArray(pos)
  glVertexAttribPointer(pos, size, kind, false, 0'i32, data)

proc attribI*(pos: uint32, size,stride: GLint, data: ptr) =
  glEnableVertexAttribArray(pos)
  glVertexAttribIPointer(pos, size, cGL_INT, 0'i32, data)

#DRAW CALLS
var draws*: seq[proc()] = @[]
proc addDraw*(draw: proc()) =
  draws.add(draw)

proc drawScene*() =
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  for i in low(draws)..high(draws):
    draws[i]()

#OBJECT MANAGEMENT

type Unchecked* {.unchecked.}[T] = array[1, T]

type Resource* = ref object of RootObj
method use*(this: Resource) = discard
method stop*(this: Resource) = discard
method destroy*(this: Resource) = discard

type Program* = ref object of Resource
  handle*: uint32
  uniforms: Table[string, int32]

method use*(this: Program) = glUseProgram(this.handle)

method uniform*(this: Program, name: string): int32 =
  if not this.uniforms.hasKey(name):
    this.uniforms[name] = glGetUniformLocation(this.handle, name)
  return this.uniforms[name]

method stop*(this: Program) = glUseProgram(0)

method destroy*(this: Program) =
  this.stop()
  glDeleteProgram(this.handle)

proc compileShader(program: uint32, shdr: uint32, file: string) =
  var src = readFile(file).cstring
  glShaderSource(shdr, 1, cast[cstringArray](addr src), nil)
  glCompileShader(shdr)
  var status: GLint
  glGetShaderiv(shdr, GL_COMPILE_STATUS, addr status)
  if status != GL_TRUE:
    var buff: array[512, char]
    glGetShaderInfoLog(shdr, 512, nil, buff)
    assert false
  glAttachShader(program, shdr)

proc initProgram*(vertexFile: string, fragmentFile: string): Program =
  result = Program(handle: glCreateProgram(), uniforms: initTable[string, int32]())
  compileShader(result.handle, glCreateShader(GL_VERTEX_SHADER), "shaders/" & vertexFile)
  compileShader(result.handle, glCreateShader(GL_FRAGMENT_SHADER), "shaders/" & fragmentFile)
  glBindFragDataLocation(result.handle, 0, "out_color")
  glLinkProgram(result.handle)
  result.use()
  glUniform1i(glGetUniformLocation(result.handle, "texture"), 0)
  glUniform1i(glGetUniformLocation(result.handle, "normalmap"), 1)

type Material* = ref object of Resource
  texture*: uint32
  normal*: uint32
  ambient*: Vec3
  diffuse*: Vec3
  specular*: Vec3
  shine*: float32

method use*(this: Material, program: Program) =
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, this.texture)
  glActiveTexture(GL_TEXTURE1)
  glBindTexture(GL_TEXTURE_2D, this.normal)
  glActiveTexture(GL_TEXTURE0)
  glUniform3f(program.uniform("mat_ambient"), this.ambient.d[0], this.ambient.d[1], this.ambient.d[2])
  glUniform3f(program.uniform("mat_diffuse"), this.diffuse.d[0], this.diffuse.d[1], this.diffuse.d[2])
  glUniform3f(program.uniform("mat_specular"), this.specular.d[0], this.specular.d[1], this.specular.d[2])
  glUniform1f(program.uniform("mat_shine"), this.shine)

method stop*(this: Material) =
  glBindTexture(GL_TEXTURE_2D, 0)

method destroy*(this: Material) =
  this.stop()
  glDeleteTextures(1, this.texture.addr)
  glDeleteTextures(1, this.normal.addr)

proc initMaterial*(file: string, normalFile: string): Material =
  result = Material(texture: parseBmp(file), normal: parseBmp(normalFile))
  result.ambient = vec3(1.0, 1.0, 1.0)
  result.diffuse = vec3(1.0, 1.0, 1.0)
  result.specular = vec3(1.0, 1.0, 1.0)
  result.shine = 40.0'f32

proc initMaterial*(file: string): Material = initMaterial(file, replace(file, ".bmp", "_normal.bmp"))

type Mesh* = ref object of Resource
  handle*: uint32
  data*: iqmData
  playRate*: float
  curFrame*: int #current frame to play
  blend*: float
  outFrame*: seq[Mat4]
  outVerts*, outNorms*: seq[float32]
  lastTime: float # internal use
  currentAnim: int

method calcAnim*(this: Mesh) =
  var
    indicies = this.data.indicies
    verticies = this.data.verticies
    normals = this.data.normals
    texCoords = this.data.texCoords
    tangents = this.data.tangents
    joints = this.data.joints
    num_joints = this.data.h.num_joints.int
    num_poses = this.data.h.num_poses.int
    num_verts = this.data.h.num_vertexes.int
    frames = this.data.frames
    blds = this.data.blendindexes
    ws = this.data.blendweights
    numTriangles = this.data.h.num_triangles.int
    numFrames = this.data.anims[this.currentAnim].num_frames.int
    curFrame = this.curFrame mod numFrames
    nextFrame = (curFrame + 1) mod numFrames
    firstFrame = this.data.anims[this.currentAnim].first_frame.int
    blend = this.blend # completely use the second frame
    outFrame = this.outFrame
    outVerts = this.outVerts
    outNorms = this.outNorms

  # If its a different frame we need to recalculate
  for i in 0..(num_joints-1) :
    let mat = frames[firstFrame + curFrame * num_joints + i] * (1-blend) + frames[firstFrame + nextFrame * num_joints + i] * blend

    if (joints[i].parent >= 0) :
      outFrame[i] = outFrame[joints[i].parent] * mat
    else :
      outFrame[i] = mat

  for i in 0..(num_verts-1) :
    let
      srcpos = vec3(verticies[i*3],verticies[i*3+1],verticies[i*3+2])
      srcnorm = vec3(normals[i*3],normals[i*3+1],normals[i*3+2])
      srctan = quat(tangents[i*4],tangents[i*4+1],tangents[i*4+2],tangents[i*4+3])
    var
      dstpos = vec3()
      dstnorm = vec3()
      dsttan = vec3()
      dstbitan = vec3()
      index: array[0..3,uint8]
      weight: array[0..3,uint8]

    index = [blds[i*4+0],blds[i*4+1],blds[i*4+2],blds[i*4+3]]
    weight = [ws[i*4+0],ws[i*4+1],ws[i*4+2],ws[i*4+3]]

    var mat = outFrame[index[0].int] * (weight[0].float/255.0)
    for j in 1..3 :
      if (weight[j].int > 0) :
        mat = mat + outFrame[index[j].int] * (weight[j].float/255.0)

    dstpos = mat * srcpos
    var matnorm = mat4(mat.b.cross(mat.c), mat.c.cross(mat.a), mat.a.cross(mat.b))
    matnorm.m[15] = 1.0 #needs to preserve old data

    dstnorm = matnorm * srcnorm
    dsttan = matnorm * vec3(srctan[0],srctan[1],srctan[2])
    dstbitan = dstnorm.cross(dsttan) * srctan.w
    this.outVerts[i*3+0] = dstpos[0]
    this.outVerts[i*3+1] = dstpos[1]
    this.outVerts[i*3+2] = dstpos[2]

    this.outNorms[i*3+0] = dstnorm[0]
    this.outNorms[i*3+1] = dstnorm[1]
    this.outNorms[i*3+2] = dstnorm[2]

method use*(this: Mesh) =
  glBindVertexArray(this.handle)
  if (this.handle.int > 0) :
    if (this.data.meshes[0].actualTex.int > 0) :
      glActiveTexture(GL_TEXTURE0)
      glBindTexture(GL_TEXTURE_2D, this.data.meshes[0].actualTex)
    glDrawElements(GL_TRIANGLES, this.data.h.num_vertexes.int32*3, GL_UNSIGNED_INT, nil)
  else :
    # Need to unbind the buffer to use Vertex pointers
    # other wise intpreted as offsets into a VBO
    glBindBuffer(GL_ARRAY_BUFFER, 0)
    var
      indicies = this.data.indicies
      meshes = this.data.meshes
    #########################
    ########ANIMATION########
    #########################
    var dt = curTime() - this.lastTime

    if (this.playRate > 0) :
      # blends verticies together at 30 frames per second
      let frameOffset = 30.0 * dt * this.playRate
      this.blend = this.blend + frameOffset

      if (this.blend > 1) :
        let floored = floor(this.blend)
        this.curFrame = this.curFrame + floored.int
        this.blend = this.blend - floored

      calcAnim(this)

    this.lastTime = curTime()
    #########################

    glVertexPointer(3, cGL_FLOAT, 0, this.outVerts[0].addr)
    let pos = glGetAttribLocation(1, "in_position").uint32
    attrib(pos, 3'i32, cGL_FLOAT, this.outVerts[0].addr)
    glNormalPointer(cGL_FLOAT, 0, this.outNorms[0].addr)
    attrib(1, 3'i32, cGL_FLOAT, this.outNorms[0].addr)
    glTexCoordPointer(2, cGL_FLOAT, 0, this.data.texCoords[0].addr)
    attrib(2, 2'i32, cGL_FLOAT, this.data.texCoords[0].addr)

    glEnableClientState(GL_VERTEX_ARRAY)
    glEnableClientState(GL_NORMAL_ARRAY)
    glEnableClientState(GL_TEXTURE_COORD_ARRAY)
    for i in 0..high(meshes) :
      if (this.data.meshes[i].actualTex.int > 0) :
        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, this.data.meshes[i].actualTex)
      glDrawElements(GL_TRIANGLES, meshes[i].num_triangles.int32*3, GL_UNSIGNED_INT, indicies[meshes[i].first_triangle.int*3].addr)
    glDisableClientState(GL_VERTEX_ARRAY)
    glDisableClientState(GL_NORMAL_ARRAY)
    glDisableClientState(GL_TEXTURE_COORD_ARRAY)

method stop*(this: Mesh) = glBindVertexArray(0)

method destroy*(this: Mesh) =
  this.stop()
  glDeleteVertexArrays(1, this.handle.addr)

proc initMesh*(filePath: string, program: uint32): Mesh =
  result = Mesh()

  var
    data = parseIQM(filePath)
    triangles = (data.h.num_triangles.int*3).int32
    vertexes = data.h.num_vertexes.int32
    normalCount = data.h.num_vertexes.int32
    textureCount = 0
    indicies = data.indicies
    verticies = data.verticies
    normals = data.normals
    texCoords = data.texCoords
    vao = GLuint(0) # if not static this will remain 0

  result.playRate = 0.0

  for i in 0..data.meshes.len-1 :
    let index = data.meshes[i].material.int
    if (index > 0) :
      var path = strAtIndex(data.text, index)
      if (find(path, ".tga") > 0) :
        path = replace(path, ".tga", "")
      if (find(path, ".bmp") <= 0) :
        path = path & ".bmp"
      path = "materials/" & replace(filePath, ".iqm", "") & "/" & path
      data.meshes[i].actualTex = parseBmp(path)

  if (data.h.num_anims.int < 1) :
    # STATIC OBJECTS ONLY
    vao = bufferArray()
    if (triangles > 0) :
      discard buffer(GL_ELEMENT_ARRAY_BUFFER, sizeof(uint32).int32 * indicies.len.int32, indicies[0].addr)

    if (vertexes > 0) :
      discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * (vertexes*3).int32, verticies[0].addr)
      let pos = glGetAttribLocation(program, "in_position").uint32
      attrib(pos, 3'i32, cGL_FLOAT)

    if (normalCount > 0) :
      discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * (vertexes*3).int32, normals[0].addr)
      #let pos = glGetAttribLocation(program, "in_normal").uint32
      attrib(1, 3'i32, cGL_FLOAT)

    if (true) : # assuming everything is textured
      discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * (vertexes*2).int32, texCoords[0].addr)
      #let pos = glGetAttribLocation(program, "in_uv").uint32
      attrib(2, 2'i32, cGL_FLOAT)
    result.handle = vao
    result.data = data
  else :
    result.playRate = 1.0 # 30 frames per second
    result.curFrame = 0
    result.blend = 0.0
    result.outFrame = newSeq[Mat4](data.h.num_joints)
    result.outVerts = newSeq[float32](verticies.len)
    result.outNorms = newSeq[float32](normals.len)
    result.lastTime = curTime()
    result.currentAnim = 0
    result.handle = vao
    result.data = data
    calcAnim(result)
  return result
