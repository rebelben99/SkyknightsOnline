extends 'res://src/ships/BaseShip.gd'

var max_health = 8000
var current_health = max_health

func _ready():
    ship_dir = 'res://src/ships/galaxy/'
    seating_diagram = ship_dir + 'galaxy_seating_diagram.png'
    seating_diagram_outline = ship_dir + 'galaxy_seating_diagram_outline.png'

    slots = {
        'weapons': {
        }
    }

    inventory = {
    }

    mass = 40
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

    $Cockpit.hide()

    for action in InputManager.actions:
        input_state[action] = false

func _process(delta):
    if current_health <= 0:
        queue_free()
