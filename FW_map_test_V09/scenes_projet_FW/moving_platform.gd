extends Node2D

#--------------------------------------------------
#- Export variables, described on the documentation     
#--------------------------------------------------

export(NodePath) var moving_pLateform_main_body
export var motion = Vector2()
export var motion_speed = 0.0
export var rotation_speed = 0.0
enum node_impact {clock_wise = 1, un_clock_wise = 2}
export (node_impact) var rotation_side

#
var accum = 0.0

#---------------------------------------------------------------------------------------------------------------------------
#- FUNC _integrate_forces (similar to process function, integrate_forces is able to interact with your Node state)
#---------------------------------------------------------------------------------------------------------------------------

func _physics_process(delta):
	
	#adapt the Node speed
	if motion_speed > 0:
		accum += delta * (1.0 / motion_speed) * PI * 2.0
		accum = fmod(accum, PI * 2.0)
		var d = sin(accum)
		var xf = Transform2D()
		xf[2]= motion * d 
		get_node(moving_pLateform_main_body).transform = xf
	if rotation_side and rotation_speed: 
		if rotation_side == 1:
			
			#apply the rotation
			rotation += rotation_speed
		else:
			rotation -= rotation_speed