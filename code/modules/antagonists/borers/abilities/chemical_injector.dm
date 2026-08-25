/// How many of OUR chemicals do we need to spend to inject 1 unit worth of chemicals being injected
#define CHEMICALS_PER_UNIT 2
/// How long will the cooldown on injection be, per chemical injected? example: 10 chemicals injected, 5 second divisor = 2 seconds
#define CHEMICAL_SECOND_DIVISOR (5 SECONDS)

/datum/action/cooldown/borer/inject_chemical
	name = "Open Chemical Injector"
	button_icon_state = "chemical"
	requires_host = TRUE
	sugar_restricted = TRUE
	ability_explanation = "chemical"
	ability_explanation = "\
	This ability allows us to inject chemicals into our host.\n\
	Our internal chemicals can be converted to human-compatible chemicals at a ratio of 2:1\n\
	"
	/// What chemicals we can inject
	var/list/known_chemicals = list()
	/// Injection rates we can select
	var/list/available_injection_amounts = list(5)
	/// How much chemicals are we currently injecting
	var/injection_amount = 5
	/// Cooldown between injecting chemicals
	COOLDOWN_DECLARE(injection_cooldown)

/datum/action/cooldown/borer/inject_chemical/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!.)
		return FALSE
	ui_interact(owner)

/datum/action/cooldown/borer/inject_chemical/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BorerChem", name)
		ui.open()

/datum/action/cooldown/borer/inject_chemical/ui_data(mob/user)
	var/list/data = list()
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	data["amount"] = injection_amount
	data["energy"] = cortical_owner.chemical_storage / CHEMICALS_PER_UNIT
	data["maxEnergy"] = cortical_owner.max_chemical_storage / CHEMICALS_PER_UNIT
	data["borerTransferAmounts"] = available_injection_amounts
	data["onCooldown"] = !COOLDOWN_FINISHED(src, injection_cooldown)
	data["notEnoughChemicals"] = ((injection_amount * CHEMICALS_PER_UNIT) > cortical_owner.chemical_storage) ? TRUE : FALSE
	data["reagent_holder"] = (cortical_owner.reagent_holder)

	var/chemicals[0]
	for(var/reagent in known_chemicals)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[reagent]
		if(temp)
			var/chemname = temp.name
			chemicals.Add(list(list("title" = chemname, "id" = temp.name)))
	data["chemicals"] = chemicals

	return data

/datum/action/cooldown/borer/inject_chemical/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/basic/cortical_borer/cortical_owner = owner
	switch(action)
		if("amount")
			var/target = text2num(params["target"])
			if(target in available_injection_amounts)
				injection_amount = target
				. = TRUE
		if("inject")
			if(!iscorticalborer(usr) || !COOLDOWN_FINISHED(src, injection_cooldown))
				return
			if(cortical_owner.host_sugar())
				owner.balloon_alert(owner, "cannot function with sugar in host")
				return
			var/reagent_name = params["reagent"]
			var/reagent = GLOB.name2reagent[reagent_name]
			if(!known_chemicals.Find(reagent))
				return

			cortical_owner.human_host.reagents.add_reagent(reagent, injection_amount, added_purity = 1)
			to_chat(cortical_owner.human_host, span_warning("You feel something cool inside of you and a dull ache in your head!"))
			cortical_owner.chemical_storage -= injection_amount * CHEMICALS_PER_UNIT
			COOLDOWN_START(src, injection_cooldown, (injection_amount / CHEMICAL_SECOND_DIVISOR))

			var/turf/human_turf = get_turf(cortical_owner.human_host)
			var/logging_text = "[key_name(cortical_owner)] injected [key_name(cortical_owner.human_host)] with [reagent_name] at [loc_name(human_turf)]"
			cortical_owner.log_message(logging_text, LOG_GAME)
			cortical_owner.human_host.log_message(logging_text, LOG_GAME)
			. = TRUE
		if("reaction_lookup")
			if(!iscorticalborer(usr))
				return
			cortical_owner.reagent_holder.reagents.ui_interact(cortical_owner)



/datum/action/cooldown/borer/inject_chemical/ui_state(mob/user)
	return GLOB.always_state

/datum/action/cooldown/borer/inject_chemical/ui_status(mob/user, datum/ui_state/state)
	if(!iscorticalborer(user))
		return UI_CLOSE

	var/mob/living/basic/cortical_borer/borer = user

	if(!borer.human_host)
		return UI_CLOSE
	return ..()

#undef CHEMICALS_PER_UNIT
#undef CHEMICAL_SECOND_DIVISOR
