extends Control

@export var hover_pointer: TextureRect
@export var buttons: Array[Button] = []

@export var pointer_offset: Vector2 = Vector2(-40, 0)
@export var tween_duration: float = 0.15
@export var pause_menu : Control

var current_tween: Tween

func _ready() -> void:
	hover_pointer.visible = false
	hover_pointer.modulate.a = 0.0

	for button in buttons:
		button.mouse_entered.connect(_on_button_hover.bind(button))
		button.mouse_exited.connect(_on_button_unhover)
		
	if !Dialogic.is_node_ready():
		await Dialogic.ready
	Dialogic.start("test_timeline")

func _on_button_hover(button: Control) -> void:
	hover_pointer.visible = true
	

	var target_pos = button.global_position + Vector2(0, button.size.y / 2.0) + pointer_offset
	hover_pointer.global_position = target_pos

	if current_tween:
		current_tween.kill()
	current_tween = create_tween()
	current_tween.tween_property(hover_pointer, "modulate:a", 1.0, tween_duration)

func _on_button_unhover() -> void:
	if current_tween:
		current_tween.kill()
	current_tween = create_tween()
	current_tween.tween_property(hover_pointer, "modulate:a", 0.0, tween_duration)
	current_tween.tween_callback(func(): hover_pointer.visible = false)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Main/main.tscn")

	

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://HUD/options.tscn")


func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_menu.visible = false
