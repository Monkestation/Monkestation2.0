/obj/item/comically_large_straw
	name = "\improper Comically Large Straw"
	desc = "For when you're only allowed one sip."
	icon = 'icons/obj/toys/straws.dmi' // my thanks to moth nyan for these sprites
	icon_state = "straw1"
	var/check_living = TRUE
	var/datum/looping_sound/zucc/soundloop
	var/suck_power = 1.5

/obj/item/comically_large_straw/Initialize(mapload)
	. = ..()
	soundloop = new(src,  FALSE)

/obj/item/comically_large_straw/Destroy(force)
	. = ..()
	QDEL_NULL(soundloop)

/obj/item/comically_large_straw/proc/try_straw(atom/target, mob/user, proximity)
	if(!target.reagents)
		return FALSE
	if(check_living && isliving(target))
		return FALSE
	return TRUE

/obj/item/comically_large_straw/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if (!try_straw(interacting_with, user))
		return NONE
	soundloop.start()
	if(do_after(user, 10 / suck_power SECONDS, interacting_with))
		interacting_with.reagents.trans_to(user, interacting_with.reagents.maximum_volume, transfered_by = user, methods = INGEST)
		user.visible_message(span_notice("[user] slurps up the [interacting_with] with [user.p_their()] [src]!"), span_notice("You slurp up the [interacting_with] with your [src]!"), span_notice("You hear a loud slurping noise!"))
	soundloop.stop()

/obj/item/comically_large_straw/meme
	name = "\improper Comically Debuggy Straw"
	desc = "Admemery has allowed this straw to drink directly from people's reagentholders at super speed. Fucked up."
	check_living = FALSE
	suck_power = 10
