#Written By Aaron Bentley 6/24/15
import streams, math, opengl, strutils, tables

type
  tableEntry = object
    name: string
    checkSum, offset, length: int32

type
  headTable = object
    version, fontRevision: uint32
    checkSumAdjustment: uint32
    magicNumber: uint32
    flags: uint16
    unitsPerEm: uint16
    created,modified: uint64
    xMin,yMin,xMax,yMax: int16
    macStyle, lowestRecPPEM, fontDirectionHint: uint16
    indexToLocFormat, glyphDataFormat: int16

proc parseTTF*(filePath: string) =
  var
    file: File

    # header variables
    version: int32
    numTables: int16
    var1,var2,var3: int16


  if (open(file, "content/" & filePath)) :
    let fStream = newFileStream(file)
    # Load the Header
    version = fStream.readInt32()
    numTables = fStream.readInt16()
    var1 = fStream.readInt16()
    var2 = fStream.readInt16()
    var3 = fStream.readInt16()

    #Load the tables
    echo(numTables)
    var tables = newSeq[tableEntry](numTables)
    for i in 0..(tables.len-1) :
      tables[i] = tableEntry()
      tables[i].name = fStream.readChar() & fStream.readChar() & fStream.readChar() & fStream.readChar()
      tables[i].checkSum = fStream.readInt32()
      tables[i].offset = fStream.readInt32()
      tables[i].length = fStream.readInt32()



    var head = headTable()
    head.version =
#parseTTF("fonts/BURNSTOW.TTF")
