/obj/item/comically_large_straw
	name = "\improper Comically Large Straw"
	desc = "For when you're only allowed one sip."
	icon = 'icons/obj/toys/straws.dmi' // my thanks to moth nyan for these sprites
	icon_state = "straw1"
	var/check_living = TRUE
	var/datum/looping_sound/zucc/soundloop
	var/suck_power = 2

/obj/item/comically_large_straw/Initialize(mapload)
	. = ..()
	soundloop = new(src,  FALSE)

/obj/item/comically_large_straw/proc/try_straw(atom/target, mob/user, proximity)
	if(!proximity)
		return FALSE
	if(!target.reagents)
		return FALSE
	if(check_living)
		if(isliving(target))
			return FALSE
	return TRUE

/obj/item/comically_large_straw/afterattack(atom/target, mob/user, proximity)
	. = ..()
	. |= AFTERATTACK_PROCESSED_ITEM

	if (!try_straw(target, user, proximity))
		return
	soundloop.start()
	if(do_after(user, 10 / suck_power SECONDS, target))
		target.reagents.trans_to(user, target.reagents.maximum_volume, transfered_by = user, methods = INGEST)
		user.visible_message("[user] slurps up the [target] with [user.p_their()] [src]!", "You slurp up the [target] with your [src]!", "You hear a loud slurping noise!")
	soundloop.stop()

/obj/item/comically_large_straw/meme
	name = "\improper Comically Debuggy Straw"
	desc = "Admemery has allowed this straw to drink directly from people's reagentholders at super speed. Fucked up."
	check_living = FALSE
	suck_power = 10
