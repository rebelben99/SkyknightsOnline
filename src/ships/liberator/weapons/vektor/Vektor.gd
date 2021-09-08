extends 'res://src/ships/BaseWeapon.gd'

func _ready():
    magazine_capacity = 50
    magazine = magazine_capacity
    ammo_capacity = 500
    ammo = ammo_capacity
    rounds_per_minute = 400.0
    reload_time = 4.0
    muzzle_velocity = 200
    damage = 240

    crosshair = 'res://src/ships/reaver/weapons/mustang/mustang_crosshair.png'
