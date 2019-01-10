extends RigidBody2D

#--------------------------------------------------
#- Export variables, described on the documentation     
#--------------------------------------------------

export(String) var move_left_control
export(String) var move_right_control
export(String) var move_jump_control

export(NodePath) var player_main_sprite

export var WALK_ACCELLERATION = 1500
export var WALK_DEACCELLERATION = 10000
export var WALK_MAX_SPEED = 12000
export var AIR_ACCEL = 200.0
export var AIR_DEACCEL = 200.0
export var JUMP_VELOCITY = 350
export var FALLING_FORCE = 20

export(String, FILE) var dead_instanced_scene

var siding_left = false
var jumping = false
var stopping_jump = false
var MAX_FLOOR_AIRBORNE_TIME = 0.01

var airborne_time = 1e20

var s = 0.0

#-------------------------------------------------------------------------------------------------
#- FUNC Ready (Read on the enter of the Node on the Tree)
#-------------------------------------------------------------------------------------------------

func _ready():
	set_contact_monitor(true)
	pass

#---------------------------------------------------
#- FUNC process (function called each frame)
#---------------------------------------------------

func _process(delta):
	
	#check coliding bodies
	var coliBodies = get_colliding_bodies()
	for body in coliBodies :
		
		#if colided body is part of the "enemi" group, PLayer die
		if body.is_in_group("enemi") == true and dead_instanced_scene:
			get_tree().change_scene(dead_instanced_scene)

#---------------------------------------------------------------------------------------------------------------------------
#- FUNC _integrate_forces (similar to process function, integrate_forces is able to interact with your Node state)
#---------------------------------------------------------------------------------------------------------------------------

func _integrate_forces(s):
	
	var lv = s.get_linear_velocity()
	var step = s.get_step()
	
	var new_siding_left = siding_left
	var move_left = Input.is_action_pressed(move_left_control)
	var move_right = Input.is_action_pressed(move_right_control)
	var jump = Input.is_action_pressed(move_jump_control)
	
	# Deapply prev floor velocity
	lv.x -= floor_h_velocity
	floor_h_velocity = 0.0
	
	# Find the floor (a contact with upwards facing collision normal)
	var found_floor = false
	var floor_index = -1
	
	for x in range(s.get_contact_count()):
		var ci = s.get_contact_local_normal(x)
		if ci.dot(Vector2(0, -1)) > 0.6:
			found_floor = true
			floor_index = x

	if found_floor:
		airborne_time = 0.0
	else:
		airborne_time += step # Time it spent in the air
	
	var on_floor = airborne_time < MAX_FLOOR_AIRBORNE_TIME

	# Process jump
	if jumping:
		if lv.y > 0:
			# Set off the jumping flag if going down
			jumping = false
		elif not jump:
			stopping_jump = true
		
		if stopping_jump:
			lv.y += FALLING_FORCE * step
	
	if on_floor:
		# Process logic when character is on floor
		if move_left and not move_right:
			if lv.x > -WALK_MAX_SPEED:
				lv.x -= WALK_ACCELLERATION * step
		elif move_right and not move_left:
			if lv.x < WALK_MAX_SPEED:
				lv.x += WALK_ACCELLERATION * step
		else:
			var xv = abs(lv.x)
			xv -= WALK_DEACCELLERATION * step
			if xv < 0:
				xv = 0
			lv.x = sign(lv.x) * xv
		
		# Check jump
		if not jumping and jump:
			lv.y = -JUMP_VELOCITY
			jumping = true
			stopping_jump = false
		
		# Check siding
		if lv.x < 0 and move_left:
			new_siding_left = true
		elif lv.x > 0 and move_right:
			new_siding_left = false
	else:
		# Process logic when the character is in the air
		if move_left and not move_right:
			if lv.x > -WALK_MAX_SPEED:
				lv.x -= AIR_ACCEL * step
		elif move_right and not move_left:
			if lv.x < WALK_MAX_SPEED:
				lv.x += AIR_ACCEL * step
		else:
			var xv = abs(lv.x)
			xv -= AIR_DEACCEL * step
			if xv < 0:
				xv = 0
			lv.x = sign(lv.x) * xv
	
	# Update siding
	if new_siding_left != siding_left:
		if player_main_sprite :
			if new_siding_left:
				get_node(player_main_sprite).scale.x = -1
			else:
				get_node(player_main_sprite).scale.x = 1
		
		siding_left = new_siding_left
	
	# Apply floor velocity
	if found_floor:
		floor_h_velocity = s.get_contact_collider_velocity_at_position(floor_index).x
		lv.x += floor_h_velocity
	
	# Finally, apply gravity and set back the linear velocity
	lv += s.get_total_gravity() * step
	s.set_linear_velocity(lv)