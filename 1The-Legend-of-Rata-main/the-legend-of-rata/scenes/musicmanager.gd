extends AudioStreamPlayer
# this is the music used in the game
const NORMAL_MUSIC = preload("res://assets/Labyrinth-of-Lost-Dreams-MP3(chosic.com).mp3")
const BOSS_MUSIC = preload("res://assets/Cinematic-Epicness(chosic.com).mp3")

func play_normal_music() -> void: # plays music as soon as the game starts
	if stream != NORMAL_MUSIC:
		stop()              # Stops whatever is currently playing
		stream = NORMAL_MUSIC
		play()

func play_boss_music() -> void: # playes the boss music when you enter the arena
	if stream != BOSS_MUSIC:
		stop()              # Stops whatever is currently playing to play the new music
		stream = BOSS_MUSIC
		play()
