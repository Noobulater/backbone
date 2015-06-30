#Written By Aaron Bentley June 29th
import globals
import opengl
import engine/coords/matrix, engine/coords/vector
import engine/glx, engine/camera

type
  Voxel* = ref object
    program*: Program
    textureID*: GLuint
    scale*: Vec3
    pos*: Vec3
    matrix*: Mat4

proc buildVoxelVAO*(program: uint32): GLuint =
  var vao = bufferArray()

  var verticies = [0.0'f32, 0.0, 0.0,
  0.0, 0.0, 1.0,
  0.0, 1.0, 0.0,
  0.0, 1.0, 1.0,
  1.0, 0.0, 0.0,
  1.0, 0.0, 1.0,
  1.0, 1.0, 0.0,
  1.0, 1.0, 1.0,
  ]

  var indicies = [0'i32,2,1,
    2,3,1,
    4,6,0,
    6,2,0,
    0,4,1,
    4,5,1,
    2,6,3,
    6,7,3,
    4,6,5,
    6,7,5,
    5,7,1,
    7,3,5,
  ]

  discard buffer(GL_ELEMENT_ARRAY_BUFFER, sizeof(uint32).int32 * indicies.len.int32, indicies[0].addr)

  discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * verticies.len.int32, verticies[0].addr)
  let pos = glGetAttribLocation(program, "in_position").uint32
  attrib(pos, 3'i32, cGL_FLOAT)

  return vao

var vao: GLuint

proc newVoxel*(): Voxel = return Voxel()

method draw*(this: Voxel) =
  if (vao.int == 0) :
    echo(this.program.handle)
    vao = buildVoxelVAO(this.program.handle)

  this.program.use()
  glUniformMatrix4fv(glGetUniformLocation(this.program.handle, "model").int32, 1, false, this.matrix.m[0].addr)
  cameraUniforms(this.program.handle)

  glBindVertexArray(vao)
  if (this.textureID.int > 0) :
    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D, this.textureID)
  glDrawElements(GL_TRIANGLES, 24.int32, GL_UNSIGNED_INT, nil)
