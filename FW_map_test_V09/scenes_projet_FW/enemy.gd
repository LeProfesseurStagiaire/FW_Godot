extends RigidBody2D

#--------------------------------------------------
#- Export variables, described on the documentation     
#--------------------------------------------------

export(bool) var stay_on_plateform
export(NodePath) var rc_left_path
export(NodePath) var rc_right_path

export(NodePath) var enemi_main_sprite

export var WALK_SPEED = 50
export(float, EXP, -1, 1, 1) var direction

#variables which will point the RayCast2D Nodes
var rc_left
var rc_right

#-------------------------------------------------------------------------------------------------
#- FUNC Ready (Read on the enter of the Node on the Tree)
#-------------------------------------------------------------------------------------------------

func _ready():
	if not direction :
		direction = 0
	
	#since the Node is attached to the "enemy" script, it is an enemy, so it is added to the "enemi" group
	self.add_to_group("enemi", true) 
	if not rc_left_path or not rc_right_path :
		print("il faut remplir les export variable des RayCast2D si vous avez coché stay_on_plateform. Pour cela, regardez la doc")
		stay_on_plateform = false
	if stay_on_plateform == true :
		rc_left = get_node(rc_left_path)
		rc_right = get_node(rc_right_path)

#---------------------------------------------------------------------------------------------------------------------------
#- FUNC _integrate_forces (similar to process function, integrate_forces is able to interact with your Node state)
#---------------------------------------------------------------------------------------------------------------------------

func _integrate_forces(s):
	
	#lv is the Node Velocity
	var lv = s.get_linear_velocity()
	
	#wall_side is the Node walk side
	var wall_side = 0.0
	for i in range(s.get_contact_count()):
		var dp = s.get_contact_local_normal(i)
		
		#if the Node is coliding, wall_side is changing it side
		if dp.x > 0.9:
			wall_side = 1.0
		elif dp.x < -0.9:
			wall_side = -1.0
	if stay_on_plateform == true :
		
		#if wall_side and direction are differents, direction change it side
		if wall_side != 0 and wall_side != direction:
			direction = -direction
			adapt_sprit_to_direction()
		
		#if RayCast2D are colliding, then change side of direction
		if direction < 0 and not rc_left.is_colliding() and rc_right.is_colliding():
			direction = -direction
			adapt_sprit_to_direction()
		elif direction > 0 and not rc_right.is_colliding() and rc_left.is_colliding():
			direction = -direction
			adapt_sprit_to_direction()

	#define the Node speed
	lv.x = direction * WALK_SPEED
	
	#modify the Node speed
	s.set_linear_velocity(lv)

#------------------------------------------------------------------------
#- FUNC adapt_sprit_to_direction
#------------------------------------------------------------------------

func adapt_sprit_to_direction():
	if enemi_main_sprite :
		get_node(enemi_main_sprite).scale.x = -direction