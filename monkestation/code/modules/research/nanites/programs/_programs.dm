/datum/nanite_program
	///The name of the Nanite Program.
	var/name = "Generic Nanite Program"
	///The description of the nanite program for easy understanding.
	var/desc = "Warn a coder if you can read this."

	///The nanite program component we're connected to.
	var/datum/component/nanites/nanites
	///The person hosting this nanite program, if any.
	var/mob/living/host_mob

	///How many nanites this uses while active.
	var/use_rate = 0
	///Boolean on whether there can have more than one of this nanite program in the same nanite component.
	var/unique = TRUE
	///Boolean on whether the nanite program has a trigger function.
	var/can_trigger = FALSE
	///Amount of nanites this uses when triggered.
	var/trigger_cost = 0
	///Dediseconds required between each trigger activation.
	var/trigger_cooldown = 50
	///World time required for the next trigger activation.
	var/next_trigger = 0

	///Special program flags.
	///(NANITE_SHOCK_IMMUNE | NANITE_EMP_IMMUNE)
	var/program_flags = NONE
	///Boolean on whether the nanites have an on/off style effect.
	var/passive_enabled = FALSE

	///What this program turns into if it glitches. This should be simpler, negative, waste of nanites, or affecting the same bodyparts. Generally.
	var/list/rogue_types = list(/datum/nanite_program/glitch)

	///Boolean whether the program is currently activated. Off programs won't proceess or have passive effects, but won't consume nanites.
	var/activated = TRUE

	///How many deciseconds to wait upon deactivation before self-reactivating. Also works if the program begins deactivated.
	var/timer_restart = 0
	///How many deciseconds to wait upon activation before self-deactivating. Also works if the program begins activated.
	var/timer_shutdown = 0
	///While active, how many dediseconds before the program attempts to trigger itself.
	var/timer_trigger = 0
	///While active, how many dediseconds the program will deelay its trigger signals.
	var/timer_trigger_delay = 0

	//Indicates the next world.time tick where these timers will act
	var/timer_restart_next = 0
	var/timer_shutdown_next = 0
	var/timer_trigger_next = 0
	var/timer_trigger_delay_next = 0

	///Code that activates the program when sent. [1-9999, 0 ignores signals]
	var/activation_code = 0
	///Code that deactivates the program [1-9999, 0 ignores signals]
	var/deactivation_code = 0
	///Code that permanently removes the program [1-9999, 0 ignores signals]
	var/kill_code = 0
	///Code that triggers the program (if available) [1-9999, 0 ignores signals]
	var/trigger_code = 0

	///Boolean on whether all rules are required for positive condition or any of specified.
	var/all_rules_required = TRUE
	///Rules that automatically manage if the program's active without requiring separate sensor programs
	var/list/datum/nanite_rule/rules = list()

	///List of extra settings the nanite program is following.
	VAR_FINAL/list/datum/nanite_extra_setting/extra_settings = list()

/datum/nanite_program/New()
	. = ..()
	register_extra_settings()

/datum/nanite_program/Destroy()
	extra_settings = null
	if(host_mob)
		if(activated)
			deactivate()
		if(passive_enabled)
			disable_passive_effect()
		on_mob_remove()
	if(nanites)
		nanites.programs -= src
	nanites = null
	return ..()

/datum/nanite_program/proc/copy()
	var/datum/nanite_program/new_program = new type()
	copy_programming(new_program, TRUE)
	return new_program

/datum/nanite_program/proc/copy_programming(datum/nanite_program/target, copy_activated = TRUE)
	if(copy_activated)
		target.activated = activated
	target.timer_restart = timer_restart
	target.timer_shutdown = timer_shutdown
	target.timer_trigger = timer_trigger
	target.timer_trigger_delay = timer_trigger_delay
	target.activation_code = activation_code
	target.deactivation_code = deactivation_code
	target.kill_code = kill_code
	target.trigger_code = trigger_code

	target.rules = list()
	for(var/datum/nanite_rule/rule as anything in rules)
		rule.copy_to(target)
	target.all_rules_required = all_rules_required

	if(istype(target,src))
		copy_extra_settings_to(target)

///Register extra settings by overriding this.
///extra_settings[name] = new typepath() for each extra setting
/datum/nanite_program/proc/register_extra_settings()
	return

///You can override this if you need to have special behavior after setting certain settings.
/datum/nanite_program/proc/set_extra_setting(setting, value)
	var/datum/nanite_extra_setting/ES = extra_settings[setting]
	return ES.set_value(value)

///You probably shouldn't be overriding this one, but I'm not a cop.
/datum/nanite_program/proc/get_extra_setting_value(setting)
	var/datum/nanite_extra_setting/ES = extra_settings[setting]
	return ES.get_value()

///Used for getting information about the extra settings to the frontend
/datum/nanite_program/proc/get_extra_settings_frontend()
	var/list/out = list()
	for(var/name in extra_settings)
		var/datum/nanite_extra_setting/ES = extra_settings[name]
		out += ES.get_frontend_list(name)
	return out

///Copy of the list instead of direct reference for obvious reasons
/datum/nanite_program/proc/copy_extra_settings_to(datum/nanite_program/target)
	var/list/copy_list = list()
	for(var/ns_name in extra_settings)
		var/datum/nanite_extra_setting/extra_setting = extra_settings[ns_name]
		copy_list[ns_name] = extra_setting.get_copy()
	target.extra_settings = copy_list

/datum/nanite_program/proc/on_add(datum/component/nanites/_nanites)
	nanites = _nanites
	if(nanites.host_mob)
		on_mob_add()

/datum/nanite_program/proc/on_mob_add()
	SHOULD_CALL_PARENT(TRUE)
	host_mob = nanites.host_mob
	if(activated) //apply activation effects depending on initial status; starts the restart and shutdown timers
		activate()
	else
		deactivate()

/datum/nanite_program/proc/on_mob_remove()
	SHOULD_CALL_PARENT(TRUE)
	return

/datum/nanite_program/proc/toggle()
	if(!activated)
		activate()
	else
		deactivate()

/datum/nanite_program/proc/activate()
	activated = TRUE
	if(timer_shutdown)
		timer_shutdown_next = world.time + timer_shutdown

/datum/nanite_program/proc/deactivate()
	if(passive_enabled)
		disable_passive_effect()
	activated = FALSE
	if(timer_restart)
		timer_restart_next = world.time + timer_restart

/datum/nanite_program/proc/on_process()
	if(!activated)
		if(timer_restart_next && world.time > timer_restart_next)
			activate()
			timer_restart_next = 0
		return

	if(timer_shutdown_next && world.time > timer_shutdown_next)
		deactivate()
		timer_shutdown_next = 0
		return

	if(timer_trigger && world.time > timer_trigger_next)
		trigger()
		timer_trigger_next = world.time + timer_trigger
		return

	if(timer_trigger_delay_next && world.time > timer_trigger_delay_next)
		trigger(delayed = TRUE)
		timer_trigger_delay_next = 0
		return

	if(check_conditions() && consume_nanites(use_rate))
		if(!passive_enabled)
			enable_passive_effect()
		active_effect()
		return

	if(passive_enabled)
		disable_passive_effect()

//If false, disables active and passive effects, but doesn't consume nanites
//Can be used to avoid consuming nanites for nothing
/datum/nanite_program/proc/check_conditions()
	if(!LAZYLEN(rules))
		return TRUE
	for(var/datum/nanite_rule/rule as anything in rules)
		if(!all_rules_required && rule.check_rule())
			return TRUE
		if(all_rules_required && !rule.check_rule())
			return FALSE
	return all_rules_required

//Constantly procs as long as the program is active
/datum/nanite_program/proc/active_effect()
	return

//Procs once when the program activates
/datum/nanite_program/proc/enable_passive_effect()
	passive_enabled = TRUE

//Procs once when the program deactivates
/datum/nanite_program/proc/disable_passive_effect()
	passive_enabled = FALSE

//Checks conditions then fires the nanite trigger effect
/datum/nanite_program/proc/trigger(delayed = FALSE, comm_message)
	if(!can_trigger)
		return
	if(!activated)
		return
	if(timer_trigger_delay && !delayed)
		timer_trigger_delay_next = world.time + timer_trigger_delay
		return
	if(world.time < next_trigger)
		return
	if(!consume_nanites(trigger_cost))
		return
	next_trigger = world.time + trigger_cooldown
	on_trigger(comm_message)

//Nanite trigger effect, requires can_trigger to be used
/datum/nanite_program/proc/on_trigger(comm_message)
	return

/datum/nanite_program/proc/consume_nanites(amount, force = FALSE)
	return nanites.consume_nanites(amount, force)

/datum/nanite_program/proc/on_emp(severity)
	if(program_flags & NANITE_EMP_IMMUNE)
		return
	if(prob(80 / severity))
		software_error()

/datum/nanite_program/proc/on_shock(shock_damage)
	if(!(program_flags & NANITE_SHOCK_IMMUNE))
		if(prob(10))
			software_error()
		else if(prob(33))
			qdel(src)

/datum/nanite_program/proc/on_minor_shock()
	if(!(program_flags & NANITE_SHOCK_IMMUNE))
		if(prob(10))
			software_error()

/datum/nanite_program/proc/on_death(gibbed)
	return

#define SOFTWARE_ERROR_DELETE 1
#define SOFTWARE_ERROR_DEPROGRAM 2
#define SOFTWARE_ERROR_TOGGLE 3
#define SOFTWARE_ERROR_TRIGGER 4
#define SOFTWARE_ERROR_ROGUE 5

/datum/nanite_program/proc/software_error()
	var/list/software_errors_weighted = list(
		SOFTWARE_ERROR_DELETE = 1,
		SOFTWARE_ERROR_DEPROGRAM = 2,
		SOFTWARE_ERROR_TOGGLE = 2,
		SOFTWARE_ERROR_TRIGGER = 2,
		SOFTWARE_ERROR_ROGUE = 3,
	)
	var/error_type = pick_weight(software_errors_weighted)
	switch(error_type)
		if(SOFTWARE_ERROR_DELETE)
			qdel(src) //kill switch
		if(SOFTWARE_ERROR_DEPROGRAM) //deprogram codes
			activation_code = 0
			deactivation_code = 0
			kill_code = 0
			trigger_code = 0
		if(SOFTWARE_ERROR_TOGGLE)
			toggle() //enable/disable
		if(SOFTWARE_ERROR_TRIGGER)
			if(can_trigger)
				trigger()
			else
				toggle() //enable/disable
		if(SOFTWARE_ERROR_ROGUE) //Program is scrambled and does something different
			var/rogue_type = pick(rogue_types)
			var/datum/nanite_program/rogue = new rogue_type
			nanites.add_program(null, rogue, src)
			qdel(src)

#undef SOFTWARE_ERROR_DELETE
#undef SOFTWARE_ERROR_DEPROGRAM
#undef SOFTWARE_ERROR_TOGGLE
#undef SOFTWARE_ERROR_TRIGGER
#undef SOFTWARE_ERROR_ROGUE

/datum/nanite_program/proc/receive_signal(code, source)
	if(activation_code && code == activation_code && !activated)
		activate()
		log_game("[host_mob]'s [name] nanite program was activated by [source] with code [code].")
	else if(deactivation_code && code == deactivation_code && activated)
		deactivate()
		log_game("[host_mob]'s [name] nanite program was deactivated by [source] with code [code].")
	if(can_trigger && trigger_code && code == trigger_code)
		trigger()
		log_game("[host_mob]'s [name] nanite program was triggered by [source] with code [code].")
	if(kill_code && code == kill_code)
		log_game("[host_mob]'s [name] nanite program was deleted by [source] with code [code].")
		qdel(src)

