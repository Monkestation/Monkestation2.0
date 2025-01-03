/datum/action/cooldown/vampire/mend
	name = "Mend"
	desc = "Undo major wounds on your body all at once. Extremely obvious."
	button_icon_state = "power_recover"
	cooldown_time = 1 MINUTE

/datum/action/cooldown/vampire/mend/Grant(mob/granted_to)
	. = ..()
	RegisterSignals(granted_to, list(COMSIG_CARBON_GAIN_WOUND, COMSIG_CARBON_LOSE_WOUND), PROC_REF(update_button))

/datum/action/cooldown/vampire/mend/Remove(mob/removed_from)
	. = ..()
	UnregisterSignal(removed_from, list(COMSIG_CARBON_GAIN_WOUND, COMSIG_CARBON_LOSE_WOUND))

/datum/action/cooldown/vampire/mend/IsAvailable(feedback)
	if(!length(user?.all_wounds)) // throws a billion runtimes if you dont have an user check
		if (feedback)
			owner.balloon_alert(owner, "no wounds!")
		return FALSE

	life_cost = length(user.all_wounds) * 10

	return ..()

/datum/action/cooldown/vampire/mend/Activate(atom/target)
	. = ..()

	owner.visible_message(
		message = span_danger("[owner]'s body makes nauseating sounds as their wounds disappear in an instant!"),
		self_message = span_boldnotice("You feel the pain subside as your wounds disappear."),
		blind_message = span_hear("You hear a series of wet crunches!")
	)

	INVOKE_ASYNC(src, PROC_REF(do_effects))

	for(var/wound as anything in user.all_wounds) // don't use QDEL_LIST here, there's signal bullshit going on and it's a lazylist so the Cut() in QDEL_LIST causes a runtime
		qdel(wound)

/datum/action/cooldown/vampire/mend/proc/do_effects()
	var/matrix/matrix1 = matrix(owner.transform)
	matrix1.Turn(-20)

	var/matrix/matrix2 = matrix(owner.transform)
	matrix2.Turn(20)

	var/matrix/matrix3 = matrix(owner.transform)

	animate(owner, time = 0.2 SECONDS, transform = matrix1)
	animate(time = 0.2 SECONDS, transform = matrix2)
	animate(time = 0.2 SECONDS, transform = matrix3)

	playsound(owner, 'sound/effects/wounds/crack1.ogg', vol = 100, vary = TRUE)
	playsound(owner, 'sound/effects/wounds/sizzle1.ogg', vol = 100, vary = TRUE)

	sleep(0.4 SECONDS)

	playsound(owner, 'sound/effects/wounds/crack2.ogg', vol = 100, vary = TRUE)
