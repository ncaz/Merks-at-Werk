extends Control

const ShopEntry = preload("res://HUD/shopEntry.tscn")

@export var unlocked: Array[PowerupMove] = []

var current_category := "moves"

@onready var tabs = $CanvasLayer/TabContainer
@onready var item_list = $CanvasLayer/TabContainer/Moves/ScrollContainer/ItemList
@onready var power_list = $CanvasLayer/TabContainer/power/ScrollContainer/ItemList
@onready var moves_button = $CanvasLayer/MovesButton
@onready var powerup_button = $CanvasLayer/PowerupButton
@onready var close_button = $CanvasLayer/CloseButton

var unlock_ids_0: Array[StringName] = ["dash"]
var unlock_ids_1: Array[StringName] = []
var unlock_ids_2: Array[StringName] = []
var current_avaliable_ids: Array[StringName] = []


func _ready() -> void:
	moves_button.pressed.connect(show_category.bind("moves"))
	powerup_button.pressed.connect(show_category.bind("powerup"))
	close_button.pressed.connect(close)
	for entry in power_list.get_children():
		if entry.has_signal("purchased"):
			entry.purchased.connect(refresh)
		else:
			push_warning("Entry '%s' has no powerupEntry script attached" % entry.name)
	open()


func open() -> void:
	show()
	show_category(current_category)


func close() -> void:
	hide()


func show_category(category: String) -> void:
	current_category = category
	tabs.current_tab = 0 if category == "moves" else 1
	refresh()


func refresh() -> void:
	for child in item_list.get_children():
		child.queue_free()

	for ability in unlocked:
		if ability.category != current_category:
			continue
		var entry = ShopEntry.instantiate()
		item_list.add_child(entry)
		entry.setup(ability)
		entry.set_state(is_owned(ability), can_afford(ability))
		entry.buy_pressed.connect(_on_buy_pressed)

	for entry in power_list.get_children():
		if entry.has_method("refresh"):
			entry.refresh()


func is_owned(ability: PowerupMove) -> bool:
	return ability.id in Globals.owned_ids


func can_afford(ability: PowerupMove) -> bool:
	return true


func _on_buy_pressed(ability: PowerupMove) -> void:
	if is_owned(ability) or not can_afford(ability):
		return

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("Shop: no node in group 'player'")
		return

	Globals.dollars -= ability.cost
	Globals.owned_ids.append(ability.id)
	ability.apply(player)
	refresh()
