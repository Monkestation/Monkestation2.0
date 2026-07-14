/obj/item/chameleonbomb
	name = "chameleon bomb"
	desc = "A devious device that can disguise itself as any object \
	and detonate a charge on the poor sod that tries to use it."
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "plastic-explosive0"
	inhand_icon_state = "plastic-explosive"
	lefthand_file = 'icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/bombs_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	///explosion size as devast, heavy, light
	var/explosive_size = list(0,0,3)
	///has at any point been disguised, to hide the examine
	var/disguised = FALSE
	///locked from being redisguised
	var/disguiselock = FALSE
	var/blowingup

/obj/item/chameleonbomb/examine(mob/user)
	. = ..()
	if(!disguised)
		. += span_notice("You can click an object to set a disguise.")
		. += span_notice("Alt-clicking the bomb when disguised will lock the disguise from being changed.")
		. += span_danger("Attempting to use the bomb inhand will explode it immediately!")

/obj/item/chameleonbomb/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(!can_copy(interacting_with) || disguiselock || SHOULD_SKIP_INTERACTION(interacting_with, src, user))
		return NONE
	make_copy(interacting_with, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/chameleonbomb/proc/can_copy(atom/target)
	if(!icon_exists(target.icon, target.icon_state))
		return FALSE
	if(!isitem(target))
		return FALSE
	var/obj/item/itemtarget = target
	if(itemtarget.w_class >= WEIGHT_CLASS_GIGANTIC)
		return FALSE //too big to hold
	if(target.alpha != 255)
		return FALSE
	if(target.invisibility != 0)
		return FALSE
	return TRUE

/obj/item/chameleonbomb/proc/make_copy(obj/item/target, mob/user)
	disguised = TRUE
	playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, TRUE, -6)
	to_chat(user, span_notice("Scanned [target]."))
	var/obj/item/temp = new /obj/item()
	temp.appearance = target.appearance
	temp.layer = initial(target.layer) // scanning things in your inventory
	SET_PLANE_EXPLICIT(temp, src.plane, src)
	appearance = temp.appearance
	name = target.name
	desc = target.desc
	w_class = target.w_class
	inhand_icon_state = target.inhand_icon_state
	lefthand_file = target.lefthand_file
	righthand_file = target.righthand_file
	log_bomber(user, "set chameleon bomb disguise to", src, message_admins = FALSE) //dont message admins, its spammable and not actually blowing up yet

/obj/item/chameleonbomb/attack_self(mob/user, modifiers)
	. = ..()
	if(blowingup)
		return
	blowingup = TRUE
	to_chat(user, span_userdanger("\The [src] loses it's decoy, it's a bomb!"))
	visible_message(span_danger("The disguise on \the [src] [user] is holding falls! It's a bomb!"), span_userdanger("\The [src] loses it's disguise, it's a bomb!"), span_hear("A warbling sound rings out with a few beeps!"))
	playsound(src, 'sound/machines/triple_beep.ogg', 50, FALSE)
	log_bomber(user, "activated a chameleon bomb disguised as ", src)
	explosion(src, explosive_size[1], explosive_size[2], explosive_size[3])
	if(iscarbon(user))
		var/mob/living/carbon/carbonuser = user
		var/obj/item/bodypart/unluckyarm = carbonuser.get_holding_bodypart_of_item(src)
		if(istype(unluckyarm)) //telekinesis bullshit? whatever!
			unluckyarm?.dismember(silent = FALSE)
	qdel(src)

/obj/item/chameleonbomb/click_alt(mob/user)
	. = ..()
	if(disguised && !disguiselock)
		to_chat(user, span_danger("You activate the disguise lock on the bomb, it is now locked as \the [name]."))
		log_bomber(user, "activated chameleonbomb disguise lock on", src)
		disguiselock = TRUE
		return CLICK_ACTION_SUCCESS
