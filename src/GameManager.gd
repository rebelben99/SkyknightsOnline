extends Node

var player_state_collection = {}

var connected = false 
var network_id = 0 setget , get_network_id

func _ready():
    pass

func get_network_id():
    if connected:
        return get_tree().get_network_unique_id()
    else:
        return 0

remote func recieve_player_state(player_state):
    var player_id = get_tree().get_rpc_sender_id()
    if player_state_collection.has(player_id):
        if player_state_collection[player_id]['time'] < player_state['time']:
            pass
        else:
            print('not newer')

var previous_state = {}
func send_player_state(player_state):
    var state_diff = {'time': OS.get_system_time_msecs()}

    for action in player_state:
        if action in previous_state:
            pass
        else:
            previous_state[action] = null

        if previous_state[action] != player_state[action]:
            state_diff[action] = player_state[action]
            previous_state[action] = player_state[action]

    # if current_time > 0.5:
    #     current_time = 0.0
        
    #     rpc_unreliable_id(1, 'network_update', input_state)
    # else:
    #     rpc_unreliable_id(1, 'network_update', state_diff)

    rpc_unreliable_id(1, 'recieve_player_state', state_diff)

remote func recieve_world_state(world_state):
    pass


func _physics_process(delta):
    pass
