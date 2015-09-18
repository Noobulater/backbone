import globals
import types
import opengl

#####################
###RENDER MANAGER####
#####################
var renders*: array[0..high(RenderGroups).int, seq[proc(): bool]]

proc init*() =
  for i in 0..high(renders) :
    renders[i] = @[]

proc addDraw*(rGroup: int, draw: proc(): bool) =
  renders[rGroup].add(draw)

proc drawScene*() =
  if (worldInit) :
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)

    for i in 0..high(renders) :
      glDepthMask(true)
      if (i == RENDERGROUP_VIEWMODEL.int) :
        glClear(GL_DEPTH_BUFFER_BIT)
      elif (i == RENDERGROUP_TRANSPARENT.int or i == RENDERGROUP_VIEWMODEL_TRANSPARENT.int) :
        glDepthMask(false)

      var removeIDs = newSeq[int]()

      var draws = renders[i]

      for i in low(draws)..high(draws):
        if (not draws[i]()) : # if it returns true, mark it for removal
          removeIDs.add(i)

      # We can't remove it while we are iterating through, so remove it after
      # To ensure safety of data

      for i in low(removeIDs)..high(removeIDs) :
        draws.delete(removeIDs[removeIDs.len-1 - i])

###################
