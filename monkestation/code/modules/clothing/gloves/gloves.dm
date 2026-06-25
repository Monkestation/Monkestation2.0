/obj/item/clothing/gloves/combat/maid
	name = "combat maid sleeves"
	desc = "These 'tactical' gloves and sleeves are fireproof and electrically insulated. Warm to boot."
	icon = 'monkestation/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/gloves.dmi'
	icon_state = "syndimaid_arms"

/obj/item/clothing/gloves/crueltysquad_gloves
	name = "CSIJ level I gloves"
	desc = "Armor used by assassins working for Cruelty Squad, stripped of all of its functions for kids to play with."
	icon = 'monkestation/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/gloves.dmi'
	icon_state = "crueltysquad_gloves"

/obj/item/clothing/gloves/civilprotection_gloves
	name = "civil protection gloves"
	desc = "Armored gloves for beating anticitizens."
	icon = 'monkestation/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/gloves.dmi'
	icon_state = "civilprotection_gloves"

/obj/item/clothing/gloves/infinity_gloves
	name = "infinity wristbands"
	desc = "The bands are oddly moist... let's hope it's not blood."
	icon = 'monkestation/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/gloves.dmi'
	icon_state = "infinity_wrist"

/obj/item/clothing/gloves/infinity_gloves/equipped(mob/living/carbon/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_GLOVES)
		var/obj/item/bodypart/user_active_arm = user.get_active_hand()
		user_active_arm.unarmed_damage_low += 0.2
		user_active_arm.unarmed_damage_high += 0.1

/obj/item/clothing/gloves/latex/surgical
	name = "black latex gloves"
	desc = "Pricy sterile gloves that are thinner than latex. The lining allows for the person to operate \
					quicker along with the faster use time of various chemical related items"
	icon = 'monkestation/icons/obj/clothing/gloves.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/gloves.dmi'
	icon_state = "surgeonlatex"
	armor_type = /datum/armor/surgeon
	clothing_traits = list(TRAIT_PERFECT_SURGEON, TRAIT_FASTMED)
	custom_premium_price = PAYCHECK_CREW * 6

/datum/armor/surgeon
	bio = 100

/obj/item/clothing/gloves/tackler/combat/insulated/admiral // Reskin for Abraxis's Admiral set
	icon_state = "admiral"
	worn_icon = 'monkestation/icons/mob/clothing/gloves.dmi'
	icon = 'monkestation/icons/obj/clothing/gloves.dmi'
	alternate_worn_layer = ABOVE_SUIT_LAYER

/obj/item/clothing/gloves/admiral // Loadout version of the Abraxis Centcom Admiral gloves
	name = "black gloves"
	icon_state = "admiral"
	worn_icon = 'monkestation/icons/mob/clothing/gloves.dmi'
	icon = 'monkestation/icons/obj/clothing/gloves.dmi'
	alternate_worn_layer = ABOVE_SUIT_LAYER

/obj/item/clothing/gloves/color/black/dimensional
	desc = "These gloves function as a dimensonal weapon storage using bluespace compression technology. It doesn't muffle surrounding sound; why would it?"

/obj/item/clothing/gloves/color/black/dimensional/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/dimensional_gloves)

/datum/storage/dimensional_gloves
	max_specific_storage = WEIGHT_CLASS_GIGANTIC
	max_total_storage = WEIGHT_CLASS_GIGANTIC * 6
	max_slots = 6

/datum/storage/dimensional_gloves/New(atom/parent, max_slots, max_specific_storage, max_total_storage, numerical_stacking, allow_quick_gather, allow_quick_empty, collection_mode, attack_hand_interact)
	. = ..()
	set_holdable(can_hold_list = list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/gun,
		/obj/item/knife,
		/obj/item/melee,
		/obj/item/nullrod,
		/obj/item/energy_katana,
		/obj/item/throwing_star,
		/obj/item/shield,
		/obj/item/spear,
		/obj/item/dualsaber,
		/obj/item/fireaxe,
		/obj/item/flamethrower,
		/obj/item/chainsaw,
		/obj/item/pitchfork,
		/obj/item/pneumatic_cannon,
		/obj/item/soulscythe,
		/obj/item/claymore,
		/obj/item/katana,
		/obj/item/switchblade,
		/obj/item/cane,
		/obj/item/highfrequencyblade,), \

		cant_hold_list = list(
			/obj/item/gun/magic, // no magic
		)
	)
