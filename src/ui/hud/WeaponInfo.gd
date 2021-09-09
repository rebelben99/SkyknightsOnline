extends VBoxContainer

var weapon_name setget set_weapon_name
var magazine setget set_magazine
var ammo setget set_ammo


func _ready():
    pass


func set_weapon_name(text):
    $Name.text = text

func set_magazine(text):
    $Ammo/Magazine.text = text

func set_ammo(text):
    $Ammo/Reserve.text = text
