extends Control

onready var ChatLog = get_node("VBoxContainer/RichTextLabel")
onready var InputLabel = get_node("VBoxContainer/HBoxContainer/Label")
onready var InputField = get_node("VBoxContainer/HBoxContainer/LineEdit")

var last_dm_sender = ''
var history = []
var history_pos = 0

var groups = [
    {'name': 'Global', 'color': '#ffffff'},
    {'name': 'Team', 'color': '#00abc7'},
    {'name': 'Match', 'color': '#ffdd8b'},
]
var group_index = 0

func _ready():
    InputField.connect("text_entered", self,'text_entered')
    change_group(0)
    Network.connect('chat_message_received', self, 'add_message')

func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_UP:
            if InputField.has_focus():
                InputField.clear()
                InputField.append_at_cursor(history[history_pos])
                if history_pos < history.size():
                    history_pos += 1
        if event.pressed and event.scancode == KEY_DOWN:
            if InputField.has_focus():
                InputField.clear()
                if history_pos > 0:
                    history_pos -= 1
                InputField.append_at_cursor(history[history_pos])
        if event.pressed and event.scancode == KEY_BACKSPACE:
            InputField.grab_focus()
            InputField.clear()
            InputField.append_at_cursor('@' + last_dm_sender + ' ')
            # InputField.caret_position = 
        if event.pressed and event.scancode == KEY_ESCAPE:
            InputField.release_focus()
        # if InputField.has_focus():
        #     if event.pressed and event.scancode == KEY_TAB:
        #         change_group(1)

func change_group(value):
    group_index += value
    if group_index > (groups.size() - 1):
        group_index = 0
    InputLabel.text = '[' + groups[group_index]['name'] + ']'
    InputLabel.set("custom_colors/font_color", Color(groups[group_index]['color']))
    
func add_message(username, text, group = 0, color = ''):
    if username == 'Server':
        color = '#ffdd8b'
    if text.begins_with('@'):
        color = '#19C8C7'
        last_dm_sender = username
        if username == 'You':
            color = '#00abc7'
    
    ChatLog.bbcode_text += '\n' 
    if color == '':
        ChatLog.bbcode_text += '[color=' + groups[group]['color'] + ']'
    else:
        ChatLog.bbcode_text += '[color=' + color + ']'
    if username != '':
        ChatLog.bbcode_text += '[' + username + ']: '
    ChatLog.bbcode_text += text
    ChatLog.bbcode_text += '[/color]'

func text_entered(text):
    if text =='/h':
        add_message('', 'There is no help message yet!', 0, '#ff5757')
        InputField.text = ''		
        return
    if text != '':
        history.insert(0, text)
        history_pos = 0
        Network.send_message(text)
        InputField.text = ''
