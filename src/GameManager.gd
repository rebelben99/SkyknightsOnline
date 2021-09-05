extends Node


func _ready():
    InputManager.connect('input_event', self, '_handle_input_event')
    print('GameManager initialized')


func _handle_input_event(action, state):
    pass

func _process(delta):
    pass