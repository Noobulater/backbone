#Written By Aaron Bentley June 29th
import globals
import opengl
import engine/types
import engine/coords/matrix, engine/coords/vector
import engine/glx, engine/camera

proc newVoxel*(): Voxel = return Voxel()

method setActive*(this: Voxel, newActive: bool) =
  this.active = newActive

method getActive*(this: Voxel): bool = return this.active

var
  baseVoxel*: int
  baseVoxelSize* = 1.0
  baseVoxelMat = 0

method draw*(this: Voxel, matrix: Mat4) =
  worldShader.use()
  var mat = matrix
  glUniformMatrix4fv(glGetUniformLocation(worldShader.handle, "model").int32, 1, false, mat.m[0].addr)
  cameraUniforms(worldShader.handle)

  glBindVertexArray(GLuint(baseVoxel))
  #if (this.textureID.int > 0) :
  glActiveTexture(GL_TEXTURE0)
  glBindTexture(GL_TEXTURE_2D, defMaterial.texture)
  glDrawElements(GL_TRIANGLES, 36.int32, GL_UNSIGNED_INT, nil)
