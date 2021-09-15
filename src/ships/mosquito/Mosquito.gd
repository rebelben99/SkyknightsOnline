extends 'res://src/ships/BaseShip.gd'


export(String, 'none', 'needler', 'rotary', 'banshee') var nosegun = 'none'

func _ready():
    ship_dir = 'res://src/ships/mosquito/'
    seating_diagram = ship_dir + 'mosquito_seating_diagram.png'
    seating_diagram_outline = ship_dir + 'mosquito_seating_diagram_outline.png'

    slots = {
        'weapons': {
            'nosegun': {
                'none': null,
                'needler': "weapons/needler/Needler.tscn",
                'rotary': "weapons/rotary/Rotary.tscn",
                'banshee': "weapons/banshee/Banshee.tscn",
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

func switch_weapon(number):
    print(number)

func give_ammo():
    current_weapon.give_ammo()

func _physics_process(delta):
    if current_weapon:
        current_weapon.firing = input_state['fire_primary']
        if input_state['reload']:
            current_weapon.reload()
