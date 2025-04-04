extends Button
var mapselected: int
const test_map = preload("res://Maps/test_map/test_map.tscn")
const main_map = preload("res://Maps/main_map/main_map.tscn")
const maps = {
	0: test_map,
	1: main_map,
}


func _on_item_list_item_selected(index: int) -> void:
	mapselected = index


func _on_pressed() -> void:
	get_tree().change_scene_to_packed(maps.get(mapselected))
