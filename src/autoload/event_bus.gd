extends Node

enum EndingType {
	SOVEREIGN_ENDING,
	POPULAR_ENDING,
	ESCAPE_ENDING,
	TRUE_ENDING
}

# interaction and captcha
signal interaction_attempted(interactable_name: String)
signal captcha_triggered
signal captcha_resolved(success: bool)

# game state and ending
signal game_ended(ending_name: String)
signal cutscene_ending(cutscene: EndingType)

# tegar's whisper of thoughts
signal voice_triggered(audio_key: String)
signal whisper_effect_triggered(color: Color, duration: float)

# ui guidance
signal guidance_text(text: String)
signal stop_guidance_text

# inventory
signal inventory_updated(slots: Array)
signal inventory_slot_selected(active_index: int)
signal item_drop(item: ItemData)

# quest
signal on_enemy_killed(enemy_id: String)
signal on_radio_activated(radio_id: String)
