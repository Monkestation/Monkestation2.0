/obj/item/organ/internal/brain/clockwork
	name = "enigmatic gearbox"
	desc = "An engineer would call this inconcievable wonder of gears and metal a 'black box'"
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'
	icon_state = "brain-clock"
	organ_flags = ORGAN_ROBOTIC
	var/robust //Set to true if the robustbits causes brain replacement. Because holy fuck is the CLANG CLANG CLANG CLANG annoying

/obj/item/organ/internal/brain/clockwork/emp_act(severity)
		owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 25)

/obj/item/organ/internal/brain/clockwork/on_life()
	. = ..()
	if(prob(5) && !robust)
		SEND_SOUND(owner, sound('sound/ambience/ambiruin3.ogg', volume = 25))

/obj/item/organ/internal/brain/synth
	name = "compact positronic brain"
	slot = ORGAN_SLOT_BRAIN
	zone = BODY_ZONE_CHEST
	organ_flags = ORGAN_ROBOTIC | ORGAN_SYNTHETIC_FROM_SPECIES | ORGAN_VITAL
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	desc = "A cube of shining metal, four inches to a side and covered in shallow grooves. It has an IPC serial number engraved on the top. It is usually slotted into the chest of synthetic crewmembers. It is not compatible with standard Posibrain/MMI interfaces, and must be placed into an MMI to be made compatible." // to inform the user that this is, in fact, not a real posibrain, but is an organ posibrain.
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "posibrain-ipc"
	/// The last time (in ticks) a message about brain damage was sent. Don't touch.
	var/last_message_time = 0

/obj/item/organ/internal/brain/synth/on_insert(mob/living/carbon/brain_owner)
	. = ..()

	if(brain_owner.stat != DEAD || !ishuman(brain_owner))
		return

	var/mob/living/carbon/human/user_human = brain_owner
	if(HAS_TRAIT(user_human, TRAIT_REVIVES_BY_HEALING) && user_human.health > SYNTH_BRAIN_WAKE_THRESHOLD)
		if(!HAS_TRAIT(user_human, TRAIT_DEFIB_BLACKLISTED))
			user_human.revive(FALSE)

/obj/item/organ/internal/brain/synth/check_for_repair(obj/item/item, mob/user)
	if(damage && item.is_drainable() && item.reagents.has_reagent(/datum/reagent/medicine/liquid_solder)) //attempt to heal the brain

		user.visible_message(span_notice("[user] starts to slowly pour the contents of [item] onto [src]."), span_notice("You start to slowly pour the contents of [item] onto [src]."))
		if(!do_after(user, 3 SECONDS, src))
			to_chat(user, span_warning("You failed to pour the contents of [item] onto [src]!"))
			return TRUE

		user.visible_message(span_notice("[user] pours the contents of [item] onto [src], causing it to restore its previous circuit paths."), span_notice("You pour the contents of [item] onto [src], causing it to restore its previous circuit paths."))
		var/amount = item.reagents.get_reagent_amount(/datum/reagent/medicine/liquid_solder)
		var/healto = max(0, damage - amount * 2)
		item.reagents.remove_all(ROUND_UP(item.reagents.total_volume / amount * (damage - healto) * 0.5)) //only removes however much solution is needed while also taking into account how much of the solution is liquid solder
		set_organ_damage(healto) //heals 2 damage per unit of liquid solder, and by using "set_organ_damage", we clear the failing variable if that was up
		cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)
		return TRUE
	return FALSE

/obj/item/organ/internal/brain/synth/emp_act(severity) // EMP act against the posi, keep the cap far below the organ health
	. = ..()

	if((. & EMP_PROTECT_SELF) || !owner)
		return

	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)

	switch(severity)
		if(EMP_HEAVY)
			to_chat(owner, span_warning("01001001 00100111 01101101 00100000 01100110 01110101 01100011 01101011 01100101 01100100 00101110"))
			apply_organ_damage(SYNTH_ORGAN_HEAVY_EMP_DAMAGE, maximum = SYNTH_EMP_BRAIN_DAMAGE_MAXIMUM, required_organ_flag = ORGAN_ROBOTIC)
		if(EMP_LIGHT)
			to_chat(owner, span_warning("Alert: Electromagnetic damage taken in central processing unit. Error Code: 401-YT"))
			apply_organ_damage(SYNTH_ORGAN_LIGHT_EMP_DAMAGE, maximum = SYNTH_EMP_BRAIN_DAMAGE_MAXIMUM, required_organ_flag = ORGAN_ROBOTIC)

/obj/item/organ/internal/brain/synth/apply_organ_damage(damage_amount, maximum = maxHealth, required_organ_flag)
	. = ..()

	if(owner && damage > 0 && (world.time - last_message_time) > SYNTH_BRAIN_DAMAGE_MESSAGE_INTERVAL)
		last_message_time = world.time

		if(damage > BRAIN_DAMAGE_SEVERE)
			to_chat(owner, span_warning("Alre: re oumtnin ilir tocorr:pa ni ne:cnrrpiioruloomatt cessingode: P1_1-H"))
			return

		if(damage > BRAIN_DAMAGE_MILD)
			to_chat(owner, span_warning("Alert: Minor corruption in central processing unit. Error Code: 001-HP"))

/*
/obj/item/organ/internal/brain/synth/circuit
	name = "compact AI circuit"
	desc = "A compact and extremely complex circuit, perfectly dimensioned to fit in the same slot as a synthetic-compatible positronic brain. It is usually slotted into the chest of synthetic crewmembers."
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "circuit-occupied"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
*/

/obj/item/organ/internal/brain/synth/mmi
	name = "compact man-machine interface"
	desc = "A compact man-machine interface, perfectly dimensioned to fit in the same slot as a synthetic-compatible positronic brain. Unfortunately, the brain seems to be permanently attached to the circuitry, and it seems relatively sensitive to it's environment. It is usually slotted into the chest of synthetic crewmembers."
	icon = 'monkestation/code/modules/smithing/icons/ipc_organ.dmi'
	icon_state = "mmi-ipc"

