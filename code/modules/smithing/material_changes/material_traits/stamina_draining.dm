/datum/material_trait/stamina_draining
	name = "Cumbersome"
	desc = "Multiplies the stamina drain by 1.5 times. Includes damage dealt if it deals Stamina Damage!"
	reforges = 6
	value_bonus = -10

/datum/material_trait/stamina_draining/post_parent_init(atom/movable/parent)
	if(isitem(parent))
		var/obj/item/item = parent
		item.stamina_cost *= 1.5
		item.stamina_cost = round(item.stamina_cost)
		if(item.damtype == STAMINA)
			item.force *= 1.5
			item.force = round(item.force)
			if(istype(item,/obj/item/smithed_part))
				var/obj/item/smithed_part/smithed = item
				if(smithed.GetComponent(/datum/component/two_handed))
					smithed.wield_force *= 1.5
					smithed.unwield_force *= 1.5
					smithed.wield_force = round(smithed.wield_force)
					smithed.unwield_force = round(smithed.unwield_force)

