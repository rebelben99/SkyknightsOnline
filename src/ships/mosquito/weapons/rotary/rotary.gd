extends 'res://src/ships/BaseWeapon.gd'

func _ready():
    magazine_capacity = 48
    magazine = magazine_capacity
    ammo_capacity = 576
    ammo = ammo_capacity
    rounds_per_minute = 1000
    reload_time = 2
    muzzle_velocity = 400
    damage = 190

    crosshair = 'res://src/ships/reaver/weapons/vortek/vortek_crosshair.png'
