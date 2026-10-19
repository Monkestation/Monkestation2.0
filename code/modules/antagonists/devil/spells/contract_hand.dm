/datum/action/cooldown/spell/touch/handshake
	name = "Contractual handshake"
	desc = "Allows you to handshake someone to apply a default contract on them alongside a random negative clause."
	button_icon_state = "arcane_barrage"
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"
	sound = null
	school = SCHOOL_MIME // I mean its kind of an emote
	invocation_type = INVOCATION_NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_CASTABLE_WITHOUT_INVOCATION
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	cooldown_time = 5 SECONDS
	hand_path = /obj/item/melee/touch_attack/devil_handshake
	var/upgraded = FALSE

/obj/item/melee/touch_attack/devil_handshake
	name = "handshake"
	desc = "There's no better way to seal the deal than shaking someone's hand."
	icon_state = "disintegrate"

/datum/action/cooldown/spell/touch/handshake/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/target, mob/living/carbon/user)
	. = TRUE
	if(!user.Adjacent(target) || !istype(target))
		return

	if(HAS_TRAIT(target, TRAIT_NO_SOUL) || isnull(target.mind))
		to_chat(user, span_notice("They don't have a soul we could take."))
		return

	if(target.stat)
		if(target.stat < DEAD || !upgraded)
			to_chat(user, span_warning("They can't possibly agree to a handshake like this."))
			return
		. = make_corpse_contract(target, user)
		return

	user.visible_message(span_notice("[user] offers a handshake to [target] whilst very visibly smirking."))
	var/message = "[user] is offering you a handshake with a visible smirk, accepting it is probably not a good idea. Accept anyway?"
	var/confirm = tgui_alert(target, message, "Sinister handshake", list("Yes", "No"))
	if(user.stat || target.stat || !user.Adjacent(target) || HAS_TRAIT(target, TRAIT_NO_SOUL))
		return
	if(confirm != "Yes")
		target.visible_message(span_notice("[target] shakes their head, declining [user]'s handshake."))
		return

	target.visible_message(span_notice("[target] accepts [user]'s handshake."))
	make_contract(target, user)

/datum/action/cooldown/spell/touch/handshake/proc/make_contract(mob/living/victim, mob/living/user)
	var/datum/antagonist/devil/devil = user.mind?.has_antag_datum(/datum/antagonist/devil)
	if(!devil || !victim.mind)
		return

	var/list/clauses = devil.default_clauses.Copy()
	var/list/negative_clauses = devil.clauses.Copy() - clauses
	for(var/datum/devil_clause/clause as anything in negative_clauses)
		if(clause.cost >= 0)
			negative_clauses -= clause

	var/picked_clause = "None..?"
	if(length(negative_clauses))
		picked_clause = pick(negative_clauses)
		clauses += picked_clause
	to_chat(user, span_notice("Their picked random negative clause is [picked_clause], you may choose to tell them this."))
	devil.sign_contract(victim.mind, clauses)

/datum/action/cooldown/spell/touch/handshake/proc/make_corpse_contract(mob/living/victim, mob/living/user)
	var/datum/antagonist/devil/devil = user.mind?.has_antag_datum(/datum/antagonist/devil)
	if(!devil)
		return TRUE

	var/datum/devil_clause/trait_giver/soul/soul_clause = locate(/datum/devil_clause/trait_giver/soul) in devil.default_clauses
	if(!soul_clause) // Yeah you can't exactly do this deal if they won't uphold their part
		to_chat(user, span_warning("You realize you can't extract souls, how unfortunate."))
		return TRUE

	user.visible_message(span_notice("[user] offers a handshake to [victim]'s corpse..?"))
	var/message = "[user] is offering to take your soul in exchange for reviving you (devil contract), Accept?"
	var/confirm = tgui_alert(victim, message, "Otherworldy handshake", list("Yes", "No"), ui_state = GLOB.observer_state)
	if(confirm != "Yes" || user.stat || victim.stat < DEAD || !user.Adjacent(victim))
		user.visible_message(span_notice("... It doesn't seem much for conversation."))
		return TRUE

	var/datum/action/cooldown/spell/devil/revival/revival = locate(/datum/action/cooldown/spell/devil/revival) in user.actions
	if(revival)
		revival.cast(victim) // Flavor? Keeping consistency? Pure jank? Ya choose.
		devil.sign_contract(victim.mind, list(soul_clause))
		user.visible_message(span_warning("[user] grabs [victim] by the hand, standing them up on their feet as [victim] opens their eyes!"))
	return FALSE
