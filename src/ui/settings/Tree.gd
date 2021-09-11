extends Tree


func _ready():
    columns = 2
    set_hide_root(true)
    set_column_titles_visible(true)
    set_column_title(0, 'Action')
    set_column_title(1, 'Key')
    # set_column_clip_content(0, true)
#    connect('item_edited', self, '_action_edited')
    var tex = load('res://icon.png')
    for action in InputManager.actions:
        var item = create_item()
        item.set_text(0, action)
        item.add_button(1, tex)
#        if 'key' in InputManager.actions[action]:
#            item.set_text(1, InputManager.actions[action]['key'])
    connect('button_pressed', self, '_button_pressed')
    
func _button_pressed(item, col, id):
    print(item, col, id)
