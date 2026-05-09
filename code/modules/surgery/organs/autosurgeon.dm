/obj/item/autosurgeon
	name = "autosurgeon"
	desc = "A device that automatically inserts an implant, skillchip or organ into the user without the hassle of extensive surgery. \
		It has a slot to insert implants or organs and a screwdriver slot for removing accidentally added items."
	icon = 'icons/obj/device.dmi'
	icon_state = "autosurgeon"
	inhand_icon_state = "nothing"
	w_class = WEIGHT_CLASS_SMALL

	/// How many times you can use the autosurgeon before it becomes useless
	var/uses = INFINITY
	/// What organ will the autosurgeon sub-type will start with. ie, CMO autosurgeon start with a medi-hud.
	var/starting_organ
	/// The organ currently loaded in the autosurgeon, ready to be implanted.
	var/obj/item/organ/stored_organ
	/// The list of organs and their children we allow into the autosurgeon. An empty list means no whitelist.
	var/list/organ_whitelist = list()
	/// The percentage modifier for how fast you can use the autosurgeon to implant other people.
	var/surgery_speed = 1
	/// The overlay that shows when the autosurgeon has an organ inside of it.
	var/loaded_overlay = "autosurgeon_loaded_overlay"

/obj/item/autosurgeon/attack_self_tk(mob/user)
	return //stops TK fuckery

/obj/item/autosurgeon/Initialize(mapload)
	. = ..()
	if(starting_organ)
		load_organ(new starting_organ(src))

/obj/item/autosurgeon/update_overlays()
	. = ..()
	if(stored_organ)
		. += loaded_overlay
		. += emissive_appearance(icon, loaded_overlay, src)

/obj/item/autosurgeon/proc/load_organ(obj/item/organ/loaded_organ, mob/living/user)
	if(user)
		if(stored_organ)
			to_chat(user, span_alert("[src] already has an implant stored."))
			return

		if(uses <= 0)
			to_chat(user, span_alert("[src] is used up and cannot be loaded with more implants."))
			return

		if(length(organ_whitelist))
			var/organ_whitelisted
			for(var/whitelisted_organ in organ_whitelist)
				if(istype(loaded_organ, whitelisted_organ))
					organ_whitelisted = TRUE
					break
			if(!organ_whitelisted)
				to_chat(user, span_alert("[src] is not compatible with [loaded_organ]."))
				return

		if(!user.transferItemToLoc(loaded_organ, src))
			to_chat(user, span_alert("[loaded_organ] is stuck to your hand!"))
			return

	stored_organ = loaded_organ
	loaded_organ.forceMove(src)

	name = "[initial(name)] ([stored_organ.name])" //to tell you the organ type, like "suspicious autosurgeon (Reviver implant)"
	update_appearance()

/obj/item/autosurgeon/proc/use_autosurgeon(mob/living/target, mob/living/user, implant_time)
	if(!stored_organ)
		to_chat(user, span_alert("[src] currently has no implant stored."))
		return

	if(!uses)
		to_chat(user, span_alert("[src] has already been used. The tools are dull and won't reactivate."))
		return

	if(!iscarbon(target))
		to_chat(user, span_alert("[target] cannot be implanted."))
		return

	if(implant_time)
		user.visible_message( "[user] prepares to use [src] on [target].", "You begin to prepare to use [src] on [target].")
		if(!do_after(user, (8 SECONDS * surgery_speed), target))
			return

	if(target != user)
		log_combat(user, target, "autosurgeon implanted [stored_organ] into", "[src]", "in [AREACOORD(target)]")
		user.visible_message(span_notice("[user] presses a button on [src] as it plunges into [target]'s body."), span_notice("You press a button on [src] as it plunges into [target]'s body."))
	else
		user.visible_message(span_notice("[user] pressses a button on [src] as it plunges into [user.p_their()] body."), "You press a button on [src] as it plunges into your body.")

	stored_organ.Insert(target)//insert stored organ into the user
	stored_organ = null
	name = initial(name) //get rid of the organ in the name
	playsound(target.loc, 'sound/weapons/circsawhit.ogg', 50, vary = TRUE)
	update_appearance()

	uses--
	if(uses <= 0)
		desc = "[initial(desc)] Looks like it's been used up."

/obj/item/autosurgeon/attack_self(mob/user)//when the object it used...
	use_autosurgeon(user, user)

/obj/item/autosurgeon/attack(mob/living/target, mob/living/user, params)
	add_fingerprint(user)
	use_autosurgeon(target, user, 8 SECONDS)

/obj/item/autosurgeon/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(isorgan(attacking_item))
		load_organ(attacking_item, user)
	else
		return ..()



/obj/item/autosurgeon/screwdriver_act(mob/living/user, obj/item/screwtool)
	if(..())
		return TRUE
	if(!stored_organ)
		to_chat(user, span_warning("There's no implant in [src] for you to remove!"))
	else
		var/atom/drop_loc = user.drop_location()
		for(var/atom/movable/stored_implant as anything in src)
			stored_implant.forceMove(drop_loc)
			to_chat(user, span_notice("You remove the [stored_organ] from [src]."))
			stored_organ = null

		screwtool.play_tool_sound(src)
		uses--
		if(uses <= 0)
			desc = "[initial(desc)] Looks like it's been used up."
		update_appearance(UPDATE_ICON)
	return TRUE

/obj/item/autosurgeon/medical_hud
	desc = "A single use autosurgeon that contains a medical heads-up display augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = /obj/item/organ/internal/cyberimp/eyes/hud/medical

/obj/item/autosurgeon/perfect_serverlink
	desc = "A single use autosurgeon that contains an advanced serverlink augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = /obj/item/organ/internal/cyberimp/brain/linked_surgery/perfect/nt

/obj/item/autosurgeon/security_hud
	desc = "A single use autosurgeon that contains a security heads-up display augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	uses = 1
	starting_organ = /obj/item/organ/internal/cyberimp/eyes/hud/security

/obj/item/autosurgeon/toolset
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/toolset
	uses = 1

/obj/item/autosurgeon/surgery
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/surgery
	uses = 1

/obj/item/autosurgeon/botany
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/botany
	uses = 1

/obj/item/autosurgeon/janitor
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/janitor
	uses = 1

/obj/item/autosurgeon/muscle
	starting_organ = /obj/item/organ/internal/cyberimp/arm/strongarm
	uses = 1

/obj/item/autosurgeon/mantis_blade
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/mantis
	uses = 1

/obj/item/autosurgeon/mantis_blade/l
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/mantis/l

/obj/item/autosurgeon/shield_blade
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/mantis/shield
	uses = 1

/obj/item/autosurgeon/shield_blade/l
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/mantis/shield/l

/obj/item/autosurgeon/drill
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/mining_drill
	uses = 1

/obj/item/autosurgeon/drill/l
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/mining_drill/l

/obj/item/autosurgeon/chemvat
	starting_organ = /obj/item/organ/internal/cyberimp/chest/chemvat
	uses = 1

///////////////////////////
// SKILLCHIP AUTOSURGEON //
///////////////////////////
/obj/item/autosurgeon/skillchip
	name = "skillchip autosurgeon"
	desc = "A device that automatically inserts a skillchip into the user's brain without the hassle of extensive surgery. \
		It has a slot to insert a skillchip and a screwdriver slot for removing accidentally added items."
	var/skillchip_type = /obj/item/skillchip
	var/starting_skillchip
	var/obj/item/skillchip/stored_skillchip

/obj/item/autosurgeon/skillchip/Initialize(mapload)
	. = ..()
	if(starting_skillchip)
		insert_skillchip(new starting_skillchip(src))

/obj/item/autosurgeon/skillchip/proc/insert_skillchip(obj/item/skillchip/skillchip)
	if(!istype(skillchip))
		return
	stored_skillchip = skillchip
	skillchip.forceMove(src)
	name = "[initial(name)] ([stored_skillchip.name])"

/obj/item/autosurgeon/skillchip/attack_self(mob/living/carbon/user)//when the object it used...
	if(uses <= 0)
		to_chat(user, span_alert("[src] has already been used. The tools are dull and won't reactivate.") )
		return

	if(!stored_skillchip)
		to_chat(user, span_alert("[src] currently has no skillchip stored.") )
		return

	if(!istype(user))
		to_chat(user, span_alert("[user]'s brain cannot accept skillchip implants.") )
		return

	// Try implanting.
	var/implant_msg = user.implant_skillchip(stored_skillchip)
	if(implant_msg)
		user.visible_message(span_notice("[user] presses a button on [src], but nothing happens.") , span_notice("The [src] quietly beeps at you, indicating some sort of error.") )
		to_chat(user, span_alert("[stored_skillchip] cannot be implanted. [implant_msg]") )
		return

	// Clear the stored skillchip, it's technically not in this machine anymore.
	var/obj/item/skillchip/implanted_chip = stored_skillchip
	stored_skillchip = null

	user.visible_message(span_notice("[user] presses a button on [src], and you hear a short mechanical noise.") , span_notice("You feel a sharp sting as [src] plunges into your brain.") )
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, TRUE)

	to_chat(user,span_notice("Operation complete! [implanted_chip] successfully implanted. Attempting auto-activation...") )

	// If implanting succeeded, try activating - Although activating isn't required, so don't early return if it fails.
	// The user can always go activate it at a skill station.
	var/activate_msg = implanted_chip.try_activate_skillchip(FALSE, FALSE)
	if(activate_msg)
		to_chat(user, span_alert("[implanted_chip] cannot be activated. [activate_msg]") )

	name = initial(name)

	uses--
	if(uses <= 0)
		desc = "[initial(desc)] The surgical tools look too blunt and worn to pierce a skull. Looks like it's all used up."

/obj/item/autosurgeon/skillchip/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(!istype(attacking_item, skillchip_type))
		return ..()

	if(stored_skillchip)
		to_chat(user, span_alert("[src] already has a skillchip stored.") )
		return

	if(uses <= 0)
		to_chat(user, span_alert("[src] has already been used up."))
		return

	if(!user.transferItemToLoc(attacking_item, src))
		to_chat(user, span_alert("You fail to insert the skillchip into [src]. It seems stuck to your hand.") )
		return

	stored_skillchip = attacking_item
	to_chat(user, span_notice("You insert the [attacking_item] into [src].") )

/obj/item/autosurgeon/skillchip/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return

	if(!stored_skillchip)
		to_chat(user, span_warning("There's no skillchip in [src] for you to remove!") )
		return TRUE

	var/atom/drop_loc = user.drop_location()
	for(var/thing in contents)
		var/atom/movable/movable_content = thing
		movable_content.forceMove(drop_loc)

	to_chat(user, span_notice("You remove the [stored_skillchip] from [src].") )
	I.play_tool_sound(src)
	stored_skillchip = null

	uses--
	if(uses <= 0)
		desc = "[initial(desc)] Looks like it's been used up."

	return TRUE

/obj/item/autosurgeon/skillchip/syndicate
	name = "suspicious skillchip autosurgeon"
	icon_state = "autosurgeon_syndicate"
	loaded_overlay = "autosurgeon_syndicate_loaded_overlay"

/obj/item/autosurgeon/skillchip/syndicate/engineer
	starting_skillchip = /obj/item/skillchip/job/engineer

///////////////////////////
// SYNDICATE AUTOSURGEON //
///////////////////////////
/obj/item/autosurgeon/syndicate
	name = "suspicious autosurgeon"
	icon_state = "autosurgeon_syndicate"
	surgery_speed = 0.75
	loaded_overlay = "autosurgeon_syndicate_loaded_overlay"

/obj/item/autosurgeon/syndicate/Initialize(mapload)
	. = ..()
	if(istype(stored_organ, /obj/item/organ/internal/cyberimp))
		var/obj/item/organ/internal/cyberimp/starting_implant = stored_organ
		starting_implant.organ_flags |= ORGAN_HIDDEN

/obj/item/autosurgeon/syndicate/laser_arm
	desc = "A single use autosurgeon that contains a combat arms-up laser augment. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/gun/laser
	uses = 1

/obj/item/autosurgeon/syndicate/thermal_eyes
	desc = "A single use autosurgeon that contains a pair of upgraded thermal eyes. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/eyes/robotic/thermals/syndicate
	uses = 1

/obj/item/autosurgeon/syndicate/xray_eyes
	desc = "A single use autosurgeon that contains a pair of x-ray eyes. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/eyes/robotic/xray/syndicate
	uses = 1

/obj/item/autosurgeon/syndicate/anti_stun
	desc = "A single use autosurgeon that contains a contraband CNS rebooter implant. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/brain/anti_stun/syndicate
	uses = 1

/obj/item/autosurgeon/syndicate/reviver
	desc = "A single use autosurgeon that contains a contraband reviver implant. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/chest/reviver/syndicate
	uses = 1

/obj/item/autosurgeon/syndicate/commsagent
	desc = "A device that automatically - painfully - inserts an implant. It seems someone's specially \
	modified this one to only insert... tongues. Horrifying."
	starting_organ = /obj/item/organ/internal/tongue

/obj/item/autosurgeon/syndicate/commsagent/Initialize(mapload)
	. = ..()
	organ_whitelist += /obj/item/organ/internal/tongue

/obj/item/autosurgeon/syndicate/emaggedsurgerytoolset
	desc = "A single use autosurgeon that contains a hacked surgical toolset implant. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/surgery/emagged
	uses = 1

/obj/item/autosurgeon/syndicate/hacked_linked_surgery
	desc = "A single use autosurgeon that contains a hacked surgical serverlink brain implant. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/brain/linked_surgery/perfect
	uses = 1

/obj/item/autosurgeon/syndicate/polyglot_voicebox
	desc = "A single use autosurgeon that contains a polyglot voicebox implant. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/tongue/polyglot_voicebox
	uses = 1

/obj/item/autosurgeon/toolset/synthcare
	name = "synthetic care toolset autosurgeon"
	desc = "A single use autosurgeon that contains a synthetic repair toolkit implant with a powerful welder and cable coils. Good for taking care of your local synthetic. Cables cannot be refilled and instead the toolset should be replaced with a new one should you run out. <b> IPCs must take care to implant the toolset in the arm that does not have their charging cable! </b>"
	uses = 1
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/synth_repair

/obj/item/autosurgeon/syndicate/esword
	desc = "A single use autosurgeon that contains a arm-mounted energy blade implant. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/esword
	uses = 1

/obj/item/autosurgeon/syndicate/ammo_counter
	starting_organ = /obj/item/organ/internal/cyberimp/arm/ammo_counter/syndicate
	uses = 1

/obj/item/autosurgeon/syndicate/nodrop
	desc = "A single use autosurgeon that contains a contraband anti-drop implant. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/brain/anti_drop/syndicate
	uses = 1

/obj/item/autosurgeon/syndicate/baton
	desc = "A single use autosurgeon that contains a arm electrification implant implant. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/baton
	uses = 1

/obj/item/autosurgeon/syndicate/flash
	desc = "A single use autosurgeon that contains a integrated high-intensity photon projector implant. A screwdriver can be used to remove it, but implants can't be placed back in."
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/flash
	uses = 1

/obj/item/autosurgeon/syndicate/hivenode
	starting_organ = /obj/item/organ/internal/alien/hivenode
	uses = 1

/obj/item/autosurgeon/syndicate/syndie_mantis
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/syndie_mantis
	uses = 1

/obj/item/autosurgeon/syndicate/syndie_mantis/l
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/syndie_mantis/l

/obj/item/autosurgeon/syndicate/razorwire
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/razorwire
	uses = 1

/obj/item/autosurgeon/syndicate/razorwire/l
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/razorwire/l

/obj/item/autosurgeon/syndicate/sandy
	starting_organ = /obj/item/organ/internal/cyberimp/chest/sandevistan
	uses = 1

/obj/item/autosurgeon/syndicate/dualwield
	starting_organ = /obj/item/organ/internal/cyberimp/chest/dualwield
	uses = 1

/obj/item/autosurgeon/syndicate/deepvien
	starting_organ = /obj/item/organ/internal/cyberimp/leg/chemplant/drugs
	uses = 1

/obj/item/autosurgeon/syndicate/deepvien/l
	starting_organ = /obj/item/organ/internal/cyberimp/leg/chemplant/drugs/l
