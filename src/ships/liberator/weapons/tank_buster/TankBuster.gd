extends 'res://src/ships/BaseWeapon.gd'

func _ready():
    magazine_capacity = 30
    magazine = magazine_capacity
    ammo_capacity = 300
    ammo = ammo_capacity
    rounds_per_minute = 1200.0
    reload_time = 3.5
    muzzle_velocity = 200
    damage = 240

    crosshair = 'res://src/ships/reaver/weapons/vortek/vortek_crosshair.png'
