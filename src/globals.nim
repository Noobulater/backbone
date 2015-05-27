#Written by Aaron Bentley 5/19/15
import sdl2

proc getTime(): float =
  return getTicks().float/1000

var
  scrW* = 640
  scrH* = 480
  windowTitle* = "Backbone - Engine"
  tickRate* = 64
  paused* = false
  alive* = true
  curTime* = getTime # current time counter

# Convience functions for sequences
proc get*[T](m: seq[T], gEntry: T): int =
  for i in low(m)..high(m) :
    if (m[i] == gEntry) :
      return i
  return -1

proc remove*[T](m: seq[T], rIndex: int) =
  m.delete(rIndex)

proc remove*[T](m: seq[T], rEntry: T) = m.remove(m.get(rEntry))
