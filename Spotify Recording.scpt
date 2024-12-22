property FILE_EXTENSION : ".m4a"

global prevInput
global prevOutput

global trackList
set trackList to {}

global trackName
global trackDuration
global trackIdentifier
global f
global quickTimeAudioRecording

-------- HANDLE AUDIO I/O --------
-- retrieveAudioSource - Retrieves and notes the audio input and output source prior to script execution
-- setBlackHole - Sets audio input and output to BlackHole 2ch in order to record audio
-- cleanup - Resets the audio input and output source to previous configuration
----------------------------------
on retrieveAudioSource()
	set prevInput to do shell script "/opt/homebrew/bin/SwitchAudioSource -c -t input"
	set prevOutput to do shell script "/opt/homebrew/bin/SwitchAudioSource -c -t output"
end retrieveAudioSource

on setBlackHole()
	do shell script "/opt/homebrew/bin/SwitchAudioSource -t input -s 'BlackHole 2ch'"
	do shell script "/opt/homebrew/bin/SwitchAudioSource -t output -s 'BlackHole 2ch'"
	do shell script "osascript -e \"set volume output volume 100\""
end setBlackHole

on cleanup()
	do shell script "osascript -e \"set volume output volume 30\""
	do shell script "/opt/homebrew/bin/SwitchAudioSource -t input -s " & quoted form of prevInput
	do shell script "/opt/homebrew/bin/SwitchAudioSource -t output -s " & quoted form of prevOutput
end cleanup


----- HANDLE SPOTIFY SETUP -----
-- 1. Gets information for current song
-- 2. Generates album folder for current song if does not exist
-- 3. Sets save file path for QuickTime audio recording
--------------------------------
on setup()
	tell application "Spotify"
		if player state is playing then pause
		set player position to -1
		set sound volume to 100
		set repeating to true
		set shuffling to false
		
		set trackNumber to (track number of current track)
		set trackName to (name of current track)
		set trackName to do shell script "echo '" & trackName & "' | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1' | sed 's/[$*?&#!\\\\\"'\\\"'|:/]/_/g'"
		set trackArtist to (artist of current track)
		set trackArtist to do shell script "echo '" & trackArtist & "' | sed 's/[$*?&#!\\\\\"'\\\"'|:/]/_/g'"
		set trackAlbum to (album of current track)
		set trackAlbum to do shell script "echo '" & trackAlbum & "' | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1' | sed 's/[$*?&#!\\\\\"'\\\"'|:/]/_/g'"
		set trackDuration to (duration of current track) * 1.0E-3 -- This is done because duration provided by Spotify does not match actual audio length
		set trackIdentifier to (trackArtist & " - " & trackName)
	end tell
	
	set saveFolder to "[" & trackArtist & "]" & " [XXXX] " & trackAlbum & " [320 kbps]"
	set indexedTrackNumber to trackNumber
	if indexedTrackNumber < 10 then
		set indexedTrackNumber to "0" & indexedTrackNumber
	end if
	set saveName to "[" & indexedTrackNumber & "] " & trackName & FILE_EXTENSION
	
	do shell script "mkdir -p " & "~/Music/QuickTime/\"" & saveFolder & "\""
	set homeDir to do shell script "echo $HOME | sed 's/\\//:/g'"
	set filePath to "Macintosh HD" & homeDir & ":Music:QuickTime:" & saveFolder & ":" & saveName
	set f to a reference to file filePath
end setup


----- HANDLE RECORDING CONTROLS -----
-- startRec - Start QuickTime audio recording
-- songPlaying - Start playing Spotify song and sleep for song duration
-- stopRec - Stop QuickTime audio recording and save file
-------------------------------------
on startRec()
	tell application "QuickTime Player"
		quit
		delay 3
		activate
		set quickTimeAudioRecording to new audio recording
		tell quickTimeAudioRecording
			start
		end tell
	end tell
end startRec

on songPlaying()
	tell application "Spotify"
		if player state is playing then pause
		set player position to 0
		play
		delay trackDuration
		pause
	end tell
end songPlaying

on stopRec()
	tell application "QuickTime Player"
		tell quickTimeAudioRecording
			pause
			save quickTimeAudioRecording in f
			stop
			close quickTimeAudioRecording
		end tell
	end tell
end stopRec


--- =========================== ----
---------- MAIN EXECUTION ----------
--- =========================== ----
try
	retrieveAudioSource()
	setBlackHole()
	
	repeat while true
		setup()
		if trackList contains trackIdentifier then break
		copy trackIdentifier to end of trackList
		
		startRec()
		songPlaying()
		stopRec()
		
		delay 2 -- Ensure Spotify starts playing next song
	end repeat
	
	cleanup()
on error errMsg number errNum
	cleanup()
end try
