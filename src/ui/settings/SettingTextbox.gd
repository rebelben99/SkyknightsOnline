extends HBoxContainer

export var setting_name = 'auto'
export var description = ''
export var default_value = ''
var value = '' setget set_value

signal value_changed(value)

func _ready():
    Settings.register(self)

    if setting_name == 'auto':
        $Name.text = name
    else:
        $Name.text = setting_name
    
    $Description.text = description

    set_value(default_value)

    $LineEdit.connect('text_entered', self, 'line_changed')

func emit():
    value = $LineEdit.text
    emit_signal('value_changed', value)

func set_value(new_value):
    value = new_value
    $LineEdit.text = new_value

func line_changed(text):
    value = text
    emit()
