/obj/item/clothing/suit/hooded/berserker/space_proof
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	var/static/list/step_sounds  = list('o-hippiestation/sound/effects/step_01.ogg', 'o-hippiestation/sound/effects/step_02.ogg', 'o-hippiestation/sound/effects/step_03.ogg')

/obj/item/clothing/suit/hooded/berserker/space_proof/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == ITEM_SLOT_OCLOTHING)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(play_stepsound))
	else
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)

/obj/item/clothing/suit/hooded/berserker/space_proof/proc/play_stepsound()
	SIGNAL_HANDLER
	playsound(src, pick(step_sounds), 20, TRUE)

/datum/outfit/centcom/death_commando
	uniform = /obj/item/clothing/under/rank/centcom/commander
	suit = /obj/item/clothing/suit/hooded/berserker
	back = /obj/item/storage/backpack
	backpack_contents = list(
		/obj/item/ammo_box/magazine/m75 = 5,
		/obj/item/flashlight = 1,
		/obj/item/reagent_containers/hypospray/medipen/survival/ = 1,
		/obj/item/grenade/c4/x4 = 1,
		/obj/item/storage/box/flashbangs = 1,
		/obj/item/storage/medkit/regular = 1,
	)
	belt = /obj/item/gun/ballistic/automatic/gyropistol/whammer
	l_hand = /obj/item/nullrod/scythe/talking/chainsword //half of server is going to be ghost, might as well give them stuff to do.
	implants = list(/obj/item/implant/adrenaline)

