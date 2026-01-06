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
	///How many credits will be charged to the Union & Command budgets per pay cycle while this is active.
	var/cost = 200

///Called when a demand is successfully implemented.
/datum/union_demand/proc/implement_demand(datum/union/union_demanding)
	return

///Called when a demand is unimplemented, this is currently admin-only.
/datum/union_demand/proc/unimplement_demand(datum/union/union_demanding)
	return

/datum/union_demand/vendor_stock
	name = "Vendor Stock Automatic Reporting"
	union_description = "The Union has noticed the vending machines on the station have been getting refilled in a very \
		inefficient manner and the Union has been getting the blame for this inefficiency. \
		As part of our new wave of agreements, we're purchasing new tracking software for vending machines \
		that will automatically report their stock and send it for Cargo's easy viewing. \
		Did you know vendors pay for refilled stock?"
	station_description = "The Cargo Union has voted for a new demand, all vending machines will be equipped \
		with surveyance software that will be reported back to Cargo so they can ensure all vendors are properly stocked."

/datum/union_demand/vendor_stock/implement_demand(datum/union/union_demanding)

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
	for(var/obj/machinery/computer/cargo/cargo_consoles as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/cargo))
		cargo_consoles.req_access = list(ACCESS_CARGO)

/datum/union_demand/cargo_console_lock/unimplement_demand(datum/union/union_demanding)
	for(var/obj/machinery/computer/cargo/cargo_consoles as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/cargo))
		cargo_consoles.req_access = initial(cargo_consoles.req_access)

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
