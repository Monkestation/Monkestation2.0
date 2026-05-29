#define GREEDY_HEAL_COST 50


/*********Greedy God**********/

/datum/religion_sect/greed
	name = "Greed"
	quote = "Greed is good."
	desc = "In the eyes of your mercantile deity, your wealth is your favor. Earn enough wealth to purchase some more business opportunities."
	tgui_icon = "dollar-sign"
	altar_icon_state = "convertaltar-yellow"
	alignment = ALIGNMENT_EVIL //greed is not good wtf
	rites_list = list(/datum/religion_rites/greed/vendatray, /datum/religion_rites/greed/custom_vending)
	altar_icon_state = "convertaltar-yellow"

/datum/religion_sect/greed/tool_examine(mob/living/holy_creature) //display money policy
	return "In the eyes of [GLOB.deity], your wealth is your favor."

/datum/religion_sect/greed/sect_bless(mob/living/blessed_living, mob/living/chap)
	var/datum/bank_account/account = chap.get_bank_account()
	if(!account)
		to_chat(chap, span_warning("You need a way to pay for the heal!"))
		return TRUE
	if(account.account_balance < GREEDY_HEAL_COST)
		to_chat(chap, span_warning("Healing from [GLOB.deity] costs [GREEDY_HEAL_COST] credits for 30 health!"))
		return TRUE
	if(!ishuman(blessed_living))
		return FALSE
	var/mob/living/carbon/human/blessed = blessed_living
	for(var/obj/item/bodypart/robolimb as anything in blessed.bodyparts)
		if(IS_ROBOTIC_LIMB(robolimb))
			to_chat(chap, span_warning("[GLOB.deity] refuses to heal this metallic taint!"))
			return TRUE

	account.adjust_money(-GREEDY_HEAL_COST, "Church Donation: Treatment")
	var/heal_amt = 30
	var/list/hurt_limbs = blessed.get_damaged_bodyparts(1, 1, BODYTYPE_ORGANIC)
	if(hurt_limbs.len)
		for(var/obj/item/bodypart/affecting as anything in hurt_limbs)
			if(affecting.heal_damage(heal_amt, heal_amt, BODYTYPE_ORGANIC))
				blessed.update_damage_overlays()
		blessed.visible_message(span_notice("[chap] barters a heal for [blessed] from [GLOB.deity]!"))
		to_chat(blessed, span_boldnotice("May the power of [GLOB.deity] compel you to be healed! Thank you for choosing [GLOB.deity]!"))
		playsound(chap, 'sound/effects/cashregister.ogg', 60, TRUE)
		blessed.add_mood_event("blessing", /datum/mood_event/blessing)
	return TRUE

///all greed rites cost money instead
/datum/religion_rites/greed
	ritual_length = 5 SECONDS
	invoke_msg = "Sorry I was late, I was just making a shitload of money."
	var/money_cost = 0

/datum/religion_rites/greed/can_afford(mob/living/user)
	var/datum/bank_account/account = user.get_bank_account()
	if(!account)
		to_chat(user, span_warning("You need a way to pay for the rite!"))
		return FALSE
	if(account.account_balance < money_cost)
		to_chat(user, span_warning("This rite requires more money!"))
		return FALSE
	return TRUE

/datum/religion_rites/greed/invoke_effect(mob/living/user, atom/movable/religious_tool)
	var/datum/bank_account/account = user.get_bank_account()
	if(!account || account.account_balance < money_cost)
		to_chat(user, span_warning("This rite requires more money!"))
		return FALSE
	account.adjust_money(-money_cost, "Church Donation: Rite")
	return ..()

/datum/religion_rites/greed/vendatray
	name = "Purchase Vend-a-tray"
	desc = "Summons a Vend-a-tray. You can use it to sell items!"
	invoke_msg = "I need a vend-a-tray to make some more money!"
	money_cost = 300

/datum/religion_rites/greed/vendatray/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/altar_turf = get_turf(religious_tool)
	new /obj/structure/displaycase/forsale(altar_turf)
	playsound(get_turf(religious_tool), 'sound/effects/cashregister.ogg', 60, TRUE)
	return TRUE

/datum/religion_rites/greed/custom_vending
	name = "Purchase Personal Vending Machine"
	desc = "Summons a custom vending machine. You can use it to sell MANY items!"
	invoke_msg = "If I get a custom vending machine for my products, I can be RICH!"
	money_cost = 1000 //quite a step up from vendatray

/datum/religion_rites/greed/custom_vending/invoke_effect(mob/living/user, atom/movable/religious_tool)
	. = ..()
	var/altar_turf = get_turf(religious_tool)
	new /obj/machinery/vending/custom/greed(altar_turf)
	playsound(get_turf(religious_tool), 'sound/effects/cashregister.ogg', 60, TRUE)
	return TRUE

#undef GREEDY_HEAL_COST
