extends Control

@export var crt_toggle: BaseButton

#most logic is in autoload file
func _ready() -> void:
	if crt_toggle:
		crt_toggle.button_pressed = CrtSettings.enabled
		if not crt_toggle.toggled.is_connected(_on_crt_toggle_toggled):
			crt_toggle.toggled.connect(_on_crt_toggle_toggled)


func _on_crt_toggle_toggled(toggled_on: bool) -> void:
	CrtSettings.set_crt_enabled(toggled_on)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://HUD/main_menu.tscn")
