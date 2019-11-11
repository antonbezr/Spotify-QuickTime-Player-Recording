--Records all songs from Spotify playlist/album.
--Only useful for Spotify premium users.

--Must have a Audio Hijack Pro session named "Spotify" connected to the Spotify app.
--Must be hijacking within the session.
--Must be no duplicate songs in the playlist/album or else it will stop recording.

--Current optimal before delay at 0.1, can change with future Spotify updates.
--Current optimal after delay at 1.2, can change with future Spotify updates.

global track_number
global track_name
global track_artist
global track_album

global the_session
global output_folder
global folder_path

global track_list
set track_list to {}

property file_extension : ".mp3"

on setup()
	tell application "Spotify"
		if player state is playing then pause
		set track_number to (track number of current track)
		set track_name to (name of current track)
		set track_artist to (artist of current track)
		set track_album to (album of current track)
	end tell
end setup

on update()
	--Activates the_session and sets up the preferences. Starts recording.
	tell application "Audio Hijack Pro"
		activate
		set the_session to (first item of (every session whose name is "Spotify"))
		tell the_session
			set output folder to output_folder
			if track_number is less than 10 then
				set output name format to "[0" & track_number & "] " & track_name
			else
				set output name format to "[" & track_number & "] " & track_name
			end if
			
			set track number tag to track_number
			set title tag to track_name
			set artist tag to track_artist
			set album tag to track_album
			--No year tag implemented currently
			
			--Set presets for audio quality settings
			set recording format to {encoding:MP3, bit rate:320, channels:Stereo, style:CBR}
		end tell
		if hijacked of the_session is false then start hijacking the_session
		delay 0.1
		start recording the_session
	end tell
end update


on start()
	--Plays the song. Stops recording on change of the current track name.
	tell application "Spotify"
		set player position to 0
		play
		
		delay 2
		
		--Changed from "until player state is not playing", as this was causing issues.
		repeat while track_name is equal to (name of current track)
			delay 0
		end repeat
		
		tell application "Audio Hijack Pro"
			delay 1.2
			stop recording the_session
		end tell
	end tell
end start

------------------------- MAIN LOOP -------------------------

my setup()

repeat while track_list does not contain track_name
	copy track_name to end of track_list
	
	set output_folder to "~/Music/Audio Hijack/" & "[" & track_artist & "] [XXXX] " & track_album & " [320 kbps]"
	set folder_path to POSIX path of output_folder
	
	my update()
	my start()
	
	delay 2
	
	my setup()
end repeat
