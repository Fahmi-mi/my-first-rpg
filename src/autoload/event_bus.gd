extends Node

# interaction and captcha
signal interaction_attempted(interactable_name: String)
signal captcha_triggered
signal captcha_resolved(success: bool)

# game state and ending
signal game_ended(ending_name: String)

# tegar's whisper of thoughts
signal voice_triggered(audio_key: String)

# inventory
signal inventory_updated(slots: Array)
