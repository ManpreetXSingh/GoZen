class_name ClipData extends Resource


const MAX_FRAME_SKIPS: int = 20


var id: int
var file_id: int
var type: File.TYPE

var track: int
var start_frame: int # Timeline begin of clip
var end_frame: int : get = get_end_frame
var duration: int
var begin: int = 0 # Only for video files

var default_audio_effects: EffectAudioDefault = EffectAudioDefault.new()
var audio_effects: Array[EffectAudio] = []


func get_end_frame() -> int:
	return start_frame + duration - 1


func get_audio() -> PackedByteArray:
	if type in View.AUDIO_TYPES:
		if !Project._audio.has(id):
			return [0]
		return Project._audio[id]
	return []


func update_audio_data() -> void:
	Threader.timed_tasks[id] = Threader.TimedTask.new(
			_update_audio, AudioHandler.check_audio.bind(self))


func _update_audio() -> void:
	if type not in [File.TYPE.AUDIO, File.TYPE.VIDEO]:
		return

	var l_file_data: FileData = Project._files_data[file_id]
	
	# Trim beginning of audio
	Project._audio[id] = l_file_data.audio.slice(
		begin * AudioHandler.bytes_per_frame,
		(begin + duration) * AudioHandler.bytes_per_frame)

	# Applying default + other effects
	default_audio_effects.apply_effect(Project._audio[id])
	for l_effect: EffectAudio in audio_effects:
		l_effect.apply_effect(Project._audio[id])


func load_video_frame(a_track: int, a_frame_nr: int) -> void:
	# Correct frame for video framerate
	a_frame_nr = a_frame_nr - start_frame + begin
	a_frame_nr = clampi(
			roundi((float(a_frame_nr) / Project.framerate) * _get_file_data().framerate),
			0, _get_file_data().frame_count)

	# Check if frame is already correct or not
	if a_frame_nr != 0 and a_frame_nr == _get_file_data().current_frame[a_track]:
		return # We already have the correct frame loaded

	# Setting the difference to check if frame skipping is required
	var l_skips: int = a_frame_nr - _get_file_data().current_frame[a_track]

	# Check if frame is before current one or after max skip
	if a_frame_nr < _get_file_data().current_frame[a_track] or l_skips > MAX_FRAME_SKIPS:
		_get_file_data().current_frame[a_track] = a_frame_nr
		if !_get_video(a_track).seek_frame(a_frame_nr):
			printerr("Couldn't seek frame!")
		return

	# Go through skips and set frame
	for i: int in l_skips - 1:
		if !_get_video(a_track).next_frame(true):
			print("Something went wrong skipping next frame!")

	_get_file_data().current_frame[a_track] = a_frame_nr
	if !_get_video(a_track).next_frame(false):
		print("Something went wrong skipping next frame!")


func _get_file_data() -> FileData:
	return Project._files_data[file_id]


func _get_video(a_track: int) -> Video:
	return Project._files_data[file_id].video[a_track]

