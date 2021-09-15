extends 'res://src/ships/BaseShip.gd'


export(String, 'none', 'tank_buster', 'vektor', 'spur') var nosegun = 'none'

var wing_angle = 0
var wing_turn_speed = 0.01

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

    $Health.maximum = 4500

    mass = 15
    linear_damp = 1
    angular_damp = 3

    $Engine.max_speed = 150
    $Engine.acceleration = 0.6
    $Engine.hover_thrust = 100
    $Engine.up_thrust = 500
    $Engine.down_thrust = 300
    $Engine.vertical_decay = 0.98
    $Engine.throttle_accel = 25
    $Engine.throttle_brake = 35
    $Engine.throttle_max = 1500
    $Engine.pitch_speed = 50
    $Engine.roll_speed = 50
    $Engine.yaw_speed = 20

    if nosegun != 'none':
        equip('weapons', 'nosegun', nosegun)

func _physics_process(delta):
    var target_wing_angle = -90
    target_wing_angle += $Engine.throttle / 10
    target_wing_angle = clamp(target_wing_angle, -90, 0)
    
    wing_angle = lerp(wing_angle, target_wing_angle, wing_turn_speed)
    
    $Model/Wings.rotation_degrees.x = wing_angle
    
    if current_weapon:
        current_weapon.firing = input_state['fire_primary']
        if input_state['reload']:
            current_weapon.reload()
