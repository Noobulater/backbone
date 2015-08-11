#Written By Aaron Bentley 07/23/15
import opengl, strutils
import globals, types
import glx, camera
import parser/bmp
import scene
import coords/matrix, coords/vector

type
  SkyBox* = ref object of RootObj
    faces*: array[0..5, GLuint] # The various sides of the box
    handle*: GLuint # the vbo for the skybox

var
  ind = @[0'i32,1,2,
    0,3,1,
    4,5,6,
    4,7,5,
    8,9,10,
    8,11,9,
    12,13,14,
    12,15,13,
    16,17,18,
    16,19,17,
    20,21,22,
    20,23,21,]


let size: float32 = 1.0
var
  sky*: SkyBox

var newView = identity()
proc draw*(this: SkyBox) =
  skyShader.use()
  skyBoxMatrix = identity()
  newView = identity().rotate(camera.ang.p, vec3(1, 0, 0)) * identity().rotate(camera.ang.y, vec3(0, 1, 0))

  glUniformMatrix4fv(glGetUniformLocation(skyShader.handle, "model").int32, 1, false, skyBoxMatrix.m[0].addr)
  glUniformMatrix4fv(glGetUniformLocation(skyShader.handle, "view").int32, 1, false, newView.m[0].addr)
  glUniformMatrix4fv(glGetUniformLocation(skyShader.handle, "proj").int32, 1, false, proj.m[0].addr)

  glDepthMask(false)
  glBindVertexArray(this.handle)

  for i in 0..high(this.faces) :
    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D, this.faces[i])
    glDrawElements(GL_TRIANGLES, 2*3, GL_UNSIGNED_INT, ind[i*6].addr)


proc loadSkyBox*(filePath: string):SkyBox =
  # filepath is the start of the file, it will be extended because we have 6 differnt
  # images to load
  result = SkyBox()
  let newPath = filePath.replace(".bmp", "")
  result.faces[5] = parseBmp(newPath & "_top.bmp")
  result.faces[3] = parseBmp(newPath & "_bot.bmp")
  result.faces[1] = parseBmp(newPath & "_left.bmp")
  result.faces[0] = parseBmp(newPath & "_right.bmp")

  result.faces[2] = parseBmp(newPath & "_front.bmp")
  result.faces[4] = parseBmp(newPath & "_back.bmp")

  for i in 0..high(result.faces) :
    glBindTexture(GL_TEXTURE_2D, result.faces[i])
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE)

  #shader = initProgram("phong.vert", "sky.frag")

  result.handle = bufferArray()

  var
    v = @[size,size,-size,
      -size,-size,-size,
      size,-size,-size,
      -size,size,-size,
      size,size,size,
      -size,-size,size,
      -size,size,size,
      size,-size,size,
      size,size,-size,
      size,-size,size,
      size,size,size,
      size,-size,-size,
      size,-size,-size,
      -size,-size,size,
      size,-size,size,
      -size,-size,-size,
      -size,-size,-size,
      -size,size,size,
      -size,-size,size,
      -size,size,-size,
      size,size,size,
      -size,size,-size,
      size,size,-size,
      -size,size,size]
    n = @[0.0'f32,0.0,-1.0,
      0.0,0.0,-1.0,
      0.0,0.0,-1.0,
      0.0,0.0,-1.0,
      0.0,0.0,1.0,
      0.0,0.0,1.0,
      0.0,0.0,1.0,
      0.0,0.0,1.0,
      1.0,0.0,0.0,
      1.0,0.0,0.0,
      1.0,0.0,0.0,
      1.0,0.0,0.0,
      0.0,-1.0,0.0,
      0.0,-1.0,0.0,
      0.0,-1.0,0.0,
      0.0,-1.0,0.0,
      -1.0,0.0,0.0,
      -1.0,0.0,0.0,
      -1.0,0.0,0.0,
      -1.0,0.0,0.0,
      0.0,1.0,0.0,
      0.0,1.0,0.0,
      0.0,1.0,0.0,
      0.0,1.0,0.0,]
    t = @[
      #right face
      1.0'f32,0.0,
      0.0,1.0,
      1.0,1.0,
      0.0,0.0,
      #left face
      0.0,0.0,
      1.0,1.0,
      1.0,0.0,
      0.0,1.0,
      #front face
      0.0,0.0,
      1.0,1.0,
      1.0,0.0,
      0.0,1.0,
      #bot face
      1.0,0.0,
      0.0,1.0,
      1.0,1.0,
      0.0,0.0,
      #back face
      1.0,1.0,
      0.0,0.0,
      0.0,1.0,
      1.0,0.0,
      #top face
      1.0,0.0,
      0.0,1.0,
      1.0,1.0,
      0.0,0.0,]

  discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * (v.len).int32, v[0].addr)
  #let pos = glGetAttribLocation(shader.handle, "in_position").uint32
  attrib(0, 3'i32, cGL_FLOAT)

  discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * (v.len*3).int32, n[0].addr)
  #let pos = glGetAttribLocation(program, "in_normal").uint32
  attrib(1, 3'i32, cGL_FLOAT)

  discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * (v.len*2).int32, t[0].addr)
  #let pos = glGetAttribLocation(program, "in_uv").uint32
  attrib(2, 2'i32, cGL_FLOAT)

  proc drawHook(): bool =
    if (sky != nil):
      sky.draw()
      return true
    return false

  addDraw(RENDERGROUP_SKYBOX.int, drawHook)
  sky = result
