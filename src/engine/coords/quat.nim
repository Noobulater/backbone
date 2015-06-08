#Written by Aaron Bentley
import math, complex

type Quat* = object
  d*: array[4, float]

proc quat*(x, y, z, w: float): Quat =
  result = Quat()
  result.d = [x, y, z, w]

proc quat*(x, y, z, w: int): Quat =
  result = Quat()
  result.d = [x.float, y.float, z.float, w.float]

proc quat*(f: float): Quat = quat(f, f, f, f)
proc quat*(f: int): Quat =
  let x = f.float
  quat(x, x, x, x)

proc quat*(f: varargs[float]): Quat =
  quat(f[0], f[1], f[2], f[3])

proc `[]`*(v: Quat, i: int): float = v.d[i]
proc `[]=`*(v: var Quat, i: int, x: float) = v.d[i] = x
proc `==`*(a, b: Quat): bool = a[0] == b[0] and a[1] == b[1] and a[2] == b[2]
proc `==`*(a:Quat, b: float): bool = a[0] == b and a[1] == b and a[2] == b
proc `!=`*(a, b: Quat): bool = a[0] != b[0] or a[1] != b[1] or a[2] != b[2]
proc `!=`*(a:Quat, b: float): bool = a[0] != b or a[1] != b or a[2] != b
proc `+=`*(a: var Quat, b: Quat) =
  a[0] = a[0] + b[0]
  a[1] = a[1] + b[1]
  a[2] = a[2] + b[2]
  a[3] = a[3] + b[3]
proc `-=`*(a: var Quat, b: Quat) =
  a[0] = a[0] - b[0]
  a[1] = a[1] - b[1]
  a[2] = a[2] - b[2]
  a[3] = a[3] - b[3]
proc `*=`*(a: var Quat, b: Quat) =
  a[0] = a[0] * b[0]
  a[1] = a[1] * b[1]
  a[2] = a[2] * b[2]
  a[3] = a[3] * b[3]
proc `*=`*(a: var Quat, s: float) =
  a[0] = a[0] * s
  a[1] = a[1] * s
  a[2] = a[2] * s
  a[3] = a[3] * s
proc `/=`*(a: var Quat, b: Quat) =
  a[0] = a[0] / b[0]
  a[1] = a[1] / b[1]
  a[2] = a[2] / b[2]
  a[3] = a[3] / b[3]
proc `/=`*(a: var Quat, s: float) =
  a[0] = a[0] / s
  a[1] = a[1] / s
  a[2] = a[2] / s
  a[3] = a[3] / s
proc `x`*(v: Quat): float = v[0]
proc `y`*(v: Quat): float = v[1]
proc `z`*(v: Quat): float = v[2]
proc `w`*(v: Quat): float = v[3]
proc `x=`*(v: var Quat, n: float): float = v[0] = n
proc `y=`*(v: var Quat, n: float): float = v[1] = n
proc `z=`*(v: var Quat, n: float): float = v[2] = n
proc `w=`*(v: var Quat, n: float): float = v[2] = n
proc `x=`*(v: var Quat, n: int) = v[0] = n.float
proc `y=`*(v: var Quat, n: int) = v[1] = n.float
proc `z=`*(v: var Quat, n: int) = v[2] = n.float
proc `w=`*(v: var Quat, n: int) = v[3] = n.float

proc `+`*(a, b: Quat): Quat = quat(a[0] + b[0], a[1] + b[1], a[2] + b[2], a[3] + b[3])
proc `-`*(a, b: Quat): Quat = quat(a[0] - b[0], a[1] - b[1], a[2] - b[2], a[3] - b[3])
proc `*`*(a, b: Quat): Quat = quat(a[0] * b[0], a[1] * b[1], a[2] * b[2], a[3] * b[3])
proc `*`*(a: Quat, s: float): Quat = quat(a[0] * s, a[1] * s, a[2] * s, a[3] * s)
proc `/`*(a, b: Quat): Quat = quat(a[0] / b[0], a[1] / b[1], a[2] / b[2], a[3] / b[3])
proc `$`*(v: Quat): string = "(" & $v[0] & ", " & $v[1] & ", " & $v[2] & ", "& $v[3] &")"
proc `&`*(s: string, v: Quat): string = s & $v
proc `&`*(v: Quat, s: string): string = $v & s


proc length2*(v: Quat): float = v[0] * v[0] + v[1] * v[1] + v[2] * v[2] + v[3] * v[3]
proc length*(v: Quat): float = sqrt(v.length2())

proc normalize*(v: var Quat) =
  let len = v.length
  if (len != 0):
    v /= len
proc normal*(v: Quat): Quat =
  let len = length(v)
  if (len == 0): quat(0.0, 0.0, 0.0, 0.0)
  else: quat(v[0] / len, v[1] / len, v[2] / len, v[3] / len)
