/obj/item/mcobject/graviton_accelerator
	name = "graviton accelerator"
	base_icon_state = "comp_accel"
	icon_state = "comp_accel"

	var/on = FALSE
	COOLDOWN_DECLARE(cd)

/obj/item/mcobject/graviton_accelerator/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, connections)

	MC_ADD_INPUT("activate", turn_on)

/obj/item/mcobject/graviton_accelerator/Destroy(force)
	on = FALSE
	return ..()

/obj/item/mcobject/graviton_accelerator/set_anchored(anchorvalue)
	. = ..()
	if(!anchored)
		on = FALSE

/obj/item/mcobject/graviton_accelerator/update_icon_state()
	. = ..()
	icon_state = anchored ? "u[base_icon_state]" : base_icon_state
	icon_state = on ? "[icon_state]1" : icon_state

/obj/item/mcobject/graviton_accelerator/proc/turn_on()
	if(on || !COOLDOWN_FINISHED(src, cd))
		return

	on = TRUE
	update_appearance(UPDATE_ICON_STATE)
	INVOKE_ASYNC(src, PROC_REF(yeet_everything_on_tile))
	addtimer(CALLBACK(src, PROC_REF(turn_off)), 2 SECONDS)

/obj/item/mcobject/graviton_accelerator/proc/yeet_everything_on_tile()
	while(on)
		for(var/atom/movable/thing as anything in loc.contents - src)
			if(!on)
				return
			if(QDELETED(thing))
				continue
			if(ismob(thing))
				if(!isliving(thing))
					continue
			else if(isobj(thing))
				if(iseffect(thing))
					continue
			else
				continue
			yeet(thing)
			CHECK_TICK_LOW
		CHECK_TICK_LOW

/obj/item/mcobject/graviton_accelerator/proc/turn_off()
	on = FALSE
	update_appearance(UPDATE_ICON_STATE)
	COOLDOWN_START(src, cd, 1 SECONDS)

/obj/item/mcobject/graviton_accelerator/proc/on_entered(source, atom/movable/thing)
	SIGNAL_HANDLER
	if(on)
		addtimer(CALLBACK(src, PROC_REF(yeet), thing), 0.2 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/item/mcobject/graviton_accelerator/proc/yeet(atom/movable/thing)
	if(thing.anchored)
		return
	if(!thing.has_gravity())
		return
	thing.safe_throw_at(get_edge_target_turf(src, dir), 8, 3)
