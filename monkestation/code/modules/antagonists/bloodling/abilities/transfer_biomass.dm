/datum/action/cooldown/mob_cooldown/bloodling/transfer_biomass
	name = "Transfer Biomass"
	desc = "Transfer biomass to another organism."
	button_icon_state = "transfer"

/datum/action/cooldown/mob_cooldown/bloodling/transfer_biomass/PreActivate(atom/target)
	. = ..()

	var/mob/living/mob = target
	// We dont wanna transfer stuff to ourselves
	if(mob == owner)
		return FALSE

	if(!istype(mob, /mob/living/basic/bloodling))
		owner.balloon_alert(owner, "only works on bloodlings!")
		return FALSE
	return

/datum/action/cooldown/mob_cooldown/bloodling/transfer_biomass/Activate(atom/target)
	. = ..()

	var/mob/living/basic/bloodling/our_mob = owner
	var/mob/living/basic/bloodling/donation_target = target

	var/amount = tgui_input_number(our_mob, "Amount", "Transfer Biomass to [donation_target]", max_value = our_mob.biomass - 1)
	if(QDELETED(donation_target) || QDELETED(src) || QDELETED(our_mob) || !IsAvailable(feedback = TRUE) || isnull(amount) || amount <= 0)
		return FALSE

	donation_target.add_biomass(amount)
	our_mob.add_biomass(-amount)

	to_chat(donation_target, span_noticealien("[our_mob] has transferred [amount] biomass to you."))
	to_chat(our_mob, span_noticealien("You transfer [amount] biomass to [donation_target]."))
	return TRUE
