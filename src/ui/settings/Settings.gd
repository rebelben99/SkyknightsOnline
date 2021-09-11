extends TabContainer

var settings_file = 'settings.json'

var settings = {}
var settings_on_disk = {}

onready var MouseFlight = $Controls/Mouse/Flight
onready var MouseFreeLook = $Controls/Mouse/FreeLook
onready var MouseTurret = $Controls/Mouse/Turret

var need_to_save = false

func _ready():
    load_settings()
    hide()

func toggle_visibility():
    if visible:
        if need_to_save:
            save_settings()
        hide()
    else:
        show()

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

func save_settings():
    var f = File.new()
    f.open(settings_file, File.WRITE)
    var data = {}
    for setting in settings:
        var value = settings[setting].value
        if setting in settings_on_disk or value != settings[setting].starting_value:
            data[setting] = value
    var json = JSON.print(data, "\t")
    f.store_string(json)
    f.close()

func load_settings():
    var f = File.new()
    if f.file_exists(settings_file):
        f.open(settings_file, File.READ)
        var text = f.get_as_text()
        var result = JSON.parse(text).result
        if result is Dictionary:
            for setting in result:
                settings[setting].value = result[setting]
                settings_on_disk[setting] = result[setting]
        f.close()
