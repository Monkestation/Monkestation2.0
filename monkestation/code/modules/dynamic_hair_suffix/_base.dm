/obj/item/clothing
	/// These allow head/mask items to dynamically alter the user's hair
	/// and facial hair, checking hair_extensions.dmi and facialhair_extensions.dmi
	/// for a state matching hair_state+dynamic_hair_suffix
	/// THESE OVERRIDE THE HIDEHAIR FLAGS
	var/dynamic_hair_suffix = "" //head > mask for head hair
	var/dynamic_fhair_suffix = "" //mask > head for facial hair

/obj/item/clothing/equipped(mob/living/user, slot)
	. = ..()
	if(ishuman(user) && (dynamic_hair_suffix || dynamic_fhair_suffix))
		user.regenerate_icons()

/obj/item/clothing/dropped(mob/living/user)
	. = ..()
	if(ishuman(user) && (dynamic_hair_suffix || dynamic_fhair_suffix))
		user.regenerate_icons()

/obj/item/clothing/head
	dynamic_hair_suffix = "+generic"

/proc/monke_hair_suffix_thing(obj/item/clothing/clothing, hair_ptr = null, fhair_ptr = null)
	if(!istype(clothing))
		return
	if(!isnull(hair_ptr))
		*hair_ptr = clothing.dynamic_hair_suffix
	if(!isnull(fhair_ptr))
		*fhair_ptr = clothing.dynamic_fhair_suffix
