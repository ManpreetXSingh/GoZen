extends Node

signal _on_language_changed(new_language: String)

signal _on_top_bar_positions_changed


var config := ConfigFile.new()


func _ready() -> void:
	# Loading settings
	if FileAccess.file_exists(ProjectSettings.get_setting("globals/path/settings")):
		config.load(ProjectSettings.get_setting("globals/path/settings"))
	
	TranslationServer.set_locale(get_language())
	get_viewport().set_embedding_subwindows(get_embed_subwindows())


func _save_settings() -> void:
	config.save(ProjectSettings.get_setting("globals/path/settings"))


func open_settings_popup() -> void:
	var popup_name := "settings_popup"
	if get_tree().root.has_node(popup_name):
		get_tree().root.get_node(popup_name).visible = true
		return
	var popup: Window = preload(
		"res://ui/popups/settings_menu/settings_menu.tscn").instantiate()
	popup.name = popup_name
	get_tree().root.add_child(popup)


func open_project_settings_popup() -> void:
	var popup_name := "project_settings_popup"
	if get_tree().root.has_node(popup_name):
		get_tree().root.get_node(popup_name).visible = true
		return
	var popup: Window = preload(
		"res://ui/popups/project_settings_menu/project_settings_menu.tscn").instantiate()
	popup.name = popup_name
	get_tree().root.add_child(popup)

#################################################################
##
##      GENERAL  -  GETTERS AND SETTERS
##
#################################################################

###############################################################
#region Setting: Language  ####################################
###############################################################

func get_language() -> String:
	return config.get_value("general", "language", "en")


func set_language(new_language: String) -> void:
	config.set_value("general", "language", new_language)
	TranslationServer.set_locale(new_language)
	_on_language_changed.emit(new_language)
	_save_settings()

#endregion
###############################################################


#################################################################
##
##      TIMELINE  -  GETTERS AND SETTERS
##
#################################################################

###############################################################
#region Default video tracks  #################################
###############################################################

func get_default_video_tracks() -> int:
	return config.get_value("timeline", "default_video_tracks", 3)


func set_default_video_tracks(new_default: int) -> void:
	config.set_value("timeline", "default_video_tracks", new_default)
	_save_settings()

#endregion
###############################################################
#region Default audio tracks  #################################
###############################################################

func get_default_audio_tracks() -> int:
	return config.get_value("timeline", "default_audio_tracks", 3)


func set_default_audio_tracks(new_default: int) -> void:
	config.set_value("timeline", "default_audio_tracks", new_default)
	_save_settings()

#endregion
###############################################################

#################################################################
##
##      TOP BAR MENU  -  GETTERS AND SETTERS
##
#################################################################

###############################################################
#region Top Bar menu position  ################################
###############################################################

func get_top_bar_menu_position(button_name: String) -> int:
	return config.get_value("top_bar", "button_%s" % button_name, 0)


func set_top_bar_menu_position(button_name: String, new_pos: int) -> void:
	# TODO: Add a way to change this through the settings menu.
	# Best way to do this is get all section keys from section "top_bar", check
	# if key starts with "button_". This way custom module buttons will also
	# show up in the list, and just add those entries dynamically to the
	# setings menu.
	# 0 = display in menu only
	# 1 = only next to editor button
	# 2 = display on both places
	config.set_value("top_bar", "button_%s" % button_name, new_pos)
	_save_settings()
	_on_top_bar_positions_changed.emit()

#endregion
#################################################################
##
##      Viewport  -  GETTERS AND SETTERS
##
#################################################################

###############################################################
#region Embed subwindows  #####################################
###############################################################

func get_embed_subwindows() -> bool:
	return config.get_value("viewport", "embed_subwindows", true)


func set_embed_subwindows(value: bool) -> void:
	get_viewport().set_embedding_subwindows(value)
	config.set_value("viewport", "embed_subwindows", value)
	_save_settings()

#region
###############################################################
