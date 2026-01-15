/datum/export/cash/spacecash
	k_elasticity = 0
	unit_name = "bills"
	export_types = list(/obj/item/stack/spacecash)

/datum/export/cash/spacecash/get_amount(obj/item/stack/spacecash/cash)
	return cash.amount * cash.value

/datum/export/cash/holochip
	k_elasticity = 0
	unit_name = "holochip"
	export_types = list(/obj/item/holochip)

/datum/export/cash/holochip/get_cost(obj/item/holochip/holo)
	return holo.credits
