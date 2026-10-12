/obj/item/clothing/under/vox
	name = "alien clothing"
	desc = "A strange set of pants and straps."
	icon = 'icons/obj/clothing/vox/vox_clothing_obj.dmi'
	worn_icon = 'icons/mob/clothing/vox/vox_clothing_mob.dmi'
	icon_state = "vox-jumpsuit"
	clothing_flags = VOX_CLOTHING
	inhand_icon_state = null
	no_worn_offset = TRUE
	can_adjust = FALSE
	body_parts_covered = CHEST|GROIN|LEGS

/obj/item/clothing/shoes/vox
	name = "alien footwear"
	desc = "A pair of heavy, jagged armoured foot pieces, seemingly suitable for a velociraptor."
	icon = 'icons/obj/clothing/vox/vox_clothing_obj.dmi'
	worn_icon = 'icons/mob/clothing/vox/vox_clothing_mob.dmi'
	icon_state = "boots-vox"
	clothing_flags = VOX_CLOTHING
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT

	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	resistance_flags = NONE

/obj/item/clothing/gloves/vox
	name = "insulated gauntlets"
	desc = "These bizarre gauntlets seem to be fitted for... bird claws?"
	icon = 'icons/obj/clothing/vox/vox_clothing_obj.dmi'
	worn_icon = 'icons/mob/clothing/vox/vox_clothing_mob.dmi'
	icon_state = "gloves-vox"
	siemens_coefficient = 0
	clothing_flags = THICKMATERIAL|VOX_CLOTHING
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT

	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	clothing_traits = list(TRAIT_PLANT_SAFE)

/obj/item/clothing/mask/breath/vox
	name = "bizarre breath mask"
	desc = "A close-fitting mask that can be connected to an air supply. This one is enlogated and tapered, strange."
	icon = 'icons/obj/clothing/vox/vox_clothing_obj.dmi'
	worn_icon = 'icons/mob/clothing/vox/vox_clothing_mob.dmi'
	icon_state = "voxmask"
	clothing_flags = MASKINTERNALS|VOX_CLOTHING
	no_worn_offset = TRUE

/obj/item/clothing/suit/hooded/vox_robes
	name = "\improper alien robes"
	desc = "Large, comfortable robes worn by those who need a bit more covering. The thick fabric contains a pocket suitable for those that need their hands free during their work, while the cloth serves to cover scars or other injuries to the wearer's body."
	icon = 'icons/obj/clothing/vox/vox_clothing_obj.dmi'
	worn_icon = 'icons/mob/clothing/vox/vox_clothing_mob.dmi'
	icon_state = "vox-robes"
	clothing_flags = VOX_CLOTHING
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	armor_type = /datum/armor/hooded_vox_robes
	hood_up_affix = "_hood"
	hoodtype = /obj/item/clothing/head/hooded/vox_hood

/datum/armor/hooded_vox_robes
	melee = 10
	laser = 10
	energy = 10
	bio = 50
	fire = 50
	acid = 20

/obj/item/clothing/suit/hooded/vox_robes/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/flashlight,
		/obj/item/lighter,
		/obj/item/modular_computer/pda,
		/obj/item/radio,
		/obj/item/storage/bag/books,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/toy,
	)

/obj/item/clothing/head/hooded/vox_hood
	name = "alien hood"
	desc = "The thick fabric of this hood serves a variety of purposes to the wearer - serving as a method to hide a scarred face or a way to keep warm in the coldest areas onboard the ship."
	icon = 'icons/obj/clothing/vox/vox_clothing_obj.dmi'
	worn_icon = 'icons/mob/clothing/vox/vox_clothing_mob.dmi'
	icon_state = "vox-hood"
	body_parts_covered = HEAD

	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEEARS|HIDEEYES
	clothing_flags = SNUG_FIT|VOX_CLOTHING
	armor_type = /datum/armor/hooded_vox_robes
	clothing_traits = list(TRAIT_SNOWSTORM_IMMUNE)
	no_worn_offset = TRUE

/obj/item/clothing/suit/space/vox
	name = "alien pressure suit"
	desc = "A huge, pressurized suit, designed for distinctly nonhuman proportions. It looks unusually cheap."
	icon = 'icons/obj/clothing/vox/vox_clothing_obj.dmi'
	worn_icon = 'icons/mob/clothing/vox/vox_clothing_mob.dmi'
	icon_state = "vox-pressure-suit"
	clothing_flags = STOPSPRESSUREDAMAGE|THICKMATERIAL|VOX_CLOTHING

/obj/item/clothing/head/helmet/space/vox
	name = "alien helmet"
	desc = "Hey, wasn't this a prop in \'The Abyss\'?"
	icon = 'icons/obj/clothing/vox/vox_clothing_obj.dmi'
	worn_icon = 'icons/mob/clothing/vox/vox_clothing_mob.dmi'
	icon_state = "vox-pressure-helmet"
	clothing_flags = STOPSPRESSUREDAMAGE|THICKMATERIAL|SNUG_FIT|PLASMAMAN_HELMET_EXEMPT|HEADINTERNALS|VOX_CLOTHING
	flags_inv = HIDEMASK|HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/suit/armor/vox
	name = "alien carapace armor"
	desc = "An armored, segmented carapace with glowing purple lights. It looks pretty run-down."
	icon = 'icons/obj/clothing/vox/vox_clothing_obj.dmi'
	worn_icon = 'icons/mob/clothing/vox/vox_clothing_mob.dmi'
	icon_state = "vox-carapace-armor"
	inhand_icon_state = null
	body_parts_covered = CHEST|GROIN|LEGS|ARMS

	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT

	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

	strip_delay = 60
	equip_delay_other = 40
	max_integrity = 300
	clothing_flags = THICKMATERIAL|VOX_CLOTHING
	flags_inv = HIDEJUMPSUIT
	resistance_flags = FIRE_PROOF|ACID_PROOF
	armor_type = /datum/armor/vox_armor

/obj/item/clothing/suit/armor/vox/Initialize(mapload)
	. = ..()
	allowed |= list(
		/obj/item/tank/internals,
		/obj/item/tank/jetpack,
	)

/datum/armor/vox_armor
	melee = 35
	bullet = 35
	laser = 50
	energy = 60
	bomb = 25
	fire = 50
	acid = 100
	bio = 50
	wound = 25

/obj/item/clothing/head/helmet/vox
	name = "alien visored helmet"
	desc = "A glowing visor, perhaps stolen from a depressed Cylon."
	icon = 'icons/obj/clothing/vox/vox_clothing_obj.dmi'
	worn_icon = 'icons/mob/clothing/vox/vox_clothing_mob.dmi'
	icon_state = "vox-carapace-helmet"
	inhand_icon_state = null

	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT

	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

	strip_delay = 60
	equip_delay_other = 40
	max_integrity = 300
	clothing_flags = SNUG_FIT|THICKMATERIAL|HEADINTERNALS|VOX_CLOTHING
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH
	flags_inv = HIDEEARS|HIDEMASK|HIDEEYES|HIDEFACIALHAIR|HIDEFACE
	resistance_flags = FIRE_PROOF|ACID_PROOF
	dog_fashion = null
	armor_type = /datum/armor/vox_armor
	no_worn_offset = TRUE

/obj/item/storage/belt/military/assault/shield
	name = "shielding device"
	desc = "An old high-tech personal shielding device attached to a belt for easier mobility. Protects the wearer from attacks and enviromental hazards such as space, planetary storms, and radiation."
	icon_state = "shield0"
	base_icon_state = "shield"
	inhand_icon_state = "security"

	worn_block = TRUE

	var/mob/living/user = null
	var/charges = 3
	var/max_charges = 3
	var/on = FALSE
	actions_types = list(/datum/action/item_action/toggle)
	// The cooldown tracking when we were last hit
	COOLDOWN_DECLARE(recently_hit_cd)
	/// The cooldown tracking when we last replenished a charge
	COOLDOWN_DECLARE(charge_add_cd)

	var/static/list/gain_traits = list(
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_NOFIRE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_ASHSTORM_IMMUNE,
		TRAIT_RADSTORM_IMMUNE,
		TRAIT_SNOWSTORM_IMMUNE)

/obj/item/storage/belt/military/assault/shield/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][on]"
	worn_icon_state = icon_state

/obj/item/storage/belt/military/assault/shield/update_overlays()
	. = ..()
	. +=  mutable_appearance(icon, "shield_light[charges]")

/obj/item/storage/belt/military/assault/shield/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)
	atom_storage.max_slots = 7

/obj/item/storage/belt/military/assault/shield/ui_action_click(mob/user)
	if(user.get_item_by_slot(ITEM_SLOT_BELT) == src)
		if(!on)
			Activate(user)
		else
			Deactivate(user)
	return

/obj/item/storage/belt/military/assault/shield/item_action_slot_check(slot, mob/user)
	if(slot & ITEM_SLOT_BELT)
		return 1

/obj/item/storage/belt/military/assault/shield/proc/Activate(mob/living/carbon/human/user)
	if(!user)
		return
	if(!COOLDOWN_FINISHED(src, charge_add_cd))
		balloon_alert(user, "on cooldown!")
		return
	src.user = user
	to_chat(user, span_notice("You activate [src]."))
	RegisterSignal(user, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	user.add_traits(gain_traits, REF(src))
	START_PROCESSING(SSobj, src)
	playsound(src, 'sound/magic/charge.ogg', 50, TRUE)
	on = TRUE
	update_appearance(UPDATE_ICON)
	user.update_worn_belt()
	user.update_appearance(UPDATE_ICON)
	slowdown = 1
	user.update_equipment_speed_mods()

/obj/item/storage/belt/military/assault/shield/proc/on_update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	if(!on)
		return
	var/mutable_appearance/shield_appearance = mutable_appearance('icons/effects/effects.dmi', "psychic", MOB_SHIELD_LAYER)
	if(ishuman(user))
		var/mob/living/carbon/human/human_wearer = user
		human_wearer.apply_height_filters(shield_appearance)
	overlays += shield_appearance

/obj/item/storage/belt/military/assault/shield/proc/Deactivate(display_message)
	STOP_PROCESSING(SSobj, src)
	on = FALSE
	update_appearance(UPDATE_ICON)
	slowdown = 0
	if(user)
		if(display_message)
			to_chat(user, span_notice("You deactivate [src]."))
		user.remove_traits(gain_traits, REF(src))
		user.update_appearance(UPDATE_ICON)
		user.update_worn_belt()
		user.update_equipment_speed_mods()
	UnregisterSignal(user, COMSIG_ATOM_UPDATE_OVERLAYS)
	user = null

/obj/item/storage/belt/military/assault/shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	. = ..()

	if(!on)
		return
	//No wearer? No block.
	if(isnull(user))
		return

	//if our wearer isn't the owner of the block, don't block
	if(owner != user)
		return

	if(charges <= 0)
		return

	if(!damage)
		return

	if(!COOLDOWN_FINISHED(src, recently_hit_cd))
		return

	owner.visible_message(span_danger("[user]'s shields deflect [attack_text] in a shower of sparks!"))

	var/datum/effect_system/spark_spread/quantum/spark_system = new /datum/effect_system/spark_spread/quantum()
	spark_system.set_up(5, TRUE, src)
	spark_system.start()

	COOLDOWN_START(src, recently_hit_cd, 1 SECOND)
	COOLDOWN_START(src, charge_add_cd, 10 SECONDS)

	charges--

	update_appearance(UPDATE_ICON)
	user.update_appearance(UPDATE_ICON)

	if(charges <= 0)
		balloon_alert(user, "out of charge!")
		INVOKE_ASYNC(src, PROC_REF(Deactivate), display_message = FALSE)

	return TRUE

/obj/item/storage/belt/military/assault/shield/dropped(mob/user)
	..()
	if(user && user.get_item_by_slot(ITEM_SLOT_BELT) != src)
		Deactivate()

/obj/item/storage/belt/military/assault/shield/process(seconds_per_tick)
	if(user.get_item_by_slot(ITEM_SLOT_BELT) != src)
		do_sparks(2, TRUE, src)
		Deactivate(display_message = FALSE)
		return

	if(!on)
		Deactivate(display_message = FALSE)
		return
	if(charges >= max_charges)
		return
	if(!COOLDOWN_FINISHED(src, charge_add_cd))
		return

	charges++

	if(charges == max_charges)
		playsound(src, 'sound/machines/ding.ogg', 50, TRUE)
	else
		playsound(src, 'sound/magic/charge.ogg', 50, TRUE)

	update_appearance(UPDATE_ICON)

	COOLDOWN_START(src, charge_add_cd, 10 SECONDS)

