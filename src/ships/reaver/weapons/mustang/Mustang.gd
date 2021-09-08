extends 'res://src/ships/BaseWeapon.gd'

func _ready():
    magazine_capacity = 55
    magazine = magazine_capacity
    ammo_capacity = 660
    ammo = ammo_capacity
    rounds_per_minute = 667.0
    reload_time = 2.4
    muzzle_velocity = 250
    damage = 190

    crosshair = 'res://src/ships/reaver/weapons/mustang/mustang_crosshair.png'
