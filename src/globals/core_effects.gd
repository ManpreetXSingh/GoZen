extends Node
# This will be important as it will handle all the effects on clips. CoreView
# will have to interact with CoreEffects a lot to get the data for each frames
# effects. That's basically all CoreEffects will do, provide the option to add
# effects to clips, change effect settings and remove effects. Effects handling
# will be done by the view.



func _ready() -> void:
	CoreError.err_connect([
			CoreTimeline._open_clip_effects.connect(open_clip_effects),
			CoreMedia._open_file_effects.connect(open_file_effects)])


func open_clip_effects(a_id: int) -> void:
	print("Opening effects for clip '%s&'" % a_id)


func open_file_effects(a_id: int) -> void:
	print("Opening effects for file '%s&'" % a_id)

