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

/obj/item/autosurgeon/skillchip
	name = "skillchip autosurgeon"
	desc = "A device that automatically inserts a skillchip into the user's brain without the hassle of extensive surgery. \
		It has a slot to insert a skillchip and a screwdriver slot for removing accidentally added items."
	var/skillchip_type = /obj/item/skillchip
	var/starting_skillchip
	var/obj/item/skillchip/stored_skillchip

/obj/item/autosurgeon/skillchip/syndicate
	name = "suspicious skillchip autosurgeon"

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

/obj/item/autosurgeon/skillchip/syndicate/engineer
	starting_skillchip = /obj/item/skillchip/job/engineer

/obj/item/autosurgeon/drill
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/mining_drill

/obj/item/autosurgeon/drill/l
	starting_organ = /obj/item/organ/internal/cyberimp/arm/item_set/mining_drill/l

/obj/item/autosurgeon/chemvat
	starting_organ = /obj/item/organ/internal/cyberimp/chest/chemvat
