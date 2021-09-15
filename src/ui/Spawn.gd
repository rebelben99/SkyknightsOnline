extends HBoxContainer

signal spawn_pressed(ship_data)

var ships = {
    'reaver': {
        'noseguns': [
            'mustang',
            'vortek',
        ],
    },
    # 'mosquito': {
    #     'noseguns': [
    #         'needler',
    #         'rotary',
    #     ],
    # },
    'liberator': {
        'noseguns': [
            'tank_buster',
            'vektor',
        ],
    },
}

func _ready():
    $Ship.connect('item_selected', self, 'on_ship_selected')
    $Spawn.connect('pressed', self, '_on_spawn_pressed')
    for ship in ships:
        $Ship.add_item(ship)

    on_ship_selected(0)

func on_ship_selected(index):
    var ship = $Ship.get_item_text(index)

    $Nosegun.clear()
    for gun in ships[ship]['noseguns']:
        $Nosegun.add_item(gun)

func _on_spawn_pressed():
    var ship = $Ship.get_item_text($Ship.selected)
    var nosegun = $Nosegun.get_item_text($Nosegun.selected)

    var ship_data = {
        'name': ship,
        'nosegun': nosegun,
    }
    emit_signal('spawn_pressed', ship_data)
