
//When cultists need to pay in blood to use their spells, they have a few options at their disposal:
// * If their hands are bloody, they can use the few units of blood on them.
// * If there is a blood splatter on the ground that still has a certain amount of fresh blood in it, they can use that?
// * If they are grabbing another person, they can stab their nails in their vessels to draw some blood from them
// * If they are standing above a bleeding person, they can dip their fingers into their wounds.
// * If they are holding a container that has blood in it (such as a beaker or a blood pack), they can pour/squeeze blood from them
// * If they are standing above a container that has blood in it, they can dip their fingers into them
// * Finally if there are no alternative blood sources, you can always use your own blood.

/*	get_available_blood
	user: the mob (generally a cultist) trying to spend blood
	amount_needed: the amount of blood required

	returns: a /list with information on nearby available blood. For use by use_available_blood().
*/
/proc/get_available_blood(var/mob/user, var/amount_needed = 0)
	var/data = list(
		BLOODCOST_TARGET_BLEEDER = null,
		BLOODCOST_AMOUNT_BLEEDER = 0,
		BLOODCOST_TARGET_GRAB = null,
		BLOODCOST_AMOUNT_GRAB = 0,
		BLOODCOST_TARGET_HANDS = null,
		BLOODCOST_AMOUNT_HANDS = 0,
		BLOODCOST_TARGET_HELD = null,
		BLOODCOST_AMOUNT_HELD = 0,
		BLOODCOST_LID_HELD = 0,
		BLOODCOST_TARGET_SPLATTER = null,
		BLOODCOST_AMOUNT_SPLATTER = 0,
		BLOODCOST_TARGET_BLOODPACK = null,
		BLOODCOST_AMOUNT_BLOODPACK = 0,
		BLOODCOST_HOLES_BLOODPACK = 0,
		BLOODCOST_TARGET_CONTAINER = null,
		BLOODCOST_AMOUNT_CONTAINER = 0,
		BLOODCOST_LID_CONTAINER = 0,
		BLOODCOST_TARGET_USER = null,
		BLOODCOST_AMOUNT_USER = 0,
		BLOODCOST_RESULT = "",
		BLOODCOST_TOTAL = 0,
		BLOODCOST_USER = null,
		)
	var/turf/T = get_turf(user)
	var/amount_gathered = 0

	data[BLOODCOST_RESULT] = user

	if (amount_needed == 0)//the cost was probably 1u, and already paid for by blood communion from another cultist
		data[BLOODCOST_RESULT] = BLOODCOST_TRIBUTE
		return data

	//Are we a construct?
	if (isconstruct(user))
		var/mob/living/basic/construct/C_user = user
		if (!C_user.purge)//Constructs can use runes for free as long as they aren't getting purged by holy water or null rods
			data[BLOODCOST_TARGET_USER] = C_user
			data[BLOODCOST_AMOUNT_USER] = amount_needed
			amount_gathered = amount_needed
			data[BLOODCOST_RESULT] = BLOODCOST_TARGET_USER
			return data

	//Is there blood on our hands?
	var/mob/living/carbon/human/H_user = user
	if (istype (H_user))
		data[BLOODCOST_TARGET_HANDS] = H_user
		var/blood_gathered = min(amount_needed, H_user.blood_in_hands)
		data[BLOODCOST_AMOUNT_HANDS] = blood_gathered
		amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_HANDS
		return data

	//Is there a fresh blood splatter on the turf?
	for (var/obj/effect/decal/cleanable/blood/B in T)
		var/blood_volume = B.count * 25
		if (blood_volume)
			data[BLOODCOST_TARGET_SPLATTER] = B
			var/blood_gathered = min(amount_needed-amount_gathered, blood_volume)
			data[BLOODCOST_AMOUNT_SPLATTER] = blood_gathered
			amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_SPLATTER
		return data

	if (user.pulling)
		if(ishuman(user.pulling))
			var/mob/living/carbon/human/H = user.pulling
			if(!HAS_TRAIT(H, TRAIT_NOBLOOD))
				var/blood_volume = H.blood_volume
				var/blood_gathered = min(amount_needed-amount_gathered, blood_volume)
				data[BLOODCOST_TARGET_GRAB] = H
				data[BLOODCOST_AMOUNT_GRAB] = blood_gathered
				amount_gathered += blood_gathered

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_GRAB
		return data

	//Is there a bleeding mob/corpse on the turf that still has blood in it?
	for (var/mob/living/carbon/human/H in T)
		if(HAS_TRAIT(H, TRAIT_NOBLOOD))
			continue
		if(user != H)
			if(H.get_bleed_rate() > 0)
				var/blood_volume = H.blood_volume
				var/blood_gathered = min(amount_needed-amount_gathered, blood_volume)
				data[BLOODCOST_TARGET_BLEEDER] = H
				data[BLOODCOST_AMOUNT_BLEEDER] = blood_gathered
				amount_gathered += blood_gathered
				break
		if (data[BLOODCOST_TARGET_BLEEDER])
			break

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_BLEEDER
		return data

	for(var/obj/item/reagent_containers/G_held in H_user.held_items) //Accounts for if the person has multiple grasping organs
		if (!istype(G_held) || !round(G_held.reagents.get_reagent_amount(/datum/reagent/blood)))
			continue
		if(istype(G_held, /obj/item/reagent_containers/blood)) //Bloodbags have their own functionality
			var/obj/item/reagent_containers/blood/blood_pack = G_held
			var/blood_volume = round(blood_pack.reagents.get_reagent_amount(/datum/reagent/blood))
			if (blood_volume)
				data[BLOODCOST_TARGET_BLOODPACK] = blood_pack
				var/blood_gathered = min(amount_needed-amount_gathered, blood_volume)
				data[BLOODCOST_AMOUNT_BLOODPACK] = blood_gathered
				amount_gathered += blood_gathered
			if (amount_gathered >= amount_needed)
				data[BLOODCOST_RESULT] = BLOODCOST_TARGET_BLOODPACK
				return data

		else
			var/blood_volume = round(G_held.reagents.get_reagent_amount(/datum/reagent/blood))
			if (blood_volume)
				data[BLOODCOST_TARGET_HELD] = G_held
				if (G_held.is_open_container())
					var/blood_gathered = min(amount_needed-amount_gathered, blood_volume)
					data[BLOODCOST_AMOUNT_HELD] = blood_gathered
					amount_gathered += blood_gathered
				else
					data[BLOODCOST_LID_HELD] = 1

			if (amount_gathered >= amount_needed)
				data[BLOODCOST_RESULT] = BLOODCOST_TARGET_HELD
				return data


	//Is there a reagent container on the turf that has blood in it?
	for (var/obj/item/reagent_containers/G in T)
		var/blood_volume = round(G.reagents.get_reagent_amount(/datum/reagent/blood))
		if (blood_volume)
			data[BLOODCOST_TARGET_CONTAINER] = G
			if (G.is_open_container())
				var/blood_gathered = min(amount_needed-amount_gathered, blood_volume)
				data[BLOODCOST_AMOUNT_CONTAINER] = blood_gathered
				amount_gathered += blood_gathered
				break
			else
				data[BLOODCOST_LID_CONTAINER] = 1

	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_CONTAINER
		return data

	//Does the user have blood? (the user can pay in blood without having to bleed first)
	if(istype(H_user))
		if(!HAS_TRAIT(H_user, TRAIT_NO_BLOOD_OVERLAY))
			var/blood_volume = H_user.blood_volume
			var/blood_gathered = min(amount_needed-amount_gathered, blood_volume)
			data[BLOODCOST_TARGET_USER] = H_user
			data[BLOODCOST_AMOUNT_USER] = blood_gathered
			amount_gathered += blood_gathered
	else//non-human trying to draw runes eh? let's see...
		if (ismonkey(user) || isalien(user))
			var/mob/living/carbon/C_user = user
			if (!C_user.stat == DEAD)
				var/blood_volume = round(max(0, C_user.health))//Unlike humans, monkeys take oxy damage when blood is taken from them.
				var/blood_gathered = min(amount_needed-amount_gathered, blood_volume)
				data[BLOODCOST_TARGET_USER] = C_user
				data[BLOODCOST_AMOUNT_USER] = blood_gathered
				amount_gathered += blood_gathered


	if (amount_gathered >= amount_needed)
		data[BLOODCOST_RESULT] = BLOODCOST_TARGET_USER
		return data

	data[BLOODCOST_RESULT] = BLOODCOST_FAILURE
	return data
