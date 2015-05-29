#Written by Aaron Bentley 5/23/15
import globals

type
  timeObj = ref object of RootObj
    nextCall*: float
    delay*: float
    call*: proc()
    count*: int #number of times its been executed
    reps*: int #number of times it should be executed

var timeSeq: seq[timeObj] = @[]

#simple timer for single repetition calls measured in second
proc simple*(delay:float, fCall: proc()) =
  let entry = timeObj() # constructed
  entry.delay = delay
  entry.nextCall = curTime() + delay
  entry.call = fCall
  entry.count = 0
  entry.reps = 1
  timeSeq.add(entry)

var garbage: seq[int] = @[]#when a timer is expired, remove it
proc update*(dt: float) =
  var entry: timeObj
  let cTime = curTime()
  for i in low(timeSeq)..high(timeSeq):
    entry = timeSeq[i] # for each timer we need to compare and
    if (entry.nextCall <= cTime) : # check to see if the time is up
      entry.call() # execute the function
      if (entry.reps >= 0) :
        entry.count += 1
        if (entry.count >= entry.reps) :
          garbage.add(i)
        entry.nextCall = cTime + entry.delay

  if (garbage.len > 0) :
    for i in high(garbage)..low(garbage) : # sorted from high to low,
      timeSeq.delete(garbage[i]) # because elements would shift otherwise
      garbage.delete(i)
