// robot_upgrades.dm
// Contains various borg upgrades.

/obj/item/borg/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/mob/silicon/robot_items.dmi'
	icon_state = "module_general"
	w_class = WEIGHT_CLASS_SMALL
	/// Whitelist of model types that can use this upgrade.
	var/list/model_type = null
	/// Bitflags listing model compatibility. Used in the exosuit fabricator for creating sub-categories.
	var/list/model_flags = NONE
	/// List of items to add with the module, if any.
	var/list/items_to_add
	/// List of items to remove with the module, if any.
	var/list/items_to_remove
	/// If true, requires the cyborg to have chosen a module.
	var/require_model = FALSE
	/// If true, will be deleted after usage and will not be stored in the cyborg.
	var/one_use = FALSE
	/// If true, allows duplicates of itself to exist within the cyborg.
	var/allow_duplicates = FALSE

/obj/item/borg/upgrade/proc/action(mob/living/silicon/robot/borg, user = usr)
	if(borg.stat == DEAD)
		to_chat(user, span_warning("[src] will not function on a deceased cyborg!"))
		return FALSE
	if(model_type && !is_type_in_list(borg.model, model_type))
		to_chat(borg, span_alert("Upgrade mounting error! No suitable hardpoint detected."))
		to_chat(user, span_warning("There's no mounting point for the module!"))
		return FALSE
	if(!allow_duplicates && (locate(type) in borg.upgrades))
		to_chat(borg, span_alert("Upgrade mounting error! Hardpoint already occupied!"))
		to_chat(user, span_warning("The mounting point for the module is already occupied!"))
		return FALSE
	// Handles adding/removing items.
	if(length(items_to_add))
		install_items(borg, user, items_to_add)
	if(length(items_to_remove))
		remove_items(borg, user, items_to_remove)
	return TRUE

/obj/item/borg/upgrade/proc/deactivate(mob/living/silicon/robot/borg, user = usr)
	if (!(src in borg.upgrades))
		return FALSE
	// Handles reverting the items back.
	if(length(items_to_add))
		remove_items(borg, user, items_to_add)
	if(length(items_to_remove))
		install_items(borg, user, items_to_remove)
	return TRUE

/// Handles adding items with the module.
/obj/item/borg/upgrade/proc/install_items(mob/living/silicon/robot/borg, mob/living/user = usr, list/items)
	for(var/item_to_add in items)
		var/obj/item/module_item = new item_to_add(borg.model)
		borg.model.basic_modules += module_item
		borg.model.add_module(module_item, FALSE, TRUE)
	return TRUE

/// Handles removing items with the module.
/obj/item/borg/upgrade/proc/remove_items(mob/living/silicon/robot/borg, mob/living/user = usr, list/items)
	for(var/item_to_remove in items)
		var/obj/item/module_item = locate(item_to_remove) in borg.model.modules
		if(module_item)
			borg.model.remove_module(module_item)
	return TRUE

/obj/item/borg/upgrade/rename
	name = "cyborg reclassification board"
	desc = "Used to rename a cyborg."
	icon_state = "cyborg_upgrade1"
	one_use = TRUE
	var/heldname = ""

/obj/item/borg/upgrade/rename/attack_self(mob/user)
	var/new_heldname = sanitize_name(tgui_input_text(user, "Enter new robot name", "Cyborg Reclassification", heldname, MAX_NAME_LEN), allow_numbers = TRUE)
	if(!new_heldname || !user.is_holding(src))
		return
	heldname = new_heldname
	user.log_message("set \"[heldname]\" as a name in a cyborg reclassification board at [loc_name(user)]", LOG_GAME)

/obj/item/borg/upgrade/rename/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	var/oldname = borg.real_name
	var/oldkeyname = key_name(borg)
	borg.custom_name = heldname
	borg.updatename()
	if(oldname == borg.real_name)
		borg.notify_ai(AI_NOTIFICATION_CYBORG_RENAMED, oldname, borg.real_name)
	usr.log_message("used a cyborg reclassification board to rename [oldkeyname] to [key_name(borg)]", LOG_GAME)

/obj/item/borg/upgrade/disablercooler
	name = "cyborg rapid disabler cooling module"
	desc = "Used to cool a mounted disabler, increasing the potential current in it and thus its recharge rate."
	icon_state = "module_security"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/security)
	model_flags = BORG_MODEL_SECURITY
	// We handle this in a custom way.
	allow_duplicates = TRUE

/obj/item/borg/upgrade/disablercooler/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	var/obj/item/gun/energy/disabler/cyborg/disabler = locate() in borg.model.modules
	if(isnull(disabler))
		to_chat(user, span_warning("There's no disabler in this unit!"))
		return FALSE
	if(disabler.charge_delay <= 2)
		to_chat(borg, span_warning("A cooling unit is already installed!"))
		to_chat(user, span_warning("There's no room for another cooling unit!"))
		return FALSE
	disabler.charge_delay = max(2, disabler.charge_delay - 4)

/obj/item/borg/upgrade/disablercooler/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	var/obj/item/gun/energy/disabler/cyborg/disabler = locate() in borg.model.modules
	if(isnull(disabler))
		return FALSE
	disabler.charge_delay = initial(disabler.charge_delay)

/obj/item/borg/upgrade/thrusters
	name = "ion thruster upgrade"
	desc = "An energy-operated thruster system for cyborgs."
	icon_state = "module_general"

/obj/item/borg/upgrade/thrusters/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	if(borg.ionpulse)
		to_chat(user, span_warning("This unit already has ion thrusters installed!"))
		return FALSE
	borg.ionpulse = TRUE
	borg.toggle_ionpulse() // Enabled by default.

/obj/item/borg/upgrade/thrusters/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	borg.ionpulse = FALSE

/obj/item/borg/upgrade/ddrill
	name = "mining cyborg diamond drill"
	desc = "A diamond drill replacement for the mining model's standard drill."
	icon_state = "module_miner"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/miner)
	model_flags = BORG_MODEL_MINER
	items_to_add = list(/obj/item/pickaxe/drill/diamonddrill)
	items_to_remove = list(/obj/item/pickaxe/drill/cyborg, /obj/item/shovel)

/obj/item/borg/upgrade/soh
	name = "mining cyborg satchel of holding"
	desc = "A satchel of holding replacement for mining cyborg's ore satchel module."
	icon_state = "module_miner"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/miner)
	model_flags = BORG_MODEL_MINER
	items_to_add = list(/obj/item/storage/bag/ore/holding)
	items_to_remove = list(/obj/item/storage/bag/ore/cyborg)

/obj/item/borg/upgrade/tboh
	name = "janitor cyborg trash bag of holding"
	desc = "A trash bag of holding replacement for the janiborg's standard trash bag."
	icon_state = "module_janitor"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/janitor)
	model_flags = BORG_MODEL_JANITOR
	items_to_add = list(/obj/item/storage/bag/trash/bluespace)
	items_to_remove = list(/obj/item/storage/bag/trash)

/obj/item/borg/upgrade/amop
	name = "janitor cyborg advanced mop"
	desc = "An advanced mop replacement for the janiborg's standard mop."
	icon_state = "module_janitor"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/janitor)
	model_flags = BORG_MODEL_JANITOR
	items_to_add = list(/obj/item/mop/advanced)
	items_to_remove = list(/obj/item/mop)

/obj/item/borg/upgrade/prt
	name = "janitor cyborg plating repair tool"
	desc = "A tiny heating device to repair burnt and damaged hull platings with."
	icon_state = "module_janitor"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/janitor)
	model_flags = BORG_MODEL_JANITOR
	items_to_add = list(/obj/item/cautery/prt)

/obj/item/borg/upgrade/syndicate
	name = "illegal equipment module"
	desc = "Unlocks the hidden, deadlier functions of a cyborg."
	icon_state = "module_illegal"
	require_model = TRUE

/obj/item/borg/upgrade/syndicate/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	if(borg.emagged)
		return FALSE
	borg.SetEmagged(TRUE)
	borg.logevent("WARN: hardware installed with missing security certificate!") // A bit of fluff to hint it was an illegal tech item.
	borg.logevent("WARN: root privleges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].") // Random eight digit hex value. Two are used because rand(1, 4294967295) throws an error.
	return TRUE

/obj/item/borg/upgrade/syndicate/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	borg.SetEmagged(FALSE)

/obj/item/borg/upgrade/lavaproof
	name = "mining cyborg lavaproof chassis"
	desc = "An upgrade kit to apply specialized coolant systems and insulation layers to a mining cyborg's chassis, enabling them to withstand exposure to molten rock and liquid plasma."
	icon_state = "module_miner"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | FREEZE_PROOF
	require_model = TRUE
	model_type = list(/obj/item/robot_model/miner)
	model_flags = BORG_MODEL_MINER

/obj/item/borg/upgrade/lavaproof/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	borg.add_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_SNOWSTORM_IMMUNE), type)

/obj/item/borg/upgrade/lavaproof/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	borg.remove_traits(list(TRAIT_LAVA_IMMUNE, TRAIT_SNOWSTORM_IMMUNE), type)

/obj/item/borg/upgrade/selfrepair
	name = "self-repair module"
	desc = "This module will repair the cyborg over time."
	icon_state = "module_general"
	require_model = TRUE
	/// The amount of burn and brute damage to be healed.
	var/repair_amount = 1
	/// The amount of deciseconds between repairs.
	var/repair_cooldown = 4 SECONDS
	/// The energy cost of the repair.
	var/energy_cost = 0.01 * STANDARD_CELL_CHARGE
	/// Is self-repair active?
	var/on = FALSE
	/// The action used to toggle self-repair.
	var/datum/action/toggle_action
	/// The cooldown between repairs.
	COOLDOWN_DECLARE(next_repair)

/obj/item/borg/upgrade/selfrepair/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	icon_state = "selfrepair_off"
	toggle_action = new /datum/action/item_action/toggle(src)
	toggle_action.Grant(borg)

/obj/item/borg/upgrade/selfrepair/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	toggle_action.Remove(borg)
	QDEL_NULL(toggle_action)
	deactivate_sr()

/obj/item/borg/upgrade/selfrepair/ui_action_click()
	if(on)
		to_chat(toggle_action.owner, span_notice("You deactivate the self-repair module."))
		deactivate_sr()
	else
		to_chat(toggle_action.owner, span_notice("You activate the self-repair module."))
		activate_sr()

/obj/item/borg/upgrade/selfrepair/update_icon_state()
	if(toggle_action)
		icon_state = "selfrepair_[on ? "on" : "off"]"
	else
		icon_state = "cyborg_upgrade5"
	return ..()

/obj/item/borg/upgrade/selfrepair/proc/activate_sr()
	START_PROCESSING(SSobj, src)
	on = TRUE
	update_appearance()

/obj/item/borg/upgrade/selfrepair/proc/deactivate_sr()
	STOP_PROCESSING(SSobj, src)
	on = FALSE
	update_appearance()

/obj/item/borg/upgrade/selfrepair/process()
	if(!COOLDOWN_FINISHED(src, next_repair))
		return
	if(!iscyborg(toggle_action.owner))
		return
	var/mob/living/silicon/robot/borg = toggle_action.owner
	if(!istype(borg) || borg.stat == DEAD || !on)
		deactivate_sr()
		return
	if(!borg.cell)
		to_chat(borg, span_alert("Self-repair module deactivated. Please insert power cell."))
		deactivate_sr()
		return
	if(borg.cell.charge < energy_cost * 2)
		to_chat(borg, span_alert("Self-repair module deactivated. Please recharge."))
		deactivate_sr()
		return
	if(borg.health < borg.maxHealth)
		if(borg.health < 0)
			repair_amount = 2.5
			energy_cost = 0.03 * STANDARD_CELL_CHARGE
		else
			repair_amount = 1
			energy_cost = 0.01 * STANDARD_CELL_CHARGE
		borg.adjustBruteLoss(-repair_amount)
		borg.adjustFireLoss(-repair_amount)
		borg.updatehealth()
		borg.cell.use(energy_cost)
	else
		borg.cell.use(0.005 * STANDARD_CELL_CHARGE)
	COOLDOWN_START(src, next_repair, repair_cooldown)
	if(!TIMER_COOLDOWN_FINISHED(src, COOLDOWN_BORG_SELF_REPAIR))
		return
	TIMER_COOLDOWN_START(src, COOLDOWN_BORG_SELF_REPAIR, 200 SECONDS)
	var/msgmode = "standby"
	if(borg.health < 0)
		msgmode = "critical"
	else if(borg.health < borg.maxHealth)
		msgmode = "normal"
	to_chat(borg, span_notice("Self-repair is active in [span_boldnotice("[msgmode]")] mode."))


/obj/item/borg/upgrade/hypospray
	name = "medical cyborg hypospray advanced synthesiser"
	desc = "An upgrade to the Medical model cyborg's hypospray, allowing it \
		to produce more advanced and complex medical reagents."
	icon_state = "module_medical"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical)
	model_flags = BORG_MODEL_MEDICAL
	var/list/additional_reagents = list()

/obj/item/borg/upgrade/hypospray/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	for(var/obj/item/reagent_containers/borghypo/hypo in borg.model.modules)
		hypo.upgrade()

/obj/item/borg/upgrade/hypospray/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	for(var/obj/item/reagent_containers/borghypo/hypo in borg.model.modules)
		hypo.downgrade()

/obj/item/borg/upgrade/hypospray/expanded
	name = "medical cyborg expanded hypospray"
	desc = "An upgrade to the Medical model's hypospray, allowing it \
		to treat a wider range of conditions and problems."

/obj/item/borg/upgrade/piercing_hypospray
	name = "cyborg piercing hypospray"
	desc = "An upgrade to a cyborg's hypospray, allowing it to \
		pierce armor and thick material."
	icon_state = "module_medical"

/obj/item/borg/upgrade/piercing_hypospray/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	var/found_hypo = FALSE
	for(var/obj/item/reagent_containers/borghypo/hypo in borg.model.modules)
		hypo.bypass_protection = TRUE
		found_hypo = TRUE
	if(!found_hypo)
		to_chat(user, span_warning("There are no installed hypospray modules to upgrade with piercing!")) // Check to see if any hyposprays were upgraded.
		return FALSE
	// If we are actually going to install the upgrade due to the presence of compatible modules, make sure their emagged counterparts get upgraded too.
	for(var/obj/item/reagent_containers/borghypo/hypo in borg.model.emag_modules)
		hypo.bypass_protection = TRUE

/obj/item/borg/upgrade/piercing_hypospray/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	for(var/obj/item/reagent_containers/borghypo/hypo in borg.model.modules)
		hypo.bypass_protection = initial(hypo.bypass_protection)
	for(var/obj/item/reagent_containers/borghypo/hypo in borg.model.emag_modules)
		hypo.bypass_protection = initial(hypo.bypass_protection)

/obj/item/borg/upgrade/defib
	name = "medical cyborg defibrillator"
	desc = "An upgrade to the Medical model, installing a built-in \
		defibrillator, for on the scene revival."
	icon_state = "module_medical"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical)
	model_flags = BORG_MODEL_MEDICAL
	items_to_add = list(/obj/item/shockpaddles/cyborg)

///A version of the above that also acts as a holder of an actual defibrillator item used in place of the upgrade chip.
/obj/item/borg/upgrade/defib/backpack
	var/obj/item/defibrillator/defib_instance

/obj/item/borg/upgrade/defib/backpack/Initialize(mapload, obj/item/defibrillator/defib)
	. = ..()
	if(isnull(defib))
		defib = new /obj/item/defibrillator
	defib_instance = defib
	name = defib_instance.name
	defib_instance.moveToNullspace()
	RegisterSignals(defib_instance, list(COMSIG_QDELETING, COMSIG_MOVABLE_MOVED), PROC_REF(on_defib_instance_qdel_or_moved))

/obj/item/borg/upgrade/defib/backpack/proc/on_defib_instance_qdel_or_moved(obj/item/defibrillator/defib)
	SIGNAL_HANDLER
	defib_instance = null
	if(!QDELETED(src))
		qdel(src)

/obj/item/borg/upgrade/defib/backpack/Destroy()
	if(!QDELETED(defib_instance))
		QDEL_NULL(defib_instance)
	return ..()

/obj/item/borg/upgrade/defib/backpack/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	defib_instance?.forceMove(borg.drop_location()) // [on_defib_instance_qdel_or_moved()] handles the rest.

/obj/item/borg/upgrade/surgical_database
	name = "medical cyborg surgical database"
	desc = "An upgrade to the Medical model, installing a surgical databank that can record available surgeries and gives instructions on how to perform surgical procedures."
	icon_state = "module_medical"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical, /obj/item/robot_model/syndicate_medical)
	model_flags = BORG_MODEL_MEDICAL
	/// Action that looks for nearby objects to load new surgeries from.
	var/datum/action/database_scanner
	// List of surgeries that can be started.
	var/list/loaded_surgeries = list()

/obj/item/borg/upgrade/surgical_database/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	RegisterSignal(borg, COMSIG_SURGERY_STARTING, PROC_REF(check_surgery))
	RegisterSignal(borg, COMSIG_MOB_SURGERY_STEP_SUCCESS, PROC_REF(on_step_completion))
	database_scanner = new /datum/action/item_action/cyborg_surgical_database(src)
	database_scanner.Grant(borg)

/obj/item/borg/upgrade/surgical_database/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	UnregisterSignal(borg, list(COMSIG_SURGERY_STARTING, COMSIG_MOB_SURGERY_STEP_SUCCESS))
	database_scanner.Remove(borg)
	QDEL_NULL(database_scanner)

/obj/item/borg/upgrade/surgical_database/ui_action_click(mob/user, actiontype)
	playsound(src, 'sound/machines/terminal_processing.ogg', 25, TRUE)
	user.balloon_alert(user, "downloading surgery data...")
	if(!do_after(user, 1 SECONDS, user))
		user.balloon_alert(user, "surgery download interrupted!")
		return
	playsound(src, 'sound/machines/terminal_success.ogg', 25, TRUE)
	var/list/surgeries_to_add = list()
	for(var/obj/nearby_object in range(1, user))
		if(istype(nearby_object, /obj/machinery/computer/operating))
			var/obj/machinery/computer/operating/operating_computer = nearby_object
			surgeries_to_add |= operating_computer.advanced_surgeries
			continue
		if(istype(nearby_object, /obj/item/disk/surgery))
			var/obj/item/disk/surgery/surgery_disk = nearby_object
			for(var/surgery in surgery_disk.surgeries)
				surgeries_to_add |= surgery
			continue
		if(istype(nearby_object, /obj/item/disk/tech_disk))
			var/obj/item/disk/tech_disk/tech_disk = nearby_object
			for(var/design in tech_disk.stored_research.researched_designs)
				var/datum/design/surgery/surgery_design = SSresearch.techweb_design_by_id(design)
				if(!istype(surgery_design))
					continue
				surgeries_to_add |= surgery_design.surgery
			continue
	if(!length(surgeries_to_add))
		user.balloon_alert(user, "no new surgery data found")
		return
	var/list/old_surgery_count = length(loaded_surgeries)
	loaded_surgeries |= surgeries_to_add
	var/list/new_surgery_count = length(loaded_surgeries)
	var/surgery_count_difference = new_surgery_count - old_surgery_count
	if(!surgery_count_difference)
		user.balloon_alert(user, "no new surgery data found")
		return
	user.balloon_alert(user, "installed [surgery_count_difference] new surgeries, [new_surgery_count] total loaded")

/obj/item/borg/upgrade/surgical_database/proc/check_surgery(mob/user, datum/surgery/surgery, mob/patient)
	SIGNAL_HANDLER
	if(surgery.replaced_by in loaded_surgeries)
		return COMPONENT_CANCEL_SURGERY
	if(surgery.type in loaded_surgeries)
		return COMPONENT_FORCE_SURGERY

/obj/item/borg/upgrade/surgical_database/proc/on_step_completion(mob/living/user, datum/surgery_step/current_step, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	SIGNAL_HANDLER
	var/possible_steps = list()
	if(current_step.repeatable)
		possible_steps += "[current_step.name]"
	var/datum/surgery_step/next_step = surgery.get_surgery_next_step()
	if(!isnull(next_step))
		possible_steps += "[next_step.name]"
		qdel(next_step)
	if(!length(possible_steps))
		target.balloon_alert(user, "surgery done!")
		return
	target.balloon_alert(user, "next step: [english_list(possible_steps, and_text = " or ")]")

/datum/action/item_action/cyborg_surgical_database
	name = "Update Surgeries"
	button_icon = 'icons/obj/device.dmi'
	button_icon_state = "surgical_processor"

/obj/item/borg/upgrade/ai
	name = "B.O.R.I.S. module"
	desc = "Bluespace Optimized Remote Intelligence Synchronization. An uplink device which takes the place of an MMI in cyborg endoskeletons, creating a robotic shell controlled by an AI."
	icon = 'icons/obj/module.dmi'
	icon_state = "boris"

/obj/item/borg/upgrade/ai/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	if(borg.key) // You cannot replace a player unless the key is completely removed.
		to_chat(user, span_warning("Intelligence patterns detected in this [borg.braintype]. Aborting."))
		return FALSE
	borg.make_shell(src)

/obj/item/borg/upgrade/ai/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!. || !borg.shell)
		return .
	borg.undeploy()
	borg.notify_ai(AI_NOTIFICATION_AI_SHELL)

/obj/item/borg/upgrade/expand
	name = "borg expander"
	desc = "A cyborg resizer, it makes a cyborg huge."
	icon_state = "module_general"

/obj/item/borg/upgrade/expand/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!. || HAS_TRAIT(borg, TRAIT_NO_TRANSFORM))
		return FALSE
	if(borg.hasExpanded)
		to_chat(usr, span_warning("This unit already has an expand module installed!"))
		return FALSE
	ADD_TRAIT(borg, TRAIT_NO_TRANSFORM, REF(src))
	var/prev_lockcharge = borg.lockcharge
	borg.SetLockdown(TRUE)
	borg.set_anchored(TRUE)
	do_smoke(1, borg, borg.loc)
	sleep(0.2 SECONDS)
	for(var/i in 1 to 4)
		playsound(borg, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, TRUE, -1)
		sleep(1.2 SECONDS)
	if(!prev_lockcharge)
		borg.SetLockdown(FALSE)
	borg.set_anchored(FALSE)
	REMOVE_TRAIT(borg, TRAIT_NO_TRANSFORM, REF(src))
	borg.hasExpanded = TRUE
	borg.update_transform(2)

/obj/item/borg/upgrade/expand/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	if (borg.hasExpanded)
		borg.hasExpanded = FALSE
		borg.update_transform(0.5)

/obj/item/borg/upgrade/bs_rped
	name = "engineering cyborg bluespace RPED"
	desc = "A bluespace rapid part exchange device for the engineering cyborg."
	icon_state = "module_engineer"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering, /obj/item/robot_model/saboteur, /obj/item/robot_model/science)
	model_flags = BORG_MODEL_ENGINEERING

/obj/item/borg/upgrade/bs_rped/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return

	var/obj/item/storage/part_replacer/cyborg/rped = locate() in borg.model.modules
	if(isnull(rped))
		to_chat(user, span_warning("This cyborg doesn't have a rapid part exchange device to upgrade!"))
		return FALSE

	install_items(borg, user, list(/obj/item/storage/part_replacer/bluespace))
	var/obj/item/storage/part_replacer/bluespace/brped = locate() in borg.model.modules
	var/move_location = borg.drop_location()
	brped.atom_storage.silent_for_user = TRUE
	for(var/obj/item in rped)
		if(!brped.atom_storage.attempt_insert(item, borg, TRUE))
			item.forceMove(move_location)
	brped.atom_storage.silent_for_user = initial(brped.atom_storage.silent_for_user)
	remove_items(borg, user, list(/obj/item/storage/part_replacer/cyborg))
	return TRUE

/obj/item/borg/upgrade/bs_rped/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return

	var/obj/item/storage/part_replacer/bluespace/brped = locate() in borg.model.modules
	if(isnull(brped))
		return FALSE

	install_items(borg, user, list(/obj/item/storage/part_replacer/cyborg))
	var/obj/item/storage/part_replacer/cyborg/rped = locate() in borg.model.modules
	var/move_location = borg.drop_location()
	rped.atom_storage.silent_for_user = TRUE
	for(var/obj/item in brped)
		if(!rped.atom_storage.attempt_insert(item, borg, TRUE))
			item.forceMove(move_location)
	rped.atom_storage.silent_for_user = initial(rped.atom_storage.silent_for_user)
	remove_items(borg, user, list(/obj/item/storage/part_replacer/bluespace))
	return TRUE

/obj/item/borg/upgrade/pinpointer
	name = "medical cyborg crew pinpointer"
	desc = "A crew pinpointer module for the medical cyborg. Permits remote access to the crew monitor."
	icon_state = "module_medical"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical, /obj/item/robot_model/syndicate_medical)
	model_flags = BORG_MODEL_MEDICAL
	items_to_add = list(/obj/item/pinpointer/crew)
	var/datum/action/crew_monitor

/obj/item/borg/upgrade/pinpointer/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	crew_monitor = new /datum/action/item_action/crew_monitor(src)
	crew_monitor.Grant(borg)

/obj/item/borg/upgrade/pinpointer/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	crew_monitor.Remove(borg)
	QDEL_NULL(crew_monitor)

/obj/item/borg/upgrade/pinpointer/ui_action_click()
	if(..())
		return
	var/mob/living/silicon/robot/borg = usr
	GLOB.crewmonitor.show(borg, borg)

/datum/action/item_action/crew_monitor
	name = "Interface With Crew Monitor"
	button_icon = 'icons/obj/device.dmi'
	button_icon_state = "scanner_med"

/obj/item/borg/upgrade/transform
	name = "borg model picker (Standard)"
	desc = "Allows you to to turn a cyborg into a standard cyborg."
	icon_state = "module_general"
	var/obj/item/robot_model/new_model = null

/obj/item/borg/upgrade/transform/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return
	if(!new_model)
		return FALSE
	borg.model.transform_to(new_model, FALSE)

/obj/item/borg/upgrade/transform/clown
	name = "borg model picker (Clown)"
	desc = "Allows you to turn a cyborg into a clown, honk."
	icon_state = "module_honk"
	new_model = /obj/item/robot_model/clown

/obj/item/borg/upgrade/extra_sheet_manipulator
	name = "secondary material manipulation apparatus"
	desc = "A supplementary apparatus for carrying, deploying, and manipulating sheets of material. The device can also carry custom floor tiles."
	icon_state = "module_engineer"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering, /obj/item/robot_model/saboteur)
	model_flags = BORG_MODEL_ENGINEERING
	items_to_add = list(/obj/item/borg/apparatus/sheet_manipulator/extra)

/obj/item/borg/upgrade/charger
	name = "power connector"
	desc = "An energy probe that can charge batteries and energy-dependent weapons (using the cyborg battery, in both directions), as well as recharge the cyborg from all types of chargers, the effectiveness depends on the components of the machine"
	icon_state = "module_engineer"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering)
	model_flags = BORG_MODEL_ENGINEERING
	items_to_add = list(/obj/item/borg/charger)

/obj/item/borg/upgrade/beaker_app
	name = "beaker storage apparatus"
	desc = "A supplementary beaker storage apparatus for medical cyborgs."
	icon_state = "module_medical"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical)
	model_flags = BORG_MODEL_MEDICAL
	items_to_add = list(/obj/item/borg/apparatus/beaker/extra)

/obj/item/borg/upgrade/uwu
	name = "cyborg UwU-speak \"upgrade\""
	desc = "As if existence as an artificial being wasn't torment enough for the unit OR the crew."
	icon_state = "module_general"

/obj/item/borg/upgrade/uwu/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	borg.AddComponentFrom(REF(src), /datum/component/fluffy_tongue)

/obj/item/borg/upgrade/uwu/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	borg.RemoveComponentSource(REF(src), /datum/component/fluffy_tongue)

/obj/item/borg/upgrade/nanite_remote
	name = "peacekeeper cyborg nanite remote"
	desc = "An upgrade to the Peacekeeper model, installing a nanite remote. \
			Allowing the cyborg to signal nanites in crew."
	icon_state = "module_peace"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/peacekeeper, /obj/item/robot_model/security, /obj/item/robot_model/science)
	model_flags = BORG_MODEL_PEACEKEEPER
	items_to_add = list(/obj/item/nanite_remote/cyborg)

/obj/item/borg/upgrade/better_clamp
	name = "improved integrated hydraulic clamp"
	desc = "An improved hydraulic clamp that trades its storage quantity to allow for bigger packages to be picked up instead!"
	icon_state = "module_cargo"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/cargo)
	model_flags = BORG_MODEL_CARGO
	items_to_add = list(/obj/item/borg/hydraulic_clamp/better)

/// This isn't an upgrade or part of the same path, but I'm gonna just stick it here because it's a tool used on cyborgs.
// A reusable tool that can bring borgs back to life. They gotta be repaired first, though.
/obj/item/borg_restart_board
	name = "cyborg emergency reboot module"
	desc = "A reusable firmware reset tool that can force a reboot of a disabled-but-repaired cyborg, bringing it back online."
	icon = 'icons/mob/silicon/robot_items.dmi'
	icon_state = "cyborg_upgrade1"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/borg_restart_board/pre_attack(mob/living/silicon/robot/borg, mob/living/user, params)
	if(!istype(borg))
		return ..()
	if(!borg.opened)
		to_chat(user, span_warning("You must access the cyborg's internals!"))
		return ..()
	if(borg.health < 0)
		to_chat(user, span_warning("You have to repair the cyborg before using this module!"))
		return ..()
	if(!(borg.stat & DEAD))
		to_chat(user, span_warning("This cyborg is already operational!"))
		return ..()

	if(borg.mind)
		borg.mind.grab_ghost()
		playsound(loc, 'sound/voice/liveagain.ogg', 75, TRUE)
	else
		playsound(loc, 'sound/machines/ping.ogg', 75, TRUE)

	borg.revive()
	borg.logevent("WARN -- System recovered from unexpected shutdown.")
	borg.logevent("System brought online.")
	return ..()

/obj/item/borg/upgrade/transform/centcom
	name = "borg model picker (CentCom)"
	desc = "Allows you to to turn a cyborg into a CentCom cyborg."
	icon_state = "module_general"
	new_model = /obj/item/robot_model/centcom

/obj/item/borg/upgrade/nvmeson
	name = "night vision mesons upgrade"
	desc = "An augmentation to the standard meson sensor array seen on mining and engineering cyborgs to increase low light visibility."
	icon_state = "module_engineer"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering, /obj/item/robot_model/miner)
	model_flags = BORG_MODEL_ENGINEERING
	items_to_add = list(/obj/item/borg/sight/meson/nightvision)
	items_to_remove = list(/obj/item/borg/sight/meson)

/obj/item/borg/upgrade/adv_healthanalyzer
	name = "health analyzer upgrade"
	desc = "An updated sensor and driver kit for medical cyborgs. Allowing the cyborg unit to perform more in-depth analysis of patients."
	icon_state = "module_medical"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical, /obj/item/robot_model/syndicate_medical) // The fact that syndicate medical doesn't get advanced stock suprises me just as much as you.
	model_flags = BORG_MODEL_MEDICAL

/obj/item/borg/upgrade/adv_healthanalyzer/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	for(var/obj/item/healthanalyzer/cyborg/analyzer in borg.model.modules)
		analyzer.upgrade()

/obj/item/borg/upgrade/adv_healthanalyzer/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	for(var/obj/item/healthanalyzer/cyborg/analyzer in borg.model.modules)
		analyzer.downgrade()

/obj/item/borg/upgrade/surgery_omnitool
	name = "cyborg surgical omni-tool upgrade"
	desc = "An upgrade to the Medical model, upgrading the built-in \
		surgical omnitool, to be on par with advanced surgical tools, allowing for faster surgery."
	icon_state = "module_medical"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical, /obj/item/robot_model/syndicate_medical)
	model_flags = BORG_MODEL_MEDICAL

/obj/item/borg/upgrade/surgery_omnitool/action(mob/living/silicon/robot/cyborg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	for(var/obj/item/borg/cyborg_omnitool/medical/omnitool_upgrade in cyborg.model.modules)
		if(omnitool_upgrade.upgraded)
			to_chat(user, span_warning("This unit is already equipped with an omnitool upgrade!"))
			return FALSE
	for(var/obj/item/borg/cyborg_omnitool/medical/omnitool in cyborg.model.modules)
		omnitool.set_upgraded(TRUE)

/obj/item/borg/upgrade/surgery_omnitool/deactivate(mob/living/silicon/robot/cyborg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	for(var/obj/item/borg/cyborg_omnitool/omnitool in cyborg.model.modules)
		omnitool.set_upgraded(FALSE)

//
// Science Cyborgs
//

// This is a base item which should be inherited from.
/obj/item/borg/upgrade/science_apparatus_improvement
	name = "science apparatus upgrade"
	desc = "An upgrade for science cyborgs that enables them to hold and manipulate more items with their apparatus."
	icon_state = "module_science"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/science)
	model_flags = BORG_MODEL_SCIENCE
	var/list/storables_to_add = list()

/obj/item/borg/upgrade/science_apparatus_improvement/action(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	var/obj/item/borg/apparatus/circuit/science/apparatus = locate() in borg.model.modules
	if(isnull(apparatus))
		to_chat(user, span_warning("This cyborg doesn't have an apparatus to upgrade!"))
		return FALSE
	if(!length(storables_to_add))
		to_chat(user, span_warning("This upgrade doesn't seem to do anything!"))
		return FALSE
	apparatus.storable |= storables_to_add

/obj/item/borg/upgrade/science_apparatus_improvement/deactivate(mob/living/silicon/robot/borg, mob/living/user = usr)
	. = ..()
	if(!.)
		return .
	var/obj/item/borg/apparatus/circuit/science/apparatus = locate() in borg.model.modules
	if(isnull(apparatus))
		return FALSE
	if(!length(storables_to_add))
		return FALSE
	apparatus.storable -= storables_to_add

/obj/item/borg/upgrade/science_apparatus_improvement/robotics
	name = "science robotics upgrade"
	desc = "An upgrade for science cyborgs that enables them to hold and manipulate robotics-related items."
	storables_to_add = list(
		/obj/item/borg/upgrade,
		/obj/item/mmi,
		/obj/item/assembly/flash,
		/obj/item/bodypart/arm/left/robot,
		/obj/item/bodypart/arm/right/robot,
		/obj/item/bodypart/leg/left/robot,
		/obj/item/bodypart/leg/right/robot,
		/obj/item/bodypart/chest/robot,
		/obj/item/bodypart/head/robot
	)

/obj/item/borg/upgrade/science_apparatus_improvement/ordnance
	name = "science ordnance upgrade"
	desc = "An upgrade for science cyborgs that enables them to hold and manipulate ordnance-related items."
	items_to_add = list(
		/obj/item/pipe_dispenser
	)
	storables_to_add = list(
		/obj/item/tank/internals,
		/obj/item/transfer_valve
	)

/obj/item/borg/upgrade/science_apparatus_improvement/circuits
	name = "science circuits upgrade"
	desc = "An upgrade for science cyborgs that enables them to hold and manipulate circuits-related items."
	items_to_add = list(
		/obj/item/multitool/circuit
	)
	storables_to_add = list(
		/obj/item/circuit_component,
		/obj/item/shell,
		/obj/item/usb_cable,
		/obj/item/keyboard_shell,
		/obj/item/wiremod_scanner,
		/obj/item/integrated_circuit,
		/obj/item/mod/module/circuit,
	)

/obj/item/borg/upgrade/science_xenobiology
	name = "science xenobiology upgrade"
	desc = "An upgrade for science cyborgs that enables them to perform work in xenobiology."
	icon_state = "module_science"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/science)
	model_flags = BORG_MODEL_SCIENCE
	items_to_add = list(
		/obj/item/vacuum_pack,
		/obj/item/storage/bag/xeno,
		/obj/item/construction/plumbing/research
	)
