/// Variant of /datum/sound_effect that supports weights (recursively)
/datum/sound_effect/assoc

/datum/sound_effect/assoc/return_sfx()
	return pick_weight_recursive(file_paths)

/datum/sound_effect/meow
	key = SFX_MEOW
	file_paths = list(
		list(
			'sound/mobs/humanoids/felinid/meow1.ogg',
			'sound/mobs/humanoids/felinid/meow2.ogg',
			'sound/mobs/humanoids/felinid/meow3.ogg',
			'sound/mobs/humanoids/felinid/meow4.ogg',
		) = 100,
		list(
			'sound/mobs/humanoids/felinid/mggaow.ogg' = 10,
			'sound/mobs/humanoids/felinid/funnymeow.ogg' = 1,
		) = 1,
	)
