/datum/status_effect/agent_pinpointer/revenger
	id = "revenger_pinpointer"
	minimum_range = 1
	range_fuzz_factor = 0
	tick_interval = 10
	alert_type = /obj/screen/alert/status_effect/agent_pinpointer/revenger

/datum/status_effect/agent_pinpointer/revenger/scan_for_target()
	scan_target = locate(/obj/item/badmin_gauntlet) in world

/obj/screen/alert/status_effect/agent_pinpointer/revenger
	name = "Revengers Pinpointer"

///////////////////////
//// NANO GUY SUIT ////
///////////////////////

/obj/item/implant/adrenalin/nanoguy
	uses = 10

/obj/item/clothing/suit/space/hardsuit/nano/nanoguy
	name = "Nanotrasen Nanotech Suit"
	desc = "A state-of-the-art nanotechnology-powered suit."
	icon = 'monkestation/icons/obj/nanoguy.dmi'
	worn_icon = 'monkestation/icons/mob/nanoguy.dmi'
	icon_state = "ngsuit"
	hardsuit_helmet = /obj/item/clothing/head/helmet/space/hardsuit/nano/nanoguy

/obj/item/clothing/head/helmet/space/hardsuit/nano/nanoguy
	name = "Nanotrasen Nanotech Helmet"
	desc = "A state-of-the-art nanotechnology-powered helmet."
	icon = 'monkestation/icons/obj/nanoguy.dmi'
	worn_icon = 'monkestation/icons/mob/nanoguy.dmi'
	icon_state = "nghelmet"

/////////////////////////
//// NANO GUY SHIELD ////
/////////////////////////

/obj/item/twohanded/required/nanoshield
	name = "Nano Shield"
	desc = "A powerful shield, powered by nanotechnology"
	icon = 'monkestation/icons/obj/nanoguy.dmi'
	lefthand_file = 'monkestation/icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/equipment/shields_righthand.dmi'
	icon_state = "ngshield"
	force = 20
	block_chance = 60
	armor_type = /datum/armor/nanoshield
	var/power = 10
	var/next_power_regen = 0

/datum/armor/nanoshield
	melee = 80
	bullet = 45
	laser = 75
	energy = 75
	bomb = 100
	fire = 100
	acid = 100

/obj/item/twohanded/required/nanoshield/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)

/obj/item/twohanded/required/nanoshield/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/twohanded/required/nanoshield/process()
	if(world.time >= next_power_regen)
		power = min(10, power + 1)
		next_power_regen = world.time + 5 SECONDS

/obj/item/twohanded/required/nanoshield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, final_block_chance, damage, attack_type)
	if(power > 0)
		power = max(0, power - 1)
		return ..()
	return FALSE

/obj/item/twohanded/required/nanoshield/IsReflect(def_zone)
	if(power > 0)
		power = max(0, power - 1)
		return TRUE
	return FALSE

/obj/item/organ/internal/cyberimp/arm/nanoguy
	name = "nanotech implant"
	contents = newlist(/obj/item/twohanded/required/nanoshield, /obj/item/nano_punch)

///obj/item/gun/energy/laser/mounted/nanoguy
//	name = "nanotech laser gun"
//	icon = 'monkestation/icons/obj/items_and_weapons.dmi'
//	icon_state = "nanolaser"

/obj/item/nano_punch
	name = "nanotech battering ram"
	icon = 'monkestation/icons/obj/items_and_weapons.dmi'
	lefthand_file = 'monkestation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/righthand.dmi'
	icon_state = "nanoram"
	force = 35

/obj/item/nano_punch/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)


////////////////////
//// THOR STUFF ////
////////////////////

/obj/item/clothing/suit/armor/thor
	name = "Thor's Armor"
	desc = "Armor worthy of the gods... literally."
	worn_icon = 'monkestation/icons/mob/suit.dmi'
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	icon_state = "thor"
	armor_type = /datum/armor/thor_armor

/datum/armor/thor_armor
	melee = 50
	bullet = 30
	laser = 50
	energy = 50
	bomb = 100
	fire = 50
	acid = 50
