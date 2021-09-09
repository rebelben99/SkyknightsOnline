extends Control

var health setget set_health
var max_health setget set_max_health
var top_texture setget set_top_texture
var bottom_texture setget set_bottom_texture

func _ready():
    pass


func set_health(value):
    $Health.text = str(value)
    $Progress.value = value

func set_max_health(value):
    $Progress.max_value = value

func set_top_texture(texture):
    $Progress.texture_progress = texture

func set_bottom_texture(texture):
    $Progress.texture_under = texture
