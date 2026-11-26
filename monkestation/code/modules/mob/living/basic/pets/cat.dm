/mob/living/basic/pet/cat
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'icons/mob/pets_held.dmi'
	lighting_cutoff_red = LIGHTING_CUTOFF_FELINE_RED
	lighting_cutoff_green = LIGHTING_CUTOFF_FELINE_GREEN
	lighting_cutoff_blue = LIGHTING_CUTOFF_FELINE_RED

/mob/living/basic/pet/cat/jerry //Holy shit we left jerry on donut ~ Arcane ~Fikou
	name = "Jerry"
	desc = "Tom is VERY amused."
	gender = MALE

/mob/living/basic/pet/cat/feral/tabby
	health = 45
	maxHealth = 45
	melee_damage_lower = 10
	melee_damage_upper = 20
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	held_state = "cat"
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/pet/cat/syndicat
	name = "Syndie Cat"
	desc = "OH GOD! RUN!! IT CAN SMELL THE DISK!"
	icon_state = "syndicat"
	icon_living = "syndicat"
	icon_dead = "syndicat_dead"
	held_state = "syndicat"
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = TCMB
	maximum_survivable_temperature = T0C + 40
	health = 80
	maxHealth = 80
	melee_damage_lower = 20
	melee_damage_upper = 35
	faction = list(FACTION_CAT, ROLE_SYNDICATE)
	gold_core_spawnable = NO_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/simple/simple_hostile

/mob/living/basic/pet/cat/syndicat/Initialize(mapload)
	. = ..()
	var/obj/item/implant/toinstall = list(/obj/item/implant/weapons_auth, /obj/item/implant/explosive)
	for(var/obj/item/implant/original_implants as anything in toinstall)
		var/obj/item/implant/copied_implant = new original_implants.type
		copied_implant.implant(src, silent = TRUE, force = TRUE)
	update_appearance(UPDATE_OVERLAYS)

/mob/living/basic/pet/cat/syndicat/revive(full_heal_flags, excess_healing, force_grab_ghost, revival_policy)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/mob/living/basic/pet/cat/syndicat/death(gibbed)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/mob/living/basic/pet/cat/syndicat/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "[icon_state]_e", src)
