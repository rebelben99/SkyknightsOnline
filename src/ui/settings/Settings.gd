extends TabContainer

var settings_file = 'settings.json'

var settings = {}
var settings_on_disk = {}

var need_to_save = false

func _ready():
    load_settings()
    hide()

func toggle_visibility():
    save_settings()
    if visible:
        hide()
    else:
        show()

func _input(event):
    if not visible:
        return

    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_ESCAPE:
            toggle_visibility()

func register(setting):
    var path = setting.get_path()
    settings[str(path).right(15)] = setting
    setting.connect('value_changed', self, 'request_save')

func request_save(_value):
    need_to_save = true

func read(path):
    if path in settings:
        return settings[path]
    else:
        return null

func connect_to(path, object, method):
    if path in settings:
        read(path).connect('value_changed', object, method)
        object.call(method, read(path).value)

func save_settings():
    var data = {}
    for setting in settings:
        settings[setting].emit()
        var value = settings[setting].value
        if setting in settings_on_disk or value != settings[setting].default_value:
            data[setting] = value
    var json = JSON.print(data, "\t")
    var f = File.new()
    f.open(settings_file, File.WRITE)
    f.store_string(json)
    f.close()

func load_settings():
    var f = File.new()
    if f.file_exists(settings_file):
        f.open(settings_file, File.READ)
        var text = f.get_as_text()
        f.close()
        var result = JSON.parse(text).result
        if result is Dictionary:
            for setting in result:
                if setting in settings:
                    settings[setting].value = result[setting]
                settings_on_disk[setting] = result[setting]
