extends RigidBody

var ship_dir = "res://src/ships/liberator/"

var slots = {
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

var inventory = {
    'weapons': {
        'nosegun': null,
        'bellygun': null,
        'tailgun': null,
    }
}

var max_health = 4500
var current_health = max_health

export(String, 'none', 'mustantank_busterg', 'vektor', 'spur') var nosegun = 'none'

var pitch_input = 0.0
var yaw_input = 0.0
var roll_input = 0.0
var input_state = {}

func _ready():
    mass = 20
    linear_damp = 1
    angular_damp = 3

    # $Engine.yaw_speed

    if nosegun != 'none':
        equip('weapons', 'nosegun', nosegun)

    for action in InputManager.actions:
        input_state[action] = false

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

func equip(category, item_type, item_name):
    if !(category in slots):
        return
    if !(item_type in slots[category]):
        return
    if !(item_name in slots[category][item_type]):
        return

    if inventory[category][item_type]:
        var prev_item = inventory[category][item_type]
        if prev_item:
            prev_item.queue_free()

    var item_dir = slots[category][item_type][item_name]
    if !item_dir:
        inventory[category][item_type] = null
        return
    
    var item = load(ship_dir + item_dir).instance()
    inventory[category][item_type] = item
    if item_type == 'nosegun':
        $Nosegun.add_child(item)
    if item_type == 'bellygun':
        $Bellygun.add_child(item)

func _process(delta):
    if current_health <= 0:
        print('i am kil')

    if $Nosegun.get_child_count():
        if input_state['reload']:
            $Nosegun.get_child(0).reload()
        var weapon = $Nosegun.get_child(0)
        weapon.update(delta, input_state['fire_primary'])

func _physics_process(delta):
    $Engine.calculate_forces(input_state, pitch_input, yaw_input, roll_input)

    apply_torque_impulse($Engine.torque * delta)
    apply_central_impulse($Engine.velocity * delta)
