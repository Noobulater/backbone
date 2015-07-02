#Written by Matt Nichols
#Modified by Aaron Bentley
import math, complex

type Vec3* = object
  d*: array[3, float]

proc vec3*(x, y, z: float): Vec3 =
  result = Vec3()
  result.d = [x, y, z]

proc vec3*(x, y, z: int): Vec3 =
  result = Vec3()
  result.d = [x.float, y.float, z.float]

proc vec3*(f: float): Vec3 = vec3(f, f, f)
proc vec3*(f: int): Vec3 =
  let x = f.float
  vec3(x, x, x)

proc vec3*(v: Vec3): Vec3 =
  result = Vec3()
  result.d = v.d

proc vec3*(f: varargs[float]): Vec3 =
  vec3(f[0], f[1], f[2])

proc `[]`*(v: Vec3, i: int): float = v.d[i]
proc `[]=`*(v: var Vec3, i: int, x: float) = v.d[i] = x
proc `==`*(a, b: Vec3): bool = a[0] == b[0] and a[1] == b[1] and a[2] == b[2]
proc `==`*(a:Vec3, b: float): bool = a[0] == b and a[1] == b and a[2] == b
proc `!=`*(a, b: Vec3): bool = a[0] != b[0] or a[1] != b[1] or a[2] != b[2]
proc `!=`*(a:Vec3, b: float): bool = a[0] != b or a[1] != b or a[2] != b
proc `+=`*(a: var Vec3, b: Vec3) =
  a[0] = a[0] + b[0]
  a[1] = a[1] + b[1]
  a[2] = a[2] + b[2]
proc `-=`*(a: var Vec3, b: Vec3) =
  a[0] = a[0] - b[0]
  a[1] = a[1] - b[1]
  a[2] = a[2] - b[2]
proc `*=`*(a: var Vec3, b: Vec3) =
  a[0] = a[0] * b[0]
  a[1] = a[1] * b[1]
  a[2] = a[2] * b[2]
proc `*=`*(a: var Vec3, s: float) =
  a[0] = a[0] * s
  a[1] = a[1] * s
  a[2] = a[2] * s
proc `/=`*(a: var Vec3, b: Vec3) =
  a[0] = a[0] / b[0]
  a[1] = a[1] / b[1]
  a[2] = a[2] / b[2]
proc `/=`*(a: var Vec3, s: float) =
  a[0] = a[0] / s
  a[1] = a[1] / s
  a[2] = a[2] / s
proc `x`*(v: Vec3): float = v[0]
proc `y`*(v: Vec3): float = v[1]
proc `z`*(v: Vec3): float = v[2]
proc `x=`*(v: var Vec3, n: float): float = v[0] = n
proc `y=`*(v: var Vec3, n: float): float = v[1] = n
proc `z=`*(v: var Vec3, n: float): float = v[2] = n
proc `x=`*(v: var Vec3, n: int) = v[0] = n.float
proc `y=`*(v: var Vec3, n: int) = v[1] = n.float
proc `z=`*(v: var Vec3, n: int) = v[2] = n.float
# ANGLE STUFF
proc `p=`*(v: var Vec3, n: float): float = v[0] = n
proc `r=`*(v: var Vec3, n: float): float = v[2] = n
proc `p=`*(v: var Vec3, n: int) = v[0] = n.float
proc `r=`*(v: var Vec3, n: int) = v[2] = n.float
proc `p`*(v: Vec3): float = v[0]
proc `r`*(v: Vec3): float = v[2]

proc `+`*(a, b: Vec3): Vec3 = vec3(a[0] + b[0], a[1] + b[1], a[2] + b[2])
proc `-`*(a, b: Vec3): Vec3 = vec3(a[0] - b[0], a[1] - b[1], a[2] - b[2])
proc `*`*(a, b: Vec3): Vec3 = vec3(a[0] * b[0], a[1] * b[1], a[2] * b[2])
proc `*`*(a: Vec3, s: float): Vec3 = vec3(a[0] * s, a[1] * s, a[2] * s)
proc `/`*(a, b: Vec3): Vec3 = vec3(a[0] / b[0], a[1] / b[1], a[2] / b[2])
proc `$`*(v: Vec3): string = "(" & $v[0] & ", " & $v[1] & ", " & $v[2] & ")"
proc `&`*(s: string, v: Vec3): string = s & $v
proc `&`*(v: Vec3, s: string): string = $v & s

proc length2*(v: Vec3): float = v[0] * v[0] + v[1] * v[1] + v[2] * v[2]
proc length*(v: Vec3): float = sqrt(v.length2())

proc normalize*(v: var Vec3) =
  let len = v.length
  if (len != 0):
    v /= len
proc normal*(v: Vec3): Vec3 =
  let len = length(v)
  if (len == 0): vec3(0.0, 0.0, 0.0)
  else: vec3(v[0] / len, v[1] / len, v[2] / len)

proc dot*(a, b: Vec3): float = a[0] * b[0] + a[1] * b[1] + a[2] * b[2]
proc normDot(a, b: Vec3): float = dot(normal(a), normal(b))

proc cross*(a, b: Vec3): Vec3 = vec3(
  a[1]*b[2] - a[2]*b[1],
  a[2]*b[0] - a[0]*b[2],
  a[0]*b[1] - a[1]*b[0])

proc max*(a,b: Vec3): Vec3 =
  for i in low(a.d)..high(a.d) :
    if (a[i] > b[i]) :
      result[i] = a[i]
    else :
      result[i] = b[i]

proc absMaxValue*(a: Vec3): float =
  result = abs(a[0])
  for i in 1..high(a.d) : #skip the first compare to save cylces
    if (abs(a[i]) > result) :
      result = abs(a[i])

proc maxValue*(a: Vec3): float =
  result = a[0]
  for i in 1..high(a.d) : #skip the first compare to save cylces
    if (a[i] > result) :
      result = a[i]

proc minValue*(a: Vec3): float =
  result = a[0]
  for i in 1..high(a.d) : #skip the first compare to save cylces
    if (a[i] < result) :
      result = a[i]

proc dSquared*(a,b: Vec3): float = #cheap af
  let r = (b - a)*(b - a)
  return r.x + r.y + r.z

proc distance*(a,b: Vec3): float =
  return sqrt(dSquared(a,b))

proc abs*(a: Vec3): Vec3 =
  result = vec3(a[0],a[1],a[2])
  for i in 0..high(a.d) : #skip the first compare to save cylces
    if (a[i] < 0) :
      result[i] = a[i] * -1

proc clampHigh*(a: Vec3, amt: float): Vec3 =
  result = vec3(a[0],a[1],a[2])
  for i in 0..high(a.d) : #skip the first compare to save cylces
    if (a[i] > amt) :
      result[i] = amt

proc clampLow*(a: Vec3, amt: float): Vec3 =
  result = vec3(a[0],a[1],a[2])
  for i in 0..high(a.d) : #skip the first compare to save cylces
    if (a[i] < amt) :
      result[i] = amt

proc clamp*(a: Vec3, lowamt, highamt: float): Vec3 =
  result = vec3(a[0],a[1],a[2])
  for i in 0..high(a.d) : #skip the first compare to save cylces
    if (a[i] > highamt) :
      result[i] = highamt
    if (a[i] < lowamt) :
      result[i] = lowamt
      
proc clampXYZamp*(a: Vec3, xamt, yamt, zamt: float): Vec3 =
  result = vec3(a[0],a[1],a[2])
  if (a[0] > xamt) :
    result[0] = xamt
  elif (a[0] < -xamt) :
    result[0] = -xamt

  if (a[1] > yamt) :
    result[1] = yamt
  elif (a[1] < -yamt) :
    result[1] = -yamt

  if (a[2] > zamt) :
    result[2] = zamt
  elif (a[2] < -zamt) :
    result[2] = -zamt

when isMainModule:
  proc test(cond: bool, name: string) =
    if (cond): echo("  PASSED: " & name)
    else: echo("FAILED: " & name)
    # assert(cond, name)
  proc testEqual(value, expected, name) =
    test(value == expected, $name & " expected " & $expected & " got " & $value)

  block:
    test(vec3(1.2, 2.4, 3.6) == vec3(1.2, 2.4, 3.6), "vec3 equality")
    test(vec3(1.2, 2.4, 3.6) != vec3(3.6, 2.4, 1.2), "vec3 not equality")

  block:
    let a = vec3(1.0, 0.0, 0.0)
    let b = vec3(0.0, 0.0, 0.0)
    testEqual(length(a), 1.0, "vec3 unit length")
    testEqual(length(b), 0.0, "vec3 zero length")

  block:
    let a = vec3(2.0, 1.0, 0.5)
    testEqual(length(normal(a)), 1.0, "vec3 normal length")

  block:
    testEqual(normDot(vec3(1, 1, 0), vec3(1, 1, 0)).float32, 1.0'f32, "vec3 dot parallel positive")
    testEqual(normDot(vec3(1, 1, 0), vec3(-1, -1, 0)).float32, -1.0'f32, "vec3 dot parallel negative")

  block:
    testEqual(cross(vec3(1, 0, 0), vec3(0, 1, 0)), vec3(0, 0, 1), "vec3 cross")
