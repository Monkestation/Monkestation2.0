/datum/action/cooldown/spell/devil/contract
	name = "Summon devilish contract"
	desc = "Summons an infernal contract."
	sound = 'sound/magic/fireball.ogg'
	school = SCHOOL_CONJURATION
	cooldown_time = 10 SECONDS
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED|AB_CHECK_HANDS_BLOCKED

/datum/action/cooldown/spell/devil/contract/cast(mob/living/user)
	. = ..()
	var/datum/antagonist/devil/devil = user.mind?.has_antag_datum(/datum/antagonist/devil)
	if(!devil) // Sorry, we need the clauses
		return

	user.visible_message(
		span_warning("[user]'s hand bursts into flames as a piece of paper is created in it!"),
		span_notice("You create an infernal contract in your hands."),
	)
	var/obj/item/paper/devil_contract/contract = new(get_turf(owner), devil.default_clauses.Copy())
	user.put_in_hands(contract)
