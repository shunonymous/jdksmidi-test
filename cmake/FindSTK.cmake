# FindModule The Synthesis ToolKit include RtAudio and RtMidi. 
# Stk:
#   STK_FOUND        - True if headers and requested libraries were found
#   STK_LIBRARY      - STK library to be link
#   STK_INCLUDE_DIR  - STK include directory
#
# RtMidi:
#   RTMIDI_FOUND     - True if headers and requested libraries were found
#   RTMIDI_LIBRARY   - RtMidi library to be link with platform specify libraries
# RtAudio:
#   RTAUDIO_FOUND     - True if headers and requested libraries were found
#   RTAUDIO_LIBRARY   - RtAudio library to be link with platform specify libraries

# Try to serch Stk Libraries and headers
find_path(STK_INCLUDE_DIR stk/Stk.h)
find_library(STK_LIBRARY stk)
find_path(RTMIDI_INCLUDE_DIR NAMES RtMidi.h PATH_SUFFIXES stk)
find_path(RTAUDIO_INCLUDE_DIR RtAudio.h PATH_SUFFIXES stk)
find_library(RTMIDI_LIBRARY rtmidi)
find_library(RTAUDIO_LIBRARY rtaudio)

# Set STK_FOUND
if(STK_LIBRARY AND STK_INCLUDE_DIR)
  set(STK_FOUND true)
endif()

# If RtMidi and RtAudio was not found, use Stk's one.
if(STK_FOUND)
  if(NOT RTMIDI_LIBRARY)
    find_library(RTMIDI_LIBRARY stk)
  endif()
  if(NOT RTAUDIO_LIBRARY)
    find_library(RTAUDIO_LIBRARY stk)
  endif()
endif()

# Set <Library>_FOUND
if(RTMIDI_LIBRARY AND RTMIDI_INCLUDE_DIR)
  set(RTMIDI_FOUND true)
endif()
if(RTAUDIO_LIBRARY AND RTAUDIO_INCLUDE_DIR)
  set(RTAUDIO_FOUND true)
endif()

# Set libraries per platforms
if(STK_FOUND)
  # For GNU/Linux systems
  if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    find_package(ALSA)
    if(ALSA_FOUND)
      set(RTMIDI_LIBRARY ${RTMIDI_LIBRARY} ${ALSA_LIBRARIES})
      set(RTAUDIO_LIBRARY ${RTAUDIO_LIBRARY} ${ALSA_LIBRARIES})
      set(STK_LIBRARY ${STK_LIBRARY} ${ALSA_LIBRARIES})
      add_definitions(-D__LINUX_ALSA__)
    endif()
    # Pulseaudio
    find_package(PulseAudio)
    if(PULSEAUDIO_FOUND)
      set(RTAUDIO_LIBRARY ${RTAUDIO_LIBRARY} ${PULSEAUDIO_LIBRARY})
      add_definitions(-D__LINUX_PULSE__)
    endif()
  endif()
  # For Mac OS
  if(APPLE)
    find_library(COREAUDIO_LIBRARY CoreAudio)
    find_library(COREMIDI_LIBRARY CoreMIDI)
    find_library(COREFOUNDATION_LIBRARY CoreFoundation)
    set(APPLE_AUDIO_LIBRARIES ${COREAUDIO_LIBRARY} ${COREMIDI_LIBRARY} ${COREFOUNDATION_LIBRARY})
    set(RTMIDI_LIBRARY ${RTMIDI_LIBRARY} ${APPLE_AUDIO_LIBRARIES})
    set(RTAUDIO_LIBRARY ${RTAUDIO_LIBRARY} ${APPLE_AUDIO_LIBRARIES})
    set(STK_LIBRARY ${STK_LIBRARY} ${APPLE_AUDIO_LIBRARIES})
    add_definitions(-D__MACOSX_CORE__)
  endif()
  # For Unix-like systems
  if(UNIX)
    find_package(JACK)
    if(JACK_FOUND)
      set(RTMIDI_LIBRARY ${RTMIDI_LIBRARY} ${JACK_LIBRARIES})
      set(RTAUDIO_LIBRARY ${RTAUDIO_LIBRARY} ${JACK_LIBRARIES})
      set(STK_LIBRARY ${STK_LIBRARY} ${JACK_LIBRARIES})
      add_definitions(-D__UNIX_JACK__)
    endif()
  endif()
  # For Windows
  if(WIN32)
    #find_library(WIN32_MULTIMEDIA_LIBRARY winmm)
    #find_library(DIRECT_SOUND_LIBRARY dsound winmm ole32)
    #find_library(ASIO_LIBRARY ole32)
    find_library(WINDOWS_MIDI_LIBRARIES winmm)
    find_library(WINDOWS_SOUND_LIBRARIES winmm dsound ole32 kuser uuid)
    set(RTMIDI_LIBRARY ${WINDOWS_MIDI_LIBRARIES})
    set(RTAUDIO_LIBRARY ${WINDOWS_SOUND_LIBRARIES})
    add_definitions(-D__WINDOWS_MM__ -D__WINDOWS_DS__)
  endif()
endif()

  
