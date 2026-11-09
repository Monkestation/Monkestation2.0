
#define CCPOST_FREIGHT_INBOUND_ID "ccpost_freight_in"
#define CCPOST_FREIGHT_OUTBOUND_ID "ccpost_freight_out"

#define CCPOST_STARTING_ALLOCATION 30
#define CCPOST_MAX_ALLOCATION 100
#define CCPOST_FREIGHT_RETURN_VALUE 2



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

#define CCPOST_FREIGHT_STATUS_NORMAL "NORMAL"
#define CCPOST_FREIGHT_STATUS_DEGRADED "DEGRADED"
#define CCPOST_FREIGHT_STATUS_PRIORITY "PRIORITY"
#define CCPOST_FREIGHT_STATUS_MIXED "MIXED"

#define CCPOST_INSTALLATION_MAINTENANCE "MAINTENANCE"
#define CCPOST_INSTALLATION_UNDER_REVIEW "UNDER REVIEW"
#define CCPOST_INSTALLATION_COMMS_DEGRADED "COMMUNICATIONS DEGRADED"
#define CCPOST_INSTALLATION_NO_CONTACT "NO CONTACT"
#define CCPOST_INSTALLATION_OFFLINE "OFFLINE"
#define CCPOST_INSTALLATION_CRITICAL "CRITICAL"

#define CCPOST_INSTALLATION_CODE_REL_A17 "NT-REL-A17"
#define CCPOST_INSTALLATION_CODE_ADM_06 "NT-ADM-06"
#define CCPOST_INSTALLATION_CODE_LOG_H09 "NT-LOG-H09"

#define CCPOST_SUPPLY_CATEGORY_ADMINISTRATION "Administration"
#define CCPOST_SUPPLY_CATEGORY_SUSTENANCE "Sustenance"
#define CCPOST_SUPPLY_CATEGORY_MEDICAL "Medical"
#define CCPOST_SUPPLY_CATEGORY_ENGINEERING "Engineering"
#define CCPOST_SUPPLY_CATEGORY_MATERIALS "Materials"
#define CCPOST_SUPPLY_CATEGORY_TECHNICAL "Technical"
#define CCPOST_SUPPLY_CATEGORY_EMERGENCY "Emergency"
#define CCPOST_SUPPLY_CATEGORY_SECURITY "Security"
#define CCPOST_SUPPLY_CATEGORY_ENTERTAINMENT "Entertainment"
#define CCPOST_SUPPLY_CATEGORY_RESTRICTED "Restricted"


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
	var/status = CCPOST_FREIGHT_STATUS_NORMAL

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
		status = CCPOST_FREIGHT_STATUS_MIXED

	else if(degraded)
		status = CCPOST_FREIGHT_STATUS_DEGRADED

	else if(priority)
		status = CCPOST_FREIGHT_STATUS_PRIORITY

	else
		status = CCPOST_FREIGHT_STATUS_NORMAL

// Checks conditions of other installations within the sector, which has an affect on freight

/datum/ccpost_logistics_network/proc/apply_installation_loss_freight_effects(
	datum/ccpost_freight_conditions/conditions,
	datum/ccpost_supply_package/package = null
)
	if(!conditions)
		return

	var/datum/ccpost_sector_network/sector_network = GLOB.ccpost_sector_network

	if(!sector_network)
		return

	for(var/datum/ccpost_sector_installation/installation as anything in sector_network.sector_installations)
		if(QDELETED(installation) || !installation.destroyed)
			continue

		var/datum/ccpost_installation_loss_effect/effect = installation.loss_effect

		if(!effect || !effect.has_logistics_effect())
			continue

		// Category-specific losses affect only matching shipments. The top-level
		// Logistics status remains a sector-wide overview, so those effects are
		// evaluated when a concrete package is actually requisitioned.
		if(length(effect.logistics_categories))
			if(!package || !(package.category in effect.logistics_categories))
				continue

		conditions.authorization_delay += effect.logistics_authorization_delay
		conditions.dispatch_delay += effect.logistics_dispatch_delay
		conditions.transit_multiplier *= effect.logistics_transit_multiplier

		if(effect.summary)
			conditions.add_reason("[installation.installation_name] has been lost. [effect.summary]")


/datum/ccpost_logistics_network/proc/get_current_freight_conditions(datum/ccpost_supply_package/package = null)
	var/datum/ccpost_freight_conditions/conditions = new

	var/datum/ccpost_sector_network/sector_network = GLOB.ccpost_sector_network

	if(!sector_network)
		conditions.finalize_status()
		return conditions

	sector_network.ensure_started()
	apply_installation_loss_freight_effects(conditions, package)

	// Communications reliability affects authorization.

	var/datum/ccpost_sector_installation/relay = sector_network.get_installation_by_code(CCPOST_INSTALLATION_CODE_REL_A17)

	if(relay && !relay.destroyed)
		switch(relay.status)
			if(CCPOST_INSTALLATION_COMMS_DEGRADED)
				conditions.authorization_delay += 5 SECONDS
				conditions.add_reason("Relay Station A-17 is reporting degraded communications.")

			if(CCPOST_INSTALLATION_NO_CONTACT, CCPOST_INSTALLATION_OFFLINE)
				conditions.authorization_delay += 10 SECONDS
				conditions.add_reason("Relay Station A-17 is unavailable. Authorization traffic is using alternate routes.")

			if(CCPOST_INSTALLATION_CRITICAL)
				conditions.authorization_delay += 15 SECONDS
				conditions.add_reason("Relay Station A-17 is experiencing a critical operational incident.")


	// Administrative processing affects authorization.

	var/datum/ccpost_sector_installation/administrative_annex = sector_network.get_installation_by_code(CCPOST_INSTALLATION_CODE_ADM_06)

	if(administrative_annex && !administrative_annex.destroyed)
		switch(administrative_annex.status)
			if(CCPOST_INSTALLATION_UNDER_REVIEW)
				conditions.authorization_delay += 5 SECONDS
				conditions.add_reason("Administrative Annex 6 is under Central Command review.")

			if(CCPOST_INSTALLATION_COMMS_DEGRADED)
				conditions.authorization_delay += 5 SECONDS
				conditions.add_reason("Administrative Annex 6 is experiencing communications degradation.")

			if(CCPOST_INSTALLATION_NO_CONTACT, CCPOST_INSTALLATION_OFFLINE)
				conditions.authorization_delay += 10 SECONDS
				conditions.add_reason("Administrative Annex 6 is unavailable. Requisition processing has been rerouted.")

			if(CCPOST_INSTALLATION_CRITICAL)
				conditions.authorization_delay += 15 SECONDS
				conditions.add_reason("Administrative Annex 6 is experiencing a critical operational incident.")


	// This is the installation most directly involved in freight.

	var/datum/ccpost_sector_installation/logistics_station = sector_network.get_installation_by_code(CCPOST_INSTALLATION_CODE_LOG_H09)

	if(logistics_station && !logistics_station.destroyed)
		switch(logistics_station.status)
			if(CCPOST_INSTALLATION_MAINTENANCE)
				conditions.dispatch_delay += 5 SECONDS
				conditions.transit_multiplier *= 1.15
				conditions.add_reason("Logistics Station H-9 is undergoing maintenance.")

			if(CCPOST_INSTALLATION_COMMS_DEGRADED)
				conditions.dispatch_delay += 5 SECONDS
				conditions.transit_multiplier *= 1.25
				conditions.add_reason("Logistics Station H-9 is reporting degraded communications.")

			if(CCPOST_INSTALLATION_NO_CONTACT)
				conditions.dispatch_delay += 10 SECONDS
				conditions.transit_multiplier *= 1.4
				conditions.add_reason("Contact with Logistics Station H-9 has been lost. Freight is being rerouted.")

			if(CCPOST_INSTALLATION_OFFLINE)
				conditions.dispatch_delay += 15 SECONDS
				conditions.transit_multiplier *= 1.5
				conditions.add_reason("Logistics Station H-9 is offline. Alternate freight infrastructure is in use.")

			if(CCPOST_INSTALLATION_CRITICAL)
				conditions.dispatch_delay += 20 SECONDS
				conditions.transit_multiplier *= 1.75
				conditions.add_reason("Logistics Station H-9 is experiencing a critical operational incident.")



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
			playsound(terminal, 'sound/machines/terminal/terminal_alert.ogg', 30, TRUE)

		terminal.say(message)


/// Generates the next unique Central Command freight shipment number.
/datum/ccpost_logistics_network/proc/generate_shipment_code()
	var/round_identifier = GLOB.round_id ? GLOB.round_id : "LOCAL"
	var/shipment_code = "CC-LG-[round_identifier]-[next_shipment_number]"

	next_shipment_number++

	return shipment_code


GLOBAL_DATUM_INIT(ccpost_logistics_network, /datum/ccpost_logistics_network, new)




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



/obj/effect/ccpost_freight_point
	name = "CCPOST freight point"
	desc = "A mapping point used by the Central Command Liaison Outpost freight system."

	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "field_dir"

	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT



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

	playsound(src, 'sound/machines/terminal/terminal_alert.ogg', vol = 25, vary = TRUE)


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

	playsound(src, 'sound/machines/terminal/terminal_alert.ogg', vol = 20, vary = TRUE)

	freight_crate.visible_message(
		span_notice("[freight_crate] is accepted for return to Sector Logistics.")
	)



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
		playsound(src, 'sound/machines/terminal/terminal_alert.ogg', vol = 30, vary = TRUE)

		network.refresh_registered_terminals()

	qdel(freight_crate)


/obj/item/circuitboard/computer/ccpost_logistics
	name = "Central Command Logistics Terminal"
	greyscale_colors = CIRCUIT_COLOR_COMMAND
	build_path = /obj/machinery/computer/ccpost_logistics


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
	if(!ccpost_has_centcom_id(user))
		return

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
	if(!ccpost_has_centcom_id(user))
		balloon_alert(user, "Central Command ID required")
		return TRUE
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

/obj/machinery/computer/ccpost_logistics/ui_status(mob/user)
	if(isobserver(user))
		return UI_INTERACTIVE
	if(!ccpost_can_view_terminal(user))
		return UI_CLOSE
	return ..()

/obj/machinery/computer/ccpost_logistics/ui_interact(mob/user, datum/tgui/ui)
	if(!ccpost_can_view_terminal(user))
		balloon_alert(user, "Central Command ID required")
		return
	. = ..()

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "CCPostLogistics", name)
		ui.open()


/obj/machinery/computer/ccpost_logistics/ui_data(mob/user)
	if(!ccpost_can_view_terminal(user))
		return list()
	var/list/data = list()
	data["read_only"] = isobserver(user)

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

		// Evaluate the concrete package as well as the sector-wide freight profile.
		// Category-specific installation losses can therefore be shown before the
		// Liaison spends CU on the requisition.
		var/datum/ccpost_freight_conditions/package_conditions = network.get_current_freight_conditions(package)
		var/package_authorization_delay = round(package_conditions.authorization_delay / (1 SECONDS))
		var/package_dispatch_delay = round(package_conditions.dispatch_delay / (1 SECONDS))
		var/package_transit_delay = round(package_conditions.get_transit_delay() / (1 SECONDS))
		var/package_estimated_total_delay = package_authorization_delay + package_dispatch_delay + package_transit_delay
		var/list/package_specific_reasons = package_conditions.reasons.Copy()

		for(var/global_reason in current_conditions.reasons)
			package_specific_reasons -= global_reason

		var/has_package_specific_routing = FALSE

		if(package_conditions.authorization_delay != current_conditions.authorization_delay)
			has_package_specific_routing = TRUE
		else if(package_conditions.dispatch_delay != current_conditions.dispatch_delay)
			has_package_specific_routing = TRUE
		else if(package_conditions.get_transit_delay() != current_conditions.get_transit_delay())
			has_package_specific_routing = TRUE
		else if(length(package_specific_reasons))
			has_package_specific_routing = TRUE

		catalog_data += list(list(
			"id" = package.id,
			"name" = package.name,
			"description" = package.desc,
			"category" = package.category,
			"cost" = package.cost,
			"contents" = package.get_content_entries(),
			"recall_locked" = recall_locked,
			"can_order" = can_order_package,
			"requisition_failure" = requisition_failure,
			"routing_status" = package_conditions.status,
			"authorization_delay" = package_authorization_delay,
			"dispatch_delay" = package_dispatch_delay,
			"transit_delay" = package_transit_delay,
			"estimated_total_delay" = package_estimated_total_delay,
			"freight_reasons" = package_conditions.reasons.Copy(),
			"package_specific_reasons" = package_specific_reasons,
			"has_package_specific_routing" = has_package_specific_routing
		))

		qdel(package_conditions)

	data["catalog"] = catalog_data
	qdel(current_conditions)

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


/obj/machinery/computer/ccpost_logistics/proc/begin_audit_print(mob/user, visible_text)
	if(!COOLDOWN_FINISHED(src, audit_print_cooldown))
		balloon_alert(user, "printer cooling down")
		return FALSE

	COOLDOWN_START(src, audit_print_cooldown, 5 SECONDS)
	playsound(src, 'sound/machines/printer.ogg', vol = 50, vary = FALSE)
	visible_message(span_notice(visible_text))
	return TRUE


/obj/machinery/computer/ccpost_logistics/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(!ccpost_has_centcom_id(ui?.user))
		return TRUE
	. = ..()

	if(.)
		return

	var/mob/user = ui.user
	var/datum/ccpost_logistics_network/network = GLOB.ccpost_logistics_network

	if(!network)
		return FALSE

	switch(action)
		if("print_package_manifest")
			var/package_id = params["package_id"]
			var/datum/ccpost_supply_package/package = network.get_supply_package(package_id)

			// Do not expose restricted manifests on an unhacked terminal.
			if(!package || (package.contraband && !contraband_unlocked))
				balloon_alert(user, "requisition authorization denied")
				return TRUE

			if(!begin_audit_print(user, "[src] prints a supply package manifest."))
				return TRUE

			print_package_manifest(package, user.name)
			balloon_alert(user, "manifest printed")
			return TRUE

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

/// Prints a pre-requisition contents manifest for a supply package.
/obj/machinery/computer/ccpost_logistics/proc/print_package_manifest(
	datum/ccpost_supply_package/package,
	generated_by
)
	if(!package)
		return FALSE

	var/safe_generated_by = generated_by || "UNKNOWN"
	var/procurement_class = package.contraband ? "Restricted Procurement" : "Standard Procurement"
	var/report_text = ccpost_paper_header()
	report_text += ccpost_paper_document_heading("Supply Package Manifest", "PRE-REQUISITION", "Declared Contents")
	report_text += ccpost_paper_value_field("Classification", procurement_class)
	report_text += ccpost_paper_value_field("Priority", "Routine")
	report_text += ccpost_paper_value_field("Category", package.category)
	report_text += ccpost_paper_value_field("Subject", package.name)
	report_text += ccpost_paper_value_field("Issued", station_time_timestamp())
	report_text += ccpost_paper_section("Requisition Details")
	report_text += ccpost_paper_value_field("Requisition Cost", "[package.cost] CU")
	report_text += ccpost_paper_value_field("Generated By", safe_generated_by)
	report_text += ccpost_paper_section("Package Description")
	report_text += "[ccpost_paper_paragraph(package.desc)]<br>"
	report_text += ccpost_paper_section("Declared Package Contents")

	var/list/content_entries = package.get_content_entries()
	if(!length(content_entries))
		report_text += "No contents declared.<br>"
	else
		report_text += ccpost_paper_table_open()
		report_text += ccpost_paper_table_row(list("Quantity", "Item"), TRUE)
		for(var/list/entry in content_entries)
			var/quantity = entry["quantity"]
			var/item_name = entry["name"]
			report_text += ccpost_paper_table_row(list("[quantity]", "[item_name]"))
		report_text += "</table>"

	report_text += ccpost_paper_note("Pre-requisition specification. This manifest does not confirm shipment, delivery, or authorization.")
	print_audit_page("Supply Manifest - [package.name]", report_text)
	return TRUE

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
		package_name = shipment.package.name
		package_cost = shipment.package.cost
		procurement_class = shipment.package.contraband ? "Restricted Procurement" : "Standard Procurement"

	var/requested_by = shipment.requested_by || "UNKNOWN"
	var/requested_at = shipment.requested_at || "N/A"
	var/authorized_at = shipment.authorized_at || "N/A"
	var/dispatched_at = shipment.dispatched_at || "N/A"
	var/delivered_at = shipment.delivered_at || "N/A"
	var/updated_at = shipment.status_updated_at || "N/A"
	var/safe_generated_by = generated_by || "UNKNOWN"
	var/terminal_status = contraband_unlocked ? "PROCUREMENT SAFEGUARDS COMPROMISED" : "PROCUREMENT SAFEGUARDS NOMINAL"

	var/report_text = ccpost_paper_header()
	report_text += ccpost_paper_document_heading("Freight Requisition Record", shipment.shipment_code, "Shipment Ledger")
	report_text += ccpost_paper_value_field("Classification", procurement_class)
	report_text += ccpost_paper_value_field("Priority", "Routine")
	report_text += ccpost_paper_value_field("Category", "Logistics")
	report_text += ccpost_paper_value_field("Subject", package_name)
	report_text += ccpost_paper_value_field("Issued", requested_at)
	report_text += ccpost_paper_section("Requisition Summary")
	report_text += ccpost_paper_value_field("Allocation Cost", "[package_cost] CU")
	report_text += ccpost_paper_value_field("Requested By", requested_by)
	report_text += ccpost_paper_value_field("Requested At", requested_at)
	report_text += ccpost_paper_value_field("Authorized At", authorized_at)
	report_text += ccpost_paper_value_field("Dispatched At", dispatched_at)
	report_text += ccpost_paper_value_field("Delivered At", delivered_at)
	report_text += ccpost_paper_value_field("Status", shipment.status)
	report_text += ccpost_paper_value_field("Last Status Update", updated_at)
	report_text += ccpost_paper_section("Sector Freight Conditions")
	report_text += ccpost_paper_value_field("Freight Profile", shipment.freight_condition_status)
	report_text += ccpost_paper_value_field("Authorization Delay", "[round(shipment.authorization_delay / (1 SECONDS))] seconds")
	report_text += ccpost_paper_value_field("Dispatch Delay", "[round(shipment.dispatch_delay / (1 SECONDS))] seconds")
	report_text += ccpost_paper_value_field("Transit Delay", "[round(shipment.transit_delay / (1 SECONDS))] seconds")
	if(length(shipment.freight_condition_reasons))
		for(var/reason in shipment.freight_condition_reasons)
			report_text += "- [ccpost_paper_paragraph(reason)]<br>"
	else
		report_text += "No additional sector factors recorded.<br>"
	if(shipment.failure_reason)
		report_text += ccpost_paper_value_field("Failure Reason", shipment.failure_reason)

	report_text += ccpost_paper_section("Audit Trail")
	report_text += ccpost_paper_value_field("Terminal Status", terminal_status)
	report_text += ccpost_paper_value_field("Audit Generated", station_time_timestamp())
	report_text += ccpost_paper_value_field("Generated By", safe_generated_by)
	report_text += ccpost_paper_note("Official freight requisition record. This document does not independently prove delivery.")
	print_audit_page("Freight Requisition Record - [shipment.shipment_code]", report_text)

/obj/machinery/computer/ccpost_logistics/proc/print_shipment_audit(
	datum/ccpost_logistics_network/network,
	generated_by
)
	if(!network)
		return

	var/safe_generated_by = generated_by || "UNKNOWN"
	var/terminal_status = contraband_unlocked ? "PROCUREMENT SAFEGUARDS COMPROMISED" : "PROCUREMENT SAFEGUARDS NOMINAL"
	var/page_size = 10
	var/page_number = 1
	var/start_index = 1

	if(!length(network.shipments))
		var/empty_text = ccpost_paper_header()
		empty_text += ccpost_paper_document_heading("Shipment Audit Record", "NO ENTRIES", "Freight Ledger")
		empty_text += ccpost_paper_value_field("Classification", "Internal")
		empty_text += ccpost_paper_value_field("Priority", "Routine")
		empty_text += ccpost_paper_value_field("Category", "Shipment Audit")
		empty_text += ccpost_paper_value_field("Subject", "Requisition History")
		empty_text += ccpost_paper_value_field("Issued", station_time_timestamp())
		empty_text += ccpost_paper_section("Record Summary")
		empty_text += ccpost_paper_value_field("Generated By", safe_generated_by)
		empty_text += ccpost_paper_value_field("Terminal Status", terminal_status)
		empty_text += "No freight requisitions have been recorded.<br>"
		empty_text += ccpost_paper_note("Central Command Sector Logistics Coordination. End of audit record.")
		print_audit_page("Central Command Shipment Audit", empty_text)
		return

	while(start_index <= length(network.shipments))
		var/end_index = min(start_index + page_size - 1, length(network.shipments))
		var/report_text = ccpost_paper_header()
		report_text += ccpost_paper_document_heading("Shipment Audit Record", "PAGE [page_number]", "Freight Ledger")
		report_text += ccpost_paper_value_field("Classification", "Internal")
		report_text += ccpost_paper_value_field("Priority", "Routine")
		report_text += ccpost_paper_value_field("Category", "Shipment Audit")
		report_text += ccpost_paper_value_field("Subject", "Requisition History")
		report_text += ccpost_paper_value_field("Issued", station_time_timestamp())
		report_text += ccpost_paper_section("Record Summary")
		report_text += ccpost_paper_value_field("Generated By", safe_generated_by)
		report_text += ccpost_paper_value_field("Terminal Status", terminal_status)
		report_text += ccpost_paper_value_field("Recorded Shipments", length(network.shipments))

		for(var/index in start_index to end_index)
			var/datum/ccpost_shipment/shipment = network.shipments[index]
			if(!shipment || QDELETED(shipment))
				continue
			var/package_name = shipment.package ? shipment.package.name : "UNKNOWN PACKAGE"
			var/package_cost = shipment.package ? shipment.package.cost : 0
			var/restriction = shipment.package?.contraband ? " (Restricted)" : ""
			var/requested_by = shipment.requested_by || "UNKNOWN"
			var/requested_at = shipment.requested_at || "N/A"
			var/updated_at = shipment.status_updated_at || "N/A"
			report_text += ccpost_paper_section("Requisition [shipment.shipment_code]")
			report_text += ccpost_paper_value_field("Package", "[package_name][restriction]")
			report_text += ccpost_paper_value_field("Cost", "[package_cost] CU")
			report_text += ccpost_paper_value_field("Requested By", requested_by)
			report_text += ccpost_paper_value_field("Requested At", requested_at)
			report_text += ccpost_paper_value_field("Status", shipment.status)
			report_text += ccpost_paper_value_field("Last Update", updated_at)
			if(shipment.failure_reason)
				report_text += ccpost_paper_value_field("Failure", shipment.failure_reason)

		report_text += ccpost_paper_note("End of shipment audit page [page_number]. Entries are retained for administrative review.")
		print_audit_page("Central Command Shipment Audit - Page [page_number]", report_text)
		start_index = end_index + 1
		page_number++

/obj/machinery/computer/ccpost_logistics/proc/print_allocation_ledger(
	datum/ccpost_logistics_network/network,
	generated_by
)
	if(!network)
		return

	var/safe_generated_by = generated_by || "UNKNOWN"
	var/terminal_status = contraband_unlocked ? "PROCUREMENT SAFEGUARDS COMPROMISED" : "PROCUREMENT SAFEGUARDS NOMINAL"
	var/page_size = 15
	var/page_number = 1
	var/start_index = 1

	if(!length(network.allocation_ledger))
		var/empty_text = ccpost_paper_header()
		empty_text += ccpost_paper_document_heading("Operational Allocation Audit", "NO ENTRIES", "Financial Ledger")
		empty_text += ccpost_paper_value_field("Classification", "Internal")
		empty_text += ccpost_paper_value_field("Priority", "Routine")
		empty_text += ccpost_paper_value_field("Category", "Financial Oversight")
		empty_text += ccpost_paper_value_field("Subject", "Operational Allocation")
		empty_text += ccpost_paper_value_field("Issued", station_time_timestamp())
		empty_text += ccpost_paper_section("Allocation Summary")
		empty_text += ccpost_paper_value_field("Generated By", safe_generated_by)
		empty_text += ccpost_paper_value_field("Terminal Status", terminal_status)
		empty_text += ccpost_paper_value_field("Current Allocation", "[network.allocation] / [network.max_allocation] CU")
		empty_text += ccpost_paper_value_field("Reserved Allocation", "[network.reserved_allocation] CU")
		empty_text += ccpost_paper_value_field("Available Allocation", "[network.get_available_allocation()] CU")
		empty_text += "No allocation transactions have been recorded.<br>"
		empty_text += ccpost_paper_note("Central Command Financial Oversight. End of audit record.")
		print_audit_page("Central Command Allocation Audit", empty_text)
		return

	while(start_index <= length(network.allocation_ledger))
		var/end_index = min(start_index + page_size - 1, length(network.allocation_ledger))
		var/report_text = ccpost_paper_header()
		report_text += ccpost_paper_document_heading("Operational Allocation Audit", "PAGE [page_number]", "Financial Ledger")
		report_text += ccpost_paper_value_field("Classification", "Internal")
		report_text += ccpost_paper_value_field("Priority", "Routine")
		report_text += ccpost_paper_value_field("Category", "Financial Oversight")
		report_text += ccpost_paper_value_field("Subject", "Operational Allocation")
		report_text += ccpost_paper_value_field("Issued", station_time_timestamp())
		report_text += ccpost_paper_section("Allocation Summary")
		report_text += ccpost_paper_value_field("Generated By", safe_generated_by)
		report_text += ccpost_paper_value_field("Terminal Status", terminal_status)
		report_text += ccpost_paper_value_field("Current Allocation", "[network.allocation] / [network.max_allocation] CU")
		report_text += ccpost_paper_value_field("Reserved Allocation", "[network.reserved_allocation] CU")
		report_text += ccpost_paper_value_field("Available Allocation", "[network.get_available_allocation()] CU")
		report_text += ccpost_paper_value_field("Recorded Transactions", length(network.allocation_ledger))

		for(var/index in start_index to end_index)
			var/datum/ccpost_allocation_ledger_entry/ledger_entry = network.allocation_ledger[index]
			if(!ledger_entry)
				continue
			var/entry_time = ledger_entry.timestamp || "N/A"
			var/entry_amount = ledger_entry.amount
			var/entry_reason = ledger_entry.reason || "Unspecified transaction"
			var/entry_actor = ledger_entry.actor || "SYSTEM"
			var/amount_prefix = entry_amount > 0 ? "+" : ""
			report_text += ccpost_paper_section("Transaction [entry_time]")
			report_text += ccpost_paper_value_field("Amount", "[amount_prefix][entry_amount] CU")
			report_text += ccpost_paper_value_field("Reason", entry_reason)
			report_text += ccpost_paper_value_field("Recorded By", entry_actor)

		report_text += ccpost_paper_note("End of allocation audit page [page_number]. Entries are retained for administrative review.")
		print_audit_page("Central Command Allocation Audit - Page [page_number]", report_text)
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

/// Returns a package's declared contents for TGUI and printed manifests.
/// Uses type defaults without spawning temporary items.
/datum/ccpost_supply_package/proc/get_content_entries()
	var/list/entries = list()

	for(var/item_type in contains)
		var/quantity = contains[item_type]

		// Match the quantity handling used by fill_crate().
		if(!isnum(quantity) || quantity < 1)
			quantity = 1

		var/item_name = initial(item_type:name)

		if(!item_name)
			item_name = "[item_type]"

		entries += list(list(
			"name" = item_name,
			"quantity" = quantity
		))

	return entries

/datum/ccpost_supply_package/proc/fill_crate(obj/structure/closet/crate/ccpost_freight/freight_crate)
	if(!freight_crate)
		return

	for(var/item_type in contains)
		var/amount = contains[item_type]

		if(!isnum(amount) || amount < 1)
			amount = 1

		for(var/i in 1 to amount)
			new item_type(freight_crate)

// Logistics CATALOG START


/datum/ccpost_supply_package/administrative
	id = "administrative"
	name = "Administrative Supplies"
	desc = "Replacement paperwork, writing implements, and general administrative equipment."
	category = CCPOST_SUPPLY_CATEGORY_ADMINISTRATION
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
	cost = 5

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



/datum/ccpost_supply_package/sustenance
	id = "sustenance"
	name = "Basic Sustenance Package"
	desc = "A modest selection of pre-approved meals for remote installation personnel."
	category = CCPOST_SUPPLY_CATEGORY_SUSTENANCE
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
	cost = 4

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

/datum/ccpost_supply_package/sustenance/hospitality
	id = "sustenance_hospitality"
	name = "Visitor Refreshments Package"
	desc = "Non-alcoholic beverages, snacks, and serving equipment intended for visiting station officials, corporate representatives, and authorized guests."
	cost = 5

	contains = list(
		/obj/item/storage/cans/sixsoda = 2,
		/obj/item/storage/box/drinkingglasses = 1,
		/obj/item/reagent_containers/cup/glass/shaker = 1,
		/obj/item/food/pistachios = 4,
		/obj/item/reagent_containers/cup/coffeepot = 1
	)

/datum/ccpost_supply_package/sustenance/luxury
	id = "luxury_goods"
	name = "Luxury Goods Crate"
	desc = "A curated assortment of premium consumables intended for executive hospitality, visiting officials, and approved morale expenditure."
	cost = 9

	contains = list(
		/obj/item/food/moonfish_caviar = 2,
		/obj/item/storage/fancy/cigarettes/cigars/havana = 1,
		/obj/item/reagent_containers/cup/glass/bottle/champagne = 2,
		/obj/item/food/pistachios = 2
	)



/datum/ccpost_supply_package/medical
	id = "medical"
	name = "Medical Resupply Package"
	desc = "General medical provisions including emergency treatment kits, diagnostic equipment, and wound-care supplies for outpost personnel."
	category = CCPOST_SUPPLY_CATEGORY_MEDICAL
	cost = 7

	contains = list(
		/obj/item/storage/medkit/regular = 1,
		/obj/item/storage/medkit/o2 = 1,
		/obj/item/storage/medkit/fire = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/stack/medical/gauze = 2,
		/obj/item/reagent_containers/medipen = 2
	)

/datum/ccpost_supply_package/medical/trauma
	id = "medical_trauma"
	name = "Trauma Treatment Package"
	desc = "Rapid-response medication and wound-care supplies for stabilizing serious injuries before evacuation or surgery."
	cost = 6

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
	cost = 6

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
	cost = 8

	contains = list(
		/obj/item/defibrillator/loaded = 2
	)

/datum/ccpost_supply_package/medical/surgery
	id = "medical_surgical"
	name = "Surgical Support Package"
	desc = "A compact set of surgical supplies for emergency procedures when routine medical support is unavailable."
	cost = 9

	contains = list(
		/obj/item/storage/backpack/duffelbag/med/surgery = 1,
		/obj/item/reagent_containers/medigel/sterilizine = 1,
		/obj/item/emergency_bed = 1
	)

/datum/ccpost_supply_package/medical/triage
	id = "medical_triage"
	name = "Mobile Triage Station"
	desc = "Portable diagnostic and stabilization equipment for assessing casualties and providing emergency treatment before transfer to a fully equipped medical facility."
	cost = 9

	contains = list(
		/obj/item/healthanalyzer = 2,
		/obj/item/reagent_containers/medipen/ekit = 2,
		/obj/item/reagent_containers/medipen/blood_loss = 2,
		/obj/item/stack/medical/gauze = 2,
		/obj/item/stack/medical/suture = 2,
		/obj/item/stack/medical/mesh = 2,
		/obj/item/emergency_bed = 1
	)


/datum/ccpost_supply_package/engineering
	id = "engineering"
	name = "Engineering Maintenance Package"
	desc = "A comprehensive supply of tools, construction materials, replacement lighting, and electrical protection for routine installation maintenance."
	category = CCPOST_SUPPLY_CATEGORY_ENGINEERING
	cost = 9

	contains = list(
		/obj/item/stack/sheet/mineral/plasma/twenty = 1,
		/obj/item/stack/sheet/iron/twenty = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/storage/box/lights/tubes = 1,
		/obj/item/storage/box/lights/bulbs = 1,
		/obj/item/storage/belt/utility/full = 1,
		/obj/item/clothing/gloves/color/yellow = 1
	)

/datum/ccpost_supply_package/engineering/toolboxes
	id = "engineering_toolboxes"
	name = "Toolbox Package"
	desc = "A reserve of electrical and mechanical toolboxes for repairs, maintenance, and emergency improvisation."
	cost = 6

	contains = list(
		/obj/item/storage/toolbox/electrical = 2,
		/obj/item/storage/toolbox/mechanical = 2
	)

/datum/ccpost_supply_package/engineering/electrical
	id = "engineering_electrical"
	name = "Electrical Repair Package"
	desc = "Insulated gloves, replacement power cells, and cable for restoring damaged electrical systems."
	cost = 7

	contains = list(
		/obj/item/clothing/gloves/color/yellow = 2,
		/obj/item/stock_parts/power_store/cell/high = 3,
		/obj/item/stack/cable_coil = 2
	)

/datum/ccpost_supply_package/engineering/atmos
	id = "engineering_atmos"
	name = "Atmospheric Recovery Package"
	desc = "Portable atmospheric equipment for recovering air, clearing contaminants, and repairing avoidable ventilation mistakes."
	cost = 9

	contains = list(
		/obj/machinery/portable_atmospherics/pump = 1,
		/obj/machinery/portable_atmospherics/scrubber = 1
	)

/datum/ccpost_supply_package/engineering/breach
	id = "engineering_breach"
	name = "Hull Breach Response Package"
	desc = "Anti-breach shield projectors and metal-foam supplies for rapid containment of structural damage."
	cost = 11

	contains = list(
		/obj/machinery/shieldgen = 2,
		/obj/item/storage/box/metalfoam = 1
	)

/datum/ccpost_supply_package/engineering/power
	id = "engineering_power"
	name = "Portable Power Package"
	desc = "Portable power-induction equipment and high-capacity cells for keeping essential systems running away from fixed chargers."
	cost = 8

	contains = list(
		/obj/item/inducer/orderable = 2,
		/obj/item/stock_parts/power_store/cell/high = 2
	)

/datum/ccpost_supply_package/engineering/auxiliary_generator
	id = "engineering_auxiliary_generator"
	name = "Auxiliary Generator Package"
	desc = "A portable plasma-powered generator and supporting electrical equipment for restoring power during major installation failures."
	cost = 12

	contains = list(
		/obj/machinery/power/port_gen/pacman = 1,
		/obj/item/stack/sheet/mineral/plasma/twenty = 1,
		/obj/item/stock_parts/power_store/cell/high = 2,
		/obj/item/stack/cable_coil = 2,
		/obj/item/multitool = 1
	)



/datum/ccpost_supply_package/materials/refurbishment
	id = "materials_refurbishment"
	name = "Interior Refurbishment Materials"
	desc = "A selection of carpeting and timber for approved office renovations, replacement furnishings, and decorative improvements."
	category = CCPOST_SUPPLY_CATEGORY_MATERIALS
	cost = 7

	contains = list(
		/obj/item/stack/tile/carpet/fifty = 1,
		/obj/item/stack/tile/carpet/black/fifty = 1,
		/obj/item/stack/tile/carpet/blue/fifty = 1,
		/obj/item/stack/sheet/mineral/wood/fifty = 1
	)

/datum/ccpost_supply_package/materials/safety
	id = "materials_safety"
	name = "Safety Flooring & Reinforcement Package"
	desc = "Industrial anti-slip flooring, structural rods, and emergency sealing supplies for improving the safety of installation corridors and work areas."
	category = CCPOST_SUPPLY_CATEGORY_MATERIALS
	cost = 7

	contains = list(
		/obj/item/stack/tile/noslip/thirty = 2,
		/obj/item/stack/rods/fifty = 1,
		/obj/item/storage/box/metalfoam = 1
	)

/datum/ccpost_supply_package/materials/construction
	id = "materials_construction"
	name = "Construction Materials Package"
	desc = "Bulk iron, glass, and plastic stock for routine construction, repairs, and approved installation improvements."
	category = CCPOST_SUPPLY_CATEGORY_MATERIALS
	cost = 8

	contains = list(
		/obj/item/stack/sheet/iron/fifty = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/stack/sheet/plastic/fifty = 1
	)

/datum/ccpost_supply_package/materials/emergency
	id = "materials_emergency"
	name = "Emergency Repair Materials"
	desc = "Reinforced construction stock and breach-control supplies intended for significant structural damage."
	category = CCPOST_SUPPLY_CATEGORY_MATERIALS
	cost = 10

	contains = list(
		/obj/item/stack/sheet/plasteel/twenty = 1,
		/obj/item/stack/sheet/iron/twenty = 1,
		/obj/item/stack/sheet/glass/fifty = 1,
		/obj/item/storage/box/metalfoam = 2
	)



/datum/ccpost_supply_package/technical/advanced_parts
	id = "technical_parts"
	name = "Advanced Parts Package"
	desc = "Contains a rapid part exchanger and supporting equipment for maintaining damaged machinery."
	category = CCPOST_SUPPLY_CATEGORY_TECHNICAL
	cost = 14

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
	category = CCPOST_SUPPLY_CATEGORY_TECHNICAL
	cost = 13

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

/datum/ccpost_supply_package/technical/mod_maintenance
	id = "technical_mod_maintenance"
	name = "MODsuit Maintenance Package"
	desc = "Replacement MODsuit power components and maintenance equipment for servicing authorized corporate protective systems."
	category = CCPOST_SUPPLY_CATEGORY_TECHNICAL
	cost = 10

	contains = list(
		/obj/item/mod/core/standard = 1,
		/obj/item/stock_parts/power_store/cell/super = 2,
		/obj/item/storage/belt/utility/full = 1,
		/obj/item/multitool = 1
	)


/datum/ccpost_supply_package/emergency/radiation
	id = "emergency_radiation"
	name = "Radiation Protection Package"
	desc = "Two complete radiation protection sets and portable radiation detection equipment for incidents involving contaminated cargo or hazardous environments."
	category = CCPOST_SUPPLY_CATEGORY_EMERGENCY
	cost = 8

	contains = list(
		/obj/item/clothing/head/utility/radiation = 2,
		/obj/item/clothing/suit/utility/radiation = 2,
		/obj/item/geiger_counter = 2
	)

/datum/ccpost_supply_package/emergency/explosive_hazard
	id = "emergency_explosive_hazard"
	name = "Explosive Hazard Response Package"
	desc = "Protective clothing and inspection tools intended for personnel responding to suspected explosive devices and other dangerous equipment."
	category = CCPOST_SUPPLY_CATEGORY_EMERGENCY
	cost = 9

	contains = list(
		/obj/item/clothing/head/utility/bomb_hood = 1,
		/obj/item/clothing/suit/utility/bomb_suit = 1,
		/obj/item/clothing/mask/gas = 1,
		/obj/item/screwdriver = 1,
		/obj/item/wirecutters = 1,
		/obj/item/multitool = 1,
		/obj/item/flashlight = 1
	)

/datum/ccpost_supply_package/eva
	id = "eva"
	name = "Emergency EVA Package"
	desc = "Two complete sets of emergency EVA equipment for evacuation, exterior repairs, and rescue operations in depressurized environments."
	category = CCPOST_SUPPLY_CATEGORY_EMERGENCY
	cost = 13

	contains = list(
		/obj/item/clothing/suit/space = 2,
		/obj/item/clothing/head/helmet/space = 2,
		/obj/item/tank/internals/oxygen = 2,
		/obj/item/clothing/mask/breath = 2
	)

/datum/ccpost_supply_package/emergency/firefighting
	id = "emergency_firefighting"
	name = "Firefighting Package"
	desc = "Protective equipment and extinguishing gear for responding to major fires and heat hazards."
	category = CCPOST_SUPPLY_CATEGORY_EMERGENCY
	cost = 8

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
	category = CCPOST_SUPPLY_CATEGORY_EMERGENCY
	cost = 6

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
	category = CCPOST_SUPPLY_CATEGORY_EMERGENCY
	cost = 13

	contains = list(
		/obj/item/storage/medkit/regular = 2,
		/obj/item/storage/medkit/o2 = 2,
		/obj/item/storage/medkit/toxin = 2,
		/obj/item/storage/medkit/brute = 2,
		/obj/item/storage/medkit/fire = 2,
		/obj/item/defibrillator/loaded = 1,
		/obj/item/storage/box/bodybags = 1,
		/obj/item/stack/medical/gauze = 2
	)



/datum/ccpost_supply_package/security
	id = "security"
	name = "Security Support Package"
	desc = "Limited defensive equipment intended for protection of Central Command personnel and property."
	category = CCPOST_SUPPLY_CATEGORY_SECURITY
	cost = 15

	contains = list(
		/obj/item/clothing/suit/armor/vest/alt/sec/private = 2,
		/obj/item/clothing/head/helmet/swat/nanotrasen = 2,
		/obj/item/gun/energy/e_gun/mini = 2,
		/obj/item/clothing/gloves/combat = 2
	)

/datum/ccpost_supply_package/security/base_defense
	id = "security_base_defense"
	name = "Base Defense Supplies Crate"
	desc = "Deployable fortifications for Central Command perimeter and corridor defense: filled sandbags, barrier grenades, pneumatic airlock seals, and a security holobarrier projector."
	cost = 12

	contains = list(
		/obj/item/stack/sheet/mineral/sandbags = 8,
		/obj/item/grenade/ccpost_barrier = 5,
		/obj/item/door_seal = 2,
		/obj/item/holosign_creator/security = 1
	)

/datum/ccpost_supply_package/security/wt550_ammo
	id = "security_wt550_ammo"
	name = "WT-550 Ammunition Resupply"
	desc = "Three replacement WT-550 magazines for the outpost armory."
	cost = 5
	contains = list(
		/obj/item/ammo_box/magazine/wt550m9 = 3
	)

/datum/ccpost_supply_package/security/wt550_replacement
	id = "security_wt550_replacement"
	name = "WT-550 Replacement Weapon"
	desc = "A replacement WT-550 autorifle and one spare magazine for an authorized outpost officer."
	cost = 19
	contains = list(
		/obj/item/gun/ballistic/automatic/wt550 = 1,
		/obj/item/ammo_box/magazine/wt550m9 = 1
	)

/datum/ccpost_supply_package/security/forensics
	id = "security_forensics"
	name = "Forensic Investigation Package"
	desc = "Investigation and evidence-processing equipment intended for examining security incidents, suspicious deliveries, and possible theft of corporate property."
	cost = 7

	contains = list(
		/obj/item/detective_scanner = 1,
		/obj/item/storage/box/evidence = 1,
		/obj/item/camera = 1,
		/obj/item/taperecorder = 1,
		/obj/item/flashlight/seclite = 1,
		/obj/item/clipboard = 1
	)

/datum/ccpost_supply_package/security/nonlethal
	id = "security_nonlethal"
	name = "Non-Lethal Response Package"
	desc = "An expanded set of incapacitation, restraint, and temporary containment equipment for installation security personnel."
	cost = 11

	contains = list(
		/obj/item/gun/energy/disabler = 2,
		/obj/item/melee/baton/security/loaded = 2,
		/obj/item/storage/box/handcuffs = 1,
		/obj/item/assembly/flash/handheld = 2,
		/obj/item/holosign_creator/security = 1
	)

/datum/ccpost_supply_package/security/protective
	id = "security_protective"
	name = "Protective Equipment Package"
	desc = "Three complete sets of standard security armor and protective accessories for reinforcing installation personnel."
	cost = 11

	contains = list(
		/obj/item/clothing/suit/armor/vest = 3,
		/obj/item/clothing/head/helmet/sec = 3,
		/obj/item/clothing/gloves/combat = 3
	)

/datum/ccpost_supply_package/security/riot_control
	id = "security_riot_control"
	name = "Riot Control Equipment Package"
	desc = "Two complete riot protection sets, including reinforced armor, helmets, shields, and deployable barriers for defending installation access points."
	cost = 16

	contains = list(
		/obj/item/clothing/suit/armor/riot = 2,
		/obj/item/clothing/head/helmet/toggleable/riot = 2,
		/obj/item/shield/riot = 2,
		/obj/item/grenade/ccpost_barrier = 4
	)

/datum/ccpost_supply_package/security/containment
	id = "security_containment"
	name = "Biological Containment Package"
	desc = "Protective suits, pathology equipment, and portable barriers for isolating suspected biological hazards."
	cost = 12

	contains = list(
		/obj/item/clothing/head/bio_hood/security = 2,
		/obj/item/clothing/suit/bio_suit/security = 2,
		/obj/item/reagent_containers/syringe/antiviral = 2,
		/obj/item/clothing/gloves/latex/nitrile = 2,
		/obj/item/clothing/glasses/pathology = 2,
		/obj/item/holosign_creator/medical = 2
	)

/datum/ccpost_supply_package/security/armory_energy
	id = "security_armory_energy"
	name = "Armory Energy Weapons Package"
	desc = "A compact emergency armory containing energy, laser, ion and disabler weapons for serious threats."
	cost = 24

	contains = list(
		/obj/item/gun/energy/e_gun = 1,
		/obj/item/gun/energy/laser = 1,
		/obj/item/gun/energy/ionrifle = 1,
		/obj/item/gun/energy/disabler = 1
	)

/datum/ccpost_supply_package/security/armory_ballistic
	id = "security_armory_ballistic"
	name = "Armory Ballistic Weapons Package"
	desc = "Two standard riot shotguns with bandoliers and non-lethal ammunition for situations requiring armed defensive intervention."
	cost = 22

	contains = list(
		/obj/item/gun/ballistic/shotgun/riot = 2,
		/obj/item/storage/belt/bandolier = 2,
		/obj/item/storage/box/rubbershot = 2,
		/obj/item/storage/box/beanbag = 1
	)

/datum/ccpost_supply_package/security/armory_ammunition
	id = "security_armory_ammunition"
	name = "Armory Ammunition Resupply"
	desc = "A reserve of standard shotgun ammunition, including rubber shot, beanbag rounds, and lethal shells. Intended for replenishing authorized defensive weapons."
	cost = 7

	contains = list(
		/obj/item/storage/box/rubbershot = 2,
		/obj/item/storage/box/beanbag = 1,
		/obj/item/storage/box/lethalshot = 1
	)

/datum/ccpost_supply_package/security/crowd_control
	id = "security_crowd_control"
	name = "Crowd Control Supplies Package"
	desc = "Flashbangs, tear gas, temporary barriers, portable barricades, and one Krav Maga close-quarters training implant for authorized outpost defensive duties."
	cost = 16

	contains = list(
		/obj/item/storage/box/flashbangs = 1,
		/obj/item/storage/box/teargas = 1,
		/obj/item/grenade/ccpost_barrier = 2,
		/obj/item/holosign_creator/security = 1,
		/obj/item/implanter/krav_maga = 1
	)

/datum/ccpost_supply_package/security/corporate_modsuit
	id = "security_corporate_modsuit"
	name = "Corporate Security MODsuit"
	desc = "A Corporate-pattern MODsuit authorized for Central Command installation security personnel. Features reinforced corporate protective plating, integrated utility systems, and a rechargeable power core. Intended for replacement equipment or additional authorized security personnel."
	cost = 40

	contains = list(
		/obj/item/mod/control/pre_equipped/corporate/ccpost_security = 1
	)


/datum/ccpost_supply_package/entertainment/bunny
	id = "entertainment_centcom_bunny"
	name = "CentCom Bunny Attire Package"
	desc = "A complete set of approved Central Command hospitality attire for formal receptions, morale initiatives, and other duties which Human Resources has declined to explain."
	category = CCPOST_SUPPLY_CATEGORY_ENTERTAINMENT
	cost = 6

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
	category = CCPOST_SUPPLY_CATEGORY_ENTERTAINMENT
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
	category = CCPOST_SUPPLY_CATEGORY_ENTERTAINMENT
	cost = 6

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
	category = CCPOST_SUPPLY_CATEGORY_ENTERTAINMENT
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

/datum/ccpost_supply_package/entertainment/morale_implants
	id = "entertainment_morale_implants"
	name = "Corporate Morale Implant Kit"
	desc = "Three voluntary employee-augmentation implants: sponsorship, concealed storage, and an automated sad trombone. Corporate morale, now permanently installed."
	category = CCPOST_SUPPLY_CATEGORY_ENTERTAINMENT
	cost = 12

	contains = list(
		/obj/item/implanter/sponsorship = 1,
		/obj/item/implanter/storage = 1,
		/obj/item/implanter/sad_trombone = 1
	)

/datum/ccpost_supply_package/entertainment/music
	id = "entertainment_music"
	name = "Music & Leisure Package"
	desc = "A selection of portable musical instruments for sanctioned recreation and unsanctioned hallway concerts."
	category = CCPOST_SUPPLY_CATEGORY_ENTERTAINMENT
	cost = 6

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
	category = CCPOST_SUPPLY_CATEGORY_ENTERTAINMENT
	cost = 7

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
	category = CCPOST_SUPPLY_CATEGORY_ENTERTAINMENT
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
	category = CCPOST_SUPPLY_CATEGORY_ENTERTAINMENT
	cost = 5

	contains = list(
		/obj/item/toy/plush/carpplushie = 1,
		/obj/item/toy/plush/slimeplushie = 1,
		/obj/item/toy/plush/lizard_plushie/greyscale = 1,
		/obj/item/toy/plush/snakeplushie = 1,
		/obj/item/toy/plush/moth = 1,
		/obj/item/toy/plush/beeplushie = 1
	)


/datum/ccpost_supply_package/entertainment/admin_plushies
	id = "entertainment_admin_plushies"
	name = "Central Command Plushie Collection"
	desc = "A complete collection of commemorative plushies depicting distinguished NanoTrasen administrative personnel. Approved for morale improvement, decorative purposes, and questionable collecting habits."
	category = CCPOST_SUPPLY_CATEGORY_ENTERTAINMENT
	cost = 9

/datum/ccpost_supply_package/entertainment/admin_plushies/New()
	. = ..()

	contains = list()

	for(var/plush_type in subtypesof(/obj/item/toy/plush/admin))
		contains[plush_type] = 1


/datum/ccpost_supply_package/entertainment/reception
	id = "entertainment_reception"
	name = "Corporate Reception Supplies"
	desc = "Decorations, serving equipment, and approved recreational materials for welcoming visiting dignitaries and hosting official receptions."
	category = CCPOST_SUPPLY_CATEGORY_ENTERTAINMENT
	cost = 6

	contains = list(
		/obj/item/storage/box/balloons = 1,
		/obj/item/storage/box/drinkingglasses = 1,
		/obj/item/flashlight/glowstick = 2,
		/obj/item/flashlight/glowstick/blue = 3,
		/obj/item/pinata = 1,
		/obj/item/food/pistachios = 2
	)



/datum/ccpost_supply_package/contraband
	category = CCPOST_SUPPLY_CATEGORY_RESTRICTED
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
		/obj/item/clothing/glasses/hud/security/night = 1,
		/obj/item/restraints/handcuffs = 2,
		/obj/item/clothing/gloves/combat = 1,
		/obj/item/clothing/suit/space/ert = 1,
		/obj/item/clothing/head/helmet/space/ert = 1
	)

/datum/ccpost_supply_package/contraband/combat_medical
	id = "restricted_combat_medical"
	name = "Unregistered Combat Medical Supplies"
	desc = "A collection of specialized combat medical equipment intended for high-risk corporate deployments. Supplies were diverted from a restricted Emergency Response Team allocation and lack the required medical authorization records."
	cost = 20
	audit_risk = 4

	contains = list(
		/obj/item/hypospray/combat = 1,
		/obj/item/reagent_containers/medipen/stimulants = 2,
		/obj/item/reagent_containers/medipen/ekit = 2,
		/obj/item/reagent_containers/medipen/blood_loss = 2,
		/obj/item/healthanalyzer = 1
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

/datum/ccpost_supply_package/contraband/implant_stock
	id = "restricted_implant_stock"
	name = "Off-Ledger Tactical Implant Stock"
	desc = "Unapproved tactical augmentations for restraint escape, covert concealment, electronic disruption, and smoke deployment. Intended for personnel whose expense approvals have already been denied."
	cost = 50
	audit_risk = 7

	contains = list(
		/obj/item/implanter/freedom = 1,
		/obj/item/implanter/stealth = 1,
		/obj/item/implanter/emp = 1,
		/obj/item/implanter/smoke = 1
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
	audit_risk = 1
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


// Logistics CATALOG END

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

	var/freight_condition_status = CCPOST_FREIGHT_STATUS_NORMAL
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

	var/datum/ccpost_freight_conditions/current_conditions = get_current_freight_conditions(package)

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

	if(shipment.freight_condition_status != CCPOST_FREIGHT_STATUS_NORMAL)
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
#undef CCPOST_FREIGHT_STATUS_NORMAL
#undef CCPOST_FREIGHT_STATUS_DEGRADED
#undef CCPOST_FREIGHT_STATUS_PRIORITY
#undef CCPOST_FREIGHT_STATUS_MIXED
#undef CCPOST_INSTALLATION_MAINTENANCE
#undef CCPOST_INSTALLATION_UNDER_REVIEW
#undef CCPOST_INSTALLATION_COMMS_DEGRADED
#undef CCPOST_INSTALLATION_NO_CONTACT
#undef CCPOST_INSTALLATION_OFFLINE
#undef CCPOST_INSTALLATION_CRITICAL
#undef CCPOST_INSTALLATION_CODE_REL_A17
#undef CCPOST_INSTALLATION_CODE_ADM_06
#undef CCPOST_INSTALLATION_CODE_LOG_H09
#undef CCPOST_SUPPLY_CATEGORY_ADMINISTRATION
#undef CCPOST_SUPPLY_CATEGORY_SUSTENANCE
#undef CCPOST_SUPPLY_CATEGORY_MEDICAL
#undef CCPOST_SUPPLY_CATEGORY_ENGINEERING
#undef CCPOST_SUPPLY_CATEGORY_MATERIALS
#undef CCPOST_SUPPLY_CATEGORY_TECHNICAL
#undef CCPOST_SUPPLY_CATEGORY_EMERGENCY
#undef CCPOST_SUPPLY_CATEGORY_SECURITY
#undef CCPOST_SUPPLY_CATEGORY_ENTERTAINMENT
#undef CCPOST_SUPPLY_CATEGORY_RESTRICTED
