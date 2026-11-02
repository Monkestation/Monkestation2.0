//revive your host
/datum/action/cooldown/borer/revive_host
	name = "Revive Host"
	cooldown_time = 2 MINUTES
	button_icon_state = "revive"
	chemical_cost = 200
	requires_host = TRUE
	sugar_restricted = TRUE
	ability_explanation = "\
	Halfs all the damage, including organ damage that your host has. Then defiblirates their heart\n\
	You may need to use this ability multiple times depending on how badly your host is damaged\n\
	"

/datum/action/cooldown/borer/revive_host/check_conditions()
	. = ..()
	if(.)
		return

	var/mob/living/basic/cortical_borer/user = owner
	if(user.human_host.stat != DEAD)
		owner.balloon_alert(owner, "dead host required")
		return COMPONENT_ACTION_BLOCK_TRIGGER

/datum/action/cooldown/borer/revive_host/Activate(mob/living/basic/cortical_borer/user)
	user.chemical_storage -= chemical_cost

	if(user.human_host.getBruteLoss())
		user.human_host.adjustBruteLoss(-user.human_host.getBruteLoss() * 0.5)
	if(user.human_host.getToxLoss())
		user.human_host.adjustToxLoss(-user.human_host.getToxLoss() * 0.5)
	if(user.human_host.getFireLoss())
		user.human_host.adjustFireLoss(-user.human_host.getFireLoss() * 0.5)
	if(user.human_host.getOxyLoss())
		user.human_host.adjustOxyLoss(-user.human_host.getOxyLoss() * 0.5)

	if(user.human_host.blood_volume < BLOOD_VOLUME_BAD)
		user.human_host.blood_volume = BLOOD_VOLUME_BAD

	for(var/obj/item/organ/internal/internal_target in user.human_host.organs)
		internal_target.apply_organ_damage(-internal_target.damage * 0.5)

	user.human_host.revive(revival_policy = POLICY_ANTAGONISTIC_REVIVAL)
	to_chat(user.human_host, span_boldwarning("Your heart jumpstarts!"))
	owner.balloon_alert(owner, "host revived")
	var/turf/human_turf = get_turf(user.human_host)
	var/logging_text = "[key_name(user)] revived [key_name(user.human_host)] at [loc_name(human_turf)]"
	user.log_message(logging_text, LOG_GAME)
	user.human_host.log_message(logging_text, LOG_GAME)
	return ..()
