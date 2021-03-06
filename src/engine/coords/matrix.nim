#Written by Aaron Bentley
#Contributions/Base Code by Matt Nichols
import math, complex
import opengl
import engine/types
import vector, quat

proc mat4*(m: Mat4): Mat4 =
  result = Mat4()
  result.m = m.m

proc mat4*(m: varargs[cfloat]): Mat4 =
  result = Mat4()
  for i in low(m)..high(m) :
    result.m[i] = GLfloat(m[i])


proc mat4*(m: varargs[int]): Mat4 =
  result = Mat4()
  for i in low(m)..high(m) :
    result.m[i] = GLfloat(m[i])

proc mat4*(a,b,c: Vec3 ): Mat4 =
  result = Mat4()
  result.m[0] = a[0]
  result.m[4] = a[1]
  result.m[8] = a[2]
  result.m[12] = 0.0

  result.m[1] = b[0]
  result.m[5] = b[1]
  result.m[9] = b[2]
  result.m[13] = 0.0

  result.m[2] = c[0]
  result.m[6] = c[1]
  result.m[10] = c[2]
  result.m[14] = 0.0

  result.m[3] = 0.0
  result.m[7] = 0.0
  result.m[11] = 0.0
  result.m[15] = 1.0

proc mat4*(r: Quat, t,s: Vec3 ): Mat4 =
  result = Mat4()
  let
    x = r.x
    y = r.y
    z = r.z
    w = r.w
    tx = 2*x
    ty = 2*y
    tz = 2*z
    txx = tx*x
    tyy = ty*y
    tzz = tz*z
    txy = tx*y
    txz = tx*z
    tyz = ty*z
    twx = w*tx
    twy = w*ty
    twz = w*tz

  result.m[0] = (1 - (tyy + tzz)) * s.x
  result.m[4] = (txy - twz) * s.y
  result.m[8] = (txz + twy) * s.z
  result.m[12] = t[0]

  result.m[1] = (txy + twz) * s.x
  result.m[5] = (1 - (txx + tzz)) * s.y
  result.m[9] = (tyz - twx) * s.z
  result.m[13] = t[1]

  result.m[2] = (txz - twy) * s.x
  result.m[6] = (tyz + twx) * s.y
  result.m[10] = (1 - (txx + tyy)) * s.z
  result.m[14] = t[2]

  result.m[3] = 0.0
  result.m[7] = 0.0
  result.m[11] = 0.0
  result.m[15] = 1.0

  #ROW ORDER VECTORS
  #  result.m[0] = (1 - (tyy + tzz)) * s.x
  #  result.m[1] = (txy - twz) * s.y
  #  result.m[2] = (txz + twy) * s.z
  #  result.m[3] = t[0]

  #  result.m[4] = (txy + twz) * s.x
  #  result.m[5] = (1 - (txx + tzz)) * s.y
  #  result.m[6] = (tyz - twx) * s.z
  #  result.m[7] = t[1]

  #  result.m[8] = (txz - twy) * s.x
  #  result.m[9] = (tyz + twx) * s.y
  #  result.m[10] = (1 - (txx + tyy)) * s.z
  #  result.m[11] = t[2]

  #  result.m[12] = 0.0
  #  result.m[13] = 0.0
  #  result.m[14] = 0.0
  #  result.m[15] = 1.0

proc identity*(): Mat4 =
  result = Mat4()
  result.m = [1.0'f32, 0.0, 0.0, 0.0,
              0.0, 1.0, 0.0, 0.0,
              0.0, 0.0, 1.0, 0.0,
              0.0, 0.0, 0.0, 1.0]

proc `[]`*(m: Mat4, i: int): GLfloat = m.m[i]
proc `[]=`*(m: var Mat4, i: int, v: GLfloat) = m.m[i] = v
#proc `[][]`*(m: Mat4, i,j: int): float = m.m[4*i+j]
#proc `[][]=`*(m: var Mat4, i,j: int, n: float) = m[i][j] = n
proc `==`*(m: Mat4, f: float): bool = (m.m[0] == f and m.m[1] == f and m.m[2] == f and m.m[3] == f and m.m[4] == f and m.m[5] == f and m.m[6] == f and m.m[7] == f and m.m[8] == f and m.m[9] == f and m.m[10] == f and m.m[11] == f and m.m[12] == f and m.m[13] == f and m.m[14] == f and m.m[15] == f)
proc `!=`*(m: Mat4, f: float): bool = (m.m[0] != f and m.m[1] != f and m.m[2] != f and m.m[3] != f and m.m[4] != f and m.m[5] != f and m.m[6] != f and m.m[7] != f and m.m[8] != f and m.m[9] != f and m.m[10] != f and m.m[11] != f and m.m[12] != f and m.m[13] != f and m.m[14] != f and m.m[15] != f)

proc `a`*(m: Mat4): Vec3 = vec3(m.m[0],m.m[4],m.m[8])
proc `b`*(m: Mat4): Vec3 = vec3(m.m[1],m.m[5],m.m[9])
proc `c`*(m: Mat4): Vec3 = vec3(m.m[2],m.m[6],m.m[10])
proc `d`*(m: Mat4): Vec3 = vec3(m.m[3],m.m[7],m.m[11])

proc `x`*(m: Mat4): Vec3 = vec3(m.m[0],m.m[1],m.m[2])
proc `y`*(m: Mat4): Vec3 = vec3(m.m[4],m.m[5],m.m[6])
proc `z`*(m: Mat4): Vec3 = vec3(m.m[8],m.m[9],m.m[10])
proc `w`*(m: Mat4): Vec3 = vec3(m.m[12],m.m[13],m.m[14])

proc `+`*(m, n: Mat4): Mat4 =
  result = Mat4()
  result[0] = m[0] + n[0]
  result[1] = m[1] + n[1]
  result[2] = m[2] + n[2]
  result[3] = m[3] + n[3]
  result[4] = m[4] + n[4]
  result[5] = m[5] + n[5]
  result[6] = m[6] + n[6]
  result[7] = m[7] + n[7]
  result[8] = m[8] + n[8]
  result[9] = m[9] + n[9]
  result[10] = m[10] + n[10]
  result[11] = m[11] + n[11]
  result[12] = m[12] + n[12]
  result[13] = m[13] + n[13]
  result[14] = m[14] + n[14]
  result[15] = m[15] + n[15]
proc `-`*(m, n: Mat4): Mat4 =
  result = Mat4()
  result[0] = m[0] + n[0]
  result[1] = m[1] + n[1]
  result[2] = m[2] + n[2]
  result[3] = m[3] + n[3]
  result[4] = m[4] + n[4]
  result[5] = m[5] + n[5]
  result[6] = m[6] + n[6]
  result[7] = m[7] + n[7]
  result[8] = m[8] + n[8]
  result[9] = m[9] + n[9]
  result[10] = m[10] + n[10]
  result[11] = m[11] + n[11]
  result[12] = m[12] + n[12]
  result[13] = m[13] + n[13]
  result[14] = m[14] + n[14]
  result[15] = m[15] + n[15]
#COLUMN ORDER MATRIX. IT WOULD'VE BEEN NICE TO KNOW THIS
proc `/`*(m, n: Mat4): Mat4 =
  let
    a00 = m[0]
    a01 = m[1]
    a02 = m[2]
    a03 = m[3]
    a10 = m[4]
    a11 = m[5]
    a12 = m[6]
    a13 = m[7]
    a20 = m[8]
    a21 = m[9]
    a22 = m[10]
    a23 = m[11]
    a30 = m[12]
    a31 = m[13]
    a32 = m[14]
    a33 = m[15]
    b00 = n[0]
    b01 = n[1]
    b02 = n[2]
    b03 = n[3]
    b10 = n[4]
    b11 = n[5]
    b12 = n[6]
    b13 = n[7]
    b20 = n[8]
    b21 = n[9]
    b22 = n[10]
    b23 = n[11]
    b30 = n[12]
    b31 = n[13]
    b32 = n[14]
    b33 = n[15]
  result = Mat4()
  result[0] = b00 / a00 + b01 / a10 + b02 / a20 + b03 / a30
  result[1] = b00 / a01 + b01 / a11 + b02 / a21 + b03 / a31
  result[2] = b00 / a02 + b01 / a12 + b02 / a22 + b03 / a32
  result[3] = b00 / a03 + b01 / a13 + b02 / a23 + b03 / a33
  result[4] = b10 / a00 + b11 / a10 + b12 / a20 + b13 / a30
  result[5] = b10 / a01 + b11 / a11 + b12 / a21 + b13 / a31
  result[6] = b10 / a02 + b11 / a12 + b12 / a22 + b13 / a32
  result[7] = b10 / a03 + b11 / a13 + b12 / a23 + b13 / a33
  result[8] = b20 / a00 + b21 / a10 + b22 / a20 + b23 / a30
  result[9] = b20 / a01 + b21 / a11 + b22 / a21 + b23 / a31
  result[10] = b20 / a02 + b21 / a12 + b22 / a22 + b23 / a32
  result[11] = b20 / a03 + b21 / a13 + b22 / a23 + b23 / a33
  result[12] = b30 / a00 + b31 / a10 + b32 / a20 + b33 / a30
  result[13] = b30 / a01 + b31 / a11 + b32 / a21 + b33 / a31
  result[14] = b30 / a02 + b31 / a12 + b32 / a22 + b33 / a32
  result[15] = b30 / a03 + b31 / a13 + b32 / a23 + b33 / a33

proc `/`*(m: Mat4, f: float): Mat4 =
  result = Mat4()
  result[0] = m[0] / f
  result[1] = m[1] / f
  result[2] = m[2] / f
  result[3] = m[3] / f
  result[4] = m[4] / f
  result[5] = m[5] / f
  result[6] = m[6] / f
  result[7] = m[7] / f
  result[8] = m[8] / f
  result[9] = m[9] / f
  result[10] = m[10] / f
  result[11] = m[11] / f
  result[12] = m[12] / f
  result[13] = m[13] / f
  result[14] = m[14] / f
  result[15] = m[15] / f

proc `*`*(m, n: Mat4): Mat4 =
  let
    a00 = m[0]
    a01 = m[1]
    a02 = m[2]
    a03 = m[3]
    a10 = m[4]
    a11 = m[5]
    a12 = m[6]
    a13 = m[7]
    a20 = m[8]
    a21 = m[9]
    a22 = m[10]
    a23 = m[11]
    a30 = m[12]
    a31 = m[13]
    a32 = m[14]
    a33 = m[15]
    b00 = n[0]
    b01 = n[1]
    b02 = n[2]
    b03 = n[3]
    b10 = n[4]
    b11 = n[5]
    b12 = n[6]
    b13 = n[7]
    b20 = n[8]
    b21 = n[9]
    b22 = n[10]
    b23 = n[11]
    b30 = n[12]
    b31 = n[13]
    b32 = n[14]
    b33 = n[15]
  result = Mat4()
  result[0] = b00 * a00 + b01 * a10 + b02 * a20 + b03 * a30
  result[1] = b00 * a01 + b01 * a11 + b02 * a21 + b03 * a31
  result[2] = b00 * a02 + b01 * a12 + b02 * a22 + b03 * a32
  result[3] = b00 * a03 + b01 * a13 + b02 * a23 + b03 * a33
  result[4] = b10 * a00 + b11 * a10 + b12 * a20 + b13 * a30
  result[5] = b10 * a01 + b11 * a11 + b12 * a21 + b13 * a31
  result[6] = b10 * a02 + b11 * a12 + b12 * a22 + b13 * a32
  result[7] = b10 * a03 + b11 * a13 + b12 * a23 + b13 * a33
  result[8] = b20 * a00 + b21 * a10 + b22 * a20 + b23 * a30
  result[9] = b20 * a01 + b21 * a11 + b22 * a21 + b23 * a31
  result[10] = b20 * a02 + b21 * a12 + b22 * a22 + b23 * a32
  result[11] = b20 * a03 + b21 * a13 + b22 * a23 + b23 * a33
  result[12] = b30 * a00 + b31 * a10 + b32 * a20 + b33 * a30
  result[13] = b30 * a01 + b31 * a11 + b32 * a21 + b33 * a31
  result[14] = b30 * a02 + b31 * a12 + b32 * a22 + b33 * a32
  result[15] = b30 * a03 + b31 * a13 + b32 * a23 + b33 * a33

proc `*`*(m: Mat4, f: float): Mat4 =
  result = Mat4()
  result[0] = m[0] * f
  result[1] = m[1] * f
  result[2] = m[2] * f
  result[3] = m[3] * f
  result[4] = m[4] * f
  result[5] = m[5] * f
  result[6] = m[6] * f
  result[7] = m[7] * f
  result[8] = m[8] * f
  result[9] = m[9] * f
  result[10] = m[10] * f
  result[11] = m[11] * f
  result[12] = m[12] * f
  result[13] = m[13] * f
  result[14] = m[14] * f
  result[15] = m[15] * f

proc `*`*(m: Mat4, v: Vec3): Vec3 =
  let x = m[0] * v[0] + m[4] * v[1] + m[8] * v[2] + m[12]
  let y = m[1] * v[0] + m[5] * v[1] + m[9] * v[2] + m[13]
  let z = m[2] * v[0] + m[6] * v[1] + m[10] * v[2] + m[14]
  vec3(x, y, z)

proc `$`*(x: Mat4): string =
  "[" & $x[0] & ", " & $x[1] & ", " & $x[2] & ", " & $x[3] & "\n " &
        $x[4] & ", " & $x[5] & ", " & $x[6] & ", " & $x[7] & "\n " &
        $x[8] & ", " & $x[9] & ", " & $x[10] & ", " & $x[11] & "\n " &
        $x[12] & ", " & $x[13] & ", " & $x[14] & ", " & $x[15] & "]"

proc perspective*(fov, aspect, near, far: GLfloat): Mat4 =
  var
    yScale = 1.0 / tan((PI / 180.0) * fov / 2.0)
    xScale = yScale / aspect
    nearmfar = near - far
  result = Mat4()
  result.m = [
    xScale.float32, 0, 0, 0,
    0, yScale, 0, 0,
    0, 0, (far + near) / nearmfar, -1,
    0, 0, 2 * far * near / nearmfar, 0
  ]

proc scale*(m: Mat4, scale: Vec3): Mat4 =
  result = mat4(m)
  result[0] = m[0] * scale[0]
  result[1] = m[1] * scale[0]
  result[2] = m[2] * scale[0]
  result[3] = m[3] * scale[0]
  result[4] = m[4] * scale[1]
  result[5] = m[5] * scale[1]
  result[6] = m[6] * scale[1]
  result[7] = m[7] * scale[1]
  result[8] = m[8] * scale[2]
  result[9] = m[9] * scale[2]
  result[10] = m[10] * scale[2]
  result[11] = m[11] * scale[2]

proc translate*(m: Mat4, v: Vec3): Mat4 =
  result = mat4(m)
  result[12] = m[0] * v[0] + m[4] * v[1] + m[8] * v[2] + m[12]
  result[13] = m[1] * v[0] + m[5] * v[1] + m[9] * v[2] + m[13]
  result[14] = m[2] * v[0] + m[6] * v[1] + m[10] * v[2] + m[14]
  result[15] = m[3] * v[0] + m[7] * v[1] + m[11] * v[2] + m[15]

proc rotate*(m: Mat4, angle: float32, axis: Vec3): Mat4 =
  let
    a = angle * PI / 180.0
    c = cos(a)
    s = sin(a)
    temp = axis * (1.0 - c)
    # Cache indexing
    a00 = m[0]
    a01 = m[1]
    a02 = m[2]
    a03 = m[3]
    a10 = m[4]
    a11 = m[5]
    a12 = m[6]
    a13 = m[7]
    a20 = m[8]
    a21 = m[9]
    a22 = m[10]
    a23 = m[11]
    # Construct the elements of the rotation matrix
    r00 = c + temp[0] * axis[0]
    r01 = 0 + temp[0] * axis[1] + s * axis[2]
    r02 = 0 + temp[0] * axis[2] - s * axis[1]

    r10 = 0 + temp[1] * axis[0] - s * axis[2]
    r11 = c + temp[1] * axis[1]
    r12 = 0 + temp[1] * axis[2] + s * axis[0]

    r20 = 0 + temp[2] * axis[0] + s * axis[1]
    r21 = 0 + temp[2] * axis[1] - s * axis[0]
    r22 = c + temp[2] * axis[2]

  result = Mat4()
  # Perform rotation-specific matrix multiplication
  result.m = [
    float32 a00 * r00 + a10 * r01 + a20 * r02,
    a01 * r00 + a11 * r01 + a21 * r02,
    a02 * r00 + a12 * r01 + a22 * r02,
    a03 * r00 + a13 * r01 + a23 * r02,

    a00 * r10 + a10 * r11 + a20 * r12,
    a01 * r10 + a11 * r11 + a21 * r12,
    a02 * r10 + a12 * r11 + a22 * r12,
    a03 * r10 + a13 * r11 + a23 * r12,

    a00 * r20 + a10 * r21 + a20 * r22,
    a01 * r20 + a11 * r21 + a21 * r22,
    a02 * r20 + a12 * r21 + a22 * r22,
    a03 * r20 + a13 * r21 + a23 * r22,
    m[12],
    m[13],
    m[14],
    m[15]
  ]

  # result[0] = m[0] * r00 + m[1] * r01 + m[2] * r02
  # result[1] = m[0] * r10 + m[1] * r11 + m[2] * r12
  # result[2] = m[0] * r20 + m[1] * r21 + m[2] * r22
  # result[3] = m[3]
  return result
  #
  #
  #
  #
  # result = mat4(m)
  # var
  #   len = axis.length()
  #   x = axis[0]
  #   y = axis[1]
  #   z = axis[2]
  # if (len > 1):
  #   x /= len
  #   y /= len
  #   z /= len
  # var
  #   theta = angle * PI / 180.0
  #   s = sin(theta)
  #   c = cos(theta)
  #   t = 1 - c
  #
  #   b00 = x * x * t + c
  #   b01 = y * x * t + z * s
  #   b02 = z * x * t - y * s
  #   b10 = x * y * t - z * s
  #   b11 = y * y * t + c
  #   b12 = z * y * t + x * s
  #   b20 = x * z * t + y * s
  #   b21 = y * z * t - x * s
  #   b22 = z * z * t + c
  #
  # result[0] = a00 * b00 + a10 * b01 + a20 * b02
  # result[1] = a01 * b00 + a11 * b01 + a21 * b02
  # result[2] = a02 * b00 + a12 * b01 + a22 * b02
  # result[3] = a03 * b00 + a13 * b01 + a23 * b02
  #
  # result[4] = a00 * b10 + a10 * b11 + a20 * b12
  # result[5] = a01 * b10 + a11 * b11 + a21 * b12
  # result[6] = a02 * b10 + a12 * b11 + a22 * b12
  # result[7] = a03 * b10 + a13 * b11 + a23 * b12
  #
  # result[8] = a00 * b20 + a10 * b21 + a20 * b22
  # result[9] = a01 * b20 + a11 * b21 + a21 * b22
  # result[10] = a02 * b20 + a12 * b21 + a22 * b22
  # result[11] = a03 * b20 + a13 * b21 + a23 * b22

#proc rotateXYZ*(a: Mat4, angles: Vec3) : Mat4 =
#  let
#    phi = angles.p * PI / 180.0
#    theta = angles.y * PI / 180.0
#    sie = angles.r * PI / 180.0
#    a00 = m[0]
#    a01 = m[1]
#    a02 = m[2]
#    a03 = m[3]
#    a10 = m[4]
#    a11 = m[5]
#    a12 = m[6]
#    a13 = m[7]
#    a20 = m[8]
#    a21 = m[9]
#    a22 = m[10]
#    a23 = m[11]
#    a30 = m[12]
#    a31 = m[13]
#    a32 = m[14]
#    a33 = m[15]

#  result = Mat4()
  # Perform rotation-specific matrix multiplication
#  result.m = [
#    float32 a00 * r00 + a10 * r01 + a20 * r02,
#    a01 * r00 + a11 * r01 + a21 * r02,
#    a02 * r00 + a12 * r01 + a22 * r02,
#    a03 * r00 + a13 * r01 + a23 * r02,
#
#    a00 * r10 + a10 * r11 + a20 * r12,
#    a01 * r10 + a11 * r11 + a21 * r12,
#    a02 * r10 + a12 * r11 + a22 * r12,
#    a03 * r10 + a13 * r11 + a23 * r12,
#
#    a00 * r20 + a10 * r21 + a20 * r22,
#    a01 * r20 + a11 * r21 + a21 * r22,
#    a02 * r20 + a12 * r21 + a22 * r22,
#    a03 * r20 + a13 * r21 + a23 * r22,
#    m[12],
#    m[13],
#    m[14],
#    m[15]
#  ]

proc xspace*(view: Mat4): Vec3 = vec3(view[0], view[1], view[2])
proc yspace*(view: Mat4): Vec3 = vec3(view[4], view[5], view[6])
proc zspace*(view: Mat4): Vec3 = vec3(view[8], view[9], view[10])
proc space*(view: Mat4, v: Vec3): Vec3 = vec3(dot(view.xspace, v), dot(view.yspace, v), dot(view.zspace, v))
proc forward*(view: Mat4): Vec3 = normal(view.space(vec3(0, 0, -1)))
proc right*(view: Mat4): Vec3 = normal(cross(view.forward(), vec3(0, 1, 0)))
proc up*(view: Mat4): Vec3 = normal(cross(view.forward(), view.right()) * -1)

proc lookat*(eye, target, up: Vec3): Mat4 =
  let
    z = normal(eye - target)
    x = normal(cross(up, z))
    y = normal(cross(z, x))
  result = Mat4()
  result.m = [
    x[0].GLfloat, x[1], x[2], 0,
    y[0],         y[1], y[2], 0,
    z[0],         z[1], z[2], 0,
    dot(x, eye), dot(y, eye), -dot(z, eye), 1
  ]

proc transpose*(m: Mat4): Mat4 =
# If we are transposing ourselves we can skip a few steps but have to cache some values
  result = Mat4()
  result.m[0] = m[0]
  result.m[4] = m[1]
  result.m[8] = m[2]
  result.m[12] = m[3]

  result.m[1] = m[4]
  result.m[5] = m[5]
  result.m[9] = m[6]
  result.m[13] = m[7]

  result.m[2] = m[8]
  result.m[6] = m[9]
  result.m[10] = m[10]
  result.m[14] = m[11]

  result.m[3] = m[12]
  result.m[7] = m[13]
  result.m[11] = m[14]
  result.m[15] = m[15]

# double mat4_determinant(mat4_t mat) {
#     # Cache the matrix values (makes for huge speed increases!)
#     double a00 = mat[0], a01 = mat[1], a02 = mat[2], a03 = mat[3],
#         a10 = mat[4], a11 = mat[5], a12 = mat[6], a13 = mat[7],
#         a20 = mat[8], a21 = mat[9], a22 = mat[10], a23 = mat[11],
#         a30 = mat[12], a31 = mat[13], a32 = mat[14], a33 = mat[15]
#
#     return (a30 * a21 * a12 * a03 - a20 * a31 * a12 * a03 - a30 * a11 * a22 * a03 + a10 * a31 * a22 * a03 +
#             a20 * a11 * a32 * a03 - a10 * a21 * a32 * a03 - a30 * a21 * a02 * a13 + a20 * a31 * a02 * a13 +
#             a30 * a01 * a22 * a13 - a00 * a31 * a22 * a13 - a20 * a01 * a32 * a13 + a00 * a21 * a32 * a13 +
#             a30 * a11 * a02 * a23 - a10 * a31 * a02 * a23 - a30 * a01 * a12 * a23 + a00 * a31 * a12 * a23 +
#             a10 * a01 * a32 * a23 - a00 * a11 * a32 * a23 - a20 * a11 * a02 * a33 + a10 * a21 * a02 * a33 +
#             a20 * a01 * a12 * a33 - a00 * a21 * a12 * a33 - a10 * a01 * a22 * a33 + a00 * a11 * a22 * a33)
# }
#
proc inverse*(m:Mat4): Mat4 =
  # Cache the matrix values (makes for huge speed increases!)
  result = Mat4()
  let
    a00 = m[0]
    a01 = m[1]
    a02 = m[2]
    a03 = m[3]
    a10 = m[4]
    a11 = m[5]
    a12 = m[6]
    a13 = m[7]
    a20 = m[8]
    a21 = m[9]
    a22 = m[10]
    a23 = m[11]
    a30 = m[12]
    a31 = m[13]
    a32 = m[14]
    a33 = m[15]

    b00 = a00 * a11 - a01 * a10
    b01 = a00 * a12 - a02 * a10
    b02 = a00 * a13 - a03 * a10
    b03 = a01 * a12 - a02 * a11
    b04 = a01 * a13 - a03 * a11
    b05 = a02 * a13 - a03 * a12
    b06 = a20 * a31 - a21 * a30
    b07 = a20 * a32 - a22 * a30
    b08 = a20 * a33 - a23 * a30
    b09 = a21 * a32 - a22 * a31
    b10 = a21 * a33 - a23 * a31
    b11 = a22 * a33 - a23 * a32

    d = (b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06)

    invDet = 1 / d

  result.m[0] = (a11 * b11 - a12 * b10 + a13 * b09) * invDet
  result.m[1] = (-a01 * b11 + a02 * b10 - a03 * b09) * invDet
  result.m[2] = (a31 * b05 - a32 * b04 + a33 * b03) * invDet
  result.m[3] = (-a21 * b05 + a22 * b04 - a23 * b03) * invDet
  result.m[4] = (-a10 * b11 + a12 * b08 - a13 * b07) * invDet
  result.m[5] = (a00 * b11 - a02 * b08 + a03 * b07) * invDet
  result.m[6] = (-a30 * b05 + a32 * b02 - a33 * b01) * invDet
  result.m[7] = (a20 * b05 - a22 * b02 + a23 * b01) * invDet
  result.m[8] = (a10 * b10 - a11 * b08 + a13 * b06) * invDet
  result.m[9] = (-a00 * b10 + a01 * b08 - a03 * b06) * invDet
  result.m[10] = (a30 * b04 - a31 * b02 + a33 * b00) * invDet
  result.m[11] = (-a20 * b04 + a21 * b02 - a23 * b00) * invDet
  result.m[12] = (-a10 * b09 + a11 * b07 - a12 * b06) * invDet
  result.m[13] = (a00 * b09 - a01 * b07 + a02 * b06) * invDet
  result.m[14] = (-a30 * b03 + a31 * b01 - a32 * b00) * invDet
  result.m[15] = (a20 * b03 - a21 * b01 + a22 * b00) * invDet


#
# mat4_t mat4_toRotationMat(mat4_t mat, mat4_t dest) {
#     if (!dest) { dest = mat4_create(NULL) }
#
#     dest[0] = mat[0]
#     dest[1] = mat[1]
#     dest[2] = mat[2]
#     dest[3] = mat[3]
#     dest[4] = mat[4]
#     dest[5] = mat[5]
#     dest[6] = mat[6]
#     dest[7] = mat[7]
#     dest[8] = mat[8]
#     dest[9] = mat[9]
#     dest[10] = mat[10]
#     dest[11] = mat[11]
#     dest[12] = 0
#     dest[13] = 0
#     dest[14] = 0
#     dest[15] = 1
#
#     return dest
# }
#
# mat3_t mat4_toMat3(mat4_t mat, mat3_t dest) {
#     if (!dest) { dest = mat3_create(NULL) }
#
#     dest[0] = mat[0]
#     dest[1] = mat[1]
#     dest[2] = mat[2]
#     dest[3] = mat[4]
#     dest[4] = mat[5]
#     dest[5] = mat[6]
#     dest[6] = mat[8]
#     dest[7] = mat[9]
#     dest[8] = mat[10]
#
#     return dest
# }
#
# mat3_t mat4_toInverseMat3(mat4_t mat, mat3_t dest) {
#     # Cache the matrix values (makes for huge speed increases!)
#     double a00 = mat[0], a01 = mat[1], a02 = mat[2],
#         a10 = mat[4], a11 = mat[5], a12 = mat[6],
#         a20 = mat[8], a21 = mat[9], a22 = mat[10],
#
#         b01 = a22 * a11 - a12 * a21,
#         b11 = -a22 * a10 + a12 * a20,
#         b21 = a21 * a10 - a11 * a20,
#
#         d = a00 * b01 + a01 * b11 + a02 * b21,
#         id
#
#     if (!d) { return NULL }
#     id = 1 / d
#
#     if (!dest) { dest = mat3_create(NULL) }
#
#     dest[0] = b01 * id
#     dest[1] = (-a22 * a01 + a02 * a21) * id
#     dest[2] = (a12 * a01 - a02 * a11) * id
#     dest[3] = b11 * id
#     dest[4] = (a22 * a00 - a02 * a20) * id
#     dest[5] = (-a12 * a00 + a02 * a10) * id
#     dest[6] = b21 * id
#     dest[7] = (-a21 * a00 + a01 * a20) * id
#     dest[8] = (a11 * a00 - a01 * a10) * id
#
#     return dest
# }
#
# mat4_t mat4_multiply(mat4_t mat, mat4_t mat2, mat4_t dest) {
#     if (!dest) { dest = mat }
#
#     # Cache the matrix values (makes for huge speed increases!)
#     double a00 = mat[0], a01 = mat[1], a02 = mat[2], a03 = mat[3],
#         a10 = mat[4], a11 = mat[5], a12 = mat[6], a13 = mat[7],
#         a20 = mat[8], a21 = mat[9], a22 = mat[10], a23 = mat[11],
#         a30 = mat[12], a31 = mat[13], a32 = mat[14], a33 = mat[15],
#
#         b00 = mat2[0], b01 = mat2[1], b02 = mat2[2], b03 = mat2[3],
#         b10 = mat2[4], b11 = mat2[5], b12 = mat2[6], b13 = mat2[7],
#         b20 = mat2[8], b21 = mat2[9], b22 = mat2[10], b23 = mat2[11],
#         b30 = mat2[12], b31 = mat2[13], b32 = mat2[14], b33 = mat2[15]
#
#     dest[0] = b00 * a00 + b01 * a10 + b02 * a20 + b03 * a30
#     dest[1] = b00 * a01 + b01 * a11 + b02 * a21 + b03 * a31
#     dest[2] = b00 * a02 + b01 * a12 + b02 * a22 + b03 * a32
#     dest[3] = b00 * a03 + b01 * a13 + b02 * a23 + b03 * a33
#     dest[4] = b10 * a00 + b11 * a10 + b12 * a20 + b13 * a30
#     dest[5] = b10 * a01 + b11 * a11 + b12 * a21 + b13 * a31
#     dest[6] = b10 * a02 + b11 * a12 + b12 * a22 + b13 * a32
#     dest[7] = b10 * a03 + b11 * a13 + b12 * a23 + b13 * a33
#     dest[8] = b20 * a00 + b21 * a10 + b22 * a20 + b23 * a30
#     dest[9] = b20 * a01 + b21 * a11 + b22 * a21 + b23 * a31
#     dest[10] = b20 * a02 + b21 * a12 + b22 * a22 + b23 * a32
#     dest[11] = b20 * a03 + b21 * a13 + b22 * a23 + b23 * a33
#     dest[12] = b30 * a00 + b31 * a10 + b32 * a20 + b33 * a30
#     dest[13] = b30 * a01 + b31 * a11 + b32 * a21 + b33 * a31
#     dest[14] = b30 * a02 + b31 * a12 + b32 * a22 + b33 * a32
#     dest[15] = b30 * a03 + b31 * a13 + b32 * a23 + b33 * a33
#
#     return dest
# }
#
# mat4_t mat4_multiplyVec3(mat4_t mat, vec3_t vec, mat4_t dest) {
#     if (!dest) { dest = vec }
#
#     double x = vec[0], y = vec[1], z = vec[2]
#
#     dest[0] = mat[0] * x + mat[4] * y + mat[8] * z + mat[12]
#     dest[1] = mat[1] * x + mat[5] * y + mat[9] * z + mat[13]
#     dest[2] = mat[2] * x + mat[6] * y + mat[10] * z + mat[14]
#
#     return dest
# }
#
# mat4_t mat4_multiplyVec4(mat4_t mat, vec4_t vec, mat4_t dest) {
#     if (!dest) { dest = vec }
#
#     double x = vec[0], y = vec[1], z = vec[2], w = vec[3]
#
#     dest[0] = mat[0] * x + mat[4] * y + mat[8] * z + mat[12] * w
#     dest[1] = mat[1] * x + mat[5] * y + mat[9] * z + mat[13] * w
#     dest[2] = mat[2] * x + mat[6] * y + mat[10] * z + mat[14] * w
#     dest[3] = mat[3] * x + mat[7] * y + mat[11] * z + mat[15] * w
#
#     return dest
# }
#
# mat4_t mat4_translate(mat4_t mat, vec3_t vec, mat4_t dest) {
#     double x = vec[0], y = vec[1], z = vec[2],
#         a00, a01, a02, a03,
#         a10, a11, a12, a13,
#         a20, a21, a22, a23
#
#     if (!dest || mat == dest) {
#         mat[12] = mat[0] * x + mat[4] * y + mat[8] * z + mat[12]
#         mat[13] = mat[1] * x + mat[5] * y + mat[9] * z + mat[13]
#         mat[14] = mat[2] * x + mat[6] * y + mat[10] * z + mat[14]
#         mat[15] = mat[3] * x + mat[7] * y + mat[11] * z + mat[15]
#         return mat
#     }
#
#     a00 = mat[0] a01 = mat[1] a02 = mat[2] a03 = mat[3]
#     a10 = mat[4] a11 = mat[5] a12 = mat[6] a13 = mat[7]
#     a20 = mat[8] a21 = mat[9] a22 = mat[10] a23 = mat[11]
#
#     dest[0] = a00 dest[1] = a01 dest[2] = a02 dest[3] = a03
#     dest[4] = a10 dest[5] = a11 dest[6] = a12 dest[7] = a13
#     dest[8] = a20 dest[9] = a21 dest[10] = a22 dest[11] = a23
#
#     dest[12] = a00 * x + a10 * y + a20 * z + mat[12]
#     dest[13] = a01 * x + a11 * y + a21 * z + mat[13]
#     dest[14] = a02 * x + a12 * y + a22 * z + mat[14]
#     dest[15] = a03 * x + a13 * y + a23 * z + mat[15]
#     return dest
# }
#
# mat4_t mat4_scale(mat4_t mat, vec3_t vec, mat4_t dest) {
#     double x = vec[0], y = vec[1], z = vec[2]
#
#     if (!dest || mat == dest) {
#         mat[0] *= x
#         mat[1] *= x
#         mat[2] *= x
#         mat[3] *= x
#         mat[4] *= y
#         mat[5] *= y
#         mat[6] *= y
#         mat[7] *= y
#         mat[8] *= z
#         mat[9] *= z
#         mat[10] *= z
#         mat[11] *= z
#         return mat
#     }
#
#     dest[0] = mat[0] * x
#     dest[1] = mat[1] * x
#     dest[2] = mat[2] * x
#     dest[3] = mat[3] * x
#     dest[4] = mat[4] * y
#     dest[5] = mat[5] * y
#     dest[6] = mat[6] * y
#     dest[7] = mat[7] * y
#     dest[8] = mat[8] * z
#     dest[9] = mat[9] * z
#     dest[10] = mat[10] * z
#     dest[11] = mat[11] * z
#     dest[12] = mat[12]
#     dest[13] = mat[13]
#     dest[14] = mat[14]
#     dest[15] = mat[15]
#     return dest
# }
#
# mat4_t mat4_rotate(mat4_t mat, double angle, vec3_t axis, mat4_t dest) {
#     double x = axis[0], y = axis[1], z = axis[2],
#         len = sqrt(x * x + y * y + z * z),
#         s, c, t,
#         a00, a01, a02, a03,
#         a10, a11, a12, a13,
#         a20, a21, a22, a23,
#         b00, b01, b02,
#         b10, b11, b12,
#         b20, b21, b22
#
#     if (!len) { return NULL }
#     if (len != 1) {
#         len = 1 / len
#         x *= len
#         y *= len
#         z *= len
#     }
#
#     s = sin(angle)
#     c = cos(angle)
#     t = 1 - c
#
#     a00 = mat[0] a01 = mat[1] a02 = mat[2] a03 = mat[3]
#     a10 = mat[4] a11 = mat[5] a12 = mat[6] a13 = mat[7]
#     a20 = mat[8] a21 = mat[9] a22 = mat[10] a23 = mat[11]
#
#     # Construct the elements of the rotation matrix
#     b00 = x * x * t + c b01 = y * x * t + z * s b02 = z * x * t - y * s
#     b10 = x * y * t - z * s b11 = y * y * t + c b12 = z * y * t + x * s
#     b20 = x * z * t + y * s b21 = y * z * t - x * s b22 = z * z * t + c
#
#     if (!dest) {
#         dest = mat
#     } else if (mat != dest) { # If the source and destination differ, copy the unchanged last row
#         dest[12] = mat[12]
#         dest[13] = mat[13]
#         dest[14] = mat[14]
#         dest[15] = mat[15]
#     }
#
#     # Perform rotation-specific matrix multiplication
#     dest[0] = a00 * b00 + a10 * b01 + a20 * b02
#     dest[1] = a01 * b00 + a11 * b01 + a21 * b02
#     dest[2] = a02 * b00 + a12 * b01 + a22 * b02
#     dest[3] = a03 * b00 + a13 * b01 + a23 * b02
#
#     dest[4] = a00 * b10 + a10 * b11 + a20 * b12
#     dest[5] = a01 * b10 + a11 * b11 + a21 * b12
#     dest[6] = a02 * b10 + a12 * b11 + a22 * b12
#     dest[7] = a03 * b10 + a13 * b11 + a23 * b12
#
#     dest[8] = a00 * b20 + a10 * b21 + a20 * b22
#     dest[9] = a01 * b20 + a11 * b21 + a21 * b22
#     dest[10] = a02 * b20 + a12 * b21 + a22 * b22
#     dest[11] = a03 * b20 + a13 * b21 + a23 * b22
#     return dest
# }
#
# mat4_t mat4_rotateX(mat4_t mat, double angle, mat4_t dest) {
#     double s = sin(angle),
#         c = cos(angle),
#         a10 = mat[4],
#         a11 = mat[5],
#         a12 = mat[6],
#         a13 = mat[7],
#         a20 = mat[8],
#         a21 = mat[9],
#         a22 = mat[10],
#         a23 = mat[11]
#
#     if (!dest) {
#         dest = mat
#     } else if (mat != dest) { # If the source and destination differ, copy the unchanged rows
#         dest[0] = mat[0]
#         dest[1] = mat[1]
#         dest[2] = mat[2]
#         dest[3] = mat[3]
#
#         dest[12] = mat[12]
#         dest[13] = mat[13]
#         dest[14] = mat[14]
#         dest[15] = mat[15]
#     }
#
#     # Perform axis-specific matrix multiplication
#     dest[4] = a10 * c + a20 * s
#     dest[5] = a11 * c + a21 * s
#     dest[6] = a12 * c + a22 * s
#     dest[7] = a13 * c + a23 * s
#
#     dest[8] = a10 * -s + a20 * c
#     dest[9] = a11 * -s + a21 * c
#     dest[10] = a12 * -s + a22 * c
#     dest[11] = a13 * -s + a23 * c
#     return dest
# }
#
# mat4_t mat4_rotateY(mat4_t mat, double angle, mat4_t dest) {
#     double s = sin(angle),
#         c = cos(angle),
#         a00 = mat[0],
#         a01 = mat[1],
#         a02 = mat[2],
#         a03 = mat[3],
#         a20 = mat[8],
#         a21 = mat[9],
#         a22 = mat[10],
#         a23 = mat[11]
#
#     if (!dest) {
#         dest = mat
#     } else if (mat != dest) { # If the source and destination differ, copy the unchanged rows
#         dest[4] = mat[4]
#         dest[5] = mat[5]
#         dest[6] = mat[6]
#         dest[7] = mat[7]
#
#         dest[12] = mat[12]
#         dest[13] = mat[13]
#         dest[14] = mat[14]
#         dest[15] = mat[15]
#     }
#
#     # Perform axis-specific matrix multiplication
#     dest[0] = a00 * c + a20 * -s
#     dest[1] = a01 * c + a21 * -s
#     dest[2] = a02 * c + a22 * -s
#     dest[3] = a03 * c + a23 * -s
#
#     dest[8] = a00 * s + a20 * c
#     dest[9] = a01 * s + a21 * c
#     dest[10] = a02 * s + a22 * c
#     dest[11] = a03 * s + a23 * c
#     return dest
# }
#
# mat4_t mat4_rotateZ(mat4_t mat, double angle, mat4_t dest) {
#     double s = sin(angle),
#         c = cos(angle),
#         a00 = mat[0],
#         a01 = mat[1],
#         a02 = mat[2],
#         a03 = mat[3],
#         a10 = mat[4],
#         a11 = mat[5],
#         a12 = mat[6],
#         a13 = mat[7]
#
#     if (!dest) {
#         dest = mat
#     } else if (mat != dest) { # If the source and destination differ, copy the unchanged last row
#         dest[8] = mat[8]
#         dest[9] = mat[9]
#         dest[10] = mat[10]
#         dest[11] = mat[11]
#
#         dest[12] = mat[12]
#         dest[13] = mat[13]
#         dest[14] = mat[14]
#         dest[15] = mat[15]
#     }
#
#     # Perform axis-specific matrix multiplication
#     dest[0] = a00 * c + a10 * s
#     dest[1] = a01 * c + a11 * s
#     dest[2] = a02 * c + a12 * s
#     dest[3] = a03 * c + a13 * s
#
#     dest[4] = a00 * -s + a10 * c
#     dest[5] = a01 * -s + a11 * c
#     dest[6] = a02 * -s + a12 * c
#     dest[7] = a03 * -s + a13 * c
#
#     return dest
# }
#
# mat4_t mat4_frustum(double left, double right, double bottom, double top, double near, double far, mat4_t dest) {
#     if (!dest) { dest = mat4_create(NULL) }
#     double rl = (right - left),
#         tb = (top - bottom),
#         fn = (far - near)
#     dest[0] = (near * 2) / rl
#     dest[1] = 0
#     dest[2] = 0
#     dest[3] = 0
#     dest[4] = 0
#     dest[5] = (near * 2) / tb
#     dest[6] = 0
#     dest[7] = 0
#     dest[8] = (right + left) / rl
#     dest[9] = (top + bottom) / tb
#     dest[10] = -(far + near) / fn
#     dest[11] = -1
#     dest[12] = 0
#     dest[13] = 0
#     dest[14] = -(far * near * 2) / fn
#     dest[15] = 0
#     return dest
# }
#
# mat4_t mat4_perspective(double fovy, double aspect, double near, double far, mat4_t dest) {
#     double top = near * tan(fovy * M_PI / 360.0),
#         right = top * aspect
#     return mat4_frustum(-right, right, -top, top, near, far, dest)
# }
#
# mat4_t mat4_ortho(double left, double right, double bottom, double top, double near, double far, mat4_t dest) {
#     if (!dest) { dest = mat4_create(NULL) }
#     double rl = (right - left),
#         tb = (top - bottom),
#         fn = (far - near)
#     dest[0] = 2 / rl
#     dest[1] = 0
#     dest[2] = 0
#     dest[3] = 0
#     dest[4] = 0
#     dest[5] = 2 / tb
#     dest[6] = 0
#     dest[7] = 0
#     dest[8] = 0
#     dest[9] = 0
#     dest[10] = -2 / fn
#     dest[11] = 0
#     dest[12] = -(left + right) / rl
#     dest[13] = -(top + bottom) / tb
#     dest[14] = -(far + near) / fn
#     dest[15] = 1
#     return dest
# }
#
# mat4_t mat4_lookAt(vec3_t eye, vec3_t center, vec3_t up, mat4_t dest) {
#     if (!dest) { dest = mat4_create(NULL) }
#
#     double x0, x1, x2, y0, y1, y2, z0, z1, z2, len,
#         ex = eye[0],
#         ey = eye[1],
#         ez = eye[2],
#         ux = up[0],
#         uy = up[1],
#         uz = up[2],
#         ox = center[0],
#         oy = center[1],
#         oz = center[2]
#
#     if (ex == ox && ey == oy && ez == oz) {
#         return mat4_identity(dest)
#     }
#
#     #vec3.direction(eye, center, z)
#     z0 = ex - ox
#     z1 = ey - oy
#     z2 = ez - oz
#
#     # normal (no check needed for 0 because of early return)
#     len = 1 / sqrt(z0 * z0 + z1 * z1 + z2 * z2)
#     z0 *= len
#     z1 *= len
#     z2 *= len
#
#     #vec3.normal(vec3.cross(up, z, x))
#     x0 = uy * z2 - uz * z1
#     x1 = uz * z0 - ux * z2
#     x2 = ux * z1 - uy * z0
#     len = sqrt(x0 * x0 + x1 * x1 + x2 * x2)
#     if (!len) {
#         x0 = 0
#         x1 = 0
#         x2 = 0
#     } else {
#         len = 1 / len
#         x0 *= len
#         x1 *= len
#         x2 *= len
#     }
#
#     #vec3.normal(vec3.cross(z, x, y))
#     y0 = z1 * x2 - z2 * x1
#     y1 = z2 * x0 - z0 * x2
#     y2 = z0 * x1 - z1 * x0
#
#     len = sqrt(y0 * y0 + y1 * y1 + y2 * y2)
#     if (!len) {
#         y0 = 0
#         y1 = 0
#         y2 = 0
#     } else {
#         len = 1 / len
#         y0 *= len
#         y1 *= len
#         y2 *= len
#     }
#
#     dest[0] = x0
#     dest[1] = y0
#     dest[2] = z0
#     dest[3] = 0
#     dest[4] = x1
#     dest[5] = y1
#     dest[6] = z1
#     dest[7] = 0
#     dest[8] = x2
#     dest[9] = y2
#     dest[10] = z2
#     dest[11] = 0
#     dest[12] = -(x0 * ex + x1 * ey + x2 * ez)
#     dest[13] = -(y0 * ex + y1 * ey + y2 * ez)
#     dest[14] = -(z0 * ex + z1 * ey + z2 * ez)
#     dest[15] = 1
#
#     return dest
# }
#
# mat4_t mat4_fromRotationTranslation(quat_t quat, vec3_t vec, mat4_t dest) {
#     if (!dest) { dest = mat4_create(NULL) }
#
#     # Quaternion math
#     double x = quat[0], y = quat[1], z = quat[2], w = quat[3],
#         x2 = x + x,
#         y2 = y + y,
#         z2 = z + z,
#
#         xx = x * x2,
#         xy = x * y2,
#         xz = x * z2,
#         yy = y * y2,
#         yz = y * z2,
#         zz = z * z2,
#         wx = w * x2,
#         wy = w * y2,
#         wz = w * z2
#
#     dest[0] = 1 - (yy + zz)
#     dest[1] = xy + wz
#     dest[2] = xz - wy
#     dest[3] = 0
#     dest[4] = xy - wz
#     dest[5] = 1 - (xx + zz)
#     dest[6] = yz + wx
#     dest[7] = 0
#     dest[8] = xz + wy
#     dest[9] = yz - wx
#     dest[10] = 1 - (xx + yy)
#     dest[11] = 0
#     dest[12] = vec[0]
#     dest[13] = vec[1]
#     dest[14] = vec[2]
#     dest[15] = 1
#
#     return dest
# }
