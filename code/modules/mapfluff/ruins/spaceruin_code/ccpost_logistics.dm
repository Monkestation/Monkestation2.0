// CENTRAL COMMAND OUTPOST LOGISTICS

#define CCPOST_FREIGHT_INBOUND_ID "ccpost_freight_in"
#define CCPOST_FREIGHT_OUTBOUND_ID "ccpost_freight_out"

#define CCPOST_STARTING_ALLOCATION 20
#define CCPOST_MAX_ALLOCATION 80
#define CCPOST_FREIGHT_RETURN_VALUE 1


// LOGISTICS NETWORK

#define CCPOST_SHIPMENT_QUEUED "QUEUED"
#define CCPOST_SHIPMENT_AUTHORIZED "AUTHORIZED"
#define CCPOST_SHIPMENT_IN_TRANSIT "IN TRANSIT"
#define CCPOST_SHIPMENT_DELIVERED "DELIVERED"
#define CCPOST_SHIPMENT_FAILED "FAILED"

#define CCPOST_MAX_ACTIVE_SHIPMENTS 2

// Base freight processing timing. Sector conditions may modify these values.
#define CCPOST_BASE_AUTHORIZATION_DELAY 30 SECONDS
#define CCPOST_BASE_DISPATCH_DELAY 45 SECONDS
#define CCPOST_BASE_TRANSIT_DELAY 60 SECONDS

#define CCPOST_SHIPMENT_RETRY_DELAY 5 SECONDS
#define CCPOST_SUPPLY_CATEGORY_MEDICAL "Medical"


/datum/ccpost_allocation_ledger_entry
	var/timestamp
	var/amount
	var/reason
	var/actor

/datum/ccpost_allocation_ledger_entry/New(_amount, _reason, _actor)
	. = ..()
	timestamp = station_time_timestamp()
	amount = _amount
	reason = _reason
	actor = _actor


/datum/ccpost_freight_conditions
	var/status = "NORMAL"

	var/authorization_delay = CCPOST_BASE_AUTHORIZATION_DELAY
	var/dispatch_delay = CCPOST_BASE_DISPATCH_DELAY
	var/transit_multiplier = 1

	var/list/reasons = list()


/datum/ccpost_freight_conditions/proc/add_reason(reason)
	if(!reason)
		return

	reasons += reason


/datum/ccpost_freight_conditions/proc/get_transit_delay()
	return max(
		5 SECONDS,
		round(CCPOST_BASE_TRANSIT_DELAY * transit_multiplier, 1 SECONDS)
	)


/datum/ccpost_freight_conditions/proc/finalize_status()
	var/degraded = FALSE
	var/priority = FALSE

	if(authorization_delay > CCPOST_BASE_AUTHORIZATION_DELAY)
		degraded = TRUE

	if(dispatch_delay > CCPOST_BASE_DISPATCH_DELAY)
		degraded = TRUE

	if(transit_multiplier > 1)
		degraded = TRUE

	if(authorization_delay < CCPOST_BASE_AUTHORIZATION_DELAY)
		priority = TRUE

	if(dispatch_delay < CCPOST_BASE_DISPATCH_DELAY)
		priority = TRUE

	if(transit_multiplier < 1)
		priority = TRUE

	if(degraded && priority)
		status = "MIXED"

	else if(degraded)
		status = "DEGRADED"

	else if(priority)
		status = "PRIORITY"

	else
		status = "NORMAL"

// Checks conditions of other installations within the sector, which has an affect on freight

/datum/ccpost_logistics_network/proc/get_current_freight_conditions()
	var/datum/ccpost_freight_conditions/conditions = new

	var/datum/ccpost_sector_network/sector_network = GLOB.ccpost_sector_network

	if(!sector_network)
		conditions.finalize_status()
		return conditions

	sector_network.ensure_started()

	// --------------------------------------------------------
	// RELAY STATION A-17
	// Communications reliability affects authorization.
	// --------------------------------------------------------

	var/datum/ccpost_sector_installation/relay = sector_network.get_installation_by_code("NT-REL-A17")

	if(relay)
		if(relay.destroyed)
			conditions.authorization_delay += 15 SECONDS
			conditions.add_reason("Relay Station A-17 has been lost. Administrative traffic is being rerouted.")

		else
			switch(relay.status)
				if("COMMUNICATIONS DEGRADED")
					conditions.authorization_delay += 5 SECONDS
					conditions.add_reason("Relay Station A-17 is reporting degraded communications.")

				if("NO CONTACT", "OFFLINE")
					conditions.authorization_delay += 10 SECONDS
					conditions.add_reason("Relay Station A-17 is unavailable. Authorization traffic is using alternate routes.")

				if("CRITICAL")
					conditions.authorization_delay += 15 SECONDS
					conditions.add_reason("Relay Station A-17 is experiencing a critical operational incident.")


	// --------------------------------------------------------
	// ADMINISTRATIVE ANNEX 6
	// Administrative processing affects authorization.
	// --------------------------------------------------------

	var/datum/ccpost_sector_installation/administrative_annex = sector_network.get_installation_by_code("NT-ADM-06")

	if(administrative_annex)
		if(administrative_annex.destroyed)
			conditions.authorization_delay += 15 SECONDS
			conditions.add_reason("Administrative Annex 6 has been lost. Requisitions are being processed through alternate administrative channels.")

		else
			switch(administrative_annex.status)
				if("UNDER REVIEW")
					conditions.authorization_delay += 5 SECONDS
					conditions.add_reason("Administrative Annex 6 is under Central Command review.")

				if("COMMUNICATIONS DEGRADED")
					conditions.authorization_delay += 5 SECONDS
					conditions.add_reason("Administrative Annex 6 is experiencing communications degradation.")

				if("NO CONTACT", "OFFLINE")
					conditions.authorization_delay += 10 SECONDS
					conditions.add_reason("Administrative Annex 6 is unavailable. Requisition processing has been rerouted.")

				if("CRITICAL")
					conditions.authorization_delay += 15 SECONDS
					conditions.add_reason("Administrative Annex 6 is experiencing a critical operational incident.")


	// --------------------------------------------------------
	// LOGISTICS STATION H-9
	// This is the installation most directly involved in freight.
	// --------------------------------------------------------

	var/datum/ccpost_sector_installation/logistics_station = sector_network.get_installation_by_code("NT-LOG-H09")

	if(logistics_station)
		if(logistics_station.destroyed)
			conditions.dispatch_delay += 20 SECONDS
			conditions.transit_multiplier *= 1.75
			conditions.add_reason("Logistics Station H-9 has been lost. Freight is being routed through distant sector infrastructure.")

		else
			switch(logistics_station.status)
				if("MAINTENANCE")
					conditions.dispatch_delay += 5 SECONDS
					conditions.transit_multiplier *= 1.15
					conditions.add_reason("Logistics Station H-9 is undergoing maintenance.")

				if("COMMUNICATIONS DEGRADED")
					conditions.dispatch_delay += 5 SECONDS
					conditions.transit_multiplier *= 1.25
					conditions.add_reason("Logistics Station H-9 is reporting degraded communications.")

				if("NO CONTACT")
					conditions.dispatch_delay += 10 SECONDS
					conditions.transit_multiplier *= 1.4
					conditions.add_reason("Contact with Logistics Station H-9 has been lost. Freight is being rerouted.")

				if("OFFLINE")
					conditions.dispatch_delay += 15 SECONDS
					conditions.transit_multiplier *= 1.5
					conditions.add_reason("Logistics Station H-9 is offline. Alternate freight infrastructure is in use.")

				if("CRITICAL")
					conditions.dispatch_delay += 20 SECONDS
					conditions.transit_multiplier *= 1.75
					conditions.add_reason("Logistics Station H-9 is experiencing a critical operational incident.")


	// --------------------------------------------------------
	// ACTIVE SECTOR NOTICES
	// --------------------------------------------------------

	for(var/datum/ccpost_sector_notice/notice as anything in sector_network.sector_notices)
		if(!notice.has_active_logistics_effect())
			continue

		conditions.authorization_delay += notice.logistics_authorization_delay
		conditions.dispatch_delay += notice.logistics_dispatch_delay
		conditions.transit_multiplier *= notice.logistics_transit_multiplier

		if(notice.logistics_effect_summary)
			conditions.add_reason("[notice.title]: [notice.logistics_effect_summary]")


	// Prevent ridiculous stacking if several incidents overlap.
	conditions.authorization_delay = clamp(
		conditions.authorization_delay,
		15 SECONDS,
		90 SECONDS
	)

	conditions.dispatch_delay = clamp(
		conditions.dispatch_delay,
		15 SECONDS,
		90 SECONDS
	)

	conditions.transit_multiplier = clamp(
		conditions.transit_multiplier,
		0.5,
		2.5
	)

	conditions.finalize_status()

	return conditions

/datum/ccpost_logistics_network
	/// Total Central Command Operational Allocation currently owned by the outpost.
	var/allocation = CCPOST_STARTING_ALLOCATION

	/// Allocation currently committed to pending orders.
	var/reserved_allocation = 0

	/// Maximum allocation the outpost may hold.
	var/max_allocation = CCPOST_MAX_ALLOCATION

	/// Incrementing number used for shipment IDs.
	var/next_shipment_number = 1

	/// Round-long record of actual allocation gains and expenditures.
	var/list/allocation_ledger = list()

	/// Registered inbound freight spawn locations.
	var/list/inbound_spawns = list()

	/// Registered inbound unloading sensors.
	var/list/unload_points = list()

	/// Registered outbound freight loading points.
	var/list/outbound_load_points = list()

	/// Registered outbound freight return receivers.
	var/list/return_receivers = list()

	/// Registered Central Command Logistics Terminals.
	var/list/registered_terminals = list()

	/// Wall-mounted freight status displays connected to the outpost logistics network.
	var/list/registered_status_displays = list()

	/// Available Central Command procurement packages.
	var/list/supply_catalog = list()

	/// Current and historical freight requisitions.
	var/list/shipments = list()

	/// Number of restricted/contraband requisitions submitted this round.
	var/contraband_requisition_count = 0

	/// TRUE when new restricted procurement activity should trigger an outpost audit.
	var/contraband_audit_pending = FALSE

	/// Restricted requisition count already covered by the most recently issued audit.
	var/contraband_requisitions_at_last_audit = 0

	/// Weighted compliance risk generated by restricted requisitions.
	var/contraband_compliance_points = 0

	/// Compliance points already covered by the most recently issued audit.
	var/contraband_points_at_last_audit = 0

	/// World time until which Restricted procurement is blocked by Internal Compliance.
	var/restricted_procurement_suspended_until = 0

	/// Maximum unfinished requisitions allowed simultaneously.
	var/max_active_shipments = CCPOST_MAX_ACTIVE_SHIPMENTS

	/// TRUE while a freight container is physically travelling along the inbound lane.
	var/inbound_lane_busy = FALSE

	/// TRUE while a freight container is physically travelling along the outbound return lane.
	var/outbound_lane_busy = FALSE


/datum/ccpost_logistics_network/Destroy()
	QDEL_LIST(allocation_ledger)
	QDEL_LIST_ASSOC_VAL(supply_catalog)
	QDEL_LIST(shipments)

	inbound_spawns = null
	unload_points = null
	outbound_load_points = null
	return_receivers = null
	registered_terminals = null
	registered_status_displays = null

	return ..()

/datum/ccpost_logistics_network/proc/is_restricted_procurement_suspended()
	return restricted_procurement_suspended_until > world.time


/datum/ccpost_logistics_network/proc/get_restricted_procurement_suspension_remaining()
	if(!is_restricted_procurement_suspended())
		return 0

	return max(0, restricted_procurement_suspended_until - world.time)


/datum/ccpost_logistics_network/proc/suspend_restricted_procurement(duration)
	if(duration <= 0)
		return

	restricted_procurement_suspended_until = max(restricted_procurement_suspended_until, world.time + duration)

	refresh_logistics_outputs()
	addtimer(CALLBACK(src, PROC_REF(clear_restricted_procurement_suspension_if_expired)), duration + 1 SECONDS)


/datum/ccpost_logistics_network/proc/clear_restricted_procurement_suspension_if_expired()
	if(world.time < restricted_procurement_suspended_until)
		return

	restricted_procurement_suspended_until = 0
	refresh_logistics_outputs()


// Freight Status Display

/datum/ccpost_logistics_network/proc/register_status_display(obj/machinery/status_display/ccpost_logistics/display)
	if(!display)
		return

	registered_status_displays |= display

	display.update()


/datum/ccpost_logistics_network/proc/unregister_status_display(obj/machinery/status_display/ccpost_logistics/display)
	if(!display)
		return

	registered_status_displays -= display

/// Returns the amount of allocation which is actually available to spend.
/datum/ccpost_logistics_network/proc/get_available_allocation()
	return max(0, allocation - reserved_allocation)


/// Records an actual financial transaction in the allocation ledger.
/datum/ccpost_logistics_network/proc/record_ledger_entry(amount, reason = "Unspecified transaction", actor = "SYSTEM")
	allocation_ledger.Insert(1, new /datum/ccpost_allocation_ledger_entry(amount, reason, actor))

	if(length(allocation_ledger) > 100)
		var/datum/ccpost_allocation_ledger_entry/oldest_entry = allocation_ledger[101]
		allocation_ledger.Cut(101)
		qdel(oldest_entry)


/// Adds operational allocation to the outpost.
///
/// Returns the amount which was actually credited after applying the maximum balance.
/datum/ccpost_logistics_network/proc/credit_allocation(amount, reason = "Central Command allocation credit", actor = "CENTRAL COMMAND")
	if(amount <= 0)
		return 0

	var/available_capacity = max_allocation - allocation

	if(available_capacity <= 0)
		return 0

	var/applied_amount = min(amount, available_capacity)

	allocation += applied_amount

	record_ledger_entry(applied_amount, reason, actor)

	return applied_amount


/// Immediately spends unreserved allocation.
///
/// Returns TRUE if the payment succeeded.
/datum/ccpost_logistics_network/proc/spend_allocation(amount, reason = "Operational expenditure", actor = "SYSTEM")
	if(amount <= 0)
		return FALSE

	if(amount > get_available_allocation())
		return FALSE

	allocation -= amount

	record_ledger_entry(-amount, reason, actor)

	return TRUE


/// Reserves allocation for an order which has been placed but not yet finalized.
///
/// Reserved allocation remains part of the total balance but cannot be spent elsewhere.
/datum/ccpost_logistics_network/proc/reserve_allocation(amount)
	if(amount <= 0)
		return FALSE

	if(amount > get_available_allocation())
		return FALSE

	reserved_allocation += amount

	return TRUE


/// Releases previously reserved allocation.
///
/// Used if an order is cancelled or otherwise fails before expenditure.
/datum/ccpost_logistics_network/proc/release_reserved_allocation(amount)
	if(amount <= 0)
		return 0

	var/released_amount = min(amount, reserved_allocation)

	reserved_allocation -= released_amount

	return released_amount


/// Converts reserved allocation into an actual expenditure.
///
/// Used when a requisition becomes financially committed.
/datum/ccpost_logistics_network/proc/commit_reserved_allocation(amount, reason = "Operational expenditure", actor = "SYSTEM")
	if(amount <= 0)
		return FALSE

	if(amount > reserved_allocation)
		return FALSE

	if(amount > allocation)
		return FALSE

	reserved_allocation -= amount
	allocation -= amount

	record_ledger_entry(-amount, reason, actor)

	return TRUE

/datum/ccpost_logistics_network/New()
	. = ..()

	build_supply_catalog()


/datum/ccpost_logistics_network/proc/build_supply_catalog()
	for(var/datum/ccpost_supply_package/package_type as anything in subtypesof(/datum/ccpost_supply_package))
		var/datum/ccpost_supply_package/package = new package_type

		if(!package.id || package.id == "undefined")
			qdel(package)
			continue

		supply_catalog[package.id] = package


/datum/ccpost_logistics_network/proc/get_supply_package(package_id)
	return supply_catalog[package_id]


/datum/ccpost_logistics_network/proc/get_requisition_failure(
	datum/ccpost_supply_package/package,
	allow_restricted = FALSE
)
	if(!package)
		return "invalid requisition"

	if(package.contraband && !allow_restricted)
		return "requisition authorization denied"

	if(package.contraband && is_restricted_procurement_suspended())
		return "restricted procurement suspended"

	if(package.category == CCPOST_SUPPLY_CATEGORY_MEDICAL && GLOB.ccpost_sector_network.is_medical_supply_recall_active())
		return "medical supply recall active"

	if(get_active_shipment_count() >= max_active_shipments)
		return "shipment queue full"

	if(package.cost > get_available_allocation())
		return "insufficient allocation"

	return null


/datum/ccpost_logistics_network/proc/get_active_shipment_count()
	var/count = 0

	for(var/datum/ccpost_shipment/shipment as anything in shipments)
		if(QDELETED(shipment))
			continue

		if(shipment.status == CCPOST_SHIPMENT_DELIVERED)
			continue

		if(shipment.status == CCPOST_SHIPMENT_FAILED)
			continue

		count++

	return count


/datum/ccpost_logistics_network/proc/find_shipment(shipment_code)
	if(!shipment_code)
		return null

	for(var/datum/ccpost_shipment/shipment as anything in shipments)
		if(QDELETED(shipment))
			continue

		if(shipment.shipment_code == shipment_code)
			return shipment

	return null

/datum/ccpost_logistics_network/proc/refresh_logistics_outputs()
	refresh_registered_terminals()

	for(var/obj/machinery/status_display/ccpost_logistics/display as anything in registered_status_displays)
		if(QDELETED(display))
			continue

		display.update()


/datum/ccpost_logistics_network/proc/refresh_registered_terminals()
	for(var/obj/machinery/computer/ccpost_logistics/terminal as anything in registered_terminals)
		if(QDELETED(terminal))
			continue

		SStgui.update_uis(terminal)

/// Freight status announcement system
//
/// Makes the terminal say the status of the freight via worldspeech
/datum/ccpost_logistics_network/proc/announce_freight_status(message, play_alert = TRUE)
	if(!message)
		return

	for(var/obj/machinery/computer/ccpost_logistics/terminal as anything in registered_terminals)
		if(QDELETED(terminal))
			continue

		if(terminal.machine_stat & (NOPOWER | BROKEN))
			continue

		if(play_alert)
			playsound(terminal, 'sound/machines/terminal_alert.ogg', 30, TRUE)

		terminal.say(message)


/// Generates the next unique Central Command freight shipment number.
/datum/ccpost_logistics_network/proc/generate_shipment_code()
	var/round_identifier = GLOB.round_id ? GLOB.round_id : "LOCAL"
	var/shipment_code = "CC-LG-[round_identifier]-[next_shipment_number]"

	next_shipment_number++

	return shipment_code


GLOBAL_DATUM_INIT(ccpost_logistics_network, /datum/ccpost_logistics_network, new)



// CONVEYOR CONTROL

/// Changes the operating state of every conveyor belt sharing a given ID.
///
/// Examples:
/// set_ccpost_conveyor_state(CCPOST_FREIGHT_INBOUND_ID, FALSE)
/// set_ccpost_conveyor_state(CCPOST_FREIGHT_INBOUND_ID, FALSE)
/proc/set_ccpost_conveyor_state(conveyor_id, operating_state)
	var/list/linked_conveyors = GLOB.conveyors_by_id[conveyor_id]

	if(!length(linked_conveyors))
		return FALSE

	for(var/obj/machinery/conveyor/belt as anything in linked_conveyors)
		if(QDELETED(belt))
			continue

		belt.set_operating(operating_state)

	return TRUE


// CENTRAL COMMAND FREIGHT CONTAINER

/obj/structure/closet/crate/ccpost_freight
	name = "Central Command freight container"
	desc = "A reusable freight container belonging to Central Command Logistics. A notice requests that empty containers be returned through an authorized freight receiver."

	/// Shipment number associated with this container.
	var/shipment_code

	/// Whether this container is eligible to be returned through the outpost freight network.
	var/returnable = TRUE

	/// Allocation returned when this empty container is successfully processed.
	var/return_value = CCPOST_FREIGHT_RETURN_VALUE


/obj/structure/closet/crate/ccpost_freight/examine(mob/user)
	. = ..()

	if(shipment_code)
		. += span_notice("Its freight identification number is [shipment_code].")

	if(returnable)
		. += span_notice("The container is marked as reusable Central Command freight property.")


// FREIGHT MAP POINTS

/obj/effect/ccpost_freight_point
	name = "CCPOST freight point"
	desc = "A mapping point used by the Central Command Liaison Outpost freight system."

	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "field_dir"

	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT


// INBOUND FREIGHT SPAWN

/// Place this on the furthest hidden inbound conveyor tile.
///
/// Ordered freight will initially appear here and travel toward the visible cargo bay.

/obj/effect/ccpost_freight_point/inbound_spawn
	name = "CCPOST inbound freight spawn"


/obj/effect/ccpost_freight_point/inbound_spawn/Initialize(mapload)
	. = ..()

	GLOB.ccpost_logistics_network.inbound_spawns |= src


/obj/effect/ccpost_freight_point/inbound_spawn/Destroy()
	GLOB.ccpost_logistics_network.inbound_spawns -= src

	return ..()

// INBOUND UNLOAD SENSOR

/// Place this on the final inbound conveyor tile inside the usable cargo bay.
///
/// When a Central Command freight container reaches this tile,
/// the inbound conveyor line stops automatically.

/obj/effect/ccpost_freight_point/inbound_unload
	name = "CCPOST inbound freight unload point"


/obj/effect/ccpost_freight_point/inbound_unload/Initialize(mapload)
	. = ..()

	GLOB.ccpost_logistics_network.unload_points |= src

	var/static/list/loc_connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_entered))
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/effect/ccpost_freight_point/inbound_unload/Destroy()
	GLOB.ccpost_logistics_network.unload_points -= src

	return ..()


/obj/effect/ccpost_freight_point/inbound_unload/proc/on_entered(datum/source, atom/movable/entering_atom)
	SIGNAL_HANDLER

	if(!istype(entering_atom, /obj/structure/closet/crate/ccpost_freight))
		return

	var/obj/structure/closet/crate/ccpost_freight/freight_crate = entering_atom

	set_ccpost_conveyor_state(CCPOST_FREIGHT_INBOUND_ID, FALSE)

	GLOB.ccpost_logistics_network.mark_shipment_delivered(freight_crate.shipment_code)

	playsound(src, 'sound/machines/terminal_alert.ogg', vol = 25, vary = TRUE)

// OUTBOUND LOAD POINT

/// Place this on the first outbound conveyor tile inside the usable cargo bay.
///
/// Empty, returnable Central Command freight containers placed on this tile
/// automatically start the outbound freight conveyor.

/obj/effect/ccpost_freight_point/outbound_load
	name = "CCPOST outbound freight loading point"


/obj/effect/ccpost_freight_point/outbound_load/Initialize(mapload)
	. = ..()

	GLOB.ccpost_logistics_network.outbound_load_points |= src

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered)
	)

	AddElement(/datum/element/connect_loc, loc_connections)


/obj/effect/ccpost_freight_point/outbound_load/Destroy()
	GLOB.ccpost_logistics_network.outbound_load_points -= src

	return ..()


/obj/effect/ccpost_freight_point/outbound_load/proc/on_entered(
	datum/source,
	atom/movable/entering_atom
)
	SIGNAL_HANDLER

	// Only Central Command freight containers can use the return system.
	if(!istype(entering_atom, /obj/structure/closet/crate/ccpost_freight))
		return

	var/obj/structure/closet/crate/ccpost_freight/freight_crate = entering_atom
	var/datum/ccpost_logistics_network/network = GLOB.ccpost_logistics_network

	if(!network)
		return

	// Prevent multiple returns from entering the outbound lane simultaneously.
	if(network.outbound_lane_busy)
		playsound(src, SFX_BUTTON_FAIL, vol = 25, vary = TRUE)

		freight_crate.visible_message(
			span_warning("[freight_crate] is rejected by the freight return system. The return lane is currently occupied.")
		)

		return

	// Only designated reusable freight containers may be returned.
	if(!freight_crate.returnable)
		playsound(src, SFX_BUTTON_FAIL, vol = 25, vary = TRUE)

		freight_crate.visible_message(
			span_warning("[freight_crate] is rejected by the freight return system.")
		)

		return

	// Containers must be completely empty before Sector Logistics will accept them.
	if(length(freight_crate.contents))
		playsound(src, SFX_BUTTON_FAIL, vol = 25, vary = TRUE)

		freight_crate.visible_message(
			span_warning("[freight_crate] is rejected by the freight return system. The container must be empty.")
		)

		return

	network.outbound_lane_busy = TRUE

	if(!set_ccpost_conveyor_state(CCPOST_FREIGHT_OUTBOUND_ID, TRUE))
		network.outbound_lane_busy = FALSE

		playsound(src, SFX_BUTTON_FAIL, vol = 25, vary = TRUE)

		freight_crate.visible_message(
			span_warning("The freight return system fails to engage.")
		)

		return

	playsound(src, 'sound/machines/terminal_alert.ogg', vol = 20, vary = TRUE)

	freight_crate.visible_message(
		span_notice("[freight_crate] is accepted for return to Sector Logistics.")
	)


// OUTBOUND RETURN RECEIVER

/// Place this on the furthest hidden outbound conveyor tile.
///
/// Empty Central Command freight containers which reach this point
/// are returned to Sector Logistics and provide a small allocation refund.

/obj/effect/ccpost_freight_point/return_receiver
	name = "CCPOST outbound freight receiver"


/obj/effect/ccpost_freight_point/return_receiver/Initialize(mapload)
	. = ..()

	GLOB.ccpost_logistics_network.return_receivers |= src

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered)
	)

	AddElement(/datum/element/connect_loc, loc_connections)


/obj/effect/ccpost_freight_point/return_receiver/Destroy()
	GLOB.ccpost_logistics_network.return_receivers -= src

	return ..()


/obj/effect/ccpost_freight_point/return_receiver/proc/on_entered(
	datum/source,
	atom/movable/entering_atom
)
	SIGNAL_HANDLER

	if(!istype(entering_atom, /obj/structure/closet/crate/ccpost_freight))
		return

	var/obj/structure/closet/crate/ccpost_freight/freight_crate = entering_atom
	var/datum/ccpost_logistics_network/network = GLOB.ccpost_logistics_network

	if(!network)
		return

	// Something has reached the end of the outbound lane, so stop it
	// and release the lane regardless of whether processing succeeds.
	set_ccpost_conveyor_state(CCPOST_FREIGHT_OUTBOUND_ID, FALSE)
	network.outbound_lane_busy = FALSE

	// Safety validation. Normally these checks are already performed
	// by the outbound loading point.
	if(!freight_crate.returnable)
		return

	if(length(freight_crate.contents))
		return

	var/credited_amount = network.credit_allocation(
		freight_crate.return_value,
		"Reusable freight container returned to Sector Logistics",
		"AUTOMATED FREIGHT RECEIVER"
	)

	if(credited_amount)
		playsound(src, 'sound/machines/terminal_alert.ogg', vol = 30, vary = TRUE)

		network.refresh_registered_terminals()

	qdel(freight_crate)

// CENTRAL COMMAND LOGISTICS TERMINAL CIRCUIT BOARD

/obj/item/circuitboard/computer/ccpost_logistics
	name = "Central Command Logistics Terminal"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/ccpost_logistics

// CENTRAL COMMAND LOGISTICS TERMINAL

/obj/machinery/computer/ccpost_logistics
	name = "Central Command logistics terminal"
	desc = "A secure Central Command procurement terminal used to manage operational allocation, freight requisitions, and remote installation logistics."

	icon_screen = "request"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_ORANGE

	circuit = /obj/item/circuitboard/computer/ccpost_logistics
	var/contraband_unlocked = FALSE

	/// Prevents audit printing from being spammed.
	COOLDOWN_DECLARE(audit_print_cooldown)

/obj/machinery/computer/ccpost_logistics/examine(mob/user)
	. = ..()

	var/datum/ccpost_logistics_network/network = GLOB.ccpost_logistics_network

	if(!network)
		return

	. += span_notice("Operational Allocation: [network.allocation] / [network.max_allocation] CU.")
	. += span_notice("Available Allocation: [network.get_available_allocation()] CU.")

	if(contraband_unlocked)
		. += span_warning("Its procurement authorization safeguards appear to have been bypassed.")

/obj/machinery/computer/ccpost_logistics/Initialize(mapload)
	. = ..()

	GLOB.ccpost_logistics_network.registered_terminals |= src


/obj/machinery/computer/ccpost_logistics/Destroy()
	GLOB.ccpost_logistics_network.registered_terminals -= src

	return ..()

/obj/machinery/computer/ccpost_logistics/multitool_act(mob/living/user, obj/item/tool)
	if(contraband_unlocked)
		balloon_alert(user, "routing override already active")
		return

	contraband_unlocked = TRUE

	tool.play_tool_sound(src, 35)

	balloon_alert(user, "procurement safeguards bypassed")

	say("WARNING: Procurement authorization matrix compromised. Unregistered vendor routes are now accessible.")

	SStgui.update_uis(src)

	return TRUE

// TGUI

/obj/machinery/computer/ccpost_logistics/ui_interact(mob/user, datum/tgui/ui)
	. = ..()

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "CCPostLogistics", name)
		ui.open()


/obj/machinery/computer/ccpost_logistics/ui_data(mob/user)
	var/list/data = list()

	var/datum/ccpost_logistics_network/network = GLOB.ccpost_logistics_network

	if(!network)
		return data

	data["allocation"] = network.allocation
	data["reserved_allocation"] = network.reserved_allocation
	data["available_allocation"] = network.get_available_allocation()
	data["max_allocation"] = network.max_allocation
	data["contraband_unlocked"] = contraband_unlocked

	data["active_shipments"] = network.get_active_shipment_count()
	data["max_active_shipments"] = network.max_active_shipments

	var/datum/ccpost_freight_conditions/current_conditions = network.get_current_freight_conditions()

	data["freight_status"] = current_conditions.status
	data["authorization_delay"] = round(current_conditions.authorization_delay / (1 SECONDS))
	data["dispatch_delay"] = round(current_conditions.dispatch_delay / (1 SECONDS))
	data["transit_delay"] = round(current_conditions.get_transit_delay() / (1 SECONDS))
	data["freight_reasons"] = current_conditions.reasons.Copy()

	qdel(current_conditions)

	var/list/catalog_data = list()
	var/medical_recall_active = GLOB.ccpost_sector_network.is_medical_supply_recall_active()

	data["medical_recall_active"] = medical_recall_active
	data["restricted_procurement_suspended"] = network.is_restricted_procurement_suspended()
	data["restricted_procurement_seconds"] = round(network.get_restricted_procurement_suspension_remaining() / (1 SECONDS))

	for(var/package_id in network.supply_catalog)
		var/datum/ccpost_supply_package/package = network.supply_catalog[package_id]

		if(!package)
			continue

		// Restricted packages are never sent to an unhacked terminal.
		if(package.contraband && !contraband_unlocked)
			continue

		// Medical stock remains visible during a recall, but every package in
		// the Medical category is locked until Central Medical Logistics clears it.
		var/recall_locked = package.category == CCPOST_SUPPLY_CATEGORY_MEDICAL && medical_recall_active
		var/requisition_failure = network.get_requisition_failure(
			package,
			contraband_unlocked
		)
		var/can_order_package = isnull(requisition_failure)

		catalog_data += list(list(
			"id" = package.id,
			"name" = package.name,
			"description" = package.desc,
			"category" = package.category,
			"cost" = package.cost,
			"recall_locked" = recall_locked,
			"can_order" = can_order_package
		))

	data["catalog"] = catalog_data

	var/list/shipment_data = list()

	for(var/datum/ccpost_shipment/shipment as anything in network.shipments)
		if(QDELETED(shipment))
			continue

		shipment_data += list(list(
			"code" = shipment.shipment_code,
			"package_name" = shipment.package?.name,
			"cost" = shipment.package?.cost,
			"requested_by" = shipment.requested_by,
			"requested_at" = shipment.requested_at,
			"status" = shipment.status,
			"updated_at" = shipment.status_updated_at,
			"authorization_delay" = round(shipment.authorization_delay / (1 SECONDS)),
			"dispatch_delay" = round(shipment.dispatch_delay / (1 SECONDS)),
			"transit_delay" = round(shipment.transit_delay / (1 SECONDS)),
			"freight_condition_status" = shipment.freight_condition_status,
			"freight_condition_reasons" = shipment.freight_condition_reasons,
			"failure_reason" = shipment.failure_reason
		))

	data["shipments"] = shipment_data

	var/list/ledger_data = list()

	for(var/datum/ccpost_allocation_ledger_entry/ledger_entry as anything in network.allocation_ledger)
		ledger_data += list(list(
			"time" = ledger_entry.timestamp,
			"amount" = ledger_entry.amount,
			"reason" = ledger_entry.reason,
			"actor" = ledger_entry.actor
		))

	data["ledger"] = ledger_data

	return data

// LOGISTICS TERMINAL ACTIONS

/obj/machinery/computer/ccpost_logistics/proc/begin_audit_print(mob/user, visible_text)
	if(!COOLDOWN_FINISHED(src, audit_print_cooldown))
		balloon_alert(user, "printer cooling down")
		return FALSE

	COOLDOWN_START(src, audit_print_cooldown, 5 SECONDS)
	playsound(src, 'sound/machines/printer.ogg', vol = 50, vary = FALSE)
	visible_message(span_notice(visible_text))
	return TRUE


/obj/machinery/computer/ccpost_logistics/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(.)
		return

	var/mob/user = ui.user
	var/datum/ccpost_logistics_network/network = GLOB.ccpost_logistics_network

	if(!network)
		return FALSE

	switch(action)
		if("order_package")
			var/package_id = params["package_id"]
			var/datum/ccpost_supply_package/package = network.get_supply_package(package_id)
			var/requisition_failure = network.get_requisition_failure(
				package,
				contraband_unlocked
			)

			if(requisition_failure)
				balloon_alert(user, requisition_failure)
				return TRUE

			var/datum/ccpost_shipment/shipment = network.create_shipment(
				package_id,
				user.name,
				contraband_unlocked
			)

			if(!shipment)
				balloon_alert(user, "requisition failed")
				return TRUE

			balloon_alert(user, "requisition queued")
			return TRUE

		if("print_shipment")
			var/shipment_code = params["shipment_code"]

			var/datum/ccpost_shipment/shipment = network.find_shipment(
				shipment_code
			)

			if(!shipment)
				balloon_alert(
					user,
					"shipment record not found"
				)

				return TRUE

			if(!begin_audit_print(user, "[src] prints a freight requisition record."))
				return TRUE

			print_shipment_record(
				shipment,
				user.name
			)

			balloon_alert(
				user,
				"shipment record printed"
			)

			return TRUE


		if("print_shipment_log")
			if(!begin_audit_print(user, "[src] prints a Central Command shipment audit."))
				return TRUE

			print_shipment_audit(
				network,
				user.name
			)

			balloon_alert(
				user,
				"shipment audit printed"
			)

			return TRUE


		if("print_ledger")
			if(!begin_audit_print(user, "[src] prints an operational allocation audit."))
				return TRUE

			print_allocation_ledger(
				network,
				user.name
			)

			balloon_alert(
				user,
				"allocation audit printed"
			)

			return TRUE


	return FALSE

// ////////////////////////////////////
// Logistics Package System
// ////////////////////////////////////

/// Creates one physical audit paper at the logistics terminal.
/obj/machinery/computer/ccpost_logistics/proc/print_audit_page(
	paper_name,
	paper_text
)
	var/obj/item/paper/audit_page = new /obj/item/paper(
		drop_location()
	)

	audit_page.name = paper_name
	audit_page.add_raw_text(paper_text)
	audit_page.update_appearance()

	return audit_page


/// Prints a detailed record for one freight requisition.
/obj/machinery/computer/ccpost_logistics/proc/print_shipment_record(
	datum/ccpost_shipment/shipment,
	generated_by
)
	if(!shipment || QDELETED(shipment))
		return

	var/package_name = "UNKNOWN PACKAGE"
	var/package_cost = 0
	var/procurement_class = "UNKNOWN"

	if(shipment.package)
		package_name = sanitize(shipment.package.name)
		package_cost = shipment.package.cost

		if(shipment.package.contraband)
			procurement_class = "RESTRICTED PROCUREMENT"
		else
			procurement_class = "STANDARD PROCUREMENT"

	var/requested_by = shipment.requested_by ? sanitize(shipment.requested_by) : "UNKNOWN"
	var/requested_at = shipment.requested_at ? shipment.requested_at : "N/A"

	var/authorized_at = shipment.authorized_at ? shipment.authorized_at : "N/A"
	var/dispatched_at = shipment.dispatched_at ? shipment.dispatched_at : "N/A"
	var/delivered_at = shipment.delivered_at ? shipment.delivered_at : "N/A"

	var/updated_at = shipment.status_updated_at ? shipment.status_updated_at : "N/A"

	var/safe_generated_by = generated_by ? sanitize(generated_by) : "UNKNOWN"

	var/terminal_status = contraband_unlocked ? "PROCUREMENT SAFEGUARDS COMPROMISED" : "PROCUREMENT SAFEGUARDS NOMINAL"

	var/report_text = "<center><b>CENTRAL COMMAND LOGISTICS</b></center>"
	report_text += "<center><b>FREIGHT REQUISITION RECORD</b></center><hr>"

	report_text += "<b>Reference:</b> [shipment.shipment_code]<br>"
	report_text += "<b>Classification:</b> [procurement_class]<br>"
	report_text += "<b>Package:</b> [package_name]<br>"
	report_text += "<b>Allocation Cost:</b> [package_cost] CU<br><br>"

	report_text += "<b>Requested By:</b> [requested_by]<br>"
	report_text += "<b>Requested At:</b> [requested_at]<br>"
	report_text += "<b>Authorized At:</b> [authorized_at]<br>"
	report_text += "<b>Dispatched At:</b> [dispatched_at]<br>"
	report_text += "<b>Delivered At:</b> [delivered_at]<br><br>"

	report_text += "<b>Status:</b> [shipment.status]<br>"
	report_text += "<b>Last Status Update:</b> [updated_at]<br><br>"

	report_text += "<b>Sector Freight Profile:</b> [shipment.freight_condition_status]<br>"
	report_text += "<b>Authorization Delay:</b> [round(shipment.authorization_delay / (1 SECONDS))] seconds<br>"
	report_text += "<b>Dispatch Delay:</b> [round(shipment.dispatch_delay / (1 SECONDS))] seconds<br>"
	report_text += "<b>Transit Delay:</b> [round(shipment.transit_delay / (1 SECONDS))] seconds<br>"

	if(length(shipment.freight_condition_reasons))
		report_text += "<br><b>Applied Sector Factors:</b><br>"

		for(var/reason in shipment.freight_condition_reasons)
			report_text += "- [sanitize("[reason]")]<br>"

	else
		report_text += "<br><b>Applied Sector Factors:</b> None<br>"

	if(shipment.failure_reason)
		report_text += "<br><b>Failure Reason:</b> [sanitize(shipment.failure_reason)]<br>"

	report_text += "<br><hr>"
	report_text += "<b>Terminal Status:</b> [terminal_status]<br>"
	report_text += "<b>Audit Generated:</b> [station_time_timestamp()]<br>"
	report_text += "<b>Generated By:</b> [safe_generated_by]<br>"
	report_text += "<br><i>Central Command Sector Logistics Coordination</i>"

	print_audit_page(
		"Freight Requisition Record - [shipment.shipment_code]",
		report_text
	)


/// Prints the complete shipment history in pages of ten requisitions.
/obj/machinery/computer/ccpost_logistics/proc/print_shipment_audit(
	datum/ccpost_logistics_network/network,
	generated_by
)
	if(!network)
		return

	var/safe_generated_by = generated_by ? sanitize(generated_by) : "UNKNOWN"

	var/terminal_status = contraband_unlocked ? "PROCUREMENT SAFEGUARDS COMPROMISED" : "PROCUREMENT SAFEGUARDS NOMINAL"

	var/page_size = 10
	var/page_number = 1

	if(!length(network.shipments))
		var/empty_text = "<center><b>CENTRAL COMMAND LOGISTICS</b></center>"
		empty_text += "<center><b>SHIPMENT AUDIT RECORD</b></center><hr>"
		empty_text += "<b>Generated:</b> [station_time_timestamp()]<br>"
		empty_text += "<b>Generated By:</b> [safe_generated_by]<br>"
		empty_text += "<b>Terminal Status:</b> [terminal_status]<br><br>"
		empty_text += "No freight requisitions have been recorded.<br>"
		empty_text += "<br><hr><i>Central Command Sector Logistics Coordination</i>"

		print_audit_page(
			"Central Command Shipment Audit",
			empty_text
		)

		return

	var/start_index = 1

	while(start_index <= length(network.shipments))
		var/end_index = min(
			start_index + page_size - 1,
			length(network.shipments)
		)

		var/report_text = "<center><b>CENTRAL COMMAND LOGISTICS</b></center>"
		report_text += "<center><b>SHIPMENT AUDIT RECORD - PAGE [page_number]</b></center><hr>"

		report_text += "<b>Generated:</b> [station_time_timestamp()]<br>"
		report_text += "<b>Generated By:</b> [safe_generated_by]<br>"
		report_text += "<b>Terminal Status:</b> [terminal_status]<br>"
		report_text += "<b>Recorded Shipments:</b> [length(network.shipments)]<br><hr><br>"

		for(var/index in start_index to end_index)
			var/datum/ccpost_shipment/shipment = network.shipments[index]

			if(!shipment || QDELETED(shipment))
				continue

			var/package_name = "UNKNOWN PACKAGE"
			var/package_cost = 0
			var/restricted_marker = ""

			if(shipment.package)
				package_name = sanitize(shipment.package.name)
				package_cost = shipment.package.cost

				if(shipment.package.contraband)
					restricted_marker = " <b>RESTRICTED</b>"

			var/requested_by = shipment.requested_by ? sanitize(shipment.requested_by) : "UNKNOWN"
			var/requested_at = shipment.requested_at ? shipment.requested_at : "N/A"
			var/updated_at = shipment.status_updated_at ? shipment.status_updated_at : "N/A"

			report_text += "<b>[shipment.shipment_code]</b>[restricted_marker]<br>"
			report_text += "Package: [package_name]<br>"
			report_text += "Cost: [package_cost] CU<br>"
			report_text += "Requested By: [requested_by]<br>"
			report_text += "Requested At: [requested_at]<br>"
			report_text += "Status: [shipment.status]<br>"
			report_text += "Last Update: [updated_at]<br>"

			if(shipment.failure_reason)
				report_text += "Failure: [sanitize(shipment.failure_reason)]<br>"

			report_text += "<br>"

		report_text += "<hr><i>Central Command Sector Logistics Coordination</i>"

		print_audit_page(
			"Central Command Shipment Audit - Page [page_number]",
			report_text
		)

		start_index = end_index + 1
		page_number++


/// Prints the allocation ledger in pages of fifteen transactions.
/obj/machinery/computer/ccpost_logistics/proc/print_allocation_ledger(
	datum/ccpost_logistics_network/network,
	generated_by
)
	if(!network)
		return

	var/safe_generated_by = generated_by ? sanitize(generated_by) : "UNKNOWN"

	var/terminal_status = contraband_unlocked ? "PROCUREMENT SAFEGUARDS COMPROMISED" : "PROCUREMENT SAFEGUARDS NOMINAL"

	var/page_size = 15
	var/page_number = 1

	if(!length(network.allocation_ledger))
		var/empty_text = "<center><b>CENTRAL COMMAND</b></center>"
		empty_text += "<center><b>OPERATIONAL ALLOCATION AUDIT</b></center><hr>"

		empty_text += "<b>Generated:</b> [station_time_timestamp()]<br>"
		empty_text += "<b>Generated By:</b> [safe_generated_by]<br>"
		empty_text += "<b>Terminal Status:</b> [terminal_status]<br><br>"

		empty_text += "<b>Current Allocation:</b> [network.allocation] / [network.max_allocation] CU<br>"
		empty_text += "<b>Reserved Allocation:</b> [network.reserved_allocation] CU<br>"
		empty_text += "<b>Available Allocation:</b> [network.get_available_allocation()] CU<br><br>"

		empty_text += "No allocation transactions have been recorded.<br>"
		empty_text += "<br><hr><i>Central Command Financial Oversight</i>"

		print_audit_page(
			"Central Command Allocation Audit",
			empty_text
		)

		return

	var/start_index = 1

	while(start_index <= length(network.allocation_ledger))
		var/end_index = min(
			start_index + page_size - 1,
			length(network.allocation_ledger)
		)

		var/report_text = "<center><b>CENTRAL COMMAND</b></center>"
		report_text += "<center><b>OPERATIONAL ALLOCATION AUDIT - PAGE [page_number]</b></center><hr>"

		report_text += "<b>Generated:</b> [station_time_timestamp()]<br>"
		report_text += "<b>Generated By:</b> [safe_generated_by]<br>"
		report_text += "<b>Terminal Status:</b> [terminal_status]<br><br>"

		report_text += "<b>Current Allocation:</b> [network.allocation] / [network.max_allocation] CU<br>"
		report_text += "<b>Reserved Allocation:</b> [network.reserved_allocation] CU<br>"
		report_text += "<b>Available Allocation:</b> [network.get_available_allocation()] CU<br>"
		report_text += "<b>Recorded Transactions:</b> [length(network.allocation_ledger)]<br><hr><br>"

		for(var/index in start_index to end_index)
			var/datum/ccpost_allocation_ledger_entry/ledger_entry = network.allocation_ledger[index]

			if(!ledger_entry)
				continue

			var/entry_time = ledger_entry.timestamp || "N/A"
			var/entry_amount = ledger_entry.amount
			var/entry_reason = ledger_entry.reason ? sanitize("[ledger_entry.reason]") : "Unspecified transaction"
			var/entry_actor = ledger_entry.actor ? sanitize("[ledger_entry.actor]") : "SYSTEM"
			var/amount_prefix = entry_amount > 0 ? "+" : ""

			report_text += "<b>[entry_time] | [amount_prefix][entry_amount] CU</b><br>"
			report_text += "Reason: [entry_reason]<br>"
			report_text += "Recorded By: [entry_actor]<br><br>"

		report_text += "<hr><i>Central Command Financial Oversight</i>"

		print_audit_page(
			"Central Command Allocation Audit - Page [page_number]",
			report_text
		)

		start_index = end_index + 1
		page_number++

/datum/ccpost_supply_package
	var/id = "undefined"
	var/name = "Undefined Supply Package"
	var/desc = "No package description available."
	var/category = "General"
	var/cost = 0

	/// Restricted packages are only visible and orderable through a compromised terminal.
	var/contraband = FALSE

	/// Internal Compliance risk weighting used when restricted procurement is audited.
	/// Harmless novelty contraband is low-risk; tactical or hostile equipment is higher-risk.
	var/audit_risk = 0

	var/list/contains = list()


/datum/ccpost_supply_package/proc/fill_crate(obj/structure/closet/crate/ccpost_freight/freight_crate)
	if(!freight_crate)
		return

	for(var/item_type in contains)
		var/amount = contains[item_type]

		if(!isnum(amount) || amount < 1)
			amount = 1

		for(var/i in 1 to amount)
			new item_type(freight_crate)

// ////////////////////////////////////
// Logistics CATALOG START
// ////////////////////////////////////

// ADMINISTRATION

/datum/ccpost_supply_package/administrative
	id = "administrative"
	name = "Administrative Supplies"
	desc = "Replacement paperwork, writing implements, and general administrative equipment."
	category = "Administration"
	cost = 4

	contains = list(
		/obj/item/paper_bin = 1,
		/obj/item/pen = 2,
		/obj/item/stamp/granted = 1,
		/obj/item/stamp/denied = 1,
		/obj/item/stamp/centcom = 1
	)

/datum/ccpost_supply_package/administrative/records
	id = "records_filing"
	name = "Records & Filing Package"
	desc = "Expanded records-management supplies for installations experiencing dangerous levels of unfiled paperwork."
	cost = 6

	contains = list(
		/obj/structure/filingcabinet/chestdrawer/wheeled = 1,
		/obj/item/hand_labeler = 1,
		/obj/item/hand_labeler_refill = 2,
		/obj/item/paper_bin = 1,
		/obj/item/paper_bin/carbon = 1,
		/obj/item/folder/blue = 1,
		/obj/item/folder/red = 1,
		/obj/item/folder/yellow = 1,
		/obj/item/clipboard = 2,
		/obj/item/storage/box/fountainpens = 1
	)


// SUSTENANCE

/datum/ccpost_supply_package/sustenance
	id = "sustenance"
	name = "Basic Sustenance Package"
	desc = "A modest selection of pre-approved meals for remote installation personnel."
	category = "Sustenance"
	cost = 5

	contains = list(
		/obj/item/food/vendor_tray_meal/side = 2,
		/obj/item/food/vendor_tray_meal/side/crackers_and_cheese = 2,
		/obj/item/food/vendor_tray_meal/sushi = 2,
		/obj/item/food/vendor_tray_meal/side/rice = 2,
		/obj/item/food/vendor_tray_meal/burger = 2,
		/obj/item/food/vendor_tray_meal/chicken_sandwich = 2,
		/obj/item/food/vendor_tray_meal = 2
	)

/datum/ccpost_supply_package/sustenance/rations
	id = "emergency_rations"
	name = "Emergency Ration Package"
	desc = "Three sealed surplus ration boxes intended for extended isolation, delayed freight, or culinary emergencies."
	cost = 4

	contains = list(
		/obj/item/storage/box/mothic_rations = 3
	)

/datum/ccpost_supply_package/sustenance/coffee
	id = "coffee_refreshments"
	name = "Coffee & Refreshments Package"
	desc = "A complete coffee-service restock for maintaining alertness, morale, and the appearance of productivity."
	cost = 6

	contains = list(
		/obj/item/storage/box/coffeepack/robusta = 1,
		/obj/item/storage/box/coffeepack = 1,
		/obj/item/reagent_containers/cup/coffeepot = 1,
		/obj/item/storage/fancy/coffee_condi_display = 1,
		/obj/item/reagent_containers/cup/glass/bottle/juice/cream = 1,
		/obj/item/reagent_containers/condiment/milk = 1,
		/obj/item/reagent_containers/condiment/soymilk = 1,
		/obj/item/reagent_containers/condiment/sugar = 1,
		/obj/item/reagent_containers/cup/bottle/syrup_bottle/caramel = 1
	)

/datum/ccpost_supply_package/sustenance/luxury
	id = "luxury_goods"
	name = "Luxury Goods Crate"
	desc = "A curated assortment of premium consumables intended for executive hospitality, visiting officials, and approved morale expenditure."
	cost = 11

	contains = list(
		/obj/item/food/moonfish_caviar = 2,
		/obj/item/storage/fancy/cigarettes/cigars/havana = 1,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 2,
		/obj/item/food/pistachios = 2
	)


// MEDICAL

/datum/ccpost_supply_package/medical
	id = "medical"
	name = "Medical Resupply Package"
	desc = "Basic medical supplies intended for routine injuries and oxygen-related emergencies."
	category = "Medical"
	cost = 8

	contains = list(
		/obj/item/storage/medkit/regular = 1,
		/obj/item/storage/medkit/o2 = 1,
		/obj/item/storage/medkit/fire = 1
	)

/datum/ccpost_supply_package/medical/trauma
	id = "medical_trauma"
	name = "Trauma Treatment Package"
	desc = "Rapid-response medication and wound-care supplies for stabilizing serious injuries before evacuation or surgery."
	cost = 7

	contains = list(
		/obj/item/reagent_containers/medipen = 2,
		/obj/item/reagent_containers/medipen/ekit = 3,
		/obj/item/reagent_containers/medipen/blood_loss = 3,
		/obj/item/stack/medical/gauze = 2
	)

/datum/ccpost_supply_package/medical/blood_fluids
	id = "medical_blood_fluids"
	name = "Blood & Fluid Resupply"
	desc = "A compact blood and saline reserve for treating blood loss and supporting emergency transfusion procedures."
	cost = 7

	contains = list(
		/obj/item/reagent_containers/blood/o_minus = 3,
		/obj/item/reagent_containers/blood/a_plus = 1,
		/obj/item/reagent_containers/blood/b_plus = 1,
		/obj/item/reagent_containers/chem_pack/saline = 3
	)

/datum/ccpost_supply_package/medical/defibrillators
	id = "medical_defibrillators"
	name = "Defibrillator Package"
	desc = "Two loaded defibrillators for installations expecting cardiac emergencies, major trauma, or questionable workplace decisions."
	cost = 9

	contains = list(
		/obj/item/defibrillator/loaded = 2
	)

/datum/ccpost_supply_package/medical/surgery
	id = "medical_surgical"
	name = "Surgical Support Package"
	desc = "A compact set of surgical supplies for emergency procedures when routine medical support is unavailable."
	cost = 10

	contains = list(
		/obj/item/storage/backpack/duffelbag/med/surgery = 1,
		/obj/item/reagent_containers/medigel/sterilizine = 1,
		/obj/item/emergency_bed = 1
	)

// ENGINEERING

/datum/ccpost_supply_package/engineering
	id = "engineering"
	name = "Engineering Maintenance Package"
	desc = "Tools and replacement materials for routine outpost maintenance."
	category = "Engineering"
	cost = 9

	contains = list(
		/obj/item/stack/sheet/mineral/plasma/twenty = 1,
		/obj/item/stack/sheet/iron/twenty = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/storage/box/lights/tubes = 1,
		/obj/item/storage/box/lights/bulbs = 1
	)

/datum/ccpost_supply_package/engineering/toolboxes
	id = "engineering_toolboxes"
	name = "Toolbox Package"
	desc = "A reserve of electrical and mechanical toolboxes for repairs, maintenance, and emergency improvisation."
	cost = 7

	contains = list(
		/obj/item/storage/toolbox/electrical = 2,
		/obj/item/storage/toolbox/mechanical = 2
	)

/datum/ccpost_supply_package/engineering/electrical
	id = "engineering_electrical"
	name = "Electrical Repair Package"
	desc = "Insulated gloves, replacement power cells, and cable for restoring damaged electrical systems."
	cost = 9

	contains = list(
		/obj/item/clothing/gloves/color/yellow = 2,
		/obj/item/stock_parts/power_store/cell/high = 3,
		/obj/item/stack/cable_coil = 2
	)

/datum/ccpost_supply_package/engineering/atmos
	id = "engineering_atmos"
	name = "Atmospheric Recovery Package"
	desc = "Portable atmospheric equipment for recovering air, clearing contaminants, and repairing avoidable ventilation mistakes."
	cost = 12

	contains = list(
		/obj/machinery/portable_atmospherics/pump = 1,
		/obj/machinery/portable_atmospherics/scrubber = 1
	)

/datum/ccpost_supply_package/engineering/breach
	id = "engineering_breach"
	name = "Hull Breach Response Package"
	desc = "Anti-breach shield projectors and metal-foam supplies for rapid containment of structural damage."
	cost = 14

	contains = list(
		/obj/machinery/shieldgen = 2,
		/obj/item/storage/box/metalfoam = 1
	)

/datum/ccpost_supply_package/engineering/power
	id = "engineering_power"
	name = "Portable Power Package"
	desc = "Portable power-induction equipment and high-capacity cells for keeping essential systems running away from fixed chargers."
	cost = 10

	contains = list(
		/obj/item/inducer/orderable = 2,
		/obj/item/stock_parts/power_store/cell/high = 2
	)


// MATERIALS

/datum/ccpost_supply_package/materials/construction
	id = "materials_construction"
	name = "Construction Materials Package"
	desc = "Bulk iron, glass, and plastic stock for routine construction, repairs, and approved installation improvements."
	category = "Materials"
	cost = 10

	contains = list(
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/sheet/plastic/fifty = 1
	)

/datum/ccpost_supply_package/materials/emergency
	id = "materials_emergency"
	name = "Emergency Repair Materials"
	desc = "Reinforced construction stock and breach-control supplies intended for significant structural damage."
	category = "Materials"
	cost = 12

	contains = list(
		/obj/item/stack/sheet/plasteel/twenty = 1,
		/obj/item/stack/sheet/iron/twenty = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/storage/box/metalfoam = 2
	)


// TECHNICAL

/datum/ccpost_supply_package/technical/advanced_parts
	id = "technical_parts"
	name = "Advanced Parts Package"
	desc = "Contains a rapid part exchanger and supporting equipment for maintaining damaged machinery."
	category = "Technical"
	cost = 12

	contains = list(
		/obj/item/storage/part_replacer = 1,
		/obj/item/stock_parts/power_store/cell/high = 5,
		/obj/item/stock_parts/matter_bin/super = 10,
		/obj/item/stock_parts/micro_laser/quadultra = 10,
		/obj/item/stock_parts/manipulator/nano = 10,
		/obj/item/stock_parts/capacitor/quadratic = 10
	)

/datum/ccpost_supply_package/technical/robotics
	id = "technical_robotics"
	name = "Robotics Utility Package"
	desc = "Basic bot assemblies, sensors, and robotic components for constructing simple support machines."
	category = "Technical"
	cost = 15

	contains = list(
		/obj/item/assembly/prox_sensor = 4,
		/obj/item/bodypart/arm/left/robot = 4,
		/obj/item/healthanalyzer = 1,
		/obj/item/clothing/head/utility/hardhat = 1,
		/obj/item/bot_assembly/floorbot = 1,
		/obj/item/bot_assembly/firebot = 1,
		/obj/item/bot_assembly/medbot = 1,
		/obj/item/bot_assembly/cleanbot = 1
	)


// EMERGENCY

/datum/ccpost_supply_package/eva
	id = "eva"
	name = "Emergency EVA Package"
	desc = "Basic equipment for emergency operations in depressurized environments."
	category = "Emergency"
	cost = 12

	contains = list(
		/obj/item/clothing/suit/space = 1,
		/obj/item/clothing/head/helmet/space = 1,
		/obj/item/tank/internals/oxygen = 1,
		/obj/item/clothing/mask/breath = 1
	)

/datum/ccpost_supply_package/emergency/firefighting
	id = "emergency_firefighting"
	name = "Firefighting Package"
	desc = "Protective equipment and extinguishing gear for responding to major fires and heat hazards."
	category = "Emergency"
	cost = 10

	contains = list(
		/obj/item/clothing/suit/utility/fire/firefighter = 2,
		/obj/item/clothing/mask/gas = 2,
		/obj/item/flashlight = 2,
		/obj/item/tank/internals/oxygen/yellow = 2,
		/obj/item/extinguisher/advanced = 2,
		/obj/item/clothing/head/utility/hardhat/fire = 2,
		/obj/item/clothing/gloves/color/black = 2
	)

/datum/ccpost_supply_package/emergency/internals
	id = "emergency_internals"
	name = "Emergency Internals Package"
	desc = "Breathing masks and portable oxygen supplies for atmospheric emergencies and evacuation."
	category = "Emergency"
	cost = 7

	contains = list(
		/obj/item/clothing/mask/gas = 3,
		/obj/item/clothing/mask/breath = 3,
		/obj/item/tank/internals/emergency_oxygen = 3,
		/obj/item/tank/internals/oxygen = 3
	)

/datum/ccpost_supply_package/emergency/mass_casualty
	id = "emergency_mass_casualty"
	name = "Mass Casualty Package"
	desc = "A broad medical reserve intended for incidents producing more casualties than the outpost's routine stock can comfortably support."
	category = "Emergency"
	cost = 15

	contains = list(
		/obj/item/storage/medkit/regular = 1,
		/obj/item/storage/medkit/o2 = 1,
		/obj/item/storage/medkit/toxin = 1,
		/obj/item/storage/medkit/brute = 1,
		/obj/item/storage/medkit/fire = 1,
		/obj/item/defibrillator/loaded = 1,
		/obj/item/storage/box/bodybags = 1,
		/obj/item/stack/medical/gauze = 2
	)


// SECURITY

/datum/ccpost_supply_package/security
	id = "security"
	name = "Security Support Package"
	desc = "Limited defensive equipment intended for protection of Central Command personnel and property."
	category = "Security"
	cost = 18

	contains = list(
		/obj/item/clothing/suit/armor/vest/alt/sec/private = 2,
		/obj/item/clothing/head/helmet/swat/nanotrasen = 2,
		/obj/item/gun/energy/e_gun/mini = 2,
		/obj/item/clothing/gloves/combat = 2
	)

/datum/ccpost_supply_package/security/nonlethal
	id = "security_nonlethal"
	name = "Non-Lethal Response Package"
	desc = "Additional restraint and incapacitation equipment intended for defensive response without lethal escalation."
	cost = 12

	contains = list(
		/obj/item/gun/energy/disabler = 2,
		/obj/item/melee/baton/security/loaded = 2,
		/obj/item/storage/box/handcuffs = 1
	)

/datum/ccpost_supply_package/security/protective
	id = "security_protective"
	name = "Protective Equipment Package"
	desc = "Standard armor and protective equipment for reinforcing outpost security during elevated threats."
	cost = 15

	contains = list(
		/obj/item/clothing/suit/armor/vest = 2,
		/obj/item/clothing/head/helmet/sec = 2,
		/obj/item/clothing/gloves/combat = 2
	)

/datum/ccpost_supply_package/security/containment
	id = "security_containment"
	name = "Biological Containment Package"
	desc = "Protective suits, pathology equipment, and portable barriers for isolating suspected biological hazards."
	cost = 14

	contains = list(
		/obj/item/clothing/head/bio_hood/security = 2,
		/obj/item/clothing/suit/bio_suit/security = 2,
		/obj/item/reagent_containers/syringe/antiviral = 2,
		/obj/item/clothing/gloves/latex/nitrile = 2,
		/obj/item/clothing/glasses/pathology = 2,
		/obj/item/holosign_creator/medical = 2
	)


// ENTERTAINMENT

/datum/ccpost_supply_package/entertainment/bunny
	id = "entertainment_centcom_bunny"
	name = "CentCom Bunny Attire Package"
	desc = "A complete set of approved Central Command hospitality attire for formal receptions, morale initiatives, and other duties which Human Resources has declined to explain."
	category = "Entertainment"
	cost = 8

	contains = list(
		/obj/item/clothing/under/costume/playbunny/centcom = 1,
		/obj/item/clothing/suit/jacket/tailcoat/centcom = 1,
		/obj/item/clothing/shoes/heels/centcom = 1,
		/obj/item/clothing/head/playbunnyears/centcom = 1,
		/obj/item/clothing/neck/tie/bunnytie/centcom/tied = 1,
		/obj/item/clothing/gloves/color/white = 1
	)

/datum/ccpost_supply_package/entertainment/cards
	id = "entertainment_cards"
	name = "Card & Table Games Package"
	desc = "Cards, dice, and a company-approved tabletop diversion for personnel with sufficient unallocated time."
	category = "Entertainment"
	cost = 4

	contains = list(
		/obj/item/toy/cards/deck = 2,
		/obj/item/dice/d6 = 12,
		/obj/item/paper/guides/knucklebone = 1,
		/obj/item/toy/crayon/white = 1
	)

/datum/ccpost_supply_package/entertainment/lasertag
	id = "entertainment_lasertag"
	name = "Laser Tag Recreation Package"
	desc = "Two complete opposing laser-tag teams for structured recreational conflict that is considerably cheaper than actual security incidents."
	category = "Entertainment"
	cost = 7

	contains = list(
		/obj/item/gun/energy/laser/redtag = 2,
		/obj/item/gun/energy/laser/bluetag = 2,
		/obj/item/clothing/suit/redtag = 2,
		/obj/item/clothing/suit/bluetag = 2,
		/obj/item/clothing/head/helmet/redtaghelm = 2,
		/obj/item/clothing/head/helmet/bluetaghelm = 2
	)

/datum/ccpost_supply_package/entertainment/morale
	id = "entertainment_morale"
	name = "Corporate Morale Package"
	desc = "A pre-approved assortment of recreational materials intended to maintain employee morale without meaningfully impacting productivity."
	category = "Entertainment"
	cost = 6

	contains = list(
		/obj/item/storage/box/balloons = 1,
		/obj/item/pinata = 1,
		/obj/item/melee/baseball_bat = 1,
		/obj/item/clothing/glasses/blindfold = 1,
		/obj/item/flashlight/glowstick = 2,
		/obj/item/flashlight/glowstick/blue = 1,
		/obj/item/flashlight/glowstick/cyan = 1
	)

/datum/ccpost_supply_package/entertainment/music
	id = "entertainment_music"
	name = "Music & Leisure Package"
	desc = "A selection of portable musical instruments for sanctioned recreation and unsanctioned hallway concerts."
	category = "Entertainment"
	cost = 8

	contains = list(
		/obj/item/instrument/violin = 1,
		/obj/item/instrument/guitar = 1,
		/obj/item/instrument/accordion = 1,
		/obj/item/instrument/saxophone = 1,
		/obj/item/instrument/recorder = 1,
		/obj/item/instrument/harmonica = 1
	)

/datum/ccpost_supply_package/entertainment/formal
	id = "entertainment_formal"
	name = "Formal Social Package"
	desc = "A small wardrobe of formal clothing suitable for receptions, ceremonies, and meetings where appearing expensive is operationally useful."
	category = "Entertainment"
	cost = 8

	contains = list(
		/obj/item/clothing/under/suit/black_really = 2,
		/obj/item/clothing/under/suit/black_really/skirt = 2,
		/obj/item/clothing/accessory/waistcoat = 2,
		/obj/item/clothing/neck/tie/blue = 1,
		/obj/item/clothing/neck/tie/red = 1,
		/obj/item/clothing/neck/tie/black = 1,
		/obj/item/clothing/head/hats/bowler = 1,
		/obj/item/clothing/head/hats/tophat = 1,
		/obj/item/clothing/shoes/laceup = 2
	)

/datum/ccpost_supply_package/entertainment/costumes
	id = "entertainment_costumes"
	name = "Costume Package"
	desc = "An assortment of harmless theatrical costumes for morale events, dramatic reenactments, and regrettable photographs."
	category = "Entertainment"
	cost = 6

	contains = list(
		/obj/item/clothing/head/costume/snowman = 1,
		/obj/item/clothing/suit/costume/snowman = 1,
		/obj/item/clothing/head/costume/chicken = 1,
		/obj/item/clothing/suit/costume/chickensuit = 1,
		/obj/item/clothing/mask/gas/monkeymask = 1,
		/obj/item/clothing/suit/costume/monkeysuit = 1,
		/obj/item/clothing/suit/hooded/bee_costume = 1
	)

/datum/ccpost_supply_package/entertainment/plushies
	id = "entertainment_plushies"
	name = "Plushie Assortment"
	desc = "A selection of soft corporate-approved companions for isolated personnel, decorative use, and entirely professional desk arrangements."
	category = "Entertainment"
	cost = 5

	contains = list(
		/obj/item/toy/plush/carpplushie = 1,
		/obj/item/toy/plush/slimeplushie = 1,
		/obj/item/toy/plush/lizard_plushie/greyscale = 1,
		/obj/item/toy/plush/snakeplushie = 1,
		/obj/item/toy/plush/moth = 1,
		/obj/item/toy/plush/beeplushie = 1
	)


// CONTRABAND

/datum/ccpost_supply_package/contraband
	category = "Restricted"
	contraband = TRUE

/datum/ccpost_supply_package/contraband/ert_equipment
	audit_risk = 5
	id = "ert_equipment"
	name = "Emergency Response Team Equipment"
	desc = "Unregistered Emergency Response Team equipment routed through an unauthorized Central Command procurement channel."
	cost = 45
	contains = list(
		/obj/item/storage/box/emps = 1,
		/obj/item/storage/belt/security = 1,
		/obj/item/gun/ballistic/revolver/mateba = 1,
		/obj/item/ammo_box/a357 = 1,
		/obj/item/clothing/glasses/hud/security/night = 1,
		/obj/item/restraints/handcuffs = 2,
		/obj/item/clothing/gloves/combat = 1,
		/obj/item/clothing/suit/space/ert = 1,
		/obj/item/clothing/head/helmet/space/ert = 1
	)

/datum/ccpost_supply_package/contraband/restricted_uniform
	audit_risk = 3
	id = "restricted_uniform"
	name = "Restricted Personnel Uniforms"
	desc = "Personnel Uniforms absent from the installation's approved equipment manifest."
	cost = 30

	contains = list(
		/obj/item/clothing/under/rank/centcom/admiral = 1,
		/obj/item/clothing/suit/armor/centcom_admiral = 1,
		/obj/item/clothing/head/hats/warden/drill/centcom_admiral = 1,
		/obj/item/clothing/shoes/combat/swat/admiral = 2,
		/obj/item/clothing/gloves/tackler/combat/insulated/admiral = 2,
		/obj/item/clothing/head/hats/centcom_cap = 1,
		/obj/item/clothing/under/rank/centcom/commander = 1,
		/obj/item/clothing/under/rank/centcom/commander/skirt = 1
	)

/datum/ccpost_supply_package/contraband/restricted_costume
	audit_risk = 1
	id = "restricted_costume"
	name = "Black-Market Costume Crate"
	desc = "An assortment of unlicensed, politically questionable, and otherwise unauthorized costumes acquired through procurement channels that officially do not exist. Central Command assumes no responsibility for disciplinary action, mistaken identity, or hostile reactions resulting from their use."
	cost = 10
	contains = list(
		/obj/item/clothing/head/syndicatefake = 1,
		/obj/item/clothing/suit/syndicatefake = 1,
		/obj/item/disk/nuclear/fake/obvious = 1,
		/obj/item/clothing/head/wizard/fake = 1,
		/obj/item/clothing/suit/wizrobe/fake = 1,
		/obj/item/clothing/shoes/sandal = 1,
		/obj/item/poster/random_contraband = 5
	)

/datum/ccpost_supply_package/contraband/restricted_exec
	audit_risk = 1
	id = "restricted_exec"
	name = "Executive Vice Package"
	desc = "A discreet selection of premium indulgences intended for executives, dignitaries, and personnel with sufficiently flexible expense accounts. Contents may include comforts not covered under standard operational provisioning."
	cost = 8

	contains = list(
		/obj/item/storage/fancy/cigarettes/cigars/havana = 1,
		/obj/item/storage/fancy/cigarettes/cigars/cohiba = 1,
		/obj/item/storage/pipebox/fancy = 1,
		/obj/item/reagent_containers/cup/glass/bottle/absinthe/premium = 1,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 1,
		/obj/item/reagent_containers/cup/glass/bottle/cognac = 1,
		/obj/item/reagent_containers/cup/glass/bottle/navy_rum = 1,
		/obj/item/reagent_containers/cup/glass/bottle/applejack = 1
	)

/datum/ccpost_supply_package/contraband/restricted_decor
	audit_risk = 1
	id = "restricted_decor"
	name = "Unapproved Exotic Decor"
	desc = "A collection of lavish and impractical furnishings sourced through unapproved procurement channels. Perfect for personnel who believe operational efficiency improves dramatically when surrounded by expensive carpet, questionable art, and décor that definitely was not included in the original budget."
	cost = 8

	contains = list(
		/obj/item/stack/tile/carpet/executive/thirty = 1,
		/obj/item/stack/tile/carpet/royalblack/fifty = 1,
		/obj/item/stack/tile/carpet/royalblue/fifty = 1,
		/obj/item/stack/tile/carpet/stellar/thirty = 1,
		/obj/item/statuebust = 2,
		/obj/item/cardboard_cutout = 3,
		/obj/item/storage/crayons = 1,
		/obj/item/wallframe/painting/eldritch/weeping = 1,
		/obj/item/wallframe/painting/eldritch/beauty = 1
	)

/datum/ccpost_supply_package/contraband/restricted_recovequip
	audit_risk = 6
	id = "restricted_recovequip"
	name = "Recovered Syndicate Equipment"
	desc = "A sealed assortment of equipment recovered from Syndicate personnel, caches, and compromised operations. Items have been cleared for controlled redistribution through channels that Internal Security would strongly prefer you not ask about."
	cost = 50

	contains = list(
		/obj/item/clothing/mask/gas/syndicate = 1,
		/obj/item/clothing/under/syndicate/unarmoured = 1,
		/obj/item/clothing/under/syndicate/unarmoured/skirt = 1,
		/obj/item/storage/medkit/hypospray/syndicate = 1,
		/obj/item/storage/toolbox/syndicate = 1,
		/obj/item/toy/cards/deck/syndicate = 1,
		/obj/item/toy/balloon/syndicate = 1,
		/obj/item/autosurgeon/syndicate/thermal_eyes = 1,
		/obj/item/card/id/advanced/chameleon = 1
	)

/datum/ccpost_supply_package/contraband/restricted_party
	audit_risk = 2
	id = "restricted_party"
	name = "Unauthorized Party Supplies"
	desc = "An unapproved assortment of celebratory supplies acquired outside standard procurement channels. Contents are intended for morale events, unofficial gatherings, and other festivities that Finance has already declined to reimburse."
	cost = 8

	contains = list(
		/obj/item/storage/box/party_poppers = 1,
		/obj/item/gun/ballistic/revolver/russian = 1,
		/obj/item/pneumatic_cannon/pie = 1,
		/obj/item/food/pie/cream = 3,
		/obj/item/bot_assembly/honkbot = 1,
		/obj/item/stamp/clown = 1,
		/obj/item/bikehorn = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/bodypart/arm/left/robot = 1,
		/obj/effect/spawner/random/decoration/glowstick = 3,
		/obj/machinery/jukebox/disco = 1,
		/obj/item/storage/box/balloons = 1
	)


// ////////////////////////////////////
// Logistics CATALOG END
// ////////////////////////////////////

/datum/ccpost_shipment
	var/shipment_code
	var/datum/ccpost_supply_package/package

	var/requested_by = "UNKNOWN"
	var/requested_at

	var/status = CCPOST_SHIPMENT_QUEUED
	var/status_updated_at

	var/authorized_at
	var/dispatched_at
	var/delivered_at

	var/authorization_delay
	var/dispatch_delay
	var/transit_delay

	/// World time at which the current shipment stage should finish.
	var/stage_ends_at = 0

	var/freight_condition_status = "NORMAL"
	var/list/freight_condition_reasons = list()

	var/freight_spawned = FALSE
	var/failure_reason

// Actual sector-aware order lifecycle

/datum/ccpost_logistics_network/proc/get_status_display_shipment()
	var/datum/ccpost_shipment/selected_shipment
	var/selected_priority = 0
	var/selected_stage_end = 0

	for(var/datum/ccpost_shipment/shipment as anything in shipments)
		if(QDELETED(shipment))
			continue

		if(shipment.status == CCPOST_SHIPMENT_DELIVERED)
			continue

		if(shipment.status == CCPOST_SHIPMENT_FAILED)
			continue

		var/shipment_priority = 0

		if(shipment.freight_spawned)
			shipment_priority = 4

		else
			switch(shipment.status)
				if(CCPOST_SHIPMENT_IN_TRANSIT)
					shipment_priority = 3

				if(CCPOST_SHIPMENT_AUTHORIZED)
					shipment_priority = 2

				if(CCPOST_SHIPMENT_QUEUED)
					shipment_priority = 1

		if(!shipment_priority)
			continue

		if(!selected_shipment)
			selected_shipment = shipment
			selected_priority = shipment_priority
			selected_stage_end = shipment.stage_ends_at
			continue

		if(shipment_priority > selected_priority)
			selected_shipment = shipment
			selected_priority = shipment_priority
			selected_stage_end = shipment.stage_ends_at
			continue

		if(shipment_priority == selected_priority)
			if(shipment.stage_ends_at && (!selected_stage_end || shipment.stage_ends_at < selected_stage_end))
				selected_shipment = shipment
				selected_stage_end = shipment.stage_ends_at

	return selected_shipment

// CENTRAL COMMAND LOGISTICS STATUS DISPLAY

/obj/machinery/status_display/ccpost_logistics
	name = "Central Command freight display"
	desc = "A wall-mounted Central Command Logistics display showing the status of incoming freight requisitions."
	current_mode = SD_MESSAGE
	text_color = COLOR_DISPLAY_ORANGE
	header_text_color = COLOR_DISPLAY_YELLOW

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/status_display/ccpost_logistics, 32)

/obj/machinery/status_display/ccpost_logistics/Initialize(mapload)
	. = ..()
	GLOB.ccpost_logistics_network.register_status_display(src)

/obj/machinery/status_display/ccpost_logistics/Destroy()
	GLOB.ccpost_logistics_network.unregister_status_display(src)
	return ..()

/obj/machinery/status_display/ccpost_logistics/process()
	if(machine_stat & (NOPOWER | BROKEN))
		update_appearance()
		return PROCESS_KILL

	var/datum/ccpost_shipment/shipment = GLOB.ccpost_logistics_network.get_status_display_shipment()

	if(!shipment)
		set_messages("CC LOGISTICS", "STANDBY")
		return PROCESS_KILL

	var/line1
	var/line2

	switch(shipment.status)
		if(CCPOST_SHIPMENT_QUEUED)
			line1 = "QUEUED"
			line2 = get_shipment_timer_text(shipment)

		if(CCPOST_SHIPMENT_AUTHORIZED)
			line1 = "AUTHORIZED"
			line2 = get_shipment_timer_text(shipment)

		if(CCPOST_SHIPMENT_IN_TRANSIT)
			if(shipment.freight_spawned)
				line1 = "ARRIVING"
				line2 = "FREIGHT BAY"
			else
				line1 = "IN TRANSIT"
				line2 = get_shipment_timer_text(shipment)

		else
			line1 = "CC LOGISTICS"
			line2 = "STANDBY"

	set_messages(line1, line2)

/obj/machinery/status_display/ccpost_logistics/proc/get_shipment_timer_text(datum/ccpost_shipment/shipment)
	if(!shipment || !shipment.stage_ends_at)
		return "--:--"

	var/time_remaining = max(0, round((shipment.stage_ends_at - world.time) / (1 SECONDS)))
	var/seconds = time_remaining % 60
	var/minutes = (time_remaining - seconds) / 60

	return "[add_leading(num2text(minutes), 2, "0")]:[add_leading(num2text(seconds), 2, "0")]"

/datum/ccpost_logistics_network/proc/create_shipment(package_id, requester_name, allow_contraband = FALSE)
	var/datum/ccpost_supply_package/package = get_supply_package(package_id)

	if(!package)
		return null

	if(package.contraband && !allow_contraband)
		return null

	if(package.contraband && is_restricted_procurement_suspended())
		return null

	if(get_active_shipment_count() >= max_active_shipments)
		return null

	if(!reserve_allocation(package.cost))
		return null

	var/datum/ccpost_freight_conditions/current_conditions = get_current_freight_conditions()

	var/datum/ccpost_shipment/shipment = new

	shipment.shipment_code = generate_shipment_code()
	shipment.package = package
	shipment.requested_by = requester_name
	shipment.requested_at = station_time_timestamp()
	shipment.status = CCPOST_SHIPMENT_QUEUED
	shipment.status_updated_at = station_time_timestamp()

	shipment.authorization_delay = current_conditions.authorization_delay
	shipment.dispatch_delay = current_conditions.dispatch_delay
	shipment.transit_delay = current_conditions.get_transit_delay()
	shipment.stage_ends_at = world.time + shipment.authorization_delay

	shipment.freight_condition_status = current_conditions.status
	shipment.freight_condition_reasons = current_conditions.reasons.Copy()

	qdel(current_conditions)

	shipments.Insert(1, shipment)

	// Restricted procurement is still recorded by the logistics network even
	// when the local terminal safeguards have been bypassed. The next available
	// tasking cycle will schedule a compliance audit.
	if(package.contraband)
		contraband_requisition_count++
		contraband_compliance_points += max(1, package.audit_risk)
		contraband_audit_pending = TRUE

	var/sector_suffix = ""

	if(shipment.freight_condition_status != "NORMAL")
		sector_suffix = " Current sector freight status: [shipment.freight_condition_status]."

	announce_freight_status("Requisition [shipment.shipment_code] for [package.name] has been queued for review.[sector_suffix]")

	refresh_logistics_outputs()

	addtimer(CALLBACK(src, PROC_REF(authorize_shipment), shipment), shipment.authorization_delay)

	return shipment


/datum/ccpost_logistics_network/proc/authorize_shipment(datum/ccpost_shipment/shipment)
	if(QDELETED(shipment))
		return

	if(shipment.status != CCPOST_SHIPMENT_QUEUED)
		return

	if(!shipment.package)
		return

	if(!commit_reserved_allocation(
		shipment.package.cost,
		"Requisition [shipment.shipment_code]: [shipment.package.name]",
		shipment.requested_by
	))
		shipment.status = CCPOST_SHIPMENT_FAILED
		shipment.failure_reason = "Operational allocation could not be committed."
		shipment.status_updated_at = station_time_timestamp()
		shipment.stage_ends_at = 0

		announce_freight_status("Requisition [shipment.shipment_code] could not be authorized due to an allocation processing error.")

		refresh_logistics_outputs()

		return

	shipment.status = CCPOST_SHIPMENT_AUTHORIZED
	shipment.authorized_at = station_time_timestamp()
	shipment.status_updated_at = station_time_timestamp()
	shipment.stage_ends_at = world.time + shipment.dispatch_delay

	announce_freight_status("Requisition [shipment.shipment_code] has been authorized. [shipment.package.cost] CU has been committed.")

	refresh_logistics_outputs()

	addtimer(CALLBACK(src, PROC_REF(mark_shipment_in_transit), shipment), shipment.dispatch_delay)


/datum/ccpost_logistics_network/proc/mark_shipment_in_transit(datum/ccpost_shipment/shipment)
	if(QDELETED(shipment))
		return

	if(shipment.status != CCPOST_SHIPMENT_AUTHORIZED)
		return

	shipment.status = CCPOST_SHIPMENT_IN_TRANSIT
	shipment.dispatched_at = station_time_timestamp()
	shipment.status_updated_at = station_time_timestamp()
	shipment.stage_ends_at = world.time + shipment.transit_delay

	var/transit_seconds = round(shipment.transit_delay / (1 SECONDS))

	announce_freight_status("Shipment [shipment.shipment_code] is now in transit to this installation. Estimated freight routing time: [transit_seconds] seconds.")

	refresh_logistics_outputs()

	addtimer(CALLBACK(src, PROC_REF(dispatch_inbound_freight), shipment), shipment.transit_delay)


/datum/ccpost_logistics_network/proc/dispatch_inbound_freight(datum/ccpost_shipment/shipment)
	if(QDELETED(shipment))
		return

	if(shipment.status != CCPOST_SHIPMENT_IN_TRANSIT)
		return

	if(shipment.freight_spawned)
		return

	if(inbound_lane_busy)
		addtimer(CALLBACK(src, PROC_REF(dispatch_inbound_freight), shipment), CCPOST_SHIPMENT_RETRY_DELAY)
		return

	if(!length(inbound_spawns))
		addtimer(CALLBACK(src, PROC_REF(dispatch_inbound_freight), shipment), CCPOST_SHIPMENT_RETRY_DELAY)
		return

	var/obj/effect/ccpost_freight_point/inbound_spawn/spawn_point = pick(inbound_spawns)

	if(QDELETED(spawn_point))
		addtimer(CALLBACK(src, PROC_REF(dispatch_inbound_freight), shipment), CCPOST_SHIPMENT_RETRY_DELAY)
		return

	var/turf/spawn_turf = get_turf(spawn_point)

	if(!spawn_turf)
		addtimer(CALLBACK(src, PROC_REF(dispatch_inbound_freight), shipment), CCPOST_SHIPMENT_RETRY_DELAY)
		return

	var/obj/structure/closet/crate/ccpost_freight/freight_crate = new(spawn_turf)

	freight_crate.shipment_code = shipment.shipment_code
	freight_crate.name = "Central Command freight container ([shipment.shipment_code])"

	shipment.package.fill_crate(freight_crate)

	inbound_lane_busy = TRUE

	if(!set_ccpost_conveyor_state(CCPOST_FREIGHT_INBOUND_ID, TRUE))
		inbound_lane_busy = FALSE
		qdel(freight_crate)

		addtimer(CALLBACK(src, PROC_REF(dispatch_inbound_freight), shipment), CCPOST_SHIPMENT_RETRY_DELAY)

		return

	shipment.freight_spawned = TRUE
	shipment.stage_ends_at = 0

	refresh_logistics_outputs()


/datum/ccpost_logistics_network/proc/mark_shipment_delivered(shipment_code)
	var/datum/ccpost_shipment/shipment = find_shipment(shipment_code)

	if(!shipment)
		return FALSE

	if(shipment.status != CCPOST_SHIPMENT_IN_TRANSIT)
		return FALSE

	shipment.status = CCPOST_SHIPMENT_DELIVERED
	shipment.delivered_at = station_time_timestamp()
	shipment.status_updated_at = station_time_timestamp()
	shipment.stage_ends_at = 0

	inbound_lane_busy = FALSE

	announce_freight_status("Shipment [shipment.shipment_code], [shipment.package.name], has arrived at the designated freight intake.")

	refresh_logistics_outputs()

	return TRUE

#undef CCPOST_FREIGHT_INBOUND_ID
#undef CCPOST_FREIGHT_OUTBOUND_ID
#undef CCPOST_STARTING_ALLOCATION
#undef CCPOST_MAX_ALLOCATION
#undef CCPOST_FREIGHT_RETURN_VALUE
#undef CCPOST_SHIPMENT_QUEUED
#undef CCPOST_SHIPMENT_AUTHORIZED
#undef CCPOST_SHIPMENT_IN_TRANSIT
#undef CCPOST_SHIPMENT_DELIVERED
#undef CCPOST_SHIPMENT_FAILED
#undef CCPOST_MAX_ACTIVE_SHIPMENTS
#undef CCPOST_BASE_AUTHORIZATION_DELAY
#undef CCPOST_BASE_DISPATCH_DELAY
#undef CCPOST_BASE_TRANSIT_DELAY
#undef CCPOST_SHIPMENT_RETRY_DELAY
#undef CCPOST_SUPPLY_CATEGORY_MEDICAL
