#define STAGE_START 0
#define STAGE_HANDSHAKE 1
#define STAGE_REVIVAL 2
#define STAGE_FINAL 3

/datum/objective/collect_souls
	name = "collect souls (devil)"
	var/disable_progression = FALSE
	/// How many souls have we collected so far
	var/collected_souls = 0
	/// How many souls do we require to succeed (or stage up)
	var/required_souls = 0
	/// The stage we are in
	var/stage = STAGE_START

/datum/objective/collect_souls/New(text)
	. = ..()
	required_souls = rand(2, 3)
	update_explanation_text()

/datum/objective/collect_souls/check_completion()
	update_explanation_text()
	if(collected_souls == required_souls && stage != STAGE_FINAL && !disable_progression)
		var/list/datum/mind/owners = get_owners()
		stage++
		required_souls = floor(required_souls * 1.5)
		if(stage != STAGE_FINAL)
			for(var/datum/mind/objective_owner as anything in owners)
				give_abilities(objective_owner)

	return collected_souls >= required_souls

/datum/objective/collect_souls/update_explanation_text()
	if(required_souls)
		explanation_text = "Collect at least [required_souls] souls from mortals (current:[collected_souls])."
	else
		explanation_text = "Collect as many souls as possible (current:[collected_souls])."

/datum/objective/collect_souls/admin_edit(mob/admin)
	var/prompt = "How many souls should the devil require? (Setting this will disable devil progression)"
	var/count = input(admin, prompt, "required souls", target_amount) as num|null
	if(!count)
		return

	disable_progression = TRUE
	required_souls = count
	check_completion()

/datum/objective/collect_souls/proc/give_abilities(datum/mind/mind)
	var/list/need_variations = list("need", "require", "must get", "should get")
	to_chat(mind.current, span_boldwarning("This isn't enough souls, i [pick(need_variations)] more."))
	var/datum/antagonist/devil/devil = mind.has_antag_datum(/datum/antagonist/devil)
	if(!devil)
		return
	var/powerup_message = ""
	switch(stage)
		if(STAGE_HANDSHAKE)
			var/datum/action/cooldown/spell/touch/handshake/handshake = new(devil)
			devil.current_abilities += handshake
			handshake.Grant(mind.current)
			powerup_message = "you gained the ability to make default-clause contracts via handshake."
		if(STAGE_REVIVAL)
			var/datum/action/cooldown/spell/touch/handshake/handshake = locate(/datum/action/cooldown/spell/touch/handshake) in devil.current_abilities
			if(handshake)
				handshake.upgraded = TRUE
				powerup_message = "your devilish handshakes have strenghtened to be able to make revival contracts with corpses."

	if(powerup_message)
		to_chat(mind.current, span_notice("From the souls you collected, [powerup_message]"))

#undef STAGE_START
#undef STAGE_HANDSHAKE
#undef STAGE_REVIVAL
#undef STAGE_FINAL
