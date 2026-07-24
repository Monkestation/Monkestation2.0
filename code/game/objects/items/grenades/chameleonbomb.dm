///Extra methods to detonate the bomb with instead of just using it in hand.
#define CHAMBOMB_DETONATE_EXTRA_NONE 0
#define CHAMBOMB_DETONATE_EXTRA_ALT 1
#define CHAMBOMB_DETONATE_EXTRA_CTRL 2
#define CHAMBOMB_DETONATE_EXTRA_PICKUP 3
#define CHAMBOMB_DETONATE_EXTRA_MELEE 4
#define CHAMBOMB_DETONATE_EXTRA_RANGED 5


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
	///the copied result of examining the disguise target.
	var/fake_examine
	var/fake_examine_more
	///locked from being redisguised, and enables extra methods to detonate the bomb.
	var/disguiselock = FALSE
	///Extra method to detonate the bomb with, once disguise lock enabled.
	var/extra_method = CHAMBOMB_DETONATE_EXTRA_NONE
	var/blowingup

/obj/item/chameleonbomb/examine(mob/user)
	. = ..()
	if(!disguised)
		. += span_notice("You can click an object to set a disguise.")
		. += span_notice("Alt-clicking the bomb when disguised will lock the disguise from being changed.")
		. += span_notice("Control-clicking the bomb will set an extra detonation method to explode the bomb once disguise locked.")
		. += span_danger("Attempting to use the bomb inhand will explode it immediately!")
		return
	return fake_examine

/obj/item/chameleonbomb/examine_more(mob/user)
	return fake_examine_more || ..()


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
	if(target.invisibility)
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
	fake_examine = target.examine(user)
	fake_examine_more = target.examine_more(user)
	w_class = target.w_class
	inhand_icon_state = target.inhand_icon_state
	lefthand_file = target.lefthand_file
	righthand_file = target.righthand_file
	user.update_held_items()
	log_bomber(user, "set chameleon bomb disguise to", src, message_admins = FALSE) //dont message admins, its spammable and not actually blowing up yet

/obj/item/chameleonbomb/attack_self(mob/user, modifiers)
	. = ..()
	mymango(user)

/obj/item/chameleonbomb/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(disguiselock && extra_method == CHAMBOMB_DETONATE_EXTRA_MELEE)
		mymango(user)


/obj/item/chameleonbomb/interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	interact_with_atom(interacting_with, user, modifiers)

/obj/item/chameleonbomb/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(disguiselock && extra_method == CHAMBOMB_DETONATE_EXTRA_RANGED)
		mymango(user)

/obj/item/chameleonbomb/pickup(mob/user)
	. = ..()
	if(disguiselock && extra_method == CHAMBOMB_DETONATE_EXTRA_PICKUP)
		addtimer(CALLBACK(src,PROC_REF(mymango),user), (0.2 SECONDS)) //runtime? what runtime?

/obj/item/chameleonbomb/click_alt(mob/user)
	. = ..()
	if(disguiselock && extra_method == CHAMBOMB_DETONATE_EXTRA_ALT)
		mymango(user)
		return CLICK_ACTION_SUCCESS
	if(!disguiselock)
		if(!disguised && tgui_alert(user, "You havent set a disguise for the bomb yet! Are you sure you want to lock the disguise? You can't undo this!", "Disguise Lock", list("Lock Disguise", "Abort")) != "Lock Disguise")
			return CLICK_ACTION_BLOCKING //kind of stupid but if you wanna disguise a chameleon bomb as... a chameleon bomb, GO AHEAD I GUESS?
		to_chat(user, span_danger("You activate the disguise lock on the bomb, it is now locked as \the [name]."))
		log_bomber(user, "activated chameleonbomb disguise lock on", src)
		disguiselock = TRUE
		return CLICK_ACTION_SUCCESS

/obj/item/chameleonbomb/item_ctrl_click(mob/user)
	if(disguiselock)
		if(extra_method == CHAMBOMB_DETONATE_EXTRA_CTRL && ismob(loc))
			mymango(user)
		return
	var/msg
	var/det_type = tgui_input_list(
		user,
		"Select an additional activation method to detonate the bomb with once the disguise lock is activated.",
		"Extra Detonation",
		list(
			"None",
			"Alt-Click",
			"Control-Click",
			"On Pickup",
			"On Usage (Melee)",
			"On Usage (Ranged)",
		)
	)
	switch(det_type)
		if("None")
			extra_method = CHAMBOMB_DETONATE_EXTRA_NONE
			msg = "disabled"
		if("Alt-Click")
			extra_method = CHAMBOMB_DETONATE_EXTRA_ALT
			msg = "set to Alt-Click in hand"
		if("Control-Click")
			extra_method = CHAMBOMB_DETONATE_EXTRA_CTRL
			msg = "set to Control-Click in hand"
		if("On Pickup")
			extra_method = CHAMBOMB_DETONATE_EXTRA_PICKUP
			msg = "set to On Pickup"
		if("On Usage (Melee)")
			extra_method = CHAMBOMB_DETONATE_EXTRA_MELEE
			msg = "set to On Melee Usage"
		if("On Usage (Ranged)")
			extra_method = CHAMBOMB_DETONATE_EXTRA_RANGED
			msg = "set to On Ranged Usage"
		else
			msg = "not updated"
	to_chat(user, span_notice("Extra Detonation method [msg]."))
	if(msg != "not updated")
		log_bomber(user, "updated chameleon bomb extra detonation method of", src, "([msg])", message_admins = FALSE)

/obj/item/chameleonbomb/proc/mymango(user) //is to blow up, and act like i dont know nobody
	if(blowingup)
		return
	blowingup = TRUE
	to_chat(user, span_userdanger("\The [src] loses it's decoy, it's a bomb!"))
	visible_message(span_danger("The disguise on \the [src] [user] is holding falls! It's a bomb!"), span_userdanger("\The [src] loses it's disguise, it's a bomb!"), span_hear("A warbling sound rings out with a few beeps!"))
	playsound(src, 'sound/machines/triple_beep.ogg', 50, FALSE)
	log_bomber(user, "activated a chameleon bomb disguised as", src)
	explosion(src, explosive_size[1], explosive_size[2], explosive_size[3])
	if(iscarbon(user))
		var/mob/living/carbon/carbonuser = user
		var/obj/item/bodypart/unluckyarm = carbonuser.get_holding_bodypart_of_item(src)
		if(istype(unluckyarm)) //telekinesis bullshit? whatever!
			unluckyarm?.dismember(silent = FALSE)
	qdel(src)



#undef CHAMBOMB_DETONATE_EXTRA_NONE
#undef CHAMBOMB_DETONATE_EXTRA_ALT
#undef CHAMBOMB_DETONATE_EXTRA_CTRL
#undef CHAMBOMB_DETONATE_EXTRA_PICKUP
