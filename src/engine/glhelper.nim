import os, times, math, tables, strutils
import opengl, glu, assimp
import coords/matrix, coords/vector, pointer_arithm
import parser/bmp, camera
import globals

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
  triangles*: int32

method use*(this: Mesh) =
  glBindVertexArray(this.handle)
  glDrawElements(GL_TRIANGLES, this.triangles, GL_UNSIGNED_INT, nil)

method stop*(this: Mesh) = glBindVertexArray(0)

method destroy*(this: Mesh) =
  this.stop()
  glDeleteVertexArrays(1, this.handle.addr)

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
