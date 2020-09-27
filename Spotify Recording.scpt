--Records all songs from Spotify playlist/album.
--Only useful for Spotify premium users.
--Must be no duplicate songs in the playlist/album or else it will stop recording.

global track_number
global track_name
global track_artist
global track_album
global track_duration

global track_list
set track_list to {}

global saveFolder
global saveName

global file_path
global f
property file_extension : ".aiff"

global new_audio_recording

on setup()
	tell application "Spotify"
		if player state is playing then pause
		set player position to -1
		set repeating to true
		set shuffling to false
		set track_number to (track number of current track)
		set track_name to (name of current track)
		set track_name to do shell script "echo \"" & track_name & "\" | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1'"
		set track_artist to (artist of current track)
		set track_album to (album of current track)
		set track_album to do shell script "echo \"" & track_album & "\" | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1'"
		set track_duration to (duration of current track) * 1.0E-3
	end tell
	
	set saveFolder to "[" & track_artist & "]" & " [XXXX] " & track_album & " [320 kbps]"
	set indexed_track_number to track_number
	if indexed_track_number < 10 then
		set indexed_track_number to "0" & indexed_track_number
	end if
	set saveName to "[" & indexed_track_number & "] " & track_name & file_extension
	
	do shell script "mkdir -p " & "~/Music/QuickTime/\"" & saveFolder & "\""
	set file_path to "MAINFRAME:Users:anton:Music:QuickTime:" & saveFolder & ":" & saveName
	set f to a reference to file file_path
end setup

on startRec()
	tell application "QuickTime Player"
		activate
		set new_audio_recording to new audio recording
		tell new_audio_recording
			start
			--delay 0.1
		end tell
	end tell
end startRec

on songPlaying()
	tell application "Spotify"
		if player state is playing then pause
		set player position to 0
		play
		delay track_duration
		pause
	end tell
end songPlaying

on stopRec()
	tell application "QuickTime Player"
		tell new_audio_recording
			pause
			save new_audio_recording in f
			stop
			close new_audio_recording
		end tell
	end tell
end stopRec

---------- MAIN LOOP ----------

setup()

repeat while track_list does not contain track_name
	
	copy track_name to end of track_list
	
	do shell script "/usr/local/bin/SwitchAudioSource -t input -s 'Built-in Microphone'"
	do shell script "/usr/local/bin/SwitchAudioSource -t output -s 'Built-in Output'"
	do shell script "osascript -e \"set volume output volume 30\""
	
	delay 3
	
	do shell script "/usr/local/bin/SwitchAudioSource -t input -s 'Soundflower (2ch)'"
	do shell script "/usr/local/bin/SwitchAudioSource -t output -s 'Soundflower (2ch)'"
	do shell script "osascript -e \"set volume output volume 100\""
	
	startRec()
	songPlaying()
	stopRec()
	
	setup()
	
end repeat

do shell script "/usr/local/bin/SwitchAudioSource -t input -s 'Built-in Microphone'"
do shell script "/usr/local/bin/SwitchAudioSource -t output -s 'Built-in Output'"
do shell script "osascript -e \"set volume output volume 30\""
