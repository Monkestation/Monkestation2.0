/obj/item/clothing/head/costume/kitty/super
	name = "Super Kitty Ears"
	desc = "A pair of kitty ears that harvest the true energy of cats. Mrow!"
	resistance_flags = FIRE_PROOF // One of a kind
	actions_types = list(/datum/action/cooldown/spell/shapeshift/kitty)

/datum/action/cooldown/spell/shapeshift/kitty
	name = "KITTY POWER!!"
	desc = "Take on the shape of a kitty cat! Gain their powers at a loss of vitality."

	cooldown_time = 20 SECONDS
	invocation = "MRR MRRRW!!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	possible_shapes = list(
		/mob/living/simple_animal/pet/cat,
		/mob/living/simple_animal/pet/cat/breadcat,
		/mob/living/simple_animal/pet/cat/original,
	)
