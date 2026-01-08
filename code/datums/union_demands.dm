/**
 * Union Demands
 * Datum storing what demands a Union can ask for, their requirements, and the effects they have on the round.
 */
/datum/union_demand
	///Name of the demand
	var/name = "Demand"
	///The description of the demand given to Union personnel.
	var/union_description = "We deserve our fair share, right?"
	///The description of the demand given to the whole station when the demand is being made.
	var/station_description = "The Cargo Union is making this demand."
	///Which department is eligible to demand this. Support for non-cargo unions don't exist yet, so this is pointless lol.
	var/department_eligible = ACCOUNT_CAR
	///Boolean on whether this Union demand is 'active' when the Union doesn't exist.
	///This is for those cases when the Union doesn't exist, should this be a feature in a union-less round?
	var/active_without_union = FALSE
	///How many credits will be charged to the Union & Command budgets per pay cycle while this is active.
	var/cost = 200

///Called when a demand is successfully implemented.
/datum/union_demand/proc/implement_demand(datum/union/union_demanding)
	SHOULD_CALL_PARENT(TRUE)

///Called when a demand is unimplemented, this is currently admin-only.
/datum/union_demand/proc/unimplement_demand(datum/union/union_demanding)
	SHOULD_CALL_PARENT(TRUE)

/datum/union_demand/vendor_stock
	name = "Vendor Stock Automatic Reporting"
	union_description = "The Union has noticed the vending machines on the station have been getting refilled in a very \
		inefficient manner and the Union has been getting the blame for this inefficiency. \
		As part of our new wave of agreements, we're purchasing new tracking software for vending machines \
		that will automatically report their stock and send it for Cargo's easy viewing through the department's \
		chatroom console, however it will also be made available to download from the NTNet store to your PDA. \
		Did you know vendors pay for refilled stock?"
	station_description = "The Cargo Union has voted for a new demand, all vending machines will be equipped \
		with surveyance software that will be reported back to Cargo so they can ensure all vendors are properly stocked. \
		This new software will be paid jointly with Command."
	active_without_union = TRUE

/datum/union_demand/vendor_stock/implement_demand(datum/union/union_demanding)
	. = ..()
	SSmodular_computers.add_program(/datum/computer_file/program/restock_tracker, store = PROGRAM_ON_NTNET_STORE)
	for(var/obj/machinery/modular_computer/cargochat_console as anything in SSmachines.get_machines_by_type(/obj/machinery/modular_computer/preset/cargochat/cargo))
		cargochat_console.cpu.store_file(new /datum/computer_file/program/restock_tracker)

/datum/union_demand/vendor_stock/unimplement_demand(datum/union/union_demanding)
	SSmodular_computers.remove_program(/datum/computer_file/program/restock_tracker, store = PROGRAM_ON_NTNET_STORE)
	for(var/obj/machinery/modular_computer/cargochat_console as anything in SSmachines.get_machines_by_type(/obj/machinery/modular_computer/preset/cargochat/cargo))
		var/datum/computer_file/program/restock_tracker/deleted_app = locate() in cargochat_console.cpu.stored_files
		if(deleted_app)
			cargochat_console.cpu.remove_file(deleted_app)
	return ..()

/datum/union_demand/cargo_console_lock
	name = "Access-locked Cargo Console"
	union_description = "The Union has noticed an uptick in people illegally gaining access to the Cargo console \
		and putting in orders using Cargo's budget without going through the request system. \
		In our recent round of demands, we've put a clause that will lock all cargo consoles to require Cargo access \
		to operate any non-request consoles."
	station_description = "The Cargo Union has voted for a new demand, all cargo consoles will have their software \
		updated with brand new access restrictions, to ensure only those with Cargo access may utilize the company cargo orders. \
		Any thieves, please feel free to use legal alternatives such as the requests console."

/datum/union_demand/cargo_console_lock/implement_demand(datum/union/union_demanding)
	. = ..()
	for(var/obj/machinery/computer/cargo/cargo_consoles as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/cargo))
		cargo_consoles.req_access = list(ACCESS_CARGO)

/datum/union_demand/cargo_console_lock/unimplement_demand(datum/union/union_demanding)
	for(var/obj/machinery/computer/cargo/cargo_consoles as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/cargo))
		cargo_consoles.req_access = initial(cargo_consoles.req_access)
	return ..()

/datum/union_demand/trade_freedom
	name = "Freedom of Association and Trade"
	union_description = "The Union feels the company is inefficient and intentionally sabotaging Cargo trades \
		by cutting crucial lines, knowing they are the only source of Cargo. \
		As the only ones able to provide this service to the station, why should we not simply open up our \
		trading outpost to other companies, and force Nanotrasen to compete?"
	station_description = "The Cargo Union has voted to open up the Cargo bay's shipping lanes to \
		any company willing to trade and associate with any corporation, as such a new Company Imports page is being \
		set up on the Cargo consoles."
	cost = 100 //this should be a no-brainer generally.
	active_without_union = TRUE

/datum/union_demand/independent_access
	name = "Dockyard Lockdown"
	union_description = "The Union feels the station oversteps their boundaries when entering the Cargo Bay, \
		from Paramedics to Blueshields, anyone feels like they have the right to just waltz into a department that isn't theirs. \
		Locking down the department to Union access personnel only seems like a sensible decision, plus it keeps that \
		Head of Personnel out."
	station_description = "The Cargo Union has voted to restrict the Bay to Union personnel only. \
		The cost of updating these access-locked doors to read badges have been delegated to Command."
	cost = 300 //hopefully get them a little more pissed.

/datum/union_demand/independent_access/implement_demand(datum/union/union_demanding)
	. = ..()
	for(var/obj/machinery/door/airlock/airlock as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock))
		if(ACCESS_CARGO in airlock.req_one_access)
			airlock.req_one_access -= ACCESS_CARGO
			airlock.req_one_access += ACCESS_UNION
		if(ACCESS_CARGO in airlock.req_access)
			airlock.req_access -= ACCESS_CARGO
			airlock.req_access += ACCESS_UNION

		if(ACCESS_QM in airlock.req_one_access)
			airlock.req_one_access -= ACCESS_QM
			airlock.req_one_access += ACCESS_UNION_LEADER
		if(ACCESS_QM in airlock.req_access)
			airlock.req_access -= ACCESS_QM
			airlock.req_access += ACCESS_UNION_LEADER

/datum/union_demand/independent_access/unimplement_demand(datum/union/union_demanding)
	for(var/obj/machinery/door/airlock/airlock as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock))
		if(ACCESS_CARGO in airlock.req_one_access)
			airlock.req_one_access += ACCESS_CARGO
			airlock.req_one_access -= ACCESS_UNION
		if(ACCESS_CARGO in airlock.req_access)
			airlock.req_access += ACCESS_CARGO
			airlock.req_access -= ACCESS_UNION
	return ..()

/datum/union_demand/better_bounties
	name = "Better bounty Payouts"
	union_description = "The Union has noticed that the price of bounties have not kept up with inflation. \
		Fixing this would require Nanotrasen increase the per-bounty profit, which is not something they are too keen \
		on accepting."
	station_description = "Following a wave of unprecedented inflation, the Cargo Union has demanded that \
		civilian bounties start keeping up with the rates of inflation, increasing payout per bounty. \
		Central Command delegates the payouts for these bounties to Command personnel."
	cost = 100 //command pays this per bounty, so let's keep this cheap.

/datum/union_demand/better_bounties/implement_demand(datum/union/union_demanding)
	. = ..()
	SSeconomy.bounty_modifier *= 1.2

/datum/union_demand/better_bounties/unimplement_demand(datum/union/union_demanding)
	SSeconomy.bounty_modifier /= 1.2
	return ..()

/* //requires cargo-access locked vendor PR to be merged
/datum/union_demand/locked_vendors
	name = "Access-locked Vendors"
	union_description = "The Union has noticed people trying to dress up as Cargo personnel \
		to work under the table for cheaper. This scabbing must end, Cargo vendors have now been locked to Cargo access."
	station_description = "The Cargo Union has implemented a new policy, adding access locks to their workplace vending machines."
	cost = 50 //really this doesn't do much tbh.
*/

/datum/union_demand/automatic_mail
	name = "Automatic Mail Tokens"
	union_description = "Recent technological advancements have shown that mail no longer needs tokens to prove \
		it has been delivered. Although this technology is rather expensive on this large of a scale, \
		we can automatically track when mail has been opened, and instantly send the profits back to Cargo."
	station_description = "As part of recent negotiations, the Cargo Union has started implementing tracking devices \
		in people's mail. This will remove the need to utilize mail tokens. Hope you don't have anything important in there."
	cost = 300

/datum/union_demand/bear_arms
	name = "Right to Bear Arms"
	union_description = "The Union's trust in the Private Security force to protect Cargo and its shipping lines has eroded. \
		New Union demands are simple, the right to bear arms. This will grant every Union badge the right to equip and wield weapons \
		of any caliber. The only security that can be granted to the Union is the one given to itself. \
		This does not include access to open/order any crates that would require Weapons access, only the right to bear them."
	station_description = "The Cargo Union has decided that they are taking Cargo security in their own hands, \
		starting off with the decision to arm themselves. Regrettably, weapons access is being installed on all \
		Union badges."
	cost = 500 //Are you really willing to pay for this, QM?

/datum/union_demand/bear_arms/implement_demand(datum/union/union_demanding)
	. = ..()
	for(var/obj/item/clothing/accessory/badge/cargo/cargo_badge as anything in union_demanding.printed_badges)
		cargo_badge.access += ACCESS_WEAPONS
		var/mob/living/carbon/human/worn_by = recursive_loc_check(cargo_badge, /mob/living/carbon/human)
		if(worn_by)
			worn_by.sec_hud_set_ID()

/datum/union_demand/bear_arms/unimplement_demand(datum/union/union_demanding)
	for(var/obj/item/clothing/accessory/badge/cargo/cargo_badge as anything in union_demanding.printed_badges)
		cargo_badge.access -= ACCESS_WEAPONS
		var/mob/living/carbon/human/worn_by = recursive_loc_check(cargo_badge, /mob/living/carbon/human)
		if(worn_by)
			worn_by.sec_hud_set_ID()
	return ..()

/datum/union_demand/boulder_payouts
	name = "Boulder Payouts"
	union_description = "Miners mine, but miners clear boulders. Boulders don't pay out? Why not? \
		Just because you're utilizing modern technology to do the heavy processing of the boulders, \
		does not justify Nanotrasen taking away the pay for boulders being processed! \
		As part of our new demands, boulder processing and refining machines will hold mining points as it \
		processes boulders, allowing miners to get paid for their work."
	station_description = "Recent negotiations with the Cargo Union has lead to our engineers modifying the \
		boulder processing machines to allow the storing of mineral points for any boulder it refines. \
		The cost of these upgrades are being delegated to the Station."
	cost = 150
	active_without_union = TRUE

/datum/union_demand/mining_sensors
	name = "Mining Sensors"
	union_description = "Too many Union Miners have been getting lost due to the lack of suit sensors available on the planet. \
		It may be expensive, but an investment in long-range antennaes, mixed with an agreement with several satellite \
		companies, has given us a newfound accessibility of letting suit sensors planet-side be visible to the station. \
		As a bonus, this will also remove the need for kheiral cuffs."
	station_description = "As part of a collaboration between the RnD departments that gave us the Kheiral cuffs and NTNet, \
		leaked technologies have been stolen and re-used to illegally modify suit sensors to work on non-station areas. \
		Nanotrasen does not approve of the Cargo Union using these technologies for their Shaft Miners."
