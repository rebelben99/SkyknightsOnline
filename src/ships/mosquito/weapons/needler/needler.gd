extends 'res://src/ships/BaseWeapon.gd'

func _ready():
    magazine_capacity = 75
    magazine = magazine_capacity
    ammo_capacity = 900
    ammo = ammo_capacity
    rounds_per_minute = 750
    reload_time = 2.5
    muzzle_velocity = 400
    damage = 190

    crosshair = 'res://src/ships/reaver/weapons/mustang/mustang_crosshair.png'
