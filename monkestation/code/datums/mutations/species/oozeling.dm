/datum/mutation/human/acid_touch
	name = "Acidic Hands"
	desc = "Allows a host to metabolize some of their blood into acid, concentrated on their hands."
	locked = TRUE
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = span_notice("You feel power flow through your hands.")
	text_lose_indication = span_notice("The energy in your hands subsides.")
	power_path = /datum/action/cooldown/spell/touch/acid
	instability = 30
	conflicts = list(/datum/mutation/human/acid_touch/unstable)
	synchronizer_coeff = 1
	power_coeff = 1
	energy_coeff = 1

/datum/mutation/human/acid_touch/modify()
	. = ..()
	if(!.)
		return

	var/datum/action/cooldown/spell/touch/acid/to_modify = .
	to_modify.acid_volume *= GET_MUTATION_POWER(src)
	to_modify.blood_cost *= GET_MUTATION_SYNCHRONIZER(src)

/datum/action/cooldown/spell/touch/acid
	name = "Acid Touch"
	desc = "Concentrate to move acid into your hand, using some of your blood."
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	button_icon_state = "consume"
	sound = 'sound/chemistry/bufferadd.ogg'
	cooldown_time = 10 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = NONE

	/// How much acid we put on something
	var/acid_volume = 15
	/// How much blood it costs for us to use the hand:tm:
	var/blood_cost = 20

	hand_path = /obj/item/melee/touch_attack/acid
	draw_message = span_notice("You secrete acid into your hand.")
	drop_message = span_notice("You let the acid in your hand dissipate.")

/datum/action/cooldown/spell/touch/acid/is_valid_target(atom/cast_on)
	return isatom(cast_on) // We are not really picky

/datum/action/cooldown/spell/touch/acid/IsAvailable(feedback = FALSE)
	if(!owner || owner.stat != CONSCIOUS || (next_use_time > world.time))
		return ..()

	var/mob/living/carbon/human = owner
	if(istype(human) && !isnull(human.handcuffed))
		return TRUE

	return ..()

/datum/action/cooldown/spell/touch/acid/can_cast_spell(feedback = TRUE)
	if(!owner || owner.stat != CONSCIOUS || (next_use_time > world.time))
		return ..()

	var/mob/living/carbon/human = owner
	if(istype(human) && !isnull(human.handcuffed))
		return TRUE

	return ..()

/datum/action/cooldown/spell/touch/acid/cast(mob/living/carbon/cast_on)
	if(isnull(cast_on.handcuffed))
		return ..()

	do_hand_hit(null, cast_on.handcuffed, cast_on)
	return TRUE

/datum/action/cooldown/spell/touch/acid/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	if(caster.blood_volume < BLOOD_VOLUME_OKAY)
		to_chat(caster, span_warning("Your acid is too weakly concentrated to use for dissolving!"))
		return FALSE

	if(caster.handcuffed)
		var/obj/handcuffs = caster.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
		if(!istype(handcuffs))
			return FALSE
		caster.visible_message(span_warning("The acid in [caster]'s hands becomes much more concentrated, starting to burn away [handcuffs]!"), \
			span_notice("You concentrate on burning away your restraints using the acid in your hands..."))

		caster.blood_volume = max(caster.blood_volume - blood_cost, 0)
		addtimer(CALLBACK(src, PROC_REF(dissolve_handcuffs), caster, handcuffs), 90 SECONDS / acid_volume) // default 6 seconds
		return TRUE

	if(victim.acid_act(50, acid_volume))
		caster.visible_message(span_warning("[caster] rubs their hands on [victim], spreading acid all over them!"))
		caster.blood_volume = max(caster.blood_volume - blood_cost, 0)
		return TRUE

	to_chat(caster, span_notice("You cannot dissolve this object."))
	return TRUE

/datum/action/cooldown/spell/touch/acid/proc/dissolve_handcuffs(mob/living/carbon/human/user, obj/O)
	if(O && user.handcuffed == O)
		user.visible_message(span_warning("[O] dissolve[O.gender == PLURAL?"":"s"] into a puddle of sizzling goop."))
		qdel(O)

/obj/item/melee/touch_attack/acid
	name = "\improper acidic hand"
	desc = "This is kind of like when you drink acid to replenish your blood, only a lot less safe for others."
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "mansus"

/datum/mutation/human/acid_touch/unstable
	name = "Unstable Acidic Hands"
	desc = "Allows a host to metabolize some of their blood into acid, concentrated on their hands. This strain is more unstable than the one found on oozelings."
	instability = 50
	conflicts = list(/datum/mutation/human/acid_touch)
