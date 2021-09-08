extends 'res://src/ships/BaseShip.gd'

var max_health = 4500
var current_health = max_health

export(String, 'none', 'tank_buster', 'vektor', 'spur') var nosegun = 'none'

func _ready():
    ship_dir = 'res://src/ships/liberator/'
    seating_diagram = ship_dir + 'liberator_seating_diagram.png'
    seating_diagram_outline = ship_dir + 'liberator_seating_diagram_outline.png'

    slots = {
        'weapons': {
            'nosegun': {
                'none': null,
                'tank_buster': "weapons/tank_buster/TankBuster.tscn",
                'vektor': "weapons/vektor/Vektor.tscn",
                'spur': "weapons/spur/Spur.tscn",
            },
            'bellygun': {
                'none': null,
                'shredder': "weapons/shredder/Shredder.tscn",
                'dalton': "weapons/dalton/Dalton.tscn",
                'zephyr': "weapons/zephyr/Zephyr.tscn",
            },
            'tailgun': {
                'none': null,
            },
        }
    }

    inventory = {
        'weapons': {
            'nosegun': null,
            'bellygun': null,
            'tailgun': null,
        }
    }

    seats = {
        0: {'occupied': false},
        1: {'occupied': false},
        2: {'occupied': false},
    }

    mass = 20
    linear_damp = 1
    angular_damp = 3

    $Engine.max_speed = 150
    $Engine.acceleration = 0.6
    $Engine.hover_thrust = 100
    $Engine.up_thrust = 500
    $Engine.down_thrust = 300
    $Engine.vertical_decay = 0.98
    $Engine.throttle_accel = 10
    $Engine.throttle_brake = 15
    $Engine.throttle_max = 200
    $Engine.pitch_speed = 50
    $Engine.roll_speed = 50
    $Engine.yaw_speed = 20

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

func enter_seat(seat_number):
    if !seats[seat_number]['occupied']:
        seats[seat_number]['occupied'] = true
    print('switching to seat #', seat_number)

func reset_freelook():
    $Seat1/FirstPersonCamera.reset()

func _process(delta):
    if current_health <= 0:
        queue_free()
