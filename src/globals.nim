#Written by Aaron Bentley 5/19/15
#Purpose: This file contains commonly used variables, and also
#convience functions to make calculations/code more concise
import sdl2
import engine/types

proc getTime(): float =
  return getTicks().float/1000

var
  scrW* = 1024
  scrH* = 640
  windowTitle* = "Backbone - Engine"
  tickRate* = 64
  paused* = false
  alive* = true
  curTime* = getTime # current time counter
  curTicks* = getTicks
  LocalPlayer*: Player
  worldShader*: Program
  defMaterial*: Material
  worldInit*: bool
  skyShader*: Program
  skyBoxMatrix*: Mat4

proc Color*(r,g,b,a: float): Colr = Colr(r: (r*255.0).int, g: (g*255.0).int, b: (b*255.0).int, a: (a*255.0).int)
proc Color*(r,g,b,a: int): Colr = Colr(r: r, g: g, b: b, a: a)

proc clampHigh*(num,numHigh: float): float =
  result = num
  if (num > numHigh) :
    result = numHigh

proc clampLow*(num,numLow: float): float =
  result = num
  if (num < numLow) :
    result = numLow

proc clamp*(num,numLow,numHigh: float): float =
  result = num
  if (num > numHigh) :
    result = numHigh
  elif (num < numLow) :
    result = numLow

# Convience functions for sequences
proc get*[T](m: seq[T], gEntry: T): int =
  for i in low(m)..high(m) :
    if (m[i] == gEntry) :
      return i
  return -1

proc remove*[T](m: seq[T], rIndex: int) =
  m.delete(rIndex)

proc remove*[T](m: seq[T], rEntry: T) =
  let x = m.get(rEntry)
  m.remove(x.Natural)

proc strAtIndex*(input: string, index: int) : string =
  result = ""
  var i = index
  var curChar = input[i]
  while (curChar != '\0') :
    curChar = input[i]
    if (curChar != '\0') :
      result = result & $curChar
      inc(i)
