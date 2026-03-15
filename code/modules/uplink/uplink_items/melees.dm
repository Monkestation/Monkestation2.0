/datum/uplink_category/melees
	name = "Melees"
	weight = 7

/datum/uplink_item/melees
	category = /datum/uplink_category/melees

/datum/uplink_item/melees/efireaxe
	name = "Syndicate Fire Axe"
	desc = "A modernised version of the infamous fire axe, courtesy of the Gorlex Marauders. Capable of breaching almost anything, and cleaving through almost any armour, it is to be handled with care."
	item = /obj/item/fireaxe/energy
	cost = 12

/datum/uplink_item/melees/sword
	name = "Energy Sword"
	desc = "The energy sword is an edged weapon with a blade of pure energy. The sword is small enough to be \
			pocketed when inactive. Activating it produces a loud, distinctive noise."
	progression_minimum = 20 MINUTES
	item = /obj/item/melee/energy/sword/saber
	cost = 8
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/melees/powerfist
	name = "Power Fist"
	desc = "The power-fist is a metal gauntlet with a built-in piston-ram powered by an external gas supply.\
			Upon hitting a target, the piston-ram will extend forward to make contact for some serious damage. \
			Using a wrench on the piston valve will allow you to tweak the amount of gas used per punch to \
			deal extra damage and hit targets further. Use a screwdriver to take out any attached tanks."
	progression_minimum = 20 MINUTES
	item = /obj/item/melee/powerfist
	cost = 18
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/melees/rapid
	name = "Gloves of the North Star"
	desc = "These gloves let the user punch people very fast. Does not improve weapon attack speed or the meaty fists of a hulk."
	progression_minimum = 20 MINUTES
	item = /obj/item/clothing/gloves/rapid
	cost = 8

/datum/uplink_item/melees/doublesword
	name = "Double-Bladed Energy Sword"
	desc = "The double-bladed energy sword does slightly more damage than a standard energy sword and will deflect \
			all energy projectiles, but requires two hands to wield. It also struggles to protect you from tackles."
	progression_minimum = 30 MINUTES
	item = /obj/item/dualsaber
	cost = 18
	purchasable_from = ~UPLINK_CLOWN_OPS

/datum/uplink_item/melees/doublesword/get_discount_value(discount_type)
	switch(discount_type)
		if(TRAITOR_DISCOUNT_BIG)
			return 0.5
		if(TRAITOR_DISCOUNT_AVERAGE)
			return 0.35
		else
			return 0.2

/datum/uplink_item/melees/venom_knife
	name = "Poisoned Knife"
	desc = "A knife that is made of two razor sharp blades, it has a secret compartment in the handle to store liquids which are injected when stabbing something.\
	Can hold up to forty units of reagents but comes empty."
	item = /obj/item/knife/venom
	cost = 6 // all in all it's not super stealthy and you have to get some chemicals yourself

/datum/uplink_item/melees/contrabaton
	name = "Contractor Baton"
	desc = "A compact, specialised baton assigned to Syndicate contractors. Applies light electrical shocks to targets. \
	These shocks are capable of affecting the inner circuitry of most robots as well, applying a short stun. \
	Has the added benefit of affecting the vocal cords of your victim, causing them to slur as if inebriated."
	item = /obj/item/melee/baton/telescopic/contractor_baton
	cost = 12
	surplus = 50
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/melees/martialarts
	name = "Martial Arts Scroll"
	desc = "This scroll contains the secrets of an ancient martial arts technique. You will master unarmed combat \
			and gain the ability to swat bullets from the air, but you will also refuse to use dishonorable ranged weaponry."
	item = /obj/item/book/granter/martial/carp
	progression_minimum = 30 MINUTES
	cost = 16 // No free northstar gloves
	surplus = 30
	purchasable_from = ~(UPLINK_NUKE_OPS | UPLINK_CLOWN_OPS)

/datum/uplink_item/melees/martialarts/advanced
	name = "Blood-stained Martial Arts Scroll"
	desc = "A scroll penned by the infamous Awakened Dragon, penned with the blood of their \
			disciples, it appears to have clues towards true enlightenment in the path of the Sleeping Carp."
	cost = 25
	item = /obj/item/book/granter/martial/carp/true
	lock_other_purchases = TRUE
	purchasable_from = ~(UPLINK_CLOWN_OPS | UPLINK_NUKE_OPS)

/datum/uplink_item/melees/edagger
	name = "Energy Dagger"
	desc = "A dagger made of energy that looks and functions as a pen when off."
	item = /obj/item/pen/edagger
	cost = 2
