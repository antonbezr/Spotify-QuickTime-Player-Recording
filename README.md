# Spotify QuickTime Player Recording

This AppleScript script allows the user to record songs from Spotify on any Mac OS device using QuickTime Player.

Dependencies for this script:
* BlackHole - https://existential.audio/blackhole/
* switchaudio-osx - https://github.com/deweller/switchaudio-osx

Before starting script:
* Make sure Spotify is playing from album/playlist you wish to download.
* Ensure your album/playlist does not have duplicate tracks, otherwise the script will exit prematurely.

The script is able to capture audio quality in Stereo 320 kbps (CBR) MP3 format, as can be seen in the spectral below. MP3 320kbps has a frequency cut-off at 20.5 kHz which is consistent with the spectral.

<p align="center">
  <img src="https://i.imgur.com/t0SpAzq.png" width="80%" height="80%">
</p>
