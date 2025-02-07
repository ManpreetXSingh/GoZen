extends Node

# TODO: For double speed, change mix_rate or pitch (mix rate is easier)

# Numbers are: mix_rate, stereo, 16 bits so 2 bytes per sample
static var bytes_per_frame: int


var players: Array[AudioStreamPlayer] = []
var streams: Array[AudioStreamWAV] = []
var clip_ids: PackedInt64Array = []

var not_ready_audio: Dictionary[int, ClipData] = {} # {track_id: ClipData)



func _ready() -> void:
	bytes_per_frame = int(float(44100 * 2 * 2) / Project.framerate)

	for i: int in 6:
		var l_player: AudioStreamPlayer = AudioStreamPlayer.new()
		var l_stream: AudioStreamWAV = AudioStreamWAV.new()

		@warning_ignore("return_value_discarded")
		clip_ids.append(-1)
		players.append(l_player)
		streams.append(l_stream)
		add_child(l_player)

		l_stream.format = AudioStreamWAV.FORMAT_16_BITS
		l_stream.stereo = true
		l_player.stream = l_stream


func _process(_delta: float) -> void:
	for l_clip_data: ClipData in not_ready_audio.values():
		check_audio(l_clip_data)


func set_audio(a_clip_data: ClipData, a_frame: int) -> void:
	if RenderLayout.is_rendering or a_clip_data.get_audio().size() == 0:
		stop_audio(a_clip_data.track)
		return

	clip_ids[a_clip_data.track] = a_clip_data.id
	streams[a_clip_data.track].data = a_clip_data.get_audio()

	if streams[a_clip_data.track].data.size() == 1: # Data still loading
		not_ready_audio[a_clip_data.track] = a_clip_data
		return
	elif a_clip_data.track in not_ready_audio:
		@warning_ignore("return_value_discarded")
		not_ready_audio.erase(a_clip_data.track)
		
	players[a_clip_data.track].play(float(a_frame) / Project.framerate)
	players[a_clip_data.track].stream_paused = !View.is_playing


func check_audio(a_clip_data: ClipData) -> void:
	if a_clip_data.id in clip_ids:
		streams[a_clip_data.track].data = a_clip_data.get_audio()

		if streams[a_clip_data.track].data.size() == 1: # Data still loading
			return
		else:
			@warning_ignore("return_value_discarded")
			not_ready_audio.erase(a_clip_data.track)

		players[a_clip_data.track].play(float(View.frame_nr) / Project.framerate)
		players[a_clip_data.track].stream_paused = !View.is_playing


func play_audio(a_track:int) -> void:
	players[a_track].stream_paused = false


func play_all_audio() -> void:
	for i: int in 6:
		play_audio(i)


func stop_audio(a_track: int) -> void:
	players[a_track].stream_paused = true


func stop_all_audio() -> void:
	for i: int in 6:
		stop_audio(i)

	
func reset_audio_stream(a_track: int) -> void:
	stop_audio(a_track)
	streams[a_track].data = []


func reset_audio_streams() -> void:
	for i: int in 6:
		reset_audio_stream(i)


func render_audio() -> PackedByteArray:
	var l_audio: PackedByteArray = []

	for l_track_id: int in Project.tracks.size():
		var l_track_audio: PackedByteArray = []

		for l_frame_point: int in Project.tracks[l_track_id].keys():
			var l_clip: ClipData = Project.clips[Project.tracks[l_track_id][l_frame_point]]

			if l_clip.type in View.AUDIO_TYPES:
				# Check if we need to add empty data to track_audio
				if l_track_audio.size() != l_clip.start_frame * AudioHandler.bytes_per_frame:
					if l_track_audio.resize(l_clip.start_frame * AudioHandler.bytes_per_frame):
						printerr("Couldn't resize l_track_audio!")
						print("resized array")

				# Add the data to l_track_audio
				l_track_audio.append_array(l_clip.get_audio())

			# Check if audio is empty or not
			if l_track_audio.size() == 0:
				continue

			# check for mistakes
			if l_track_audio.size() > (Project.timeline_end + 1) * AudioHandler.bytes_per_frame:
				printerr("Too much audio data!")

			# Resize the last parts to equal the size to timeline_end
			if l_track_audio.resize((Project.timeline_end + 1) * AudioHandler.bytes_per_frame):
				printerr("Couldn't resize l_track_audio!")

		if l_audio.size() == 0:
			l_audio = l_track_audio
		elif l_audio.size() == l_track_audio.size():
			l_audio = Audio.combine_data(l_audio, l_track_audio)

	# Check for the total audio length
	#print((float(l_audio.size()) / AudioHandler.bytes_per_frame) / 30)
	print("Rendering audio complete")
	return l_audio

