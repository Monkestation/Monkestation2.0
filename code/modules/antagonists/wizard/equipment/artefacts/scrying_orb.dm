/obj/item/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, merely holding it gives you vision and hearing beyond mortal means, and staring into it lets you see the entire universe."
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state ="bluespace"
	throw_speed = 3
	throw_range = 7
	throwforce = 15
	damtype = BURN
	force = 15
	hitsound = 'sound/items/welder2.ogg'

	var/mob/current_owner

/obj/item/scrying/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/scrying/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

//should be refactored to use signals
/obj/item/scrying/process()
	var/mob/holder = get(loc, /mob)
	if(current_owner && current_owner != holder)

		to_chat(current_owner, span_notice("Your otherworldly vision fades..."))

		current_owner.remove_traits(list(TRAIT_SIXTHSENSE, TRAIT_XRAY_VISION), SCRYING_ORB)
		current_owner.update_sight()

		current_owner = null

	if(!current_owner && holder)
		current_owner = holder

		to_chat(current_owner, span_notice("You can see...everything!"))

		current_owner.add_traits(list(TRAIT_SIXTHSENSE, TRAIT_XRAY_VISION), SCRYING_ORB)
		current_owner.update_sight()

/obj/item/scrying/attack_self(mob/user)
	visible_message(span_danger("[user] stares into [src], their eyes glazing over."))
	user.ghostize(TRUE)
