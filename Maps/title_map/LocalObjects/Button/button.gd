extends Button
var mapselected: int
const test_map: String = ("res://Maps/test_map/test_map.tscn")
const main_map: String = ("res://Maps/main_map/main_map.tscn")
const light_test_map: String = ("res://Maps/light_test_map/light_test_map.tscn")
const maps: Dictionary = {
	0: test_map,
	1: main_map,
	2: light_test_map,
}


func _on_item_list_item_selected(index: int) -> void:
	mapselected = index


func _on_pressed() -> void:
	#get_tree().change_scene_to_packed(maps.get(mapselected))
	get_tree().root.get_child(0).load_level(maps.get(mapselected))
