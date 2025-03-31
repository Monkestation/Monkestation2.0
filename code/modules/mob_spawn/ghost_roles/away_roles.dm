
//roles found on away missions, if you can remember to put them here.

//undead that protect a zlevel

/obj/effect/mob_spawn/ghost_role/human/skeleton
	name = "skeletal remains"
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	mob_name = "skeleton"
	prompt_name = "a skeletal guardian"
	mob_species = /datum/species/skeleton
	you_are_text = "By unknown powers, your skeletal remains have been reanimated!"
	flavour_text = "Walk this mortal plane and terrorize all living adventurers who dare cross your path."
	spawner_job_path = /datum/job/skeleton
	restricted_species = list(/datum/species/skeleton) //if you have a skelly species, on a halloween and this disabled gateway map spawns, I applaud you
	loadout_enabled = FALSE
	quirks_enabled = TRUE

/obj/effect/mob_spawn/ghost_role/human/skeleton/special(mob/living/new_spawn)
	. = ..()
	to_chat(new_spawn, "<b>You have this horrible lurching feeling deep down that your binding to this world will fail if you abandon this zone... Were you reanimated to protect something?</b>")
	new_spawn.AddComponent(/datum/component/stationstuck, PUNISHMENT_MURDER, "You experience a feeling like a stressed twine being pulled until it snaps. Then, merciful nothing.")

/obj/effect/mob_spawn/ghost_role/human/zombie
	name = "rotting corpse"
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	mob_name = "zombie"
	prompt_name = "an undead guardian"
	mob_species = /datum/species/zombie
	spawner_job_path = /datum/job/zombie
	you_are_text = "By unknown powers, your rotting remains have been resurrected!"
	flavour_text = "Walk this mortal plane and terrorize all living adventurers who dare cross your path."
	restricted_species = list(/datum/species/zombie) //if you have a high-functioning zombie, on a halloween and this disabled gateway map spawns, I applaud you
	loadout_enabled = FALSE
	quirks_enabled = TRUE

/obj/effect/mob_spawn/ghost_role/human/zombie/special(mob/living/new_spawn)
	. = ..()
	to_chat(new_spawn, "<b>You have this horrible lurching feeling deep down that your binding to this world will fail if you abandon this zone... Were you reanimated to protect something?</b>")
	new_spawn.AddComponent(/datum/component/stationstuck, PUNISHMENT_MURDER, "You experience a feeling like a stressed twine being pulled until it snaps. Then, merciful nothing.")

/obj/effect/mob_spawn/ghost_role/human/away/snow_operative
	name = "sleeper"
	prompt_name = "a snow operative"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	faction = list(ROLE_SYNDICATE)
	outfit = /datum/outfit/snowsyndie/away
	you_are_text = "You are a syndicate operative, a respected engineer. Except something went wrong and you're crashlanded on a snow planet."
	flavour_text = "You need to reestablish contact with command, how tho ? And what is that sound ? Nanotrasen..."

/datum/outfit/snowsyndie/away
	name = "Syndicate Snow Operative"
	id = /obj/item/card/id/advanced/chameleon
	id_trim = /datum/id_trim/chameleon/operative
	uniform = /obj/item/clothing/under/syndicate/coldres
	ears = /obj/item/radio/headset/syndicate/alt
	shoes = /obj/item/clothing/shoes/combat/coldres
	r_pocket = /obj/item/gun/ballistic/automatic/pistol

	implants = list(/obj/item/implant/exile)


