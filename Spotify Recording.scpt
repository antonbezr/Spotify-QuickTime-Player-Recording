--Records all songs from Spotify playlist/album.
--Only useful for Spotify premium users.
--Must be no duplicate songs in the playlist/album or else it will stop recording.

global track_number
global track_name
global track_artist
global track_album
set track_name to ""

global the_session
global output_folder
global folder_path

global track_list
set track_list to {}

--Current optimal after song delay at 1.2 seconds
global after_delay
set after_delay to 1.2

-- If recording high quality set to ".m4a"
-- If recording maximum quality set to ".aifc"
property file_extension : ".aifc"

on reset()
	tell application "Spotify"
		if player state is playing then pause
		set player position to 0
		set repeating to true
		set shuffling to false
		set track_number to (track number of current track)
		set track_name to (name of current track)
		set track_artist to (artist of current track)
		set track_album to (album of current track)
	end tell
end reset

on rec()
	set saveFolder to "[" & track_artist & "]" & " [XXXX] " & track_album & " [320 kbps]"
	if track_number < 10 then
		set track_number to "0" & track_number
	end if
	set saveName to "[" & track_number & "] " & track_name & file_extension
	
	do shell script "mkdir -p " & "~/Music/QuickTime/\"" & saveFolder & "\""
	set filePath to "MAINFRAME:Users:anton:Music:QuickTime:" & saveFolder & ":" & saveName
	set f to a reference to file filePath
	
	tell application "QuickTime Player"
		activate
		set new_audio_recording to new audio recording
		tell new_audio_recording
			start
			tell application "Spotify"
				play
				repeat while track_name is equal to (name of current track)
					delay 0
				end repeat
			end tell
			delay after_delay
			pause
			save new_audio_recording in f
			stop
			close new_audio_recording
		end tell
	end tell
end rec

------------------------- MAIN LOOP -------------------------

repeat while track_list does not contain track_name
	do shell script "/usr/local/bin/SwitchAudioSource -t input -s 'Built-in Microphone'"
	do shell script "/usr/local/bin/SwitchAudioSource -t output -s 'Built-in Output'"
	copy track_name to end of track_list
	reset()
	delay 5
	do shell script "/usr/local/bin/SwitchAudioSource -t input -s 'Soundflower (2ch)'"
	do shell script "/usr/local/bin/SwitchAudioSource -t output -s 'Soundflower (2ch)'"
	do shell script "osascript -e \"set volume output volume 100\""
	rec()
end repeat
