extends Control

const ShopEntry = preload("res://HUD/shopEntry.tscn")

@export var unlocked: Array[PowerupMove] = []

var current_category := "moves"

# Which abilities the player has bought. 
#TO DO: Move this into globals later
var owned_ids: Array[StringName] = []
@onready var item_list = $CanvasLayer/ScrollContainer/ItemList
@onready var moves_button = $CanvasLayer/MovesButton
@onready var powerup_button = $CanvasLayer/PowerupButton
@onready var close_button = $CanvasLayer/CloseButton


func _ready() -> void:
	moves_button.pressed.connect(show_category.bind("moves"))
	powerup_button.pressed.connect(show_category.bind("powerup"))
	close_button.pressed.connect(close)
	open()   # TEMP for testing; change back to hide() later


func open() -> void:
	show()
	show_category(current_category)


func close() -> void:
	hide()


func show_category(category: String) -> void:
	current_category = category
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
		


func is_owned(ability: PowerupMove) -> bool:
	return ability.id in owned_ids


func can_afford(ability: PowerupMove) -> bool:
	return true


func _on_buy_pressed(ability: PowerupMove) -> void:
	if is_owned(ability) or not can_afford(ability):
		return

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("Shop: no node in group 'player'")
		return

	Globals.gold -= ability.cost
	owned_ids.append(ability.id)
	ability.apply(player)
	refresh()  
	
	
