extends 'res://src/ships/BaseShip.gd'

var max_health = 3000
var current_health = max_health

export(String, 'none', 'mustang', 'vortek') var nosegun = 'none'

func _ready():
	ship_dir = 'res://src/ships/reaver/'
	seating_diagram = ship_dir + 'reaver_seating_diagram.png'
	seating_diagram_outline = ship_dir + 'reaver_seating_diagram_outline.png'

	slots = {
		'weapons': {
			'nosegun': {
				'none': null,
				'mustang': "weapons/mustang/Mustang.tscn",
				'vortek': "weapons/vortek/Vortek.tscn",
			},
			'pylons': {
				'none': null,
				'tanks': "weapons/tanks/Tanks.tscn",
				'rocket_pods': "weapons/rocket_pods/RocketPods.tscn",
			},
		}
	}

	inventory = {
		'weapons': {
			'nosegun': null,
			'pylons': null,
		}
	}

	mass = 10
	linear_damp = 1
	angular_damp = 3

	$Engine.max_speed = 150
	$Engine.acceleration = 0.6
	$Engine.hover_thrust = 45
	$Engine.up_thrust = 500
	$Engine.down_thrust = 300
	$Engine.vertical_decay = 0.98
	$Engine.throttle_accel = 15
	$Engine.throttle_brake = 20
	$Engine.throttle_max = 1000
	$Engine.pitch_speed = 75
	$Engine.roll_speed = 75
	$Engine.yaw_speed = 15

	if nosegun != 'none':
		equip('weapons', 'nosegun', nosegun)

func set_camera(number=1):
	if number:
		$Seat1/FirstPersonCamera.set_current()
		$Cockpit.show()
		$Chassis.hide()
	else:
		$Seat1/ThirdPersonCamera.set_current()
		$Cockpit.hide()
		$Chassis.show()

func set_freelook(pos):
	$Seat1/FirstPersonCamera.yaw(-pos.x)
	$Seat1/FirstPersonCamera.pitch(pos.y)

func reset_freelook():
	$Seat1/FirstPersonCamera.reset()

func switch_weapon(number):
	print(number)

func give_ammo():
	print('getting ammo')
	current_weapon.give_ammo()

func _process(delta):
	if current_health <= 0:
		queue_free()
