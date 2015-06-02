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
  glClear(GL_DEPTH_BUFFER_BIT)
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
  #ind: pointer#data.indicies[data.meshes[0].first_triangle.int].addr
#2386
var incremnt = 0.01
method use*(this: Mesh) =
  #glBindVertexArray(this.handle)

  var
    meshes = this.data.meshes
    indicies = this.data.indicies
    verticies = this.data.verticies
    normals = this.data.normals
    texCoords = this.data.texCoords
    tangents = this.data.tangents

  this.data.curframe = this.data.curframe + 1#incremnt.int
  if (incremnt.int > 0) :
    incremnt = 0
  incremnt = incremnt + 0.1
  #echo(this.data.curframe)
  #echo(incremnt)
  #########################
  ########ANIMATION########
  #########################
  var
    joints = this.data.joints
    num_joints = this.data.h.num_joints.int
    num_poses = this.data.h.num_poses.int
    num_verts = this.data.h.num_vertexes.int
    frames = this.data.frames
    blds = this.data.blendindexes
    ws = this.data.blendweights
    numTriangles = this.data.h.num_triangles.int
    numframes = this.data.h.num_frames.int

    curFrame = this.data.curframe mod numframes #Mod this in the real deal, for the sim we dont need to worry
    nextFrame = (curFrame + 1) mod numframes

    outframe = newSeq[Mat4](num_joints)
    outVerts = newSeq[float32](verticies.len)
    outNorms = newSeq[float32](normals.len)

  for i in 0..(num_joints-1) :
    let mat = frames[curFrame * num_joints + i] * (0.5) + frames[nextFrame * num_joints + i] * (0.5)

    if (joints[i].parent >= 0) :
      outframe[i] = outframe[joints[i].parent] * mat
    else :
      outframe[i] = mat

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

    var mat = outframe[index[0].int] * (weight[0].float/255.0)
    for j in 1..3 :
      if (weight[j].int > 0) :
        mat = mat + outframe[index[j].int] * (weight[j].float/255.0)
    #echo("weights", weight[0]," ", weight[1]," ", weight[2]," ",weight[3])

    dstpos = mat * srcpos
    var matnorm = mat4(mat.b.cross(mat.c), mat.c.cross(mat.a), mat.a.cross(mat.b))
    matnorm.m[15] = 1.0 #needs to preserve old data

    dstnorm = matnorm * srcnorm
    dsttan = matnorm * vec3(srctan[0],srctan[1],srctan[2])
    dstbitan = dstnorm.cross(dsttan) * srctan.w
    outVerts[i*3+0] = dstpos[0]
    outVerts[i*3+1] = dstpos[1]
    outVerts[i*3+2] = dstpos[2]

    outNorms[i*3+0] = dstnorm[0]
    outNorms[i*3+1] = dstnorm[1]
    outNorms[i*3+2] = dstnorm[2]

  if (this.data.curframe > this.data.h.num_frames.int) :
    this.data.curframe = 0

  #########################

  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, 2)
  glVertexPointer(3, cGL_FLOAT, 0, outVerts[0].addr)
  let pos = glGetAttribLocation(1, "in_position").uint32
  attrib(pos, 3'i32, cGL_FLOAT, outVerts[0].addr)
  glNormalPointer(cGL_FLOAT, 0, outNorms[0].addr)
  attrib(1, 3'i32, cGL_FLOAT, outNorms[0].addr)
  glTexCoordPointer(2, cGL_FLOAT, 0, texCoords[0].addr)
  attrib(2, 2'i32, cGL_FLOAT, texCoords[0].addr)

  glEnableClientState(GL_VERTEX_ARRAY)
  glEnableClientState(GL_NORMAL_ARRAY)

  glDrawElements(GL_TRIANGLES, meshes[0].num_triangles.int32*3, GL_UNSIGNED_INT, indicies[meshes[0].first_triangle.int*3].addr)
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, 1)
  glDrawElements(GL_TRIANGLES,  meshes[1].num_triangles.int32*3, GL_UNSIGNED_INT, indicies[meshes[1].first_triangle.int*3].addr)


method stop*(this: Mesh) = glBindVertexArray(0)

method destroy*(this: Mesh) =
  this.stop()
  glDeleteVertexArrays(1, this.handle.addr)

proc initMesh*(filename: string, program: uint32): Mesh =
  var i: seq[uint32] = @[0'u32,1,2,
    0,3,1,
    4,5,6,
    4,7,5,
    8,9,10,
    8,11,9,
    12,13,14,
    12,14,15,
    16,17,18,
    16,18,19,
    20,21,22,
    20,22,23]
  var v: seq[float32] = @[
    0.0'f32,0.0,0.0,
    1.0,1.0,0.0,
    1.0,0.0,0.0,
    0.0,1.0,0.0,
    0.0,0.0,0.0,
    0.0,1.0,1.0,
    0.0,1.0,0.0,
    0.0,0.0,1.0,
    0.0,1.0,0.0,
    1.0,1.0,1.0,
    1.0,1.0,0.0,
    0.0,1.0,1.0,
    1.0,0.0,0.0,
    1.0,1.0,0.0,
    1.0,1.0,1.0,
    1.0,0.0,1.0,
    0.0,0.0,0.0,
    1.0,0.0,0.0,
    1.0,0.0,1.0,
    0.0,0.0,1.0,
    0.0,0.0,1.0,
    1.0,0.0,1.0,
    1.0,1.0,1.0,
    0.0,1.0,1.0]
  #if (find(filename, ".iqm") > 0) :
  var
    data = parseIQM(filename)
    triangles = (data.h.num_triangles.int*3).int32
    vertexes = data.h.num_vertexes.int32
    normalCount = data.h.num_vertexes.int32
    textureCount = 0
    indicies = data.indicies
    verticies = data.verticies
    normals = data.normals
    texCoords = data.texCoords
  #var vao = bufferArray()
  #if (triangles > 0) :
    #for i in low(indicies)..high(indicies) :
      #echo(indicies[i])
    #discard buffer(GL_ELEMENT_ARRAY_BUFFER, sizeof(uint32).int32 * indicies.len.int32, indicies[0].addr)

  if (vertexes > 0) :
    #for i in low(verticies)..high(verticies) :
      #echo(verticies[i])
    #discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * (vertexes*3).int32, verticies[0].addr)
    let pos = glGetAttribLocation(program, "in_position").uint32
    echo(pos)
    #attrib(pos, 3'i32, cGL_FLOAT)

  if (normalCount > 0) :
    discard
    # some reason normals are pointed inward not out
    #discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * (vertexes*3).int32, normals[0].addr)
    # let pos = glGetAttribLocation(program, "in_normal").uint32
    #attrib(1, 3'i32, cGL_FLOAT)

  if (true) :
    discard
    #discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * (vertexes*2).int32, texCoords[0].addr)
    # let pos = glGetAttribLocation(program, "in_uv").uint32
    #attrib(2, 2'i32, cGL_FLOAT)

  return Mesh(handle: 0, data: data)
