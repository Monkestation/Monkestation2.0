/obj/item/soulstone/gem
	name = "soul gem"
	desc = "A freshly cut stone which appears to hold the same soul catching properties as shards of the Soul Stone. This one however is cut to perfection."
	icon = 'monkestation/code/modules/bloody_cult/icons/cult.dmi'
	icon_state = "soulstone"
	perfect = TRUE

/obj/item/soulstone/gem/update_icon_state()
	. = ..()
	var/mob/living/basic/shade/shade = locate(/mob/living/basic/shade) in contents
	if(shade)
		icon_state = "soulstone2"
	else
		icon_state = "soulstone"
