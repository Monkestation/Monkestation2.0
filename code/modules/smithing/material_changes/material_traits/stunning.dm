/datum/material_trait/stunning
	name = "Stunning"
	desc = "Changes the weapon damage type to stamina."
	value_bonus = 50

/datum/material_trait/stunning/post_parent_init(atom/movable/parent)
	if(isobj(parent))
		var/obj/obj = parent
		obj.damtype = STAMINA
		obj.force *= 1.75 //People have more stamina than health.
		obj.force = round(obj.force)
		if(istype(obj,/obj/item/smithed_part))
			var/obj/item/smithed_part/smithed = obj
			if(smithed.GetComponent(/datum/component/two_handed))
				smithed.wield_force *= 1.5
				smithed.unwield_force *= 1.5
				smithed.wield_force = round(smithed.wield_force)
				smithed.unwield_force = round(smithed.unwield_force)
