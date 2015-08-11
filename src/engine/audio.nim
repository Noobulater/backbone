#written by Aaron Bentley 5/24/15
import sdl2, sdl2/mixer
import types

# THIS SECTION OPENS UP THE AUDIO SO THAT IT CAN SUPPORT WAV FORMATS
# TODO : Modify this section to allow for dynamic format loading
proc init*() =
  discard

proc update*(dt: float) =
  discard

proc destroy*() =
  mixer.closeAudio()

###############
##SND METHODS##
###############

proc Sound*(filePath: string): SND = # Creates the sound
  result = SND()
  result.buffers = 4096 # common example
  result.channels = 2 # stereo, not mono
  result.channel = -1 #not set yet
  result.volume = mixer.MIX_MAX_VOLUME # set it to max volume

  if (mixer.openAudio(result.rate, result.format, result.channels, result.buffers) != 0) :
    echo("ERROR sound.nim : FAILURE TO OPEN AUDIO")

  result.data = mixer.loadWAV("content/" & filePath)
  if ( result.data == nil ) :
    echo("ERROR sound.nim : SOUND DATA EMPTY")

method isPlaying*(sound: SND): bool =
  if (sound.playing and mixer.playing(sound.channel) != 0) :
    return true
  return false

method play*(sound: SND) =
  sound.playing = true
  sound.channel = mixer.playChannel(-1, sound.data, 0) #wav
  if (sound.channel == -1) :
    echo(getError())
    quit("Unable to play sound")

method unpause*(sound: SND) =
  if (sound.channel > -1 and not sound.isPlaying()) :
    mixer.resume(sound.channel)
    sound.playing = true

method pause*(sound: SND) =
  if (sound.isPlaying()) :
    mixer.pause(sound.channel)
  sound.playing = false

method clean*(sound: SND) =
  sound.playing = false
  mixer.freeChunk(sound.data)

method setVolume*(sound: SND, newVolume: float) = #0-1 scale
  sound.volume = cint(mixer.MIX_MAX_VOLUME.float * newVolume)
  if (sound.volume < 0) :
    sound.volume = 0
  if (sound.volume > mixer.MIX_MAX_VOLUME) :
    sound.volume = mixer.MIX_MAX_VOLUME

  discard mixer.volume(sound.channel, sound.volume)

method setVolume*(sound: SND, newVolume: int) = #0-1 scale
  sound.setVolume(newVolume.float)

method getVolume*(sound: SND): float =
  return sound.volume.float/mixer.MIX_MAX_VOLUME.float

#TEST CODE
#let x = Sound("content/whatayabuyin.wav")
#let y = Sound("content/isthatall.wav")
#let z = Sound("content/thankyou.wav")

#proc delayed() =
  #x.play()
#  y.play()
  #simple(1, z.play)

#var playd = false

#proc d() =
#  playd = true

#simple(2, delayed)

#proc playSound() =
#  var sound2 : MusicPtr

#  var channel : cint
#  var audio_rate : cint
#  var audio_format : uint16
#  var audio_buffers : cint    = 4096
#  var audio_channels : cint   = 2

#  if mixer.openAudio(audio_rate, audio_format, audio_channels, audio_buffers) != 0:
#      quit("There was a problem")

#  var sound = mixer.loadWAV("content/whatayabuyin.wav")
  #sound2 = mixer.loadMUS("SDL_PlaySound/sound.ogg")

#  if isNil(sound):
#    quit("Unable to load sound file")

#  channel = mixer.playChannel(-1, sound, 0) #wav
  #channel = mixer.playWAV(sound, 0) #ogg/flac
#  if channel == -1:
#      quit("Unable to play sound")

  #let the sound finish
#  while mixer.playing(channel) != 0:
#      discard

#  mixer.freeChunk(sound) #clear wav
  #mixer.freeMusic(sound2) #clear ogg
#  mixer.closeAudio()
