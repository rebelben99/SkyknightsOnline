extends Node

func parse_cmd_args():
    # default args
    var args = {
        'server': 0,
        'connect': 0,
    }
    for arg in OS.get_cmdline_args():
        if arg.find("=") > -1:
            var key_value = arg.split("=")
            args[key_value[0].lstrip("--")] = key_value[1]
    return args

func _ready():
    var args = parse_cmd_args()

    if args['server']:
        HUD.Chat.show()
        Network.create_server()
        OS.set_window_title('Skyknights Online - Server')
        MainMenu.hide()
    elif args['connect']:
        Network.join_server()
        MainMenu.Spawn.connect('spawn_pressed', Game, 'spawn_pressed')
    else:
        MainMenu.Connect.connect('pressed', Network, 'join_server')
        MainMenu.Local.connect('pressed', Game, 'on_local_pressed')
        MainMenu.Spawn.hide()
        Game.load_world('hangar')
        MainMenu.Spawn.connect('spawn_pressed', Game, 'spawn_pressed')
