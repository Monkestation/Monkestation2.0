/obj/item/firing_pin
	name = "electronic firing pin"
	desc = "A small authentication device, to be inserted into a firearm receiver to allow operation. NT safety regulations require all new designs to incorporate one."
	icon = 'icons/obj/device.dmi'
	icon_state = "firing_pin"
	inhand_icon_state = "pen"
	worn_icon_state = "pen"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_TINY
	attack_verb_continuous = list("pokes")
	attack_verb_simple = list("poke")
	var/fail_message = "invalid user!"
	/// Explode when user check is failed.
	var/selfdestruct = FALSE
	/// Can forcefully replace other pins.
	var/force_replace = FALSE
	/// Can be replaced by any pin.
	var/pin_hot_swappable = FALSE
	///Can be removed from the gun using tools or replaced by a pin with force_replace
	var/pin_removable = TRUE
	var/obj/item/gun/gun

/obj/item/firing_pin/New(newloc)
	..()
	if(isgun(newloc))
		gun = newloc

/obj/item/firing_pin/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isgun(interacting_with))
		return NONE

	var/obj/item/gun/targeted_gun = interacting_with
	var/obj/item/firing_pin/old_pin = targeted_gun.pin
	if(old_pin?.pin_removable && (force_replace || old_pin.pin_hot_swappable))
		if(Adjacent(user))
			user.put_in_hands(old_pin)
		else
			old_pin.forceMove(targeted_gun.drop_location())
		old_pin.gun_remove(user)

	if(!targeted_gun.pin)
		if(!user.temporarilyRemoveItemFromInventory(src))
			return .
		if(gun_insert(user, targeted_gun))
			if(old_pin)
				balloon_alert(user, "swapped firing pin")
			else
				balloon_alert(user, "inserted firing pin")
	else
		to_chat(user, span_notice("This firearm already has a firing pin installed."))

	return ITEM_INTERACT_SUCCESS

/obj/item/firing_pin/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	balloon_alert(user, "authentication checks overridden")
	return TRUE

/obj/item/firing_pin/proc/gun_insert(mob/living/user, obj/item/gun/G)
	gun = G
	forceMove(gun)
	gun.pin = src
	return TRUE

/obj/item/firing_pin/proc/gun_remove(mob/living/user)
	gun.pin = null
	gun = null
	return

/obj/item/firing_pin/proc/pin_auth(mob/living/user)
	return TRUE

/obj/item/firing_pin/proc/auth_fail(mob/living/user)
	if(user)
		balloon_alert(user, fail_message)
	if(selfdestruct)
		if(user)
			user.show_message("[span_danger("SELF-DESTRUCTING...")]<br>", MSG_VISUAL)
			to_chat(user, span_userdanger("[gun] explodes!"))
		explosion(src, devastation_range = -1, light_impact_range = 2, flash_range = 3)
		if(gun)
			qdel(gun)


/obj/item/firing_pin/magic
	name = "magic crystal shard"
	desc = "A small enchanted shard which allows magical weapons to fire."


// Test pin, works only near firing range.
/obj/item/firing_pin/test_range
	name = "test-range firing pin"
	desc = "This safety firing pin allows weapons to be fired within proximity to a firing range."
	fail_message = "test range check failed!"
	pin_hot_swappable = TRUE

/obj/item/firing_pin/test_range/pin_auth(mob/living/user)
	if(!istype(user))
		return FALSE
	if (istype(get_area(user), /area/station/security/range))
		return TRUE
	return FALSE


// Implant pin, checks for implant
/obj/item/firing_pin/implant
	name = "implant-keyed firing pin"
	desc = "This is a security firing pin which only authorizes users who are implanted with a certain device."
	fail_message = "implant check failed!"
	var/obj/item/implant/req_implant = null

/obj/item/firing_pin/implant/pin_auth(mob/living/user)
	if(user)
		for(var/obj/item/implant/I in user.implants)
			if(req_implant && I.type == req_implant)
				return TRUE
	return FALSE

/obj/item/firing_pin/implant/mindshield
	name = "mindshield firing pin"
	desc = "This Security firing pin authorizes the weapon for only mindshield-implanted users."
	icon_state = "firing_pin_loyalty"
	req_implant = /obj/item/implant/mindshield

/obj/item/firing_pin/implant/pindicate
	name = "syndicate firing pin"
	icon_state = "firing_pin_pindi"
	req_implant = /obj/item/implant/weapons_auth



// Honk pin, clown's joke item.
// Can replace other pins. Replace a pin in cap's laser for extra fun!
/obj/item/firing_pin/clown
	name = "hilarious firing pin"
	desc = "Advanced clowntech that can convert any firearm into a far more useful object."
	color = "#FFFF00"
	fail_message = "honk!"
	force_replace = TRUE

/obj/item/firing_pin/clown/pin_auth(mob/living/user)
	playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
	return FALSE

// Ultra-honk pin, clown's deadly joke item.
// A gun with ultra-honk pin is useful for clown and useless for everyone else.
/obj/item/firing_pin/clown/ultra
	name = "ultra hilarious firing pin"

/obj/item/firing_pin/clown/ultra/pin_auth(mob/living/user)
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, TRUE)
	if(QDELETED(user))  //how the hell...?
		stack_trace("/obj/item/firing_pin/clown/ultra/pin_auth called with a [isnull(user) ? "null" : "invalid"] user.")
		return TRUE
	if(HAS_TRAIT(user, TRAIT_CLUMSY)) //clumsy
		return TRUE
	if(user.mind)
		if(is_clown_job(user.mind.assigned_role)) //traitor clowns can use this, even though they're technically not clumsy
			return TRUE
		if(user.mind.has_antag_datum(/datum/antagonist/nukeop/clownop)) //clown ops aren't clumsy by default and technically don't have an assigned role of "Clown", but come on, they're basically clowns
			return TRUE
		if(user.mind.has_antag_datum(/datum/antagonist/nukeop/leader/clownop)) //Wanna hear a funny joke?
			return TRUE //The clown op leader antag datum isn't a subtype of the normal clown op antag datum.
	return FALSE

/obj/item/firing_pin/clown/ultra/gun_insert(mob/living/user, obj/item/gun/G)
	..()
	G.clumsy_check = FALSE

/obj/item/firing_pin/clown/ultra/gun_remove(mob/living/user)
	gun.clumsy_check = initial(gun.clumsy_check)
	..()

// Now two times deadlier!
/obj/item/firing_pin/clown/ultra/selfdestruct
	name = "super ultra hilarious firing pin"
	desc = "Advanced clowntech that can convert any firearm into a far more useful object. It has a small nitrobananium charge on it."
	selfdestruct = TRUE


// DNA-keyed pin.
// When you want to keep your toys for yourself.
/obj/item/firing_pin/dna
	name = "DNA-keyed firing pin"
	desc = "This is a DNA-locked firing pin which only authorizes one user. Attempt to fire once to DNA-link."
	icon_state = "firing_pin_dna"
	fail_message = "dna check failed!"
	var/unique_enzymes = null

/obj/item/firing_pin/dna/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(iscarbon(interacting_with))
		var/mob/living/carbon/M = interacting_with
		if(M.dna && M.dna.unique_enzymes)
			unique_enzymes = M.dna.unique_enzymes
			balloon_alert(user, "dna lock set")
			return ITEM_INTERACT_SUCCESS
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/item/firing_pin/dna/pin_auth(mob/living/carbon/user)
	if(user && user.dna && user.dna.unique_enzymes)
		if(user.dna.unique_enzymes == unique_enzymes)
			return TRUE
	return FALSE

/obj/item/firing_pin/dna/auth_fail(mob/living/carbon/user)
	if(!unique_enzymes)
		if(user && user.dna && user.dna.unique_enzymes)
			unique_enzymes = user.dna.unique_enzymes
			balloon_alert(user, "dna lock set")
	else
		..()

/obj/item/firing_pin/dna/dredd
	desc = "This is a DNA-locked firing pin which only authorizes one user. Attempt to fire once to DNA-link. It has a small explosive charge on it."
	selfdestruct = TRUE

// Paywall pin, brought to you by ARMA 3 DLC.
// Checks if the user has a valid bank account on an ID and if so attempts to extract a one-time payment to authorize use of the gun. Otherwise fails to shoot.
/obj/item/firing_pin/paywall
	name = "paywall firing pin"
	desc = "A firing pin with a built-in configurable paywall."
	color = "#FFD700"
	fail_message = ""
	///list of account IDs which have accepted the license prompt. If this is the multi-payment pin, then this means they accepted the waiver that each shot will cost them money
	var/list/gun_owners = list()
	///how much gets paid out to license yourself to the gun
	var/payment_amount
	var/datum/bank_account/pin_owner
	///if true, user has to pay everytime they fire the gun
	var/multi_payment = FALSE
	var/owned = FALSE
	///purchase prompt to prevent spamming it, set to the user who opens to prompt to prevent locking the gun up for other users.
	var/active_prompt_user

/obj/item/firing_pin/paywall/attack_self(mob/user)
	multi_payment = !multi_payment
	to_chat(user, span_notice("You set the pin to [( multi_payment ) ? "process payment for every shot" : "one-time license payment"]."))

/obj/item/firing_pin/paywall/examine(mob/user)
	. = ..()
	if(pin_owner)
		. += span_notice("This firing pin is currently authorized to pay into the account of [pin_owner.account_holder].")

/obj/item/firing_pin/paywall/gun_insert(mob/living/user, obj/item/gun/G)
	if(!pin_owner)
		to_chat(user, span_warning("ERROR: Please swipe valid identification card before installing firing pin!"))
		user.put_in_hands(src)
		return FALSE
	gun = G
	forceMove(gun)
	gun.pin = src
	if(multi_payment)
		gun.desc += span_notice(" This [gun.name] has a per-shot cost of [payment_amount] credit[( payment_amount > 1 ) ? "s" : ""].")
		return TRUE
	gun.desc += span_notice(" This [gun.name] has a license permit cost of [payment_amount] credit[( payment_amount > 1 ) ? "s" : ""].")
	return TRUE


/obj/item/firing_pin/paywall/gun_remove(mob/living/user)
	gun.desc = initial(desc)
	..()

/obj/item/firing_pin/paywall/attackby(obj/item/M, mob/living/user, params)
	if(isidcard(M))
		var/obj/item/card/id/id = M
		if(!id.registered_account)
			to_chat(user, span_warning("ERROR: Identification card lacks registered bank account!"))
			return
		if(id.registered_account != pin_owner && owned)
			to_chat(user, span_warning("ERROR: This firing pin has already been authorized!"))
			return
		if(id.registered_account == pin_owner)
			to_chat(user, span_notice("You unlink the card from the firing pin."))
			gun_owners -= user.get_bank_account()
			pin_owner = null
			owned = FALSE
			return
		var/transaction_amount = tgui_input_number(user, "Insert valid deposit amount for gun purchase", "Money Deposit")
		if(!transaction_amount || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
			return
		pin_owner = id.registered_account
		owned = TRUE
		payment_amount = transaction_amount
		gun_owners += user.get_bank_account()
		to_chat(user, span_notice("You link the card to the firing pin."))

/obj/item/firing_pin/paywall/pin_auth(mob/living/user)
	if(!istype(user))//nice try commie
		return FALSE
	var/datum/bank_account/credit_card_details = user.get_bank_account()
	if(credit_card_details in gun_owners)
		if(multi_payment && credit_card_details)
			if(!gun.can_shoot())
				return TRUE //So you don't get charged for attempting to fire an empty gun.
			if(credit_card_details.adjust_money(-payment_amount, "Firing Pin: Gun Rent"))
				if(pin_owner)
					pin_owner.adjust_money(payment_amount, "Firing Pin: Payout For Gun Rent")
				return TRUE
			to_chat(user, span_warning("ERROR: User balance insufficent for successful transaction!"))
			return FALSE
		return TRUE
	if(!credit_card_details)
		to_chat(user, span_warning("ERROR: User has no valid bank account to subtract neccesary funds from!"))
		return FALSE
	if(active_prompt_user == user)
		return FALSE
	active_prompt_user = user
	var/license_request = tgui_alert(user, "Do you wish to pay [payment_amount] credit[( payment_amount > 1 ) ? "s" : ""] for [( multi_payment ) ? "each shot of [gun.name]" : "usage license of [gun.name]"]?", "Weapon Purchase", list("Yes", "No"), 15 SECONDS)
	if(!user.can_perform_action(src))
		active_prompt_user = null
		return FALSE
	switch(license_request)
		if("Yes")
			if(multi_payment)
				gun_owners += credit_card_details
				to_chat(user, span_notice("Gun rental terms agreed to, have a secure day!"))

			else if(credit_card_details.adjust_money(-payment_amount, "Firing Pin: Gun License"))
				if(pin_owner)
					pin_owner.adjust_money(payment_amount, "Firing Pin: Gun License Bought")
				gun_owners += credit_card_details
				to_chat(user, span_notice("Gun license purchased, have a secure day!"))

			else
				to_chat(user, span_warning("ERROR: User balance insufficent for successful transaction!"))

		if("No", null)
			to_chat(user, span_warning("ERROR: User has declined to purchase gun license!"))
	active_prompt_user = null
	return FALSE //we return false here so you don't click initially to fire, get the prompt, accept the prompt, and THEN the gun

// Explorer Firing Pin- Prevents use on station Z-Level, so it's justifiable to give Explorers guns that don't suck.
/obj/item/firing_pin/explorer
	name = "outback firing pin"
	desc = "A firing pin used by the austrailian defense force, retrofit to prevent weapon discharge on the station."
	icon_state = "firing_pin_explorer"
	fail_message = "cannot fire while on station, mate!"

// This checks that the user isn't on the station Z-level.
/obj/item/firing_pin/explorer/pin_auth(mob/living/user)
	var/turf/station_check = get_turf(user)
	if(!station_check || is_station_level(station_check.z))
		return FALSE
	return TRUE

// Laser tag pins
/obj/item/firing_pin/tag
	name = "laser tag firing pin"
	desc = "A recreational firing pin, used in laser tag units to ensure users have their vests on."
	fail_message = "suit check failed!"
	var/obj/item/clothing/suit/suit_requirement = null
	var/tagcolor = ""

/obj/item/firing_pin/tag/pin_auth(mob/living/user)
	if(ishuman(user))
		var/mob/living/carbon/human/M = user
		if(istype(M.wear_suit, suit_requirement))
			return TRUE
	to_chat(user, span_warning("You need to be wearing [tagcolor] laser tag armor!"))
	return FALSE

/obj/item/firing_pin/tag/red
	name = "red laser tag firing pin"
	icon_state = "firing_pin_red"
	suit_requirement = /obj/item/clothing/suit/redtag
	tagcolor = "red"

/obj/item/firing_pin/tag/blue
	name = "blue laser tag firing pin"
	icon_state = "firing_pin_blue"
	suit_requirement = /obj/item/clothing/suit/bluetag
	tagcolor = "blue"

/obj/item/firing_pin/Destroy()
	if(gun)
		gun.pin = null
	return ..()

/obj/item/firing_pin/monkey
	name = "monkeylock firing pin"
	desc = "This firing pin prevents non-monkeys from firing a gun."
	fail_message = "not a monkey!"

/obj/item/firing_pin/monkey/pin_auth(mob/living/user)
	if(!is_simian(user))
		playsound(src, SFX_SCREECH, 75, TRUE)
		return FALSE
	return TRUE

//Wastes firing pin - restricts a weapon to only outside when mining - based on area defines not z-level
/obj/item/firing_pin/wastes
	name = "Wastes firing pin"
	desc = "This safety firing pin allows weapons to be fired only outside on the wastes of lavaland or icemoon."
	fail_message = "Wastes check failed! - Make your way to lavaland or the Ice Caves!"
	pin_hot_swappable = FALSE
	pin_removable = FALSE
	var/list/wastes = list( //locations you CAN use this
		/area/icemoon/underground/unexplored, //surface outdoor of icemoon is not here because its the first floor, full of the most player activity.
		/area/icemoon/underground/explored,

		/area/lavaland/surface/outdoors,

		/area/ocean, // uses Z-levels until Oshan mapping is fixed
		// /area/ocean/generated,
		// /area/ocean/generated_above,

		/area/ruin,

		/area/centcom/central_command_areas //can be used mostly anywhere on centcom, mainly for admins.
	)
	var/list/blacklist = list( //Locations you CANNOT use things with this pin specifically, for stuff like ghost role ruins.
		/area/space, //no going outside
		/area/ruin/space, //no explorers >:(
		/area/ruin/powered/reebe // no stomping clock cults >:(
	)

/obj/item/firing_pin/wastes/pin_auth(mob/living/user)
	if(!istype(user) || is_type_in_list(get_area(user), blacklist))
		return FALSE
	if(SSticker.current_state == GAME_STATE_FINISHED) //now unlocks after game is over. have fun
		return TRUE
	if(is_type_in_list(get_area(user), wastes))
		var/turf/userturf = get_turf(user)
		if(istype(get_area(user), /area/ocean) && SSmapping.level_trait(userturf.z, ZTRAIT_STATION))
			return FALSE // block Oshan main station Z
		return TRUE
	return FALSE

/obj/item/firing_pin/cargo //Firing pin for use in cargo only
	name = "cargo-locked firing pin"
	desc = "A firing pin that scans the area to check if it is within the station's cargo bay or warehouse before firing."
	fail_message = "Area check failed"
	var/list/station_cargo = list(
		/area/station/cargo/warehouse,
		/area/station/cargo/storage,
		/area/station/cargo/office,
		/area/station/cargo/sorting,
		)

//Checks to see if the user in cargo or it's warehouse
/obj/item/firing_pin/cargo/pin_auth(mob/living/user)
	if(!istype(user))
		return FALSE
	if(is_type_in_list(get_area(user), station_cargo))
		return TRUE
	return FALSE


/obj/item/firing_pin/cargo/unremovable
	pin_removable = FALSE

/obj/item/firing_pin/buckshotroulette
	name = "roulette firing pin"
	desc = "A firing pin that remembers the identity of the last person that fired it, only allowing them to fire once before having to give up their turn, unless they shoot themselves."
	fail_message = "turn finished"
	var/last_user

/obj/item/firing_pin/buckshotroulette/proc/check_fire(obj/item/gun/weapon, mob/living/carbon/user, atom/target, params, zone_override)
	if(user == target)
		balloon_alert(user, "turn continued")
		last_user = null

/obj/item/firing_pin/buckshotroulette/gun_insert(mob/living/user, obj/item/gun/G)
	..()
	RegisterSignal(G, COMSIG_GUN_FIRED, PROC_REF(check_fire))

/obj/item/firing_pin/buckshotroulette/pin_auth(mob/living/user)
	if(!istype(user))
		return FALSE
	if (user == last_user)
		return FALSE
	last_user = user
	return TRUE


/obj/item/firing_pin/buckshotroulette/unremovable //no cheating allowed
	pin_removable = FALSE
