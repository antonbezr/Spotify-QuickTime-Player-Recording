# Spotify Audio Hijack Recording

This AppleScript script allows the user to record/download songs from Spotify on any Mac OS device. An additional application (Audio Hijack Pro v.2) is needed in order to utilize this script. Newer versions of Audio Hijack Pro will not work with this script.

Before starting script:
* Change destination folder path (line xx) to preferred directory.
* Hijack the Spotify session within Audio Hijack Pro.
* Make sure Spotify is playing from album/playlist with repeat enabled.

This is what the Audio Hijack Pro application should look like after starting the script:

<p align="center">
  <img src="https://i.imgur.com/pL4lfih.png" width="616" height="399">
</p>

The script is able to capture audio quality in MP3 320 kbps (CBR) as can be seen in the spectral below. This is the highest audio quality for MP3 files. MP3 320kbps (CBR) has a frequency cut-off at 20.5 kHz which is consistent with the spectral.

<p align="center">
  <img src="https://i.imgur.com/t0SpAzq.png" width="616" height="415">
</p>
