extends Area2D

#--------------------------------------------------
#- Export variables, described on the documentation     
#--------------------------------------------------

export(NodePath) var if_node

var instanced_node_loaded_enter
var instanced_node_loaded_extire
var instanced_node_loaded_button

export(bool) var do_enter = false
export(Array, NodePath) var so_die_enter
export(Array, NodePath) var so_hide_enter
export(Array, NodePath) var so_show_enter
export(String, FILE) var so_instance_enter
export(Array, NodePath) var so_in_instance_enter
export(String, FILE) var so_loadScene_enter
export(Array, NodePath) var so_playSound_enter
export(bool) var so_killOwn_enter

export(bool) var do_extire = false
export(Array, NodePath) var so_die_extire
export(Array, NodePath) var so_hide_extire
export(Array, NodePath) var so_show_extire
export(String, FILE) var so_instance_extire
export(Array, NodePath) var so_in_instance_extire
export(String, FILE) var so_loadScene_extire
export(Array, NodePath) var so_playSound_extire
export(bool) var so_killOwn_extire

export(bool) var do_button = false
export(bool) var only_on_trigger_shape = false
export var do_press_controll = ""
export(Array, NodePath) var so_die_button
export(Array, NodePath) var so_hide_button
export(Array, NodePath) var so_show_button
export(String, FILE) var so_instance_button
export(Array, NodePath) var so_in_instance_button
export(String, FILE) var so_loadScene_button
export(Array, NodePath) var so_playSound_button
export(bool) var so_killOwn_button

var action_dict
var body_path
var varnode_selected_path = ""
var on_shape = false
var can_read = true
var just_entered = false

#-------------------------------------------------------------------------------------------------
#- FUNC Ready (Read on the enter of the Node on the Tree)
#-------------------------------------------------------------------------------------------------

func _ready() :
	if so_instance_enter :
		instanced_node_loaded_enter = load(so_instance_enter)
	if so_instance_extire :
		instanced_node_loaded_extire = load(so_instance_extire)
	if so_instance_button :
		instanced_node_loaded_button = load(so_instance_button)
	action_dict = {
		"enter":{"die":so_die_enter,"hide":so_hide_enter,"show":so_show_enter,"instance":instanced_node_loaded_enter,
		"in_instance":so_in_instance_enter,"scene":so_loadScene_enter,"sound":so_playSound_enter,"kill_own":so_killOwn_enter},
		"extire":{"die":so_die_extire,"hide":so_hide_extire,"show":so_show_extire,"instance":instanced_node_loaded_extire,
		"in_instance":so_in_instance_extire,"scene":so_loadScene_extire,"sound":so_playSound_extire,"kill_own":so_killOwn_extire},
		"button":{"die":so_die_button,"hide":so_hide_button,"show":so_show_button,"instance":instanced_node_loaded_button,
		"in_instance":so_in_instance_button,"scene":so_loadScene_button,"sound":so_playSound_button,"kill_own":so_killOwn_button}
		}
	pass

#---------------------------------------------------
#- FUNC process (function called each frame)
#---------------------------------------------------

func _process(delta):
	
	#function button
	if Input.is_action_just_pressed(do_press_controll) and do_button == true:
		if only_on_trigger_shape == true: 
			if on_shape == true:
				so_node_do("button")
				print("function so_node_do(button) can initialyse")
		else:
			so_node_do("button")
			print("function so_node_do(button) can initialyse")
	
	#function shape entered
	if self.overlaps_body(get_node(if_node)) :
		on_shape = true
		if do_enter == true and just_entered == false:
			just_entered = true
			print("function so_node_do(enter) can initialyse")
			so_node_do("enter")
	
	#function shape extired
	else :
		just_entered = false
		if on_shape == true :
			print("function so_node_do(extire) can initialyse")
			so_node_do("extire")
		on_shape = false

var where_die = false

func so_node_do(action):
	if can_read == true :
		if action_dict[action]["die"] and where_die == false:
			for node in action_dict[action]["die"]:
				make_path(node)
				if varnode_selected_path :
					varnode_selected_path.queue_free()
				where_die = true
		if action_dict[action]["hide"]:
			for node in action_dict[action]["hide"]:
				make_path(node)
				if varnode_selected_path :
					varnode_selected_path.hide()
		if action_dict[action]["show"]:
			for node in action_dict[action]["show"]:
				make_path(node)
				if varnode_selected_path :
					varnode_selected_path.show()
		if action_dict[action]["instance"] != null and action_dict[action]["in_instance"]:
			for node in action_dict[action]["in_instance"] :
				print("instance ",action_dict[action]["instance"]," in ",action_dict[action]["in_instance"])
				make_path(node)
				var instance = action_dict[action]["instance"].instance()
				if varnode_selected_path :
					varnode_selected_path.add_child(instance)
		if action_dict[action]["scene"] != null:
			get_tree().change_scene(action_dict[action]["scene"])
		if action_dict[action]["sound"]:
			for node in action_dict[action]["sound"] :
				make_path(node)
				if varnode_selected_path :
					varnode_selected_path.play()
		if action_dict[action]["kill_own"] == true:
			self.queue_free()
			can_read = false
		

func make_path(node):
	varnode_selected_path = get_node(node)