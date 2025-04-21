extends Node

const MAIN_MENU_UID = "uid://dfuudoym2pnvu"

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		print("Quitting to main menu")
		get_tree().change_scene_to_file(MAIN_MENU_UID)
	
	if Input.is_action_just_pressed("take_screenshot"):
		print("Screenshot!")
		var img = get_tree().current_scene.get_viewport().get_texture().get_image()
		
		var dir = DirAccess.open("res://")
		dir.make_dir("screenshots")
		
		var screenshots_dir = DirAccess.open("res://screenshots")
		var index = screenshots_dir.get_files().size()
		
		var result = img.save_png("res://screenshots/screenshot_%d_%s.png" % [index, get_tree().current_scene.name.to_snake_case()])
		print("Screenshot saved: %s" % error_string(result))
		
