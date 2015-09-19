#Written By Aaron Bentley September 16th 2015
import globals
import opengl, math
import engine/types
import engine/coords/matrix, engine/coords/vector
import engine/glx, engine/camera
import voxel

proc newVoxelChunk*(): VoxelChunk = VoxelChunk()
proc `[]`*(v: VoxelChunk, i,j,k: int): Voxel = v.d[i][j][k]
proc `[]`*(v: VoxelChunk, i,j,k: float): Voxel = v.d[i.int][j.int][k.int]

method init*(chunk: VoxelChunk) =
  chunk.pos = vec3(0)
  for x in 0..high(chunk.d) :
    for y in 0..high(chunk.d[x]) :
      for z in 0..high(chunk.d[x][y]) :
        chunk.d[x][y][z] = newVoxel()
        if (y == 0 or ((y == 1 or y == 2 or y == 3) and random(130) == 0)) :
          chunk.d[x][y][z].setActive(true)

method draw*(chunk: VoxelChunk) =
  worldShader.use()
  var mat = chunk.matrix
  glUniformMatrix4fv(glGetUniformLocation(worldShader.handle, "model").int32, 1, false, mat.m[0].addr)
  cameraUniforms(worldShader.handle)

  glBindVertexArray(GLuint(chunk.handle))
  #if (this.textureID.int > 0) :
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, defMaterial.texture)
  glDrawElements(GL_TRIANGLES, chunk.size.int32, GL_UNSIGNED_INT, nil)

let size = 0.5'f32
let offset = 0.0'f32
proc addFace*(i: var seq[int32], v, n: var seq[float32], position: Vec3, index, dir: int32) =
  i.add([index, index+1, index+2, index, index+3, index+1])

  case (dir) :
  of 0: # DOWN
    v.add([position.x.float32 + size + offset, position.y.float32 + -size + offset, position.z.float32 + size + offset,
          position.x.float32 + -size + offset, position.y.float32 + -size + offset, position.z.float32 + -size + offset,
          position.x.float32 + size + offset, position.y.float32 + -size + offset, position.z.float32 + -size + offset,
          position.x.float32 + -size + offset, position.y.float32 + -size + offset, position.z.float32 + size + offset,])
    n.add([0.0'f32,-1.0,0.0,
      0.0,-1.0,0.0,
      0.0,-1.0,0.0,
      0.0,-1.0,0.0,])
  of 1: # UP
    v.add([position.x.float32 + size + offset, position.y.float32 + size + offset, position.z.float32 + size + offset,
          position.x.float32 + -size + offset, position.y.float32 + size + offset, position.z.float32 + -size + offset,
          position.x.float32 + -size + offset, position.y.float32 + size + offset, position.z.float32 + size + offset,
          position.x.float32 + size + offset, position.y.float32 + size + offset, position.z.float32 + -size + offset,])

    n.add([0.0'f32,1.0,0.0,
      0.0,1.0,0.0,
      0.0,1.0,0.0,
      0.0,1.0,0.0,])
  of 2: # +Z SIDE
    v.add([position.x.float32 + size + offset, position.y.float32 + -size + offset, position.z.float32 + size + offset,
          position.x.float32 + size + offset, position.y.float32 + size + offset, position.z.float32 + -size + offset,
          position.x.float32 + size + offset, position.y.float32 + size + offset, position.z.float32 + size + offset,
          position.x.float32 + size + offset, position.y.float32 + -size + offset, position.z.float32 + -size + offset,])

    n.add([1.0'f32,0.0,0.0,
          1.0,0.0,0.0,
          1.0,0.0,0.0,
          1.0,0.0,0.0,])
  of 3: #-X Side
    v.add([position.x.float32 + size + offset, position.y.float32 + -size + offset, position.z.float32 + -size + offset,
          position.x.float32 + -size + offset, position.y.float32 + size + offset, position.z.float32 + -size + offset,
          position.x.float32 + size + offset, position.y.float32 + size + offset, position.z.float32 + -size + offset,
          position.x.float32 + -size + offset, position.y.float32 + -size + offset, position.z.float32 + -size + offset,])

    n.add([0.0'f32,0.0,-1.0,
          0.0,0.0,-1.0,
          0.0,0.0,-1.0,
          0.0,0.0,-1.0,])
  of 4: #-Z Side
    v.add([position.x.float32 + -size + offset, position.y.float32 + -size + offset, position.z.float32 + -size + offset,
          position.x.float32 + -size + offset, position.y.float32 + size + offset, position.z.float32 + size + offset,
          position.x.float32 + -size + offset, position.y.float32 + size + offset, position.z.float32 + -size + offset,
          position.x.float32 + -size + offset, position.y.float32 + -size + offset, position.z.float32 + size + offset,])

    n.add([-1.0'f32,0.0,0.0,
          -1.0,0.0,0.0,
          -1.0,0.0,0.0,
          -1.0,0.0,0.0,])
  of 5: #+X Side
    v.add([position.x.float32 + size + offset, position.y.float32 + size + offset, position.z.float32 + size + offset,
          position.x.float32 + -size + offset, position.y.float32 + -size + offset, position.z.float32 + size + offset,
          position.x.float32 + size + offset, position.y.float32 + -size + offset, position.z.float32 + size + offset,
          position.x.float32 + -size + offset, position.y.float32 + size + offset, position.z.float32 + size + offset,])

    n.add([0.0'f32,0.0,1.0,
          0.0,0.0,1.0,
          0.0,0.0,1.0,
          0.0,0.0,1.0,])
  else :
    discard

method rebuild*(chunk: VoxelChunk) =
  # Responsible for generating the chunk's VAO
  var indicies = newSeq[int32](0)
  var verticies = newSeq[float32](0)
  var normals = newSeq[float32](0)
  var index = 0'i32
  var count = 0
  for x in 0..high(chunk.d) :
    for y in 0..high(chunk.d[x]) :
      for z in 0..high(chunk.d[x][y]) :
        if (chunk.d[x][y][z].getActive()) :
          addFace(indicies, verticies, normals, vec3(x,y,z), index + 0, 0)
          addFace(indicies, verticies, normals, vec3(x,y,z), index + 4, 1)
          addFace(indicies, verticies, normals, vec3(x,y,z), index + 8, 2)
          addFace(indicies, verticies, normals, vec3(x,y,z), index + 12, 3)
          addFace(indicies, verticies, normals, vec3(x,y,z), index + 16, 4)
          addFace(indicies, verticies, normals, vec3(x,y,z), index + 20, 5)
          index = (indicies.len.float * (2/3)).int32

  chunk.handle = bufferArray().int
  discard buffer(GL_ELEMENT_ARRAY_BUFFER, sizeof(uint32).int32 * indicies.len.int32, indicies[0].addr)

  discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * (verticies.len).int32, verticies[0].addr)
  let pos = glGetAttribLocation(worldShader.handle, "in_position").uint32
  attrib(pos, 3'i32, cGL_FLOAT)

  discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * (normals.len).int32, normals[0].addr)
  #let pos = glGetAttribLocation(program, "in_normal").uint32
  attrib(1, 3'i32, cGL_FLOAT)

  chunk.size = indicies.len

  #discard buffer(GL_ARRAY_BUFFER, sizeof(float32).int32 * (vertexes*2).int32, texCoords[0].addr)
  #let pos = glGetAttribLocation(program, "in_uv").uint32
  #attrib(2, 2'i32, cGL_FLOAT)
