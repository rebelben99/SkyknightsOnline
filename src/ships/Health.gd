extends Node

export var current = 1000
export var maximum = 1000 setget set_maximum

func do_damage(amount):
    current -= amount

func set_maximum(new_max):
    current = new_max
    maximum = new_max

func reset():
    current = maximum
