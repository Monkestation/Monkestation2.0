/obj/item/melee/nabber_blade
	name = "Hunting arm"
	desc = "A sharpened, grotesque limb of chitin and hydraulic muscles, designed to pierce into a target and bleed them out like a stuck pig."
	icon = 'icons/obj/nabber_claws.dmi'
	icon_state = "mantis_arm_r"
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	force = 17
	armour_penetration = 7 //Hydraulic muscle-driven arms.
	throwforce = 0 //Buggy.
	throw_range = 0
	throw_speed = 0
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_EDGED
	wound_bonus = 5 // 1/3rd of cleaver
	bare_wound_bonus = 10 // Way less due to the fact that on a random greytider this would give them almost 30 wound_threshold bonus pre-damage calc.
	var/icon_type_on //will manage if a blade should have custom icons.
	var/icon_type_off

/obj/item/melee/nabber_blade/Initialize(mapload,silent,synthetic)
	. = ..() //Always run last. Chain last together repeatedly to modify butcher statistics.
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT) //They're designed for this
	AddComponent(/datum/component/butchering, \
	speed = 3 SECONDS, \
	effectiveness = 85, \
	)

/obj/item/melee/nabber_blade/Destroy()
	icon_type_on = null
	icon_type_off = null
	return ..()

/obj/item/melee/nabber_blade/alt
	icon_state = "mantis_arm_l"

/obj/item/melee/nabber_blade/sharp
	force = 21 //+4 damage to simulate whetstone usage.
	wound_bonus = 15 // Same as cleaver
	bare_wound_bonus = 10 // Less than the default, due to higher flat wound_bonus
	name = "lethally sharpened hunting-arm"

/obj/item/melee/nabber_blade/sharp/alt
	icon_state = "mantis_arm_l" //todo: replace sprites

/obj/item/melee/nabber_blade/sharp/Initialize(mapload,silent,synthetic)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT) //They're designed for this
	var/datum/component/butchering/held_component = src.GetComponent(/datum/component/butchering)
	held_component.effectiveness = 95
	held_component.speed = 1.5 SECONDS

/obj/item/melee/nabber_blade/syndicate
	name = "energy-enhanced bladearm"
	force = 29 //Only 5 less than a DEsword, but way more utility for nabbers.
	armour_penetration = 45 //Almost half AP however
	wound_bonus = 15 //Same as cleaver
	bare_wound_bonus = 20 //Insane, but this is a 18tc item. On-par with double-bladed esword/esword
	hitsound = 'sound/weapons/blade1.ogg'
	hit_reaction_chance = 45 //45% chance to block leaps/melee/unarmed.
	armor_type = /datum/armor/item_shield
	icon_type_on = "blades_on"
	icon_type_off = "blades_off"
	light_system = OVERLAY_LIGHT
	light_outer_range = 5
	light_power = 0.65 //Bright, but not awfully so.
	light_on = TRUE
	light_color = LIGHT_COLOR_INTENSE_RED //Cant forget this

/obj/item/melee/nabber_blade/syndicate/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == UNARMED_ATTACK || attack_type == MELEE_ATTACK || attack_type == LEAP_ATTACK)
		if(prob(hit_reaction_chance))
			owner.visible_message(span_danger("[owner] reflexively blocks [attack_text] with [src]!"))
			return TRUE
	return FALSE

/* Adds balance concerns & a lack of coolness I don't like.
/obj/item/melee/nabber_blade/syndicate/IsReflect() // IF EVERYTHING, ABSOLUTELY EVERYTHING FAILS, ABSOLUTELY MAKE SURE YOU REFLECT AND DO NOT BLOCK.
	return TRUE
*/

/obj/item/melee/nabber_blade/syndicate/Initialize(mapload,silent,synthetic)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT) //They're designed for this
	var/datum/component/butchering/held_component = src.GetComponent(/datum/component/butchering)
	held_component.effectiveness = 65
	held_component.speed = 4 SECONDS //Faster, but they're worse at it.

/obj/item/melee/nabber_blade/syndicate/alt
	icon_state = "mantis_arm_l" //todo: custom sprites.

/obj/item/melee/nabber_blade/pre_attack(atom/Whetstone, mob/living/user, params) //Handles whetstoning your limbs. TODO: Maybe add nabber-specific traitor item for this?
	if (istype(Whetstone, /obj/item/sharpener))
		var/obj/item/sharpener/poorstone = Whetstone
		for(var/datum/action/cooldown/toggle_arms/arms in user.actions)
			if(arms.blade_type != NABBER_ARM_TYPE_REGULAR)
				user.visible_message(span_notice("[user] tries to sharpen their blade-arms... But fails, like a doofus."),
										span_notice("You can't sharpen these!"))
				return FALSE
		if(poorstone.uses >= 1)
			user.visible_message(span_notice("[user] begins to sharpen their massive blade-arms."),
									span_notice("You begin to sharpen your natural weaponry."))
			if(do_after(user, 7 SECONDS, target = src))
				user.visible_message(span_notice("[user] sharpens the large, sharp underside of their bladearms..."),
										span_notice("You sharpen the large underside of your bladearm, ready to kill..."))
				playsound(src, 'sound/items/unsheath.ogg', 100, TRUE)
				poorstone.uses-- //Make sure you cant sharpen both for a single whetstone!
				poorstone.name = "thoroughly ruined whetstone"
				poorstone.desc = "A whetstone, ruined seemingly by sharpening both sides of a massive, bladed limb - ground utterly smooth." //Give a forensic hint as to what ruined it.
				for(var/datum/action/cooldown/toggle_arms/arms in user.actions) //Should only ever be one instance. Make sure to handle it, though
					arms.blade_type = NABBER_ARM_TYPE_SHARPENED
					arms.held_desc = span_notice("has sharpened their blade-arms with what appears to be crude whetstoning, the honed edge gleaming with a dangerous tint...")
			return
		else
			user.visible_message(span_notice("[user] attempts to sharpen their arms, only to find the whetstone too smooth to do so!"),
									span_notice("You fail to even grind the burr away from your chitinous limbs. Use a better stone."))


	if (istype(Whetstone, /obj/item/nabber_energyblades)) //Ideally turn this into a component in the future.
		user.visible_message(span_notice("[user] begins to carefully run their blade-arms through the suspicious case, an ominous red glow present..."),
								span_notice("You lower your arms into the case, utilising the inbuilt autosurgeon to attach several energy-projectors to the undersides."))
		if(do_after(user, 7 SECONDS, target = src))
			user.visible_message(span_notice("[user] raises their blade-arms, a new black-and-red set of projectors providing an ominous nimbus..."),
									span_notice("With your new energy-blades, you're more than ready to kill."))
			playsound(src, 'sound/weapons/saberon.ogg', 100, TRUE)
			qdel(Whetstone) //Destroy the evidence!
			for(var/datum/action/cooldown/toggle_arms/arms in user.actions) //Should only ever be one instance. Make sure to handle it, though
				arms.blade_type = NABBER_ARM_TYPE_SYNDICATE
				arms.held_desc = span_bolddanger("has clearly been modified - several large energy projectors attached to their blade-arms, glowing with the classic red nimbus of syndicate technology...")
		return
	return ..()

/obj/item/melee/nabber_blade/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	else if(istype(target, /obj/structure/chair))
		var/obj/structure/chair/C = target
		C.deconstruct()
	else if(istype(target, /obj/machinery/computer))
		var/obj/machinery/computer/C = target
		C.attack_alien(user)

                      //TRAITOR ITEMS\\

/datum/uplink_item/device_tools/nabber_energyblades
	name = "Energy Projector Attachment Case (EPAC)"
	desc = "Techy, flashy. The ultimate upgrade for a premier predator - this case of energy-projectors allows Nabbers to turn themselves from scary, to downright terrifying. \
		Once attached to their blade-arms, these project a sharp energy-field on-par with a double-bladed energy sword, capable of blocking a majority of incoming fire; while rendering them far more lethal than normal."
	item = /obj/item/nabber_energyblades
	cost = 18 // These give people 28 damage, 45 AP weapons with huge total block and basically no way to remove them past getting their arms cut off.
	restricted_species = list(SPECIES_NABBER) //Whoops.

/obj/item/nabber_energyblades
	name = "sinister case"
	desc = "A sinster black-and-red box, advertised as containing a large supply of nabber-related energy emitters. Printed on the side is instructions on how to attach them to ones bladearms: Open case, slot bladearms inside, wait until process complete."
	w_class = WEIGHT_CLASS_TINY
	icon = 'goon/icons/obj/large_storage.dmi'
	icon_state = "attachecase-old" //stealing these for now.
