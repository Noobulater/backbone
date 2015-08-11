#Written by Aaron Bentley 5/19/15
import streams, math, opengl, strutils, tables

var bmpCache = initTable[string, GLuint]() # a mapping of string to GLuint (textureID)

proc parseBmp*(filePath: string): GLuint =
  if bmpCache.hasKey(filePath):
    return bmpCache[filePath]

  #if we didn't find it in the cache
  var
    file: File

    # header variables
    hField : char
    hField2 : char
    size : int32
    extraInfo : int32 #this is reserved for the image prcoessor
    offset : int32
    dibSize : int32
    imageWidth : int32
    imageHeight : int32
    #DIB crap its 124 bytes

    #Here is what we want

  if (open(file, "content/" & filePath)) :
    let fStream = newFileStream(file)

    hField = readChar(fStream)
    hField2 = readChar(fStream)

    size = readInt32(fStream)
    extraInfo = readInt32(fStream)
    offset = readInt32(fStream)

    dibSize = readInt32(fStream)
    imageWidth = readInt32(fStream)
    imageHeight = readInt32(fStream)

    # we know that the format of the bmps is R8 B8 G8 A8
    # Jump to the pixel data
    fStream.setPosition(offset)
    var tempSeq = newSeq[uint8]((imageWidth*imageHeight)*4)
    for i in 0..((imageWidth*imageHeight*4)-1) :
      tempSeq[i] = fStream.readInt8().uint8
    #unfortunately i don't think we are done.
    #we have all the pixel data, except it isn't usable because its in a slighly
    #different ordering.

    var finalSeq = newSeq[uint8]((imageWidth*imageHeight)*4)
    let max = (finalSeq.len/4).int-1
    for i in 0..max : # this routine correts the data from BGR TO RGBA
      finalSeq[i*4 + 0] = tempSeq[(max-i)*4 + 3]
      finalSeq[i*4 + 1] = tempSeq[(max-i)*4 + 2]
      finalSeq[i*4 + 2] = tempSeq[(max-i)*4 + 1]
      finalSeq[i*4 + 3] = tempSeq[(max-i)*4 + 0]

    # Now the pixel data is still really out of order, so this corrects that
    var finalfinalSeq = newSeq[uint8]((imageWidth*imageHeight)*4)
    let
      mh = imageHeight-1
      mw = imageWidth-1

    for i in 0..mh :
      for j in 0..mw :
        finalfinalSeq[i*imageWidth*4 + j*4 + 0] = finalSeq[i*imageWidth*4 + (mw-j)*4 + 0]
        finalfinalSeq[i*imageWidth*4 + j*4 + 1] = finalSeq[i*imageWidth*4 + (mw-j)*4 + 1]
        finalfinalSeq[i*imageWidth*4 + j*4 + 2] = finalSeq[i*imageWidth*4 + (mw-j)*4 + 2]
        finalfinalSeq[i*imageWidth*4 + j*4 + 3] = finalSeq[i*imageWidth*4 + (mw-j)*4 + 3]

    var textureID: GLuint

    glGenTextures(1, addr textureID)
    glActiveTexture(GL_TEXTURE0)
    glBindTexture(GL_TEXTURE_2D, textureID)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, addr finalfinalSeq[0])
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    close(fStream)

    bmpCache[filePath] = textureID
    return textureID

  echo("ERROR: " & filePath & " file not found")
  return 0


# OUTDATED CODE FOR R8 B8 G8
  #Essentially the rows of a bitmap get padded, so we need to go through each
  #row and sift through the padding
  #It gets padded so that the bytes are divisible by 4
  #var
  #  index = 0 # size of the return sequence, without the padding
  #  padding = (imageWidth * 4 - (imageWidth * 3) mod 4) mod 4 # function for
  #finding the padding. the data needs to fit in something divisible by 4 bytes
  #var i = 0
  #var tempSeq = newSeq[uint8]((imageWidth*imageHeight)*3)
  #while i < size-offset : # the amount of room the data takes up
  #  if ( i mod (imageWidth*3+padding) <= (imageWidth*3)-1 ) : #-1 because i is zero'd
  #    tempSeq[index] = readInt8(fStream).uint8 # bitmaps have some padding
  #    inc(index)

      # they need to be able to be stored in a number of bytes divisible by 4
      # example 2x2 picture has 6 bytes in the first row, with a padding of 2 and
      # 6 bytes in the second row with a padding of 2
  #  else :
  #    discard readInt8(fStream).uint8 # toss the padding byte
  #  inc(i) # make an array with all the data in it
