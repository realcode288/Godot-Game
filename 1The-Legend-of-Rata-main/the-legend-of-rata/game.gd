extends Node2D


func _ready() -> void: # Just plays the music when the game starts
	MusicManager.play_normal_music()
