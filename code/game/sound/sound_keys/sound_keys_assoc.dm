/// Variant of /datum/sound_effect that supports weights (recursively)
/datum/sound_effect/assoc

/datum/sound_effect/assoc/return_sfx()
	return pick_weight_recursive(file_paths)

/datum/sound_effect/meow
	key = SFX_MEOW
	file_paths = list(
		list(
			'monkestation/sound/voice/feline/meow1.ogg',
			'monkestation/sound/voice/feline/meow2.ogg',
			'monkestation/sound/voice/feline/meow3.ogg',
			'monkestation/sound/voice/feline/meow4.ogg',
		) = 100,
		list(
			'monkestation/sound/voice/feline/mggaow.ogg' = 10,
			'monkestation/sound/voice/feline/funnymeow.ogg' = 1,
		) = 1,
	)
