/datum/mutation/human/telekinesis
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/telekinesis/modify()
	. = ..()
	if(owner && GET_MUTATION_SYNCHRONIZER(src) < 1)
		owner.update_mutations_overlay()

/datum/mutation/human/telekinesis/get_visual_indicator()
	if(GET_MUTATION_SYNCHRONIZER(src) < 1) // Stealth
		return FALSE
	return visual_indicators[type][1]

/obj/item/tk_grab
	var/added_damage // The damage we have given our target, we store it in a var to avoid adding chromosomes breaking things

/obj/item/tk_grab/Destroy()
	if(!QDELETED(focus) && added_damage)
		focus.throwforce -= added_damage
	return ..()

/obj/item/tk_grab/focus_object(obj/target) // Okay this is a LITTLE BIT jank BUT hear me out-- okay maybe don't.
	. = ..()
	if(!.)
		return

	var/datum/mutation/human/telekinesis/telekinesis = locate(/datum/mutation/human/telekinesis) in tk_user.dna.mutations
	if(!telekinesis)
		return

	var/mutation_power = GET_MUTATION_POWER(telekinesis)
	if(mutation_power <= 1)
		return

	added_damage = mutation_power * 4
	focus.throwforce += added_damage
