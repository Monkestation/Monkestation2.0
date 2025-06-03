
////////////////////////////////
///// Construction datums //////
////////////////////////////////
/datum/component/construction/mecha
	var/base_icon

	// Component typepaths.
	// most must be defined unless
	// get_steps is overriden.

	// Circuit board typepaths.
	// circuit_control and circuit_periph must be defined
	// unless get_circuit_steps is overriden.
	var/circuit_control
	var/circuit_periph
	var/circuit_weapon

	// Armor plating typepaths. both must be defined
	// unless relevant step procs are overriden. amounts
	// must be defined if using /obj/item/stack/sheet types
	var/obj/inner_plating
	var/inner_plating_amount

	var/obj/outer_plating
	var/outer_plating_amount

/datum/component/construction/mecha/spawn_result()
	if(!result)
		return
	// Remove default mech power cell, as we replace it with a new one.
	var/obj/vehicle/sealed/mecha/M = new result(drop_location())
	QDEL_NULL(M.cell)
	QDEL_NULL(M.scanmod)
	QDEL_NULL(M.capacitor)

	var/obj/item/mecha_parts/chassis/parent_chassis = parent
	M.CheckParts(parent_chassis.contents)

	SSblackbox.record_feedback("tally", "mechas_created", 1, M.name)
	QDEL_NULL(parent)

// Default proc to generate mech steps.
// Override if the mech needs an entirely custom process (See HONK mech)
// Otherwise override specific steps as needed (Ripley, Clarke, Phazon)
/datum/component/construction/mecha/proc/get_steps()
	return get_frame_steps() + get_circuit_steps() + (circuit_weapon ? get_circuit_weapon_steps() : list()) + get_stockpart_steps() + get_inner_plating_steps() + get_outer_plating_steps()

/datum/component/construction/mecha/update_parent(step_index)
	steps = get_steps()
	..()
	// By default, each step in mech construction has a single icon_state:
	// "[base_icon][index - 1]"
	// For example, Ripley's step 1 icon_state is "ripley0"
	var/atom/parent_atom = parent
	if(!steps[index]["icon_state"] && base_icon)
		parent_atom.icon_state = "[base_icon][index - 1]"

/datum/component/construction/unordered/mecha_chassis/custom_action(obj/item/I, mob/living/user, typepath)
	. = user.transferItemToLoc(I, parent)
	if(.)
		var/atom/parent_atom = parent
		user.balloon_alert_to_viewers("connected [I]")
		parent_atom.add_overlay(I.icon_state+"+o")
		qdel(I)

/datum/component/construction/unordered/mecha_chassis/spawn_result()
	var/atom/parent_atom = parent
	parent_atom.icon = 'icons/mecha/mech_construction.dmi'
	parent_atom.set_density(TRUE)
	parent_atom.cut_overlays()
	..()

// Default proc for the first steps of mech construction.
/datum/component/construction/mecha/proc/get_frame_steps()
	return list(
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems can be connected with a <b>wrench</b>.",
			"forward_message" = "connected the hydraulic systems",
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected, and can be activated with a <b>screwdriver</b>.",
			"forward_message" = "activated the hydraulic systems",
			"backward_message" = "disconnected the hydraulic systems"
		),
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active, and the frame can be <b>wired</b>.",
			"forward_message" = "added wiring",
			"backward_message" = "deactivated the hydraulic systems"
		),
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added, and can be adjusted with <b>wirecutters</b>.",
			"forward_message" = "adjusted wiring",
			"backward_message" = "removed wiring"
		)
	)

// Default proc for the circuit board steps of a mech.
// Second set of steps by default.
/datum/component/construction/mecha/proc/get_circuit_steps()
	return list(
		list(
			"key" = circuit_control,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted, and the <b>central control module</b> slot has opened.",
			"forward_message" = "added central control module",
			"backward_message" = "disconnected wiring"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed, and can be <b>screwed</b> into place.",
			"forward_message" = "secured central control module",
			"backward_message" = "removed central control module"
		),
		list(
			"key" = circuit_periph,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured, and the <b>peripheral control module</b> slot has opened.",
			"forward_message" = "added peripheral control module",
			"backward_message" = "unsecured central control module"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripheral control module is installed, and can be <b>screwed</b> into place.",
			"forward_message" = "secured peripheral control module",
			"backward_message" = "removed peripheral control module"
		)
	)

// Default proc for weapon circuitboard steps
// Used by combat mechs
/datum/component/construction/mecha/proc/get_circuit_weapon_steps()
	return list(
		list(
			"key" = circuit_weapon,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured, and the <b>weapon control module<b> slot has opened.",
			"forward_message" = "added weapon control module",
			"backward_message" = "unsecured peripheral control module"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Weapon control module is installed, and can be <b>screwed</b> into place.",
			"forward_message" = "secured weapon control module",
			"backward_message" = "removed weapon control module"
		)
	)

// Default proc for stock part installation
// Third set of steps by default
/datum/component/construction/mecha/proc/get_stockpart_steps()
	var/prevstep_text = circuit_weapon ? "Weapon control module is secured" : "Peripherals control module is secured"
	prevstep_text += ", and the <b>scanning module</b> can be added."
	var/backward_text = circuit_weapon ? "unsecured weapon control module" : "unsecured peripheral module"
	return list(
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = prevstep_text,
			"forward_message" = "added scanning module",
			"backward_message" = backward_text
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanning module is installed, and can be <b>screwed</b> into place.",
			"forward_message" = "secured scanning module",
			"backward_message" = "removed scanning module"
		),
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanning module is secured, the <b>capacitor</b> can be added.",
			"forward_message" = "added capacitor",
			"backward_message" = "unscecured scanning module"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed, and can be <b>screwed</b> into place.",
			"forward_message" = "secured capacitor",
			"backward_message" = "removed capacitor"
		),
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured, and the <b>power cell</b> can be added.",
			"forward_message" = "added power cell",
			"backward_message" = "unsecured capacitor"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed, and can be <b>screwed</b> into place.",
			"forward_message" = "secured power cell",
			"backward_message" = "removed power cell"
		)
	)

// Default proc for inner armor plating
// Fourth set of steps by default
/datum/component/construction/mecha/proc/get_inner_plating_steps()
	var/list/first_step
	if(ispath(inner_plating, /obj/item/stack/sheet))
		first_step = list(
			list(
				"key" = inner_plating,
				"amount" = inner_plating_amount,
				"back_key" = TOOL_SCREWDRIVER,
				"desc" = "The power cell is secured, [inner_plating_amount] sheets of [initial(inner_plating.name)] can be used as inner plating.",
				"forward_message" = "installed internal armor layer",
				"backward_message" = "unsecured power cell"
			)
		)
	else
		first_step = list(
			list(
				"key" = inner_plating,
				"action" = ITEM_DELETE,
				"back_key" = TOOL_SCREWDRIVER,
				"desc" = "The power cell is secured, [initial(inner_plating.name)] can be used as inner plating.",
				"forward_message" = "installed internal armor layer",
				"backward_message" = "unsecured power cell"
			)
		)

	return first_step + list(
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Inner plating is installed, and can be <b>wrenched</b> into place.",
			"forward_message" = "secured internal armor layer",
			"backward_message" = "pried off internal armor layer"
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Inner plating is wrenched, and can be <b>welded</b>.",
			"forward_message" = "welded internal armor layer",
			"backward_message" = "unfastened internal armor layer"
		)
	)

// Default proc for outer armor plating
// Fifth set of steps by default
/datum/component/construction/mecha/proc/get_outer_plating_steps()
	var/list/first_step
	if(ispath(outer_plating, /obj/item/stack/sheet))
		first_step = list(
			list(
				"key" = outer_plating,
				"amount" = outer_plating_amount,
				"back_key" = TOOL_WELDER,
				"desc" = "Inner plating is welded, [outer_plating_amount] sheets of [initial(outer_plating.name)] can be used as external armor.",
				"forward_message" = "installed external armor layer",
				"backward_message" = "cut off internal armor layer"
			)
		)
	else
		first_step = list(
			list(
				"key" = outer_plating,
				"action" = ITEM_DELETE,
				"back_key" = TOOL_WELDER,
				"desc" = "Inner plating is welded, [initial(outer_plating.name)] can be used as external armor.",
				"forward_message" = "installed external armor layer",
				"backward_message" = "cut off internal armor layer"
			)
		)

	return first_step + list(
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed, and can be <b>wrenched</b> into place.",
			"forward_message" = "secured external armor layer",
			"backward_message" = "pried off external armor layer"
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched, and can be <b>welded</b>.",
			"forward_message" = "welded external armor layer",
			"backward_message" = "unfastened external armor layer"
		)
	)

/// Generic mech construction messages
/datum/component/construction/mecha/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	if(diff == FORWARD && steps[index]["forward_message"])
		user.balloon_alert_to_viewers(steps[index]["forward_message"])
	else if(steps[index]["backward_message"])
		user.balloon_alert_to_viewers(steps[index]["backward_message"])

	return TRUE

//RIPLEY
/datum/component/construction/unordered/mecha_chassis/ripley
	result = /datum/component/construction/mecha/ripley
	steps = list(
		/obj/item/mecha_parts/part/ripley_torso,
		/obj/item/mecha_parts/part/ripley_left_arm,
		/obj/item/mecha_parts/part/ripley_right_arm,
		/obj/item/mecha_parts/part/ripley_left_leg,
		/obj/item/mecha_parts/part/ripley_right_leg
	)

/datum/component/construction/mecha/ripley
	result = /obj/vehicle/sealed/mecha/working/ripley
	base_icon = "ripley"

	circuit_control = /obj/item/circuitboard/mecha/ripley/main
	circuit_periph = /obj/item/circuitboard/mecha/ripley/peripherals

	inner_plating=/obj/item/stack/sheet/iron
	inner_plating_amount = 5

	outer_plating=/obj/item/stack/rods
	outer_plating_amount = 10

/datum/component/construction/mecha/ripley/get_outer_plating_steps()
	return list(
		list(
			"key" = /obj/item/stack/rods,
			"amount" = 10,
			"back_key" = TOOL_WELDER,
			"desc" = "Outer plating is welded, and 10 <b>rods</b> can be used to install the cockpit.",
			"forward_message" = "installed cockpit",
			"backward_message" = "cut off outer armor layer"
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WIRECUTTER,
			"desc" = "Cockpit wire screen is installed, and can be <b>welded</b>.",
			"forward_message" = "welded cockpit",
			"backward_message" = "cut off cockpit"
		),
	)

//GYGAX
/datum/component/construction/unordered/mecha_chassis/gygax
	result = /datum/component/construction/mecha/gygax
	steps = list(
		/obj/item/mecha_parts/part/gygax_torso,
		/obj/item/mecha_parts/part/gygax_left_arm,
		/obj/item/mecha_parts/part/gygax_right_arm,
		/obj/item/mecha_parts/part/gygax_left_leg,
		/obj/item/mecha_parts/part/gygax_right_leg,
		/obj/item/mecha_parts/part/gygax_head
	)

/datum/component/construction/mecha/gygax
	result = /obj/vehicle/sealed/mecha/gygax
	base_icon = "gygax"

	circuit_control = /obj/item/circuitboard/mecha/gygax/main
	circuit_periph = /obj/item/circuitboard/mecha/gygax/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/gygax/targeting

	inner_plating = /obj/item/stack/sheet/iron
	inner_plating_amount = 5

	outer_plating=/obj/item/mecha_parts/part/gygax_armor
	outer_plating_amount=1

/datum/component/construction/mecha/gygax/action(datum/source, atom/used_atom, mob/user)
	ASYNC //This proc will never actually sleep, it calls do_after with a time of 0.
		. = check_step(used_atom, user)
	return .

//CLARKE
/datum/component/construction/unordered/mecha_chassis/clarke
	result = /datum/component/construction/mecha/clarke
	steps = list(
		/obj/item/mecha_parts/part/clarke_torso,
		/obj/item/mecha_parts/part/clarke_left_arm,
		/obj/item/mecha_parts/part/clarke_right_arm,
		/obj/item/mecha_parts/part/clarke_head
	)

/datum/component/construction/mecha/clarke
	result = /obj/vehicle/sealed/mecha/working/clarke
	base_icon = "clarke"

	circuit_control = /obj/item/circuitboard/mecha/clarke/main
	circuit_periph = /obj/item/circuitboard/mecha/clarke/peripherals

	inner_plating = /obj/item/stack/sheet/plasteel
	inner_plating_amount = 5

	outer_plating = /obj/item/stack/sheet/mineral/gold
	outer_plating_amount = 5

/datum/component/construction/mecha/clarke/get_frame_steps()
	return list(
		list(
			"key" = /obj/item/stack/conveyor,
			"amount" = 4,
			"desc" = "The treads can be added using 4 sheets of conveyor belts.",
			"forward_message" = "added tread systems",
		),
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The treads are installed, and the hydraulic systems can be connected with a <b>wrench</b>.",
			"forward_message" = "connected the hydraulic systems",
			"backward_message" = "removed tread systems"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected, and can be activated with a <b>screwdriver</b>.",
			"forward_message" = "activated hydraulic systems",
			"backward_message" = "disconnected hydraulic systems"
		),
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active, and the frame can be <b>wired</b>.",
			"forward_message" = "added wiring",
			"backward_message" = "deactivated hydraulic systems"
		),
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added, and can be adjusted with <b>wirecutters</b>.",
			"forward_message" = "adjusted wiring",
			"backward_message" = "removed wiring"
		)
	)

//HONKER
/datum/component/construction/unordered/mecha_chassis/honker
	result = /datum/component/construction/mecha/honker
	steps = list(
		/obj/item/mecha_parts/part/honker_torso,
		/obj/item/mecha_parts/part/honker_left_arm,
		/obj/item/mecha_parts/part/honker_right_arm,
		/obj/item/mecha_parts/part/honker_left_leg,
		/obj/item/mecha_parts/part/honker_right_leg,
		/obj/item/mecha_parts/part/honker_head
	)

/datum/component/construction/mecha/honker
	result = /obj/vehicle/sealed/mecha/honker
	steps = list(
		list(
			"key" = /obj/item/bikehorn,
			"desc" = "HONK!"
		),
		list(
			"key" = /obj/item/circuitboard/mecha/honker/main,
			"action" = ITEM_DELETE,
			"desc" = "Fun <b>central board</b> can be added!",
			"forward_message" = "added fun"

		),
		list(
			"key" = /obj/item/bikehorn,
			"desc" = "HONK!!"
		),
		list(
			"key" = /obj/item/circuitboard/mecha/honker/peripherals,
			"action" = ITEM_DELETE,
			"desc" = "Joke <b>peripheral board</b> can be added!",
			"forward_message" = "added joke"
		),
		list(
			"key" = /obj/item/bikehorn,
			"desc" = "HONK!!!"
		),
		list(
			"key" = /obj/item/circuitboard/mecha/honker/targeting,
			"action" = ITEM_DELETE,
			"desc" = "Prank <b>targeting board</b> can be added!",
			"forward_message" = "added prank"
		),
		list(
			"key" = /obj/item/bikehorn,
			"desc" = "HONK!!!!"
		),
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"desc" = "Silly <b>scanning</b> module can be added!",
			"forward_message" = "added silly"
		),
		list(
			"key" = /obj/item/bikehorn,
			"desc" = "HONK!!!!!"
		),
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"desc" = "Humor <b>capacitor</b> can be added!",
			"forward_message" = "added humor"
		),
		list(
			"key" = /obj/item/bikehorn,
			"desc" = "HONK!!!!!!"
		),
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"desc" = "Laughter <b>cell</b> can be added!",
			"forward_message" = "added laughter"
		),
		list(
			"key" = /obj/item/bikehorn,
			"desc" = "HONK!!!!!!!"
		),
		list(
			"key" = /obj/item/clothing/mask/gas/clown_hat,
			"action" = ITEM_DELETE,
			"desc" = "Clown mask can be ceremoniously added!",
			"forward_message" = "added mask"
		),
		list(
			"key" = /obj/item/bikehorn,
			"desc" = "HONK!!!!!!!!"
		),
		list(
			"key" = /obj/item/clothing/shoes/clown_shoes,
			"action" = ITEM_DELETE,
			"desc" = "Clown shoes can be reverently added!",
			"forward_message" = "added shoes"
		),
		list(
			"key" = /obj/item/bikehorn,
			"desc" = "Honk again, if you are brave enough."
		),
	)

/datum/component/construction/mecha/honker/get_steps()
	return steps

// HONK doesn't have any construction step icons, so we just set an icon once.
/datum/component/construction/mecha/honker/update_parent(step_index)
	if(step_index == 1)
		var/atom/parent_atom = parent
		parent_atom.icon = 'icons/mecha/mech_construct.dmi'
		parent_atom.icon_state = "honker_chassis"
	..()

/datum/component/construction/mecha/honker/custom_action(obj/item/I, mob/living/user, diff)
	if(istype(I, /obj/item/bikehorn))
		playsound(parent, 'sound/items/bikehorn.ogg', 50, TRUE)
		user.balloon_alert_to_viewers("HONK!")
		return TRUE

	return ..()

//DURAND
/datum/component/construction/unordered/mecha_chassis/durand
	result = /datum/component/construction/mecha/durand
	steps = list(
		/obj/item/mecha_parts/part/durand_torso,
		/obj/item/mecha_parts/part/durand_left_arm,
		/obj/item/mecha_parts/part/durand_right_arm,
		/obj/item/mecha_parts/part/durand_left_leg,
		/obj/item/mecha_parts/part/durand_right_leg,
		/obj/item/mecha_parts/part/durand_head
	)

/datum/component/construction/mecha/durand
	result = /obj/vehicle/sealed/mecha/durand
	base_icon = "durand"

	circuit_control = /obj/item/circuitboard/mecha/durand/main
	circuit_periph = /obj/item/circuitboard/mecha/durand/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/durand/targeting

	inner_plating = /obj/item/stack/sheet/iron
	inner_plating_amount = 5

	outer_plating = /obj/item/mecha_parts/part/durand_armor
	outer_plating_amount = 1

//PHAZON
/datum/component/construction/unordered/mecha_chassis/phazon
	result = /datum/component/construction/mecha/phazon
	steps = list(
		/obj/item/mecha_parts/part/phazon_torso,
		/obj/item/mecha_parts/part/phazon_left_arm,
		/obj/item/mecha_parts/part/phazon_right_arm,
		/obj/item/mecha_parts/part/phazon_left_leg,
		/obj/item/mecha_parts/part/phazon_right_leg,
		/obj/item/mecha_parts/part/phazon_head
	)

/datum/component/construction/mecha/phazon
	result = /obj/vehicle/sealed/mecha/phazon
	base_icon = "phazon"

	circuit_control = /obj/item/circuitboard/mecha/phazon/main
	circuit_periph = /obj/item/circuitboard/mecha/phazon/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/phazon/targeting

	inner_plating = /obj/item/stack/sheet/plasteel
	inner_plating_amount = 5

	outer_plating = /obj/item/mecha_parts/part/phazon_armor
	outer_plating_amount = 1

/datum/component/construction/mecha/phazon/get_stockpart_steps()
	return list(
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Weapon control module is secured, and the <b>scanning module</b> can be added.",
			"forward_message" = "added scanning module",
			"backward_message" = "unsecured weapon control module"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanning module is installed, and can be <b>screwed</b> into place.",
			"forward_message" = "secured scanning module",
			"backward_message" = "removed scanning module"
		),
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanning module is secured, and the <b>capacitor</b> can be added.",
			"forward_message" = "added capacitor",
			"backward_message" = "unsecured scanning module"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" =  "Capacitor is installed, and can be <b>screwed</b> into place.",
			"forward_message" = "secured capacitor",
			"backward_message" = "removed capacitor"
		),
		list(
			"key" = /obj/item/stack/ore/bluespace_crystal,
			"amount" = 1,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured, and the <b>bluespace crystal</b> can be added.",
			"forward_message" = "added bluespace crystal",
			"backward_message" = "unsecured capacitor"
		),
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The bluespace crystal is installed, and can be <b>wired</b> to the mech systems.",
			"forward_message" = "connected bluespace crystal",
			"backward_message" = "removed bluespace crystal"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WIRECUTTER,
			"desc" = "The bluespace crystal is connected, and the system can be engaged with a <b>screwdriver</b>.",
			"forward_message" = "engaded bluespace crystal",
			"backward_message" = "disconnected bluespace crystal"
		),
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The bluespace crystal is engaged, and the <b>power cell</b> can be added.",
			"forward_message" = "added power cell",
			"backward_message" = "disengaged bluespace crystal"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed, and can be <b>screwed</b> into place.",,
			"forward_message" = "secured power cell",
			"backward_message" = "removed power cell",
			"icon_state" = "phazon17"
			// This is the point where a step icon is skipped, so "icon_state" had to be set manually starting from here.
		)
	)

/datum/component/construction/mecha/phazon/get_outer_plating_steps()
	return list(
		list(
			"key" = outer_plating,
			"amount" = 1,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded, [initial(outer_plating.name)] can be used as external armor.",
			"forward_message" = "added external armor layer",
			"backward_message" = "cut off internal armor layer"
		),
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed, and can be <b>wrenched</b> into place.",
			"forward_message" = "secured external armor layer",
			"backward_message" = "pried off external armor"
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched, and can be <b>welded</b>.",
			"forward_message" = "welded external armor",
			"backward_message" = "unfastened external armor layer"
		),
		list(
			"key" = /obj/item/assembly/signaler/anomaly/bluespace,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "The external armor is welded, and the <b>bluespace anomaly core</b> socket is open.",
			"icon_state" = "phazon24",
			"forward_message" = "inserted bluespace anomaly core",
			"backward_message" = "cut off external armor"
		)
	)

//SAVANNAH-IVANOV
/datum/component/construction/unordered/mecha_chassis/savannah_ivanov
	result = /datum/component/construction/mecha/savannah_ivanov
	steps = list(
		/obj/item/mecha_parts/part/savannah_ivanov_torso,
		/obj/item/mecha_parts/part/savannah_ivanov_head,
		/obj/item/mecha_parts/part/savannah_ivanov_left_arm,
		/obj/item/mecha_parts/part/savannah_ivanov_right_arm,
		/obj/item/mecha_parts/part/savannah_ivanov_left_leg,
		/obj/item/mecha_parts/part/savannah_ivanov_right_leg
	)

/datum/component/construction/mecha/savannah_ivanov
	result = /obj/vehicle/sealed/mecha/savannah_ivanov
	base_icon = "savannah_ivanov"

	circuit_control = /obj/item/circuitboard/mecha/savannah_ivanov/main
	circuit_periph = /obj/item/circuitboard/mecha/savannah_ivanov/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/savannah_ivanov/targeting

	inner_plating = /obj/item/stack/sheet/plasteel
	inner_plating_amount = 10

	outer_plating = /obj/item/mecha_parts/part/savannah_ivanov_armor
	outer_plating_amount = 1

//ODYSSEUS
/datum/component/construction/unordered/mecha_chassis/odysseus
	result = /datum/component/construction/mecha/odysseus
	steps = list(
		/obj/item/mecha_parts/part/odysseus_torso,
		/obj/item/mecha_parts/part/odysseus_head,
		/obj/item/mecha_parts/part/odysseus_left_arm,
		/obj/item/mecha_parts/part/odysseus_right_arm,
		/obj/item/mecha_parts/part/odysseus_left_leg,
		/obj/item/mecha_parts/part/odysseus_right_leg
	)

/datum/component/construction/mecha/odysseus
	result = /obj/vehicle/sealed/mecha/odysseus
	base_icon = "odysseus"

	circuit_control = /obj/item/circuitboard/mecha/odysseus/main
	circuit_periph = /obj/item/circuitboard/mecha/odysseus/peripherals

	inner_plating = /obj/item/stack/sheet/iron
	inner_plating_amount = 5

	outer_plating = /obj/item/stack/sheet/plasteel
	outer_plating_amount = 5

//KINGSPIRE MK.1
/datum/component/construction/unordered/mecha_chassis/kingspire
	result = /datum/component/construction/mecha/kingspire
	steps = list(
		/obj/item/mecha_parts/part/kingspire_torso,
		/obj/item/mecha_parts/part/kingspire_left_arm,
		/obj/item/mecha_parts/part/kingspire_right_arm,
		/obj/item/mecha_parts/part/kingspire_left_leg,
		/obj/item/mecha_parts/part/kingspire_right_leg
	)

/datum/component/construction/mecha/kingspire
	result = /obj/vehicle/sealed/mecha/kingspire
	base_icon = "kingspire"

	circuit_control = /obj/item/circuitboard/mecha/kingspire/main
	circuit_periph = /obj/item/circuitboard/mecha/kingspire/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/kingspire/targeting

	inner_plating = /obj/item/stack/sheet/iron
	inner_plating_amount = 3

	outer_plating = /obj/item/mecha_parts/part/kingspire_armor
	outer_plating_amount = 1

/datum/component/construction/mecha/kingspire/get_frame_steps()
	return list(
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The roadwheels are disconnected but can be attached to keep the hull of the ground with a <b>wrench</b>.",
			"forward_message" = "Attached roadwheels",
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The track is still slack from the lack of return rollers, which can be attached with a <b>screwdriver</b>.",
			"forward_message" = "attached return rollers",
			"backward_message" = "removed roadwheels"
		),
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The tracks are now tensioned and ready for use, now the engine can be <b>wired</b>.",
			"forward_message" = "added wiring",
			"backward_message" = "removed return rollers"
		),
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added, and can be adjusted with <b>wirecutters</b>.",
			"forward_message" = "adjusted wiring",
			"backward_message" = "removed wiring"
		),
	)
/datum/component/construction/mecha/kingspire/get_circuit_steps()
	return list(
		list(
			"key" = circuit_control,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The engine is wired and the <b>Radio Equipment</b> can now be wired in and powered.",
			"forward_message" = "added radio set",
			"backward_message" = "disconnected wiring"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The radio is in but is sitting unsecured. it and can be <b>screwed</b> into place.",
			"forward_message" = "secured radio set",
			"backward_message" = "removed radio set"
		),
		list(
			"key" = circuit_periph,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Radio is now secured, and the <b>hydraulic equipment</b> can be slotted in.",
			"forward_message" = "added hydraulic equipment",
			"backward_message" = "unsecured radio set"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The hydraulics are now installed, and the hoses can be <b>screwed</b> into place.",
			"forward_message" = "secured hydraulic lines",
			"backward_message" = "removed hydraulics"
		)
	)
/datum/component/construction/mecha/kingspire/get_circuit_weapon_steps()
	return list(
				list(
			"key" = circuit_weapon,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The <b>Seating</b> is still not in, do you want to crouch while driving?.",
			"forward_message" = "added the seats",
			"backward_message" = "disconnected hydraulic lines"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The seats are loose and your not stupid enough to leave it like that.",
			"forward_message" = "secured seating",
			"backward_message" = "removed seating"
		),
	)
/datum/component/construction/mecha/kingspire/get_stockpart_steps()
	return list(
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "the crew compartment parts are almost finished, you can add the <b>scanning_module</b> for the driver.",
			"forward_message" = "added scanning module",
			"backward_message" = "unsecured seats"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanning module is installed, and can be <b>screwed</b> into place.",
			"forward_message" = "secured scanning module",
			"backward_message" = "removed scanning module"
		),
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanning module is secured, the <b>capacitor</b> can be added.",
			"forward_message" = "added capacitor",
			"backward_message" = "unscecured scanning module"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed, and can be <b>screwed</b> into place.",
			"forward_message" = "secured capacitor",
			"backward_message" = "removed capacitor"
		),
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured, and the <b>power cell</b> can be added.",
			"forward_message" = "added power cell",
			"backward_message" = "unsecured capacitor"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed, and can be <b>screwed</b> into place.",
			"forward_message" = "secured power cell",
			"backward_message" = "removed power cell"
		),
	)

/datum/component/construction/mecha/kingspire/get_inner_plating_steps()
	return list(
		list(
			"key" = inner_plating,
			"amount" = inner_plating_amount,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The interior of the Kingspire is finished, you need to use [inner_plating_amount] sheets of [initial(inner_plating.name)] to make the headlight.",
			"forward_message" = "installed headlight socket",
			"backward_message" = "unsecured power cell"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The headlight socket is built, the bulb can be <b>screwed</b> into place.",
			"forward_message" = "lightbulb added",
			"backward_message" = "pried off headlight mount"
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hull is finished, you need to reinforce everything by welding it.",
			"forward_message" = "welded tank hull",
			"backward_message" = "removed lightbulb"
		),
	)
/datum/component/construction/mecha/kingspire/get_outer_plating_steps()
	return list(
		list(
			"key" = outer_plating,
			"amount" = outer_plating_amount,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "the hull is welded, you now need to add the turret to the tank.",
			"forward_message" = "installed turret",
			"backward_message" = "cut welds on hull"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The turret is now on the Kingspire, you need to mount the antenna and machinegun into the turret",
			"forward_message" = "gun and antenna added",
			"backward_message" = "pried off turret"
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The turret is assembled, the plates on it need to be welded shut for combat.",
			"forward_message" = "welded turret",
			"backward_message" = "removed turret parts"
		),
	)

// t5 percutio
/datum/component/construction/unordered/mecha_chassis/percutio
	result = /datum/component/construction/mecha/percutio
	steps = list(
		/obj/item/mecha_parts/part/percutio_left_arm,
		/obj/item/mecha_parts/part/percutio_right_arm,
		/obj/item/mecha_parts/part/percutio_left_leg,
		/obj/item/mecha_parts/part/percutio_right_leg
	)


/datum/component/construction/mecha/percutio
	result = /obj/vehicle/sealed/mecha/percutio
	base_icon = "percutio"

	circuit_control = /obj/item/circuitboard/mecha/percutio/main
	circuit_periph = /obj/item/circuitboard/mecha/percutio/peripherals
	circuit_weapon = /obj/item/circuitboard/mecha/percutio/targeting

	inner_plating = /obj/item/stack/rods
	inner_plating_amount = 16

	outer_plating = /obj/item/mecha_parts/part/percutio_armor
	outer_plating_amount = 1

/datum/component/construction/mecha/percutio/get_frame_steps()
	return list(
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The wheels are lying on the ground, you can put them on with a <b>wrench</b>.",
			"forward_message" = "Attached wheels",
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The wheels are on the axle but the suspension is slack, you can set the suspension with a <b>screwdriver</b>.",
			"forward_message" = "activated suspension",
			"backward_message" = "removed wheels"
		),
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wheels are finished, you can now put the headlights in and <b>wire</b> them.",
			"forward_message" = "added & wired headlights",
			"backward_message" = "reset suspension"
		),
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The headlights are ready, now the engine needs some <b>wire</b>.",
			"forward_message" = "added engine wiring",
			"backward_message" = "removed wiring & headlights"
		),
	)
/datum/component/construction/mecha/percutio/get_circuit_steps()
	return list(
		list(
			"key" = circuit_control,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The engine is wired. You can go throw in the fuel tank.",
			"forward_message" = "added fuel tank",
			"backward_message" = "disconnected engine wiring"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The fuel is in but is sitting unsecured. it and can be <b>screwed</b> into place.",
			"forward_message" = "secured fuel tank",
			"backward_message" = "removed fuel tank"
		),
		list(
			"key" = circuit_periph,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The fuel tank is now secured, and the <b>hydraulic equipment</b> can be slotted in.",
			"forward_message" = "added hydraulic equipment",
			"backward_message" = "unsecured fuel tank"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The hydraulics are now installed, and the hoses can be <b>screwed</b> into place.",
			"forward_message" = "secured hydraulic lines",
			"backward_message" = "removed hydraulics"
		)
	)
/datum/component/construction/mecha/percutio/get_circuit_weapon_steps()
	return list(
				list(
			"key" = circuit_weapon,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The <b>Seating</b> is still not in, do you want to crouch while driving?.",
			"forward_message" = "added the seats",
			"backward_message" = "disconnected hydraulic lines"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The seats are loose and your not stupid enough to leave it like that.",
			"forward_message" = "secured seating",
			"backward_message" = "removed seating"
		),
	)
/datum/component/construction/mecha/percutio/get_stockpart_steps()
	return list(
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "the crew compartment parts are almost finished, you can add the <b>scanning_module</b> for the driver.",
			"forward_message" = "added scanning module",
			"backward_message" = "unsecured seats"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanning module is installed, and can be <b>screwed</b> into place.",
			"forward_message" = "secured scanning module",
			"backward_message" = "removed scanning module"
		),
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Scanning module is secured, the <b>capacitor</b> can be added.",
			"forward_message" = "added capacitor",
			"backward_message" = "unscecured scanning module"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Capacitor is installed, and can be <b>screwed</b> into place.",
			"forward_message" = "secured capacitor",
			"backward_message" = "removed capacitor"
		),
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Capacitor is secured, and the <b>power cell</b> can be added.",
			"forward_message" = "added power cell",
			"backward_message" = "unsecured capacitor"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed, and can be <b>screwed</b> into place.",
			"forward_message" = "secured power cell",
			"backward_message" = "removed power cell"
		),
	)

/datum/component/construction/mecha/percutio/get_inner_plating_steps()
	return list(
		list(
			"key" = inner_plating,
			"amount" = inner_plating_amount,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The interior of the Percutio is finished, you need to use 16 iron rods to form the back wheels chains.",
			"forward_message" = "installed traction chains",
			"backward_message" = "unsecured power cell"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The chains are on but slacked, they can be adjusted with a <b>screwdriver</b>.",
			"forward_message" = "chains tightened",
			"backward_message" = "removed chains"
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hull is finished, you need to reinforce everything by welding it.",
			"forward_message" = "welded car hull",
			"backward_message" = "slackened chains"
		),
	)
/datum/component/construction/mecha/percutio/get_outer_plating_steps()
	return list(
		list(
			"key" = outer_plating,
			"amount" = outer_plating_amount,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "the hull is welded, you now need to add the turret to the tank.",
			"forward_message" = "installed turret",
			"backward_message" = "cut welds on hull"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The turret is now on the percutio, but its ready to fall out at any movement, you need to <b> screw <b/> it in.",
			"forward_message" = "gun and antenna added",
			"backward_message" = "pushed off turret"
		),
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The turret is assembled, the plates on it need to be welded shut for combat.",
			"forward_message" = "welded turret",
			"backward_message" = "unsecured turret"
		),
	)

// Balfour Stockade (the chimera mech non mech)

/datum/component/construction/unordered/mecha_chassis/stockade
	result = /datum/component/construction/mecha/stockade
	steps = list(
		/obj/item/mecha_parts/part/stockade_left_arm,
		/obj/item/mecha_parts/part/stockade_right_arm,
		/obj/item/mecha_parts/part/stockade_left_leg,
	)


/datum/component/construction/mecha/stockade
	result = /obj/vehicle/ridden/stockade // yep, mech building for a non mech
	base_icon = "stockade"

	outer_plating = /obj/item/mecha_parts/part/stockade_armor
	outer_plating_amount = 1

/datum/component/construction/mecha/stockade/get_frame_steps()
	return list(
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The wheels arent attached to the carriage, you can <b>wrench</b> the first bolts on.",
			"forward_message" = "Attached wheels",
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The wheels are on the axle but the thing has like 20 screws per wheel also, better get busy with a <b>screwdriver</b>.",
			"forward_message" = "screwed screws",
			"backward_message" = "removed wheels"
		),
		list(
			"key" = TOOL_CROWBAR,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wheels are on the carriage, now the gunshield, you might be able to lever it up with a <b>crowbar</b>.",
			"forward_message" = "set gunshield",
			"backward_message" = "unscrewed wheels"
		),
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The gunshield bent your crowbar slightly, but its set in its position, you can use a <b>wrench</b> to secure it.",
			"forward_message" = "secured gunshield",
			"backward_message" = "unset gunshield"
		),
	)
/datum/component/construction/mecha/stockade/get_circuit_steps()
	return list(
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The gunshield needs to be <b>welded</b> so it can protect you.",
			"forward_message" = "welded gunshield",
			"backward_message" = "unsecured gunshield"
		),
		list(
			"key" = TOOL_CROWBAR,
			"back_key" = TOOL_WELDER,
			"desc" = "The slot for the box of more ammo is exposed now, you can <b>pry</b> it into its slot.",
			"forward_message" = "inserted box of infinity ammo",
			"backward_message" = "broke welds"
		),
	)
/datum/component/construction/mecha/stockade/get_circuit_weapon_steps()
	return list(
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "You need to <b>screw</b> the box in, otherwise it might tip over and it said dont do that.",
			"forward_message" = "unset syndicate doom box",
			"backward_message" = "secured violation of thermodynamics"
		),
	)
/datum/component/construction/mecha/stockade/get_stockpart_steps()
	return list(
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "the gunsight needs to be made, put a <b>scanning_module</b> in.",
			"forward_message" = "added scanning module",
			"backward_message" = "unsecured blackbox of boom"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Scanning module is installed, and can be <b>screwed</b> into place.",
			"forward_message" = "secured scanning module",
			"backward_message" = "removed scanning module"
		),
	)

/datum/component/construction/mecha/stockade/get_inner_plating_steps()
	return list(
	)
/datum/component/construction/mecha/stockade/get_outer_plating_steps()
	return list(
		list(
			"key" = outer_plating,
			"amount" = outer_plating_amount,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "the gun needs to be put in get ready to heave.",
			"forward_message" = "gun lifted into place",
			"backward_message" = "unsecured scanning module"
		),
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Your arms dont want to work much anymore, but the gun is in its mounting, now you need to <b> screw </b> it in.",
			"forward_message" = "gun affixed",
			"backward_message" = "pushed off gun"
		),
		list(
			"key" = TOOL_CROWBAR,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The uhh, thing looks compressed? Smack the funny box the syndicate made with a <b> Crowbar </b> and maybe that fixes it.",
			"forward_message" = "space time distortion dispersed",
			"backward_message" = "unsecured gun"
		),
	)
