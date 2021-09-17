extends Node

onready var scenes = {
    'player': preload("res://src/Player.tscn"),
    'peer': preload("res://src/Peer.tscn"),
    'test_world': preload("res://src/scenes/TestWorld.tscn"),
    'hangar': preload("res://src/scenes/Hangar.tscn"),
}

onready var ships = {
    'reaver': preload("res://src/ships/reaver/Reaver.tscn"),
    'mosquito': preload("res://src/ships/mosquito/Mosquito.tscn"),
    'liberator': preload("res://src/ships/liberator/Liberator.tscn"),
}


onready var World = get_node('/root/Main/World')
onready var Ships = get_node('/root/Main/Ships')
onready var Players = get_node('/root/Main/Players')

func _ready():
    pass

func on_local_pressed():
    Game.load_world('test_world')
    create_player(0)
    MainMenu.Spawn.show()

remote func load_world(name):
    if World.get_child_count():
        World.get_child(0).queue_free()

    var world = scenes[name].instance()
    World.add_child(world)

    if world.get_node('Camera'):
        world.get_node('Camera').current = true

remotesync func create_player(id):
    var player         

    if id == Network.net_id:
        player = scenes['player'].instance()
        player.set_network_master(Network.net_id)
    else:
        player = scenes['peer'].instance()

    player.name = str(id)
    Players.add_child(player)

remotesync func remove_player(id):
    if Ships.get_node(str(id)):
        Ships.get_node(str(id)).queue_free()
    
    Players.get_node(str(id)).queue_free()

func spawn_pressed(data):
    var id = Network.net_id

    if Network.connected:
        rpc('spawn_ship', id, data)
    else:
        if Ships.has_node(str(id)):
            var player = Players.get_node(str(id))
            if player:
                player.leave_ship()
            Ships.get_node(str(id)).kill()
        spawn_ship(id, data)

var next_spawn = 1
remotesync func spawn_ship(id, data):
    if Ships.has_node(str(id)):
        return

    var spawn_origin = World.get_child(0).get_node('Spawnpoints')
    var spawn = spawn_origin.get_node(str(next_spawn))
    next_spawn = ((next_spawn + 1) % 4) + 1

    if data['name'] in ships:
        var ship = ships[data['name']].instance()
        ship.name = str(id)
        ship.data = data
        Ships.add_child(ship)
        ship.equip('weapons', 'nosegun', data['nosegun'])
        ship.global_transform = spawn.global_transform
        ship.look_at(spawn_origin.global_transform.origin, Vector3.UP)
        Players.get_node(str(id)).enter_ship(ship)
    
    var display_name = ''
    if id == Network.net_id:
        display_name += 'my '
    display_name += data['name']

func _physics_process(delta):
    if Network.connected:
        if is_network_master():
            for ship in get_tree().get_nodes_in_group('ships'):
                if ship.dead:
                    var player = Players.get_node(ship.name)
                    if player:
                        player.leave_ship()
                    ship.rpc('kill')
