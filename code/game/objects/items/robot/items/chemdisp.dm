/obj/item/reagent_containers/borghypo
	name = "cyborg hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "borghypo"
	inhand_icon_state = "hypo"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	amount_per_transfer_from_this = 5
	/// In the hypo's TGUI, each of these numbers will be available as buttons to click on.
	possible_transfer_amounts = list(2, 5)
	/** The maximum volume for each reagent stored in this hypospray.
	 *  In most places, we add + 1 because we're secretly keeping [max_volume_per_reagent + 1]
	 *  units, so that when this reagent runs out it's not wholesale removed from the reagents.
	 */
	var/max_volume_per_reagent = 30
	/// Cell cost for charging a reagent.
	var/charge_cost = 0.05 * STANDARD_CELL_CHARGE
	/// Counts up to the next time we charge.
	var/charge_timer = 0 SECONDS
	/// Time it takes for shots to recharge (in deciseconds).
	var/recharge_time = 10 SECONDS
	/// Optional variable to override the temperature that [add_reagent()] will use.
	var/dispensed_temperature = DEFAULT_REAGENT_TEMPERATURE
	/// Can the hypospray bypass clothing that have THICKMATERIAL?
	var/bypass_protection = FALSE
	/// Has this hypospray been upgraded with additional chemicals? See [upgrade_hypo()].
	var/upgraded = FALSE
	/// The basic reagents that come with this hypospray.
	var/list/default_reagent_types
	/// The expanded suite of reagents that comes from upgrading this hypospray.
	var/list/expanded_reagent_types
