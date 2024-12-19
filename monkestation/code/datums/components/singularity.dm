/datum/component/singularity/consume_bullets(datum/source, obj/projectile/projectile)
	if(istype(projectile, /obj/projectile/bullet/srn_rocket))
		return NONE
	return ..()
