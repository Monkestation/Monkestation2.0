/datum/scripture/slab/empower_wall
	name = "Empower Wall"
	desc = "Empowers a clockwork wall's stabilization lattice, improving its resilience."
	tip = "Empowers a clockwork wall's stabilization lattice, improving its resilience."
	button_icon_state = "empower_wall"
	power_cost = STANDARD_CELL_CHARGE * 0.1
	invocation_time = 3 SECONDS
	invocation_text = list("Strengthen our resolve...", "So we may never fall!")
	slab_overlay = "hateful_manacles"
	use_time = 30 SECONDS
	cogs_required = 3
	category = SPELLTYPE_STRUCTURES
	uses = 3

/datum/scripture/slab/empower_wall/apply_effects(obj/structure/destructible/clockwork/wall_lattice/applied_to)
	if(!istype(applied_to))
		return FALSE

	if(applied_to.is_empowered)
		applied_to.balloon_alert(invoker, "\The [applied_to] is already empowered.")
		return FALSE

	applied_to.balloon_alert(invoker, "you start to empower \the [applied_to].")
	if(!do_after(invoker, 3 SECONDS, applied_to) || applied_to?.is_empowered)
		applied_to.balloon_alert(invoker, "you fail to empower \the [applied_to].")
		return FALSE

	if(QDELETED(applied_to))
		return FALSE

	applied_to.balloon_alert(invoker, "you empower \the [applied_to].")
	applied_to.empower()
	return TRUE
