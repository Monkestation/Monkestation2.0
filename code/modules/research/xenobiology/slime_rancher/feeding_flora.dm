/mob/living/basic/cockroach/rockroach
	name = "rockroach"
	desc = "This cockroach has decided to cosplay as a turtle and is carrying a rock shell on its back."
	icon = 'icons/obj/xenobiology/slime_rancher/xenofauna.dmi'
	icon_state = "rockroach"
	health = 15
	maxHealth = 15
	biomass_value = 1

/mob/living/basic/cockroach/rockroach/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/death_drops, list(/obj/item/rockroach_shell))

/// Dropped when a rockroach dies.
/obj/item/rockroach_shell
	name = "rockroach shell"
	desc = "A rocky shell of some poor rockroach."
	icon = 'icons/obj/xenobiology/slime_rancher/xenofauna.dmi'
	icon_state = "rockroach_shell"
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 2
	throw_range = 7

/mob/living/basic/cockroach/iceroach
	name = "iceroach"
	desc = "This cockroach has decided to cosplay as a turtle and is carrying some ice shards on its back."
	icon = 'icons/obj/xenobiology/slime_rancher/xenofauna.dmi'
	icon_state = "iceroach"
	health = 15
	maxHealth = 15
	biomass_value = 1

/mob/living/basic/cockroach/gemroach
	name = "gemroach"
	desc = "I swear I've seen this one before but I can't remember where."
	icon = 'icons/obj/xenobiology/slime_rancher/xenofauna.dmi'
	icon_state = "gemroach"
	health = 15
	maxHealth = 15
	biomass_value = 1

/// Small critters for slimes to drain, deleted on death.
/mob/living/basic/xenofauna
	desc = "Feed these to the slimes!"
	icon = 'icons/obj/xenobiology/slime_rancher/xenofauna.dmi'
	ai_controller = /datum/ai_controller/basic_controller/cockroach
	health = 40
	maxHealth = 40
	basic_mob_flags = DEL_ON_DEATH
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSMOB // otherwise these fuckers will be super annoying
	biomass_value = 2

/mob/living/basic/xenofauna/diyaab
	name = "diyaab"
	icon_state = "diyaab"

/mob/living/basic/xenofauna/lavadog
	name = "lava dog"
	icon_state = "lavadog"

/mob/living/basic/xenofauna/dron
	name = "semi-organic bug"
	icon_state = "dron"

/mob/living/basic/xenofauna/greeblefly
	name = "greeblefly"
	icon_state = "greeblefly"

/mob/living/basic/xenofauna/possum
	name = "possum"
	icon_state = "possum"

/mob/living/basic/xenofauna/thoom
	name = "thoom"
	icon_state = "thoom"

/mob/living/basic/xenofauna/meatbeast
	name = "meat beast"
	icon_state = "meatbeast"

/mob/living/basic/xenofauna/thinbug
	name = "thin bug"
	icon_state = "thinbug"

/mob/living/basic/xenofauna/voxslug
	name = "strange slug"
	icon_state = "voxslug"
