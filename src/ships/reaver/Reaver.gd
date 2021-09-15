extends 'res://src/ships/BaseShip.gd'

export(String, 'none', 'mustang', 'vortek') var nosegun = 'none'

var wing_angle = 0
var wing_turn_speed = 0.05

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

    $Health.maximum = 3000
    
    mass = 10
    linear_damp = 1
    angular_damp = 3

    $Engine.max_speed = 150
    $Engine.acceleration = 0.6
    $Engine.hover_thrust = 45
    $Engine.up_thrust = 750
    $Engine.down_thrust = 500
    $Engine.vertical_decay = 0.98
    $Engine.throttle_accel = 15
    $Engine.throttle_brake = 20
    $Engine.throttle_max = 1500
    $Engine.pitch_speed = 75
    $Engine.roll_speed = 75
    $Engine.yaw_speed = 15

    if nosegun != 'none':
        equip('weapons', 'nosegun', nosegun)

func switch_weapon(number):
    print(number)

func give_ammo():
    if current_weapon:
        current_weapon.give_ammo()

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
