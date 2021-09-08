extends 'res://src/ships/BaseWeapon.gd'

func _ready():
    magazine_capacity = 27
    magazine = magazine_capacity
    ammo_capacity = 324
    ammo = ammo_capacity
    rounds_per_minute = 750.0
    reload_time = 2.25
    muzzle_velocity = 200
    damage = 240

    crosshair = 'res://src/ships/reaver/weapons/vortek/vortek_crosshair.png'
