//Originally coded for HippieStation by Steamp0rt, shared under the AGPL license.

/obj/item/badmin_stone/supermatter
	name = "Supermatter Stone"
	desc = "Don't touch, it's hot! Oh yeah, and it bends reality."
	stone_type = SUPERMATTER_STONE
	color = "#ECF332"
	ability_text = list(
		"HELP INTENT: Fire a short-range, burning-hot crystal spray.",
		"DISARM INTENT: Fire a short-range fire blast that knocks people back.",
		"HARM INTENT: Fire a long-range, rapid, but low damage volt ray.",
		"Use on a material to use 25 sheets of it for a golem. 2 minute cooldown!"
	)
	spell_types = list (
		/datum/action/cooldown/spell/spacetime_dist/supermatter_stone
	)
	gauntlet_spell_types = list(
		/datum/action/cooldown/spell/pointed/infinity/tesla,
		/datum/action/cooldown/spell/pointed/infinity/delamination
	)
	var/next_golem = 0

/obj/item/badmin_stone/supermatter/disarm_act(atom/target, mob/user, proximity_flag)
	if(!HandleGolem(user, target))
		fire_projectile(/obj/projectile/forcefire, target)
		user.changeNext_move(6)

/obj/item/badmin_stone/supermatter/harm_act(atom/target, mob/user, proximity_flag)
	if(!proximity_flag || !HandleGolem(user, target))
		fire_projectile(/obj/projectile/voltray, target)
		user.changeNext_move(CLICK_CD_RAPID)

/obj/item/badmin_stone/supermatter/help_act(atom/target, mob/user, proximity_flag)
	if(!proximity_flag || !HandleGolem(user, target))
		fire_projectile(/obj/projectile/supermatter_stone, target)
		user.changeNext_move(CLICK_CD_RANGE)


/obj/item/badmin_stone/supermatter/proc/HandleGolem(mob/user, atom/target)
	var/static/list/golem_shell_species_types = list(
		/obj/item/stack/sheet/iron = /datum/species/golem,
		/obj/item/stack/sheet/glass = /datum/species/golem/glass,
		/obj/item/stack/sheet/plasteel = /datum/species/golem/plasteel,
		/obj/item/stack/sheet/mineral/sandstone = /datum/species/golem/sand,
		/obj/item/stack/sheet/mineral/plasma = /datum/species/golem/plasma,
		/obj/item/stack/sheet/mineral/diamond = /datum/species/golem/diamond,
		/obj/item/stack/sheet/mineral/gold = /datum/species/golem/gold,
		/obj/item/stack/sheet/mineral/silver = /datum/species/golem/silver,
		/obj/item/stack/sheet/mineral/uranium = /datum/species/golem/uranium,
		/obj/item/stack/sheet/mineral/bananium = /datum/species/golem/bananium,
		/obj/item/stack/sheet/mineral/titanium = /datum/species/golem/titanium,
		/obj/item/stack/sheet/mineral/plastitanium = /datum/species/golem/plastitanium,
		/obj/item/stack/sheet/mineral/abductor = /datum/species/golem/alloy,
		/obj/item/stack/sheet/mineral/wood = /datum/species/golem/wood,
		/obj/item/stack/sheet/bluespace_crystal = /datum/species/golem/bluespace,
		/obj/item/stack/sheet/runed_metal = /datum/species/golem/runic,
		/obj/item/stack/medical/gauze = /datum/species/golem/cloth,
		/obj/item/stack/sheet/cloth = /datum/species/golem/cloth,
		/obj/item/stack/sheet/mineral/adamantine = /datum/species/golem/adamantine,
		/obj/item/stack/sheet/plastic = /datum/species/golem/plastic,
		/obj/item/stack/sheet/bronze = /datum/species/golem/bronze,
		/obj/item/stack/tile/bronze = /datum/species/golem/clockwork,
		/obj/item/stack/sheet/cardboard = /datum/species/golem/cardboard,
		/obj/item/stack/sheet/leather = /datum/species/golem/leather,
		/obj/item/stack/sheet/bone = /datum/species/golem/bone,
		/obj/item/stack/sheet/durathread = /datum/species/golem/durathread,
		/obj/item/stack/sheet/cotton/durathread = /datum/species/golem/durathread,
		/obj/item/stack/sheet/mineral/metal_hydrogen = /datum/species/golem/mhydrogen
	)
	if(istype(target, /obj/item/stack))
		if(world.time < next_golem)
			to_chat(user, span_notice("You need to wait [DisplayTimeText(world.time-next_golem)] before you can make another golem."))
			return TRUE
		var/obj/item/stack/stack_target = target
		var/species = golem_shell_species_types[stack_target.merge_type]
		if(species)
			if(stack_target.use(25))
				to_chat(user, span_notice("You materialize a golem with 25 sheets of [stack_target]."))
				new /obj/item/golem_shell/servant(get_turf(target), species, user)
				next_golem = world.time + 2 MINUTES
				return TRUE
	return FALSE

/////////////////////////////////////////////
/////////////////// SPELLS //////////////////
/////////////////////////////////////////////

/datum/action/cooldown/spell/spacetime_dist/supermatter_stone
	name = "Supermatter Stone: Reality Distortion"
	desc = "Bend reality until it's unrecognizable for a short time."
	button_icon = 'monkestation/icons/obj/infinity.dmi'
	button_icon_state = "reality"
	spell_requirements = NONE
	antimagic_flags = NONE
	invocation_type = INVOCATION_NONE
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "sm"

/datum/action/cooldown/spell/pointed/infinity/delamination
	name = "Supermatter Stone: Delamination!"
	desc = "After 3 seconds, put a marker on someone, which will EXPLODE after 15 seconds!"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "sm"

/datum/action/cooldown/spell/pointed/infinity/delamination/InterceptClickOn(mob/living/user, params, atom/target)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(target))
		return FALSE
	var/mob/living/living_target = target
	if(locate(/obj/item/badmin_stone) in living_target.get_all_contents())
		living_target.visible_message(span_bolddanger("[living_target] resists an unseen force!"))
		return TRUE
	if(!user.Adjacent(living_target))
		to_chat(user, span_notice("They're too far away!"))
		return FALSE
	if(do_after(user, 30, target = living_target))
		living_target.visible_message(span_bolddanger("[living_target] seems a bit hot..."), span_userdanger("You feel like you'll explode any second!"))
		addtimer(CALLBACK(GLOBAL_PROC, PROC_REF(explosion), living_target, 0, 0, 2, 3, 3, FALSE), 150)
	return TRUE

/////////////////////////////////////////////
/////////////////// STUFF ///////////////////
/////////////////////////////////////////////

/obj/projectile/supermatter_stone
	name = "burning crystal"
	icon_state = "guardian"
	damage = 15
	damage_type = BURN
	color = "#ECF332"
	speed = 0.95
	armour_penetration = 100

/obj/projectile/voltray
	name = "volt ray"
	icon = 'icons/effects/beam.dmi'
	icon_state = "volt_ray"
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	tracer_type = /obj/effect/projectile/tracer/voltray
	muzzle_type = /obj/effect/projectile/muzzle/voltray
	impact_type = /obj/effect/projectile/impact/voltray
	hitscan = TRUE

/obj/projectile/voltray/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.electrocute_act(7, src)

/obj/effect/projectile/tracer/voltray
	name = "volt ray"
	icon_state = "solar"

/obj/effect/projectile/muzzle/voltray
	name = "volt ray"
	icon_state = "muzzle_solar"

/obj/effect/projectile/impact/voltray
	name = "volt ray"
	icon_state = "impact_solar"

/obj/projectile/forcefire
	name = "forcefire"
	icon_state = "plasma"
	damage = 10
	damage_type = BURN
	range = 5
	speed = 0.95
	var/knockback = 3

/obj/projectile/forcefire/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(ismovable(target))
		var/atom/movable/atom_movable_target = target
		if(!atom_movable_target.anchored)
			if(isliving(atom_movable_target))
				var/mob/living/living_target = atom_movable_target
				living_target.adjust_fire_stacks(2)
				living_target.ignite_mob()
				living_target.Paralyze(4)
			atom_movable_target.throw_at(get_edge_target_turf(atom_movable_target, get_dir(src, atom_movable_target)), knockback, 4)

/datum/action/cooldown/spell/pointed/infinity/tesla
	name = "Supermatter Blast"
	desc = "Charge up an arc of supermatter-amped electricity"
	button_icon = 'icons/obj/engine/supermatter.dmi'
	button_icon_state = "destabilizing_crystal"
	background_icon = 'monkestation/icons/obj/infinity.dmi'
	background_icon_state = "sm"
	cast_range = 10
	cooldown_time = 30 SECONDS
	var/bounce_range = 10

/datum/action/cooldown/spell/pointed/infinity/tesla/cast(atom/cast_on)
	. = ..()
	if(iscarbon(cast_on))
		var/mob/living/carbon/target = cast_on
		bolt(owner, target, 40, 10, owner)

/datum/action/cooldown/spell/pointed/infinity/tesla/proc/bolt(mob/origin, mob/target, bolt_energy, bounces, mob/user = usr)
	origin.Beam(target, icon_state = "nzcrentrs_power", time = 5)
	var/mob/living/carbon/current_target = target
	if(bounces < 1)
		current_target.electrocute_act(bolt_energy, SHOCK_TESLA)
		playsound(get_turf(current_target), 'sound/weapons/taser.ogg', 50, 1, -1)
	else
		current_target.electrocute_act(bolt_energy, SHOCK_TESLA)
		playsound(get_turf(current_target), 'sound/weapons/taser.ogg', 50, 1, -1)
		var/list/possible_targets = new
		for(var/mob/living/viewable_living in view(bounce_range, target))
			if(user == viewable_living || target == viewable_living && can_see(current_target, viewable_living, bounce_range))
				continue
			possible_targets += viewable_living
		if(!possible_targets.len)
			return
		var/mob/living/next_target = pick(possible_targets)
		if(next_target)
			bolt(current_target, next_target, max((bolt_energy - 5), 5), bounces - 1, user)
