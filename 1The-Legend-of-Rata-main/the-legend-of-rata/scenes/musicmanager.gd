extends AudioStreamPlayer

const NORMAL_MUSIC = preload("res://assets/Labyrinth-of-Lost-Dreams-MP3(chosic.com).mp3")
const BOSS_MUSIC = preload("res://assets/Cinematic-Epicness(chosic.com).mp3")

func play_normal_music() -> void:
	if stream != NORMAL_MUSIC:
		stop()              # Stop whatever is currently playing
		stream = NORMAL_MUSIC
		play()

func play_boss_music() -> void:
	if stream != BOSS_MUSIC:
		stop()              # Stop whatever is currently playing
		stream = BOSS_MUSIC
		play()
