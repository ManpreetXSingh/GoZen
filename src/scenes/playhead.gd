class_name Playhead extends Panel


@onready var main: Control = get_parent()

static var instance: Playhead
static var frame_nr: int = 0
static var is_moving: bool = false


func _ready() -> void:
	instance = self


func _process(_delta: float) -> void:
	if is_moving:
		ViewPanel.instance._force_set_frame(clampi(
			floori(main.get_local_mouse_position().x / Project.timeline_scale),
			0, Project.timeline_end))


func _on_main_gui_input(a_event: InputEvent) -> void:
	if a_event is InputEventMouseButton:
		if (a_event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
			if a_event.is_pressed():
				is_moving = true
			elif a_event.is_released():
				is_moving = false


func step() -> int:
	# Go one frame further
	frame_nr += 1
	position.x += Project.timeline_scale

	_on_end_check()
	return frame_nr


func move(a_frame_nr: int) -> int:
	# Move playhead frame further
	frame_nr = a_frame_nr
	position.x = Project.timeline_scale * frame_nr

	_on_end_check()
	return frame_nr


func skip(a_amount: int) -> int:
	# Move playhead frame further
	frame_nr += a_amount
	position.x = Project.timeline_scale * frame_nr

	_on_end_check()
	return frame_nr


func _on_end_check() -> void:
	if frame_nr >= Project.timeline_end:
		ViewPanel.instance._on_end_reached()
		frame_nr = Project.timeline_end

