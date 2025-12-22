/obj/projectile/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = TOX
	stamina = 20
	knockdown = 2 SECONDS //monkestation edit: replaced 10 second paralyze with thise
	armor_flag = BIO
	impact_effect_type = /obj/effect/temp_visual/impact_effect/neurotoxin

/obj/projectile/neurotoxin/on_hit(atom/target, blocked = 0, pierce_hit)
	if(isalien(target))
		knockdown = 0 SECONDS //monkestation edit: from paralyze to knockdown
		damage = 0
		stamina = 0
	return ..()


/obj/projectile/neurotoxin/damaging //for ai controlled aliums
	damage = 30
	paralyze = 0 SECONDS
