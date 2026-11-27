///Stuff used in Central Command Liaison Outpost Ruin.

// Outpost-specific production pulse weapons. Native weapons remain unchanged.
// Use plain beam projectiles rather than the destructive native pulse parent.
#define CCPOST_PRODUCTION_CHARGE LASER_SHOTS(200, STANDARD_CELL_CHARGE * 40)
#define CCPOST_OVERCHARGE_COST (3 * CCPOST_PRODUCTION_CHARGE)
#define CCPOST_REPULSOR_COOLDOWN (6 SECONDS)
#define CCPOST_CONTAINMENT_COOLDOWN (10 SECONDS)

/obj/projectile/beam/ccpost_pulse
	name = "corporate pulse"
	icon_state = "u_laser"
	damage = 25
	pass_flags = PASSTABLE | PASSWINDOW | PASSGRILLE
	projectile_phasing = PASSWINDOW
	phasing_ignore_direct_target = TRUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/pulse
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	impact_type = /obj/effect/projectile/impact/pulse
	wound_bonus = 10
	demolition_mod = 0
	damage_walls = FALSE

/obj/projectile/beam/ccpost_pulse/carbine
	damage = 40

/obj/projectile/beam/ccpost_pulse/overcharge
	name = "overcharged corporate pulse"
	damage = 45
	light_color = "#BCEBFF"
	light_outer_range = 2
	light_power = 1.4
	ricochets_max = 0

/obj/projectile/beam/ccpost_pulse/overcharge/Initialize(mapload)
	. = ..()
	transform = matrix() * 1.4

/obj/projectile/beam/ccpost_pulse/overcharge/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	// Localized light EMP, not a room-wide blast. Window phasing never calls on_hit.
	if(!QDELETED(target) && blocked < 100 && . != BULLET_ACT_BLOCK)
		target.emp_act(EMP_LIGHT)

/obj/projectile/beam/ccpost_pulse/repulsor
	name = "corporate repulsor bolt"
	icon_state = "omnilaser"
	damage = 5
	damage_type = BRUTE
	armor_flag = ENERGY
	range = 3
	wound_bonus = -30
	bare_wound_bonus = 0
	eyeblur = 0
	pass_flags = PASSTABLE
	projectile_phasing = NONE
	ricochets_max = 0
	reflectable = FALSE
	light_color = "#51D9EE"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ccpost_chimera_cyan

/obj/projectile/beam/ccpost_pulse/repulsor/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!isliving(target) || QDELETED(target) || blocked >= 100 || . == BULLET_ACT_BLOCK)
		return
	var/mob/living/victim = target
	var/direction = angle2dir(angle)
	var/turf/destination = get_ranged_target_turf(victim, direction, 5)
	if(destination && destination != get_turf(victim))
		// Native throw collision handles walls, doors, mobs and other obstacles.
		victim.throw_at(destination, 5, 2, firer, spin = FALSE)

/obj/projectile/beam/ccpost_pulse/containment
	name = "corporate containment bolt"
	icon_state = "omnilaser"
	damage = 0
	stamina = 25
	armor_flag = ENERGY
	wound_bonus = -30
	bare_wound_bonus = 0
	eyeblur = 0
	ricochets_max = 0
	reflectable = FALSE
	light_color = "#C17CFF"
	color = "#C17CFF"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser

/obj/projectile/beam/ccpost_pulse/containment/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(isliving(target) && !QDELETED(target) && blocked < 100 && . != BULLET_ACT_BLOCK)
		var/mob/living/victim = target
		victim.apply_status_effect(/datum/status_effect/ccpost_containment)

/datum/movespeed_modifier/ccpost_containment
	multiplicative_slowdown = 2

/datum/status_effect/ccpost_containment
	id = "ccpost_containment"
	duration = 5 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

/datum/status_effect/ccpost_containment/on_apply()
	. = ..()
	if(!.)
		return
	owner.add_movespeed_modifier(/datum/movespeed_modifier/ccpost_containment)
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(draw_containment_shield))
	owner.update_appearance(UPDATE_ICON)
	owner.balloon_alert(owner, "movement suppressed!")
	return TRUE

/// Visual only: use the same native overlay layer as the MOD energy shield.
/// Rebuilds with the owner's icon and persists until this status is removed.
/datum/status_effect/ccpost_containment/proc/draw_containment_shield(atom/source, list/overlays)
	SIGNAL_HANDLER
	// shield1 uses animated concentric rings instead of electrical arcs.
	var/mutable_appearance/field = mutable_appearance('icons/effects/effects.dmi', "shield1", MOB_SHIELD_LAYER)
	// The source art is blue/cyan: map its energy channels to violet.
	field.color = ccpost_experimental_energy_matrix("#C17CFF", 0, 0.35, 0.65)
	field.alpha = 180
	overlays += field

/datum/status_effect/ccpost_containment/on_remove()
	UnregisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/ccpost_containment)
	if(!QDELETED(owner))
		owner.update_appearance(UPDATE_ICON)
		var/turf/location = get_turf(owner)
		if(location)
			new /obj/effect/temp_visual/ccpost_containment_dissipate(location)
	return ..()

// One cosmetic burst when the field ends; no shield component or damage.
/obj/effect/temp_visual/ccpost_containment_dissipate
	name = "dissipating containment field"
	icon = 'icons/effects/effects.dmi'
	icon_state = "purplesparkles"
	duration = 6
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = MOB_SHIELD_LAYER

// Standalone version of the Chimera suppression bolt. Deliberately NOT a
// subtype of Chimera: the radial attack's one-hit-per-volley cap must not apply.
/obj/projectile/beam/ccpost_pulse/scatter
	name = "corporate suppression bolt"
	icon_state = "omnilaser"
	damage = 5
	stamina = 12
	armor_flag = ENERGY
	speed = 2
	range = 6
	ricochets_max = 0
	reflectable = FALSE
	eyeblur = 0
	wound_bonus = -20
	bare_wound_bonus = 0
	light_color = "#51D9EE"
	color = "#51D9EE"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ccpost_chimera_cyan

/obj/item/ammo_casing/energy/laser/pulse/ccpost
	projectile_type = /obj/projectile/beam/ccpost_pulse
	select_name = "Pulse"

/obj/item/ammo_casing/energy/laser/pulse/ccpost/carbine
	projectile_type = /obj/projectile/beam/ccpost_pulse/carbine

/obj/item/ammo_casing/energy/laser/pulse/ccpost/repulsor
	projectile_type = /obj/projectile/beam/ccpost_pulse/repulsor
	select_name = "Repulsor"
	e_cost = 2 * CCPOST_PRODUCTION_CHARGE

/obj/item/ammo_casing/energy/laser/pulse/ccpost/containment
	projectile_type = /obj/projectile/beam/ccpost_pulse/containment
	select_name = "Containment"
	e_cost = 2 * CCPOST_PRODUCTION_CHARGE
	harmful = FALSE
	fire_sound = 'sound/items/weapons/gun/energy/Laser2.ogg'

/obj/item/ammo_casing/energy/laser/pulse/ccpost/scatter
	projectile_type = /obj/projectile/beam/ccpost_pulse/scatter
	select_name = "Scatter"
	e_cost = 3 * CCPOST_PRODUCTION_CHARGE
	pellets = 5
	variance = 45
	fire_sound = 'sound/items/weapons/gun/energy/Laser2.ogg'

// Retain the old casing paths for compatibility with existing references.
/obj/projectile/beam/laser/ccpost
	demolition_mod = 0
	damage_walls = FALSE

/obj/item/ammo_casing/energy/laser/ccpost
	projectile_type = /obj/projectile/beam/laser/ccpost

/obj/item/stock_parts/power_store/cell/pulse/pistol/ccpost
	name = "corporate pulse pistol power cell"
	maxcharge = 6 * CCPOST_PRODUCTION_CHARGE

/obj/item/stock_parts/power_store/cell/pulse/carbine/ccpost
	name = "corporate security carbine power cell"
	maxcharge = 18 * CCPOST_PRODUCTION_CHARGE

/// Actual HR-enrolled mind and original body; no ID, mindshield or access shortcut.
/proc/ccpost_production_weapon_authorized(mob/living/user)
	if(!user || !GLOB.ccpost_hr_service)
		return FALSE
	var/datum/ccpost_hr_employee/record = GLOB.ccpost_hr_service.employee_for(user, FALSE)
	return record && (record.employee_role == "Central Command Liaison" || record.employee_role == "Outpost Security Officer")

/obj/item/firing_pin/ccpost_outpost
	name = "Central Command outpost authentication pin"
	desc = "A sealed personnel authentication device keyed to the registered employees of the Central Command Liaison Outpost."
	icon_state = "firing_pin_loyalty"
	pin_removable = FALSE
	fail_message = "outpost authentication failed!"

/obj/item/firing_pin/ccpost_outpost/pin_auth(mob/living/user)
	return ccpost_production_weapon_authorized(user)

/obj/item/firing_pin/ccpost_outpost/emag_act(mob/user, obj/item/card/emag/emag_card)
	balloon_alert(user, "sealed authentication module!")
	return FALSE

/// Only the sidearm has a destructive response; localized to its operator.
/obj/item/firing_pin/ccpost_outpost/asset_denial
	name = "Central Command asset denial firing pin"
	desc = "A sealed authentication device with a permanent destructive countermeasure against unauthorized discharge."
	var/denial_triggered = FALSE

/obj/item/firing_pin/ccpost_outpost/asset_denial/auth_fail(mob/living/user)
	if(denial_triggered || QDELETED(gun))
		return
	denial_triggered = TRUE
	var/obj/item/gun/weapon = gun
	if(user)
		user.visible_message(span_danger("[weapon] detonates in [user]'s hands!"), span_userdanger("UNAUTHORIZED OPERATOR. ASSET DENIAL INITIATED! [weapon] explodes in your hands!"))
		user.apply_damage(40, BURN, BODY_ZONE_CHEST)
		user.Knockdown(2 SECONDS)
	var/turf/location = get_turf(weapon)
	if(location)
		playsound(location, 'sound/effects/explosion/explosion1.ogg', 65, TRUE)
		do_sparks(5, FALSE, location)
		new /obj/effect/temp_visual/ccpost_chimera_radial_flash(location)
	qdel(weapon)

// Cosmetic only: the native spark particle exposes turfs to heat, so reuse
// its existing artwork without the particle's ignition or movement effects.
/obj/effect/temp_visual/ccpost_overcharge_spark
	name = "pulse emitter sparks"
	icon = 'icons/effects/effects.dmi'
	icon_state = "sparks"
	duration = 5
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = MOB_SHIELD_LAYER
	alpha = 210

// Keep the original type paths used by outfits and maps, but borrow the existing
// Cryo Pistol and Ion Carbine art. Both DMI states have charge1..4 and empty.
/obj/item/gun/energy/pulse/pistol/m1911/ccpost
	name = "\improper NT-P6 corporate pulse sidearm"
	desc = "A revolver-pattern pulse sidearm commissioned for NanoTrasen's Central Command Liaisons. Unlike conventional pulse weaponry, the NT-P6 operates at a reduced energy output to minimize collateral damage within corporate installations. Its regenerative power cell supports standard pulse fire, concentrated overcharged discharges and kinetic repulsor blasts. Proprietary personnel authentication and a sealed asset denial system protect the weapon from unauthorized use."
	icon_state = "cryopistol"
	inhand_icon_state = null
	worn_icon_state = "gun"
	modifystate = FALSE
	shaded_charge = TRUE
	charge_sections = 4
	automatic_charge_overlays = FALSE
	cell_type = /obj/item/stock_parts/power_store/cell/pulse/pistol/ccpost
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse/ccpost, /obj/item/ammo_casing/energy/laser/pulse/ccpost/repulsor)
	pin = /obj/item/firing_pin/ccpost_outpost/asset_denial
	selfcharge = TRUE
	charge_delay = 20
	var/overcharge_state = 0 // 0: normal, 1: charging, 2: primed
	var/overcharge_token = 0
	var/datum/weakref/overcharge_operator
	var/asset_denial_started = FALSE
	var/repulsor_ready_at = 0

/obj/item/gun/energy/pulse/pistol/m1911/ccpost/Initialize(mapload)
	. = ..()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_delay = shot.delay
	fire_sound = shot.fire_sound

/obj/item/gun/energy/pulse/pistol/m1911/ccpost/handle_pins(mob/living/user)
	if(ccpost_production_weapon_authorized(user))
		return TRUE
	// Enforce the sealed countermeasure even if an external interaction replaced
	// or emagged the pin. Unauthorized dry firing is also an attempt.
	if(!asset_denial_started)
		asset_denial_started = TRUE
		var/obj/item/firing_pin/ccpost_outpost/asset_denial/denial = pin
		if(!istype(denial))
			denial = new /obj/item/firing_pin/ccpost_outpost/asset_denial(src)
			denial.gun = src
		denial.auth_fail(user)
	return FALSE

/obj/item/gun/energy/pulse/pistol/m1911/ccpost/can_trigger_gun(mob/living/user, akimbo_usage)
	// Merely carrying a stolen sidearm in the off hand is not a trigger pull.
	if(akimbo_usage && !ccpost_production_weapon_authorized(user))
		return FALSE
	. = ..()
	if(!.)
		return FALSE
	if(select == 2 && world.time < repulsor_ready_at)
		if(!akimbo_usage)
			balloon_alert(user, "repulsor recharging!")
		return FALSE

/obj/item/gun/energy/pulse/pistol/m1911/ccpost/examine(mob/user)
	. = ..()
	. += span_notice("Click in hand to switch Pulse/Repulsor. Alt-click while held in Pulse mode with at least three charges to charge or cancel an Overcharged Pulse. The charged shot consumes three charges. Repulsor has a six-second cooldown.")
	. += span_warning("ASSET DENIAL: Unauthorized firing attempts permanently destroy this weapon, even when its cell is empty.")
	if(overcharge_state)
		. += span_notice(overcharge_state == 2 ? "Overcharged Pulse ready." : "Overcharged Pulse charging.")

/obj/item/gun/energy/pulse/pistol/m1911/ccpost/click_alt(mob/user)
	if(!isliving(user) || !user.is_holding(src) || !ccpost_production_weapon_authorized(user))
		return CLICK_ACTION_SUCCESS
	var/mob/living/operator = user
	if(operator.incapacitated())
		return CLICK_ACTION_SUCCESS
	if(overcharge_state)
		cancel_overcharge()
		balloon_alert(operator, "overcharge cancelled")
		return CLICK_ACTION_SUCCESS
	if(select != 1 || !cell || cell.charge < CCPOST_OVERCHARGE_COST || semicd)
		balloon_alert(operator, "pulse mode and three charges required!")
		return CLICK_ACTION_SUCCESS
	overcharge_state = 1
	overcharge_operator = WEAKREF(operator)
	var/token = ++overcharge_token
	operator.visible_message(span_warning("[operator] begins charging [src]'s pulse emitter!"))
	balloon_alert(operator, "charging pulse...")
	playsound(src, 'sound/items/modsuit/ballin.ogg', 40, TRUE)
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(finish_overcharge), token), 2 SECONDS)
	emit_overcharge_sparks()
	addtimer(CALLBACK(src, PROC_REF(overcharge_spark_tick), token, 1), 1 SECONDS)
	return CLICK_ACTION_SUCCESS

/obj/item/gun/energy/pulse/pistol/m1911/ccpost/proc/finish_overcharge(token)
	if(token != overcharge_token || overcharge_state != 1)
		return
	var/mob/living/operator = overcharge_operator?.resolve()
	if(!operator || !operator.is_holding(src) || operator.incapacitated() || !ccpost_production_weapon_authorized(operator) || select != 1 || !cell || cell.charge < CCPOST_OVERCHARGE_COST)
		cancel_overcharge()
		return
	overcharge_state = 2
	balloon_alert(operator, "overcharged pulse ready!")
	playsound(src, 'sound/machines/beep/beep.ogg', 40, TRUE)
	update_appearance()
	// A primed shot cannot remain stored indefinitely. Cancellation is free.
	addtimer(CALLBACK(src, PROC_REF(expire_overcharge), token), 10 SECONDS)
	emit_overcharge_sparks()
	addtimer(CALLBACK(src, PROC_REF(overcharge_spark_tick), token, 2), 3 SECONDS)

/obj/item/gun/energy/pulse/pistol/m1911/ccpost/proc/emit_overcharge_sparks(discharge = FALSE)
	var/turf/location = get_turf(src)
	if(!location)
		return
	var/count = discharge ? 2 : 1
	for(var/i in 1 to count)
		var/obj/effect/temp_visual/ccpost_overcharge_spark/spark = new(location)
		spark.pixel_x = rand(-6, 6)
		spark.pixel_y = rand(-3, 5)
		spark.transform = matrix() * (discharge ? 1.1 : 0.75)
		if(discharge)
			spark.alpha = 255

/obj/item/gun/energy/pulse/pistol/m1911/ccpost/proc/overcharge_spark_tick(token, expected_state)
	// Token and phase guard stale timers after cancellation, firing or reprime.
	if(QDELETED(src) || token != overcharge_token || overcharge_state != expected_state)
		return
	var/mob/living/operator = overcharge_operator?.resolve()
	if(!operator || !operator.is_holding(src) || operator.incapacitated() || !ccpost_production_weapon_authorized(operator) || select != 1 || !cell || cell.charge < CCPOST_OVERCHARGE_COST)
		cancel_overcharge()
		return
	emit_overcharge_sparks()
	if(expected_state == 2)
		addtimer(CALLBACK(src, PROC_REF(overcharge_spark_tick), token, 2), 3 SECONDS)

/obj/item/gun/energy/pulse/pistol/m1911/ccpost/proc/expire_overcharge(token)
	if(token == overcharge_token && overcharge_state == 2)
		cancel_overcharge()

/obj/item/gun/energy/pulse/pistol/m1911/ccpost/proc/cancel_overcharge()
	if(!overcharge_state)
		return
	overcharge_token++
	overcharge_state = 0
	overcharge_operator = null
	update_appearance()

/obj/item/gun/energy/pulse/pistol/m1911/ccpost/select_fire(mob/living/user)
	cancel_overcharge()
	return ..()

/obj/item/gun/energy/pulse/pistol/m1911/ccpost/dropped(mob/user, silent)
	cancel_overcharge()
	return ..()

/obj/item/gun/energy/pulse/pistol/m1911/ccpost/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	// Recheck here too: some native firing paths call process_fire directly.
	if(!handle_pins(user))
		return FALSE
	if(overcharge_state == 1)
		balloon_alert(user, "pulse charging!")
		return FALSE
	if(overcharge_state != 2)
		var/is_repulsor = select == 2
		if(is_repulsor && world.time < repulsor_ready_at)
			balloon_alert(user, "repulsor recharging!")
			return FALSE
		. = ..()
		if(. && is_repulsor && !QDELETED(src))
			repulsor_ready_at = world.time + CCPOST_REPULSOR_COOLDOWN
		return .
	if(semicd || select != 1 || !cell || cell.charge < CCPOST_OVERCHARGE_COST || overcharge_operator?.resolve() != user || !user.is_holding(src))
		cancel_overcharge()
		return FALSE
	// Temporarily replace ONLY the chambered Pulse casing's projectile/cost.
	// Native process_fire handles aim, cooldown, pacifism, logs and charge drain.
	// Never insert a third selectable mode or leave the charged projectile loaded.
	var/obj/item/ammo_casing/energy/shot = ammo_type[1]
	var/old_projectile = shot.projectile_type
	var/old_cost = shot.e_cost
	var/old_sound = fire_sound
	shot.projectile_type = /obj/projectile/beam/ccpost_pulse/overcharge
	shot.e_cost = CCPOST_OVERCHARGE_COST
	QDEL_NULL(shot.loaded_projectile)
	chambered = null
	recharge_newshot(TRUE)
	fire_sound = 'monkestation/code/modules/blueshift/sounds/laser_firing/vaporize.ogg'
	. = ..()
	if(QDELETED(src) || QDELETED(shot))
		return .
	shot.projectile_type = old_projectile
	shot.e_cost = old_cost
	fire_sound = old_sound
	QDEL_NULL(shot.loaded_projectile)
	chambered = null
	recharge_newshot(TRUE)
	cancel_overcharge()
	if(.)
		charge_timer = 0
		emit_overcharge_sparks(discharge = TRUE)
	update_appearance()
	return .

// Recover a fixed pulse shot every 20 seconds, independent of tick frequency.
/obj/item/gun/energy/pulse/pistol/m1911/ccpost/process(seconds_per_tick)
	if(overcharge_state)
		var/mob/living/operator = overcharge_operator?.resolve()
		if(!operator || !operator.is_holding(src) || operator.incapacitated() || !cell || cell.charge < CCPOST_OVERCHARGE_COST)
			cancel_overcharge()
	if(!cell || cell.percent() >= 100)
		charge_timer = 0
		return
	charge_timer += seconds_per_tick
	if(charge_timer < charge_delay)
		return
	var/charge_ticks = FLOOR(charge_timer / charge_delay, 1)
	charge_timer -= charge_ticks * charge_delay
	cell.give(charge_ticks * CCPOST_PRODUCTION_CHARGE)
	if(!chambered)
		recharge_newshot(TRUE)
	update_appearance()

/obj/item/gun/energy/pulse/pistol/m1911/ccpost/proc/production_energy_tint()
	if(overcharge_state)
		return overcharge_state == 2 ? "#D4F6FF" : "#83C9FF"
	return select == 2 ? "#51D9EE" : "#3569D6"

/obj/item/gun/energy/pulse/pistol/m1911/ccpost/update_icon_state()
	. = ..()
	var/ratio = get_charge_ratio()
	lefthand_file = ccpost_production_held_icon(initial(lefthand_file), icon_state, ratio, production_energy_tint())
	righthand_file = ccpost_production_held_icon(initial(righthand_file), icon_state, ratio, production_energy_tint())

/obj/item/gun/energy/pulse/pistol/m1911/ccpost/update_overlays()
	. = ..()
	if(cell)
		. += ccpost_production_charge_overlay(src, production_energy_tint())

/obj/item/gun/energy/pulse/carbine/ccpost
	name = "\improper NT-PC corporate security pulse carbine"
	desc = "A military-pattern pulse carbine commissioned for Central Command installation security. Although less powerful than standard pulse weaponry, the NT-PC compensates with specialized personnel containment and directional suppression configurations. Its regulated energy output provides effective firepower while minimizing damage to sensitive corporate infrastructure. Restricted to authorized outpost personnel."
	icon_state = "ioncarbine"
	inhand_icon_state = null
	worn_icon_state = "gun"
	modifystate = FALSE
	shaded_charge = TRUE
	charge_sections = 4
	automatic_charge_overlays = FALSE
	cell_type = /obj/item/stock_parts/power_store/cell/pulse/carbine/ccpost
	ammo_type = list(/obj/item/ammo_casing/energy/laser/pulse/ccpost/carbine, /obj/item/ammo_casing/energy/laser/pulse/ccpost/containment, /obj/item/ammo_casing/energy/laser/pulse/ccpost/scatter)
	pin = /obj/item/firing_pin/ccpost_outpost
	selfcharge = FALSE
	var/containment_ready_at = 0

/obj/item/gun/energy/pulse/carbine/ccpost/Initialize(mapload)
	. = ..()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_delay = shot.delay
	fire_sound = shot.fire_sound

/obj/item/gun/energy/pulse/carbine/ccpost/handle_pins(mob/living/user)
	if(ccpost_production_weapon_authorized(user))
		return TRUE
	balloon_alert(user, "outpost authentication failed!")
	return FALSE

/obj/item/gun/energy/pulse/carbine/ccpost/can_trigger_gun(mob/living/user, akimbo_usage)
	. = ..()
	if(!.)
		return FALSE
	if(select == 2 && world.time < containment_ready_at)
		if(!akimbo_usage)
			balloon_alert(user, "containment recharging!")
		return FALSE

/obj/item/gun/energy/pulse/carbine/ccpost/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(!handle_pins(user))
		return FALSE
	var/is_containment = select == 2
	if(is_containment && world.time < containment_ready_at)
		balloon_alert(user, "containment recharging!")
		return FALSE
	. = ..()
	if(. && is_containment && !QDELETED(src))
		containment_ready_at = world.time + CCPOST_CONTAINMENT_COOLDOWN
	return .

/obj/item/gun/energy/pulse/carbine/ccpost/examine(mob/user)
	. = ..()
	. += span_notice("Click in hand to cycle Pulse, Containment and Scatter. Containment slows targets for five seconds and has a ten-second cooldown. All three modes share an 18-charge cell; a weapon charger is required to replenish it.")

/obj/item/gun/energy/pulse/carbine/ccpost/proc/production_energy_tint()
	if(select == 2)
		return "#C17CFF"
	if(select == 3)
		return "#51D9EE"
	return "#3569D6"

/obj/item/gun/energy/pulse/carbine/ccpost/update_icon_state()
	. = ..()
	var/ratio = get_charge_ratio()
	lefthand_file = ccpost_production_held_icon(initial(lefthand_file), icon_state, ratio, production_energy_tint())
	righthand_file = ccpost_production_held_icon(initial(righthand_file), icon_state, ratio, production_energy_tint())

/obj/item/gun/energy/pulse/carbine/ccpost/update_overlays()
	. = ..()
	if(cell)
		. += ccpost_production_charge_overlay(src, production_energy_tint())

/// Reuse Chimera's color-matrix helper on the isolated native charge layer only.
/// Do not alter the physical chassis or any source DMI file.
/proc/ccpost_production_charge_overlay(obj/item/gun/energy/weapon, tint)
	var/ratio = weapon.get_charge_ratio()
	var/state = ratio ? "[weapon.icon_state]_charge[ratio]" : "[weapon.icon_state]_empty"
	var/mutable_appearance/charge = mutable_appearance(weapon.icon, state)
	if(ratio)
		charge.color = ccpost_experimental_energy_matrix(tint, 0.33, 0.34, 0.33)
	return charge

/// Both native hand sheets have complete 4-direction charge states (0..4),
/// not separate glow overlays. The exact opaque energy colors were inspected
/// in both sheets. Recolor only those colors, preserving the chassis and the
/// dark unlit charge segments. Cache small directional sets, not full sheets.
/proc/ccpost_production_held_icon(source_file, base_state, ratio, tint)
	if(!ratio)
		return source_file
	var/static/list/held_cache = list()
	var/cache_key = "[source_file]|[base_state]|[tint]"
	if(held_cache[cache_key])
		return held_cache[cache_key]
	var/list/source_colors
	switch(base_state)
		if("cryopistol")
			source_colors = list("#29218D", "#74E8EB")
		if("ioncarbine")
			source_colors = list("#33FFFF", "#FF3300", "#FF6600", "#FF9900", "#E6A400", "#FFCD00", "#0FCF00", "#66FF00")
		else
			return source_file
	var/list/states = icon_states(source_file)
	var/icon/result = icon()
	for(var/level in 1 to 4)
		var/state = "[base_state][level]"
		if(!(state in states))
			return source_file
		for(var/direction in GLOB.cardinals)
			var/icon/held_frame = icon(source_file, state, direction, 1)
			result.Insert(held_frame, state, direction, 1)
	var/tint_red = hex2num(copytext(tint, 2, 4)) / 255
	var/tint_green = hex2num(copytext(tint, 4, 6)) / 255
	var/tint_blue = hex2num(copytext(tint, 6, 8)) / 255
	for(var/pixel in source_colors)
		var/red = hex2num(copytext(pixel, 2, 4))
		var/green = hex2num(copytext(pixel, 4, 6))
		var/blue = hex2num(copytext(pixel, 6, 8))
		var/gray = round(0.65 * max(red, green, blue) + 0.35 * (0.2126 * red + 0.7152 * green + 0.0722 * blue))
		result.SwapColor(lowertext(pixel), rgb(round(gray * tint_red), round(gray * tint_green), round(gray * tint_blue), 255))
	held_cache[cache_key] = result
	return result

#undef CCPOST_OVERCHARGE_COST
#undef CCPOST_REPULSOR_COOLDOWN
#undef CCPOST_CONTAINMENT_COOLDOWN
#undef CCPOST_PRODUCTION_CHARGE

/obj/item/paper/fluff/ruins/ccpost/transmission
	default_raw_text = "Nothing of interest"

/// General assignment directive for Central Command Outpost personnel.
/obj/item/paper/fluff/ruins/ccpost/transmission/assignment
	name = "Central Command outpost assignment directive"
	default_raw_text = {"<center><table border="0" cellspacing="0" cellpadding="4" bgcolor="#0a1e2b" style="border: 4px solid white; border-radius: 10px; font-family: Bahnschrift, sans-serif;"><tr><td><font color="#f0f0f0" size="6"><b>&#9701;</b></font></td><td><font color="#f0f0f0" size="7"><b>N</b></font></td><td><font color="#f0f0f0" size="6"><b>&#9699;</b></font></td></tr></table></center>
	<br><center><small><i>Official transmission from Central Command</i></small></center><hr><hr><small>
	<br>Issued by: Nina C. Trayson
	<br>Position: Central Command Liaison Manager
	<br>Posting: Central Command Liaison Outpost
	<br>Recipients: All Assigned Outpost Personnel
	<br>Classification: Internal Administrative Directive
	<br>Status: Active
	<br>
	<br><b>SUBJECT: INSTALLATION DUTIES, AUTHORITY AND JURISDICTION</b>
	<br>
	<br>Effective immediately, all personnel assigned to this installation are reminded of their responsibilities as representatives of Central Command.
	<br>
	<br><b>1. INSTALLATION STATUS</b>
	<br>
	<br>This outpost is operated under the direct administration of Central Command. It is a separate corporate installation and does not fall under the operational chain of command of the nearby Nanotrasen station.
	<br>
	<br>Station-issued rank does not automatically confer command authority, unrestricted access or security jurisdiction within this facility. This applies equally to visiting members of Station Command and Security.
	<br>
	<br><b>2. LIAISON RESPONSIBILITIES</b>
	<br>
	<br>Central Command Liaisons are responsible for administrative oversight, sector communications, operational reporting, tasking assignments and management of the outpost's logistical allocation.
	<br>
	<br>Liaisons are expected to monitor relevant station activity, maintain professional contact with station Command, review incoming sector requests, verify information and submit accurate findings.
	<br>
	<br>This posting grants oversight responsibilities. It does not authorize Liaisons to assume operational command of station departments or interfere unnecessarily with station affairs. Consult existing records before requesting information. A request is not an order. Do not duplicate inquiries or interrupt essential operations; document unavailable cooperation and defer nonessential requests.
	<br>
	<br><b>3. SECURITY RESPONSIBILITIES</b>
	<br>
	<br>The assigned Central Command Security Officer is responsible for maintaining the security of this installation, its personnel, restricted facilities and corporate property.
	<br>
	<br>The officer is authorized to establish reasonable access controls, screen visitors, inspect regional freight and suspicious deliveries, investigate incidents and respond to threats occurring aboard the outpost.
	<br>
	<br>These responsibilities extend to all visitors, including station personnel and members of Station Command. Visitors must comply with legitimate installation security instructions regardless of their station rank.
	<br>
	<br>Where necessary, the officer may deny entry, remove unauthorized visitors or temporarily restrain individuals presenting a genuine security threat. Such actions must remain proportionate, documented and consistent with applicable regulations.
	<br>
	<br>The officer's jurisdiction is limited to legitimate matters concerning the outpost. This assignment does not grant command authority over station Security or permission to conduct unauthorized enforcement operations aboard the station.
	<br>
	<br><b>4. INTERNAL COORDINATION</b>
	<br>
	<br>The Liaison oversees the outpost's administrative operations and coordinates its official activities. The Security Officer exercises operational responsibility for installation security.
	<br>
	<br>Both positions are expected to cooperate, communicate significant incidents and respect their respective responsibilities. Emergency armory equipment is reserved for legitimate defense and should be returned when no longer required. Disagreements requiring higher authorization are to be referred to Central Command.
	<br>
	<br><b>5. VISITORS AND CORPORATE PROPERTY</b>
	<br>
	<br>Visitors are guests of Central Command and remain subject to applicable access restrictions and security procedures. No station appointment, including Captain or Head of Security, independently grants authority to override these procedures.
	<br>
	<br>Legitimate directives from appropriately authorized Central Command personnel remain binding. All staff must comply with applicable corporate regulations.
	<br>
	<br>Visitor retrieval is voluntary. Respect declined invitations and do not repeatedly solicit the same individual. Protect confidential credentials and records.
	<br>
	<br><b>6. REGIONAL FREIGHT INSPECTION</b>
	<br>Security shall compare incoming inspection consignments against the official manifest. Remove undeclared goods and secure them as evidence; do not appropriate them. Stamp the original manifest, return it inside the crate with the declared goods, and certify the consignment with your registered Security identification before dispatching it through the outbound freight lane. These consignments are not discretionary supplies.
	<br>
	<br><b>7. CLASSIFIED ASSET DENIAL CONTINGENCY</b>
	<br>The NT-ADP-7 Asset Denial Device is a classified emergency contingency intended to prevent unauthorized acquisition of sensitive corporate assets. The authentication disk must remain secured at all times in the personal custody of authorized personnel. Do not leave it unattended. Keep associated authorization information separately secured and report suspected loss, theft or compromise immediately.
	<br>Asset denial is a measure of last resort. Activation is prohibited during ordinary security incidents, administrative disputes or routine evacuation. If the device is activated without authorization, prioritize preventing detonation where safely practicable, notify Central Command and prepare for emergency evacuation.
	<br>
	<br><b>8. GENERAL CONDUCT</b>
	<br>
	<br>Remain aboard the installation unless official duties or an emergency reasonably require otherwise. Protect confidential information, preserve relevant records and avoid unnecessary interference with station operations.
	<br>
	<br>Professionalism, impartiality and proper documentation are expected at all times.
	<br>
	<br>Central Command has invested considerable resources in this installation. Please refrain from creating additional reasons for an expenditure review.
	<br>
	<br></small><hr><hr><small><i>Signed, Nina C. Trayson</i></small>
	<br>CENTRAL COMMAND
	<br>SECTOR OVERSIGHT DEPARTMENT
	"}

// Recovered lower-deck data printout from the destroyed Syndicate vessel.
// Place /obj/item/paper/fluff/ruins/ccpost/syndicate_wreck_log on a turf
// beside the damaged terminal in the surviving lower half of the wreck.
/obj/item/paper/fluff/ruins/ccpost/syndicate_wreck_log
	name = "recovered SSV EAVESDROPPER mission log"
	desc = "A damaged Syndicate operations printout recovered from a wrecked vessel. The bottom of the record is scorched and abruptly cut off."

/obj/item/paper/fluff/ruins/ccpost/syndicate_wreck_log/Initialize(mapload)
	. = ..()
	add_raw_text({"<center><b>SYNDICATE OPERATIONS DIVISION</b><br><b>RECOVERED MISSION LOG: SSV EAVESDROPPER</b></center><hr>
	<b>Operation:</b> SILENT EMBER<br>
	<b>Target:</b> NanoTrasen Central Command Liaison Outpost<br>
	<b>Objective:</b> Infiltrate installation, recover classified intelligence, and deploy nuclear payload.<br><br>
	<b>Assigned Operatives:</b><br>
	Agent Crimson, Team Leader<br>
	Agent Crowbar, Demolitions Specialist<br>
	Agent Cobalt, Infiltration Specialist<br>
	Agent Dagger, Weapons Specialist<br>
	Agent Wrench, Pilot and Engineer<br><hr>
	<b>23:43 | Agent Wrench:</b> Approach vector confirmed. Outpost looks lightly staffed. Awaiting final order to breach.<br>
	<b>23:45 | Agent Crimson:</b> No open broadcasts. We take the records first, then plant the charge. Maintain radio discipline.<br>
	<b>23:47 | Agent Cobalt:</b> Automated perimeter defenses just acquired us. Multiple turret contacts. This is NOT a passive installation.<br>
	<b>23:48 | Agent Wrench:</b> First impacts across upper gun deck. Returning fire. Control link still responding.<br>
	<b>23:49 | Agent Dagger:</b> They're tracking our course correction. Crowbar, Cobalt, answer your damn radios.<br>
	<b>23:50 | Agent Crimson:</b> Upper hull is gone. Crowbar and Cobalt are unresponsive. Abort the boarding plan. Wrench, get us out.<br>
	<b>23:51 | Agent Wrench:</b> ANOTHER SALVO INCOMING! BRACE FOR IMPA :::<br><hr>
	<small>DATA EXTRACTION INCOMPLETE. ORIGINAL SOURCE MEDIUM LOST.</small>"})
	update_appearance()

// Visitor pamphlet
/obj/item/paper/pamphlet/ccpost_visitor
	name = "pamphlet - 'Central Command Liaison Outpost Visitor Guide'"
	desc = "A neatly folded NanoTrasen pamphlet for visitors to the Sector Liaison Outpost."
	default_raw_text = @{"
<center><b><font size="4">NANOTRASEN CENTRAL COMMAND</font></b></center>
<center><b>SECTOR LIAISON OUTPOST</b></center>
<center><i>Visitor Information and Facility Guidance</i></center>
<br>
<b>WELCOME</b><br>
This installation serves as a regional Central Command liaison, communications, administrative oversight and logistics coordination facility. Our personnel can receive official correspondence, arrange meetings and request reports concerning station operations.<br><br>
<b>VISITING THE OUTPOST</b><br>
1. Arrange your visit with the Liaison or Outpost Security before approaching the installation.<br>
2. Report to reception and explain the purpose of your visit.<br>
3. Remain in public and escorted areas unless expressly authorized to enter elsewhere.<br>
4. Declare weapons or dangerous equipment to Outpost Security before entry. Follow local security instructions while on the premises.<br><br>
<b>IMPORTANT: AUTOMATED DEFENSES</b><br>
Exterior perimeter turrets may engage unidentified lifeforms and personnel without mindshield protection. Do not approach the perimeter without prior clearance. Visitors should request that Outpost Security disable defenses or arrange safe passage before arrival.<br><br>
<b>ABOUT LIAISON AUTHORITY</b><br>
Visitor retrieval is voluntary. Declining an invitation does not affect your standing. Security may inspect declared equipment and require an escort. Liaisons conduct administrative oversight and report findings to Central Command. They do not command station personnel, station security, or station leadership. Outpost Security authority applies to this installation and its immediate premises only.<br><br>
<b>IN AN EMERGENCY</b><br>
Follow Outpost Security instructions and keep clear of restricted compartments and exterior defenses. Contact the Liaison or Security Office for assistance.<br><br>
<center><i>NanoTrasen appreciates your cooperation. Unauthorized visits may be rescheduled indefinitely.</i></center>
"}

/obj/item/radio/headset/headset_cent/alt/ccpost
	keyslot = /obj/item/encryptionkey/headset_cent
	keyslot2 = null

/obj/item/radio/headset/headset_cent/alt/ccpost/talk_into_impl(atom/movable/talking_movable, message, channel, list/spans, datum/language/language, list/message_mods)
	if(channel != RADIO_CHANNEL_CENTCOM && !(channel == MODE_DEPARTMENT && channels[1] == RADIO_CHANNEL_CENTCOM))
		return
	return ..()

/obj/item/radio/headset/headset_cent/alt/ccpost/liaison
	name = "Central Command Liaison headset"
	desc = "A secure headset for Central Command Liaisons. Monitors station communications and protects against flashbangs."

/obj/item/radio/headset/headset_cent/alt/ccpost/security
	name = "Central Command Outpost Security headset"
	desc = "A secure headset for Outpost Security personnel. Monitors station communications and protects against flashbangs."
	keyslot = /obj/item/encryptionkey/headset_cent
	keyslot2 = null

/obj/item/card/id/advanced/centcom/ccpost_liaison
	name = "Central Command Liaison ID"

/obj/item/card/id/advanced/centcom/ccpost_security
	name = "Central Command Outpost Security ID"

// CentCom-funded personal payroll for the two outpost ghost IDs.
// Bank accounts are registered so card payments/ATMs can use them.
/datum/bank_account/ccpost_personnel
	// Employee account. Keep registered for normal payment devices.

/datum/bank_account/ccpost_personnel/payday(amount_of_paychecks, free = FALSE, skippable = FALSE, event = "Payday")
	if(!account_job || amount_of_paychecks <= 0)
		return FALSE
	if(skippable && !free)
		while(paydays_to_skip > 0 && amount_of_paychecks > 0)
			paydays_to_skip--
			amount_of_paychecks--
	if(amount_of_paychecks <= 0)
		return FALSE
	var/credits = round(account_job.paycheck * payday_modifier * amount_of_paychecks)
	if(credits <= 0)
		return FALSE
	if(!adjust_money(credits, "Central Command: [event]"))
		return FALSE
	if(!free)
		bank_card_talk("Central Command payroll processed: +[credits] credits. Balance: [account_balance] credits.")
	return TRUE

// Called once when an outpost ghost-role ID first enters its owner's ID slot.
/proc/ccpost_initialize_personal_payroll(obj/item/card/id/employee_id, mob/user)
	var/mob/living/carbon/human/employee = user
	if(!istype(employee) || !istype(employee_id))
		return

	// Prevent repeated payday grants when an ID is unequipped and worn again.
	if(employee_id.registered_account && !employee_id.registered_account.replaceable)
		return

	var/datum/bank_account/account
	if(employee.account_id)
		account = SSeconomy.bank_accounts_by_id["[employee.account_id]"]

	// Most ghost roles have no real bank account on spawn.
	if(!account)
		var/datum/job/payroll_job = new /datum/job/ghost_role
		payroll_job.paycheck = PAYCHECK_CREW
		var/payday_modifier = employee.dna?.species?.payday_modifier
		if(isnull(payday_modifier) || payday_modifier <= 0)
			payday_modifier = 1
		var/datum/bank_account/ccpost_personnel/new_account = new(employee.real_name, payroll_job, payday_modifier, TRUE)
		new_account.replaceable = FALSE
		new_account.payday(STARTING_PAYCHECKS, free = TRUE, event = "Appointment Allowance")
		account = new_account
		employee.account_id = account.account_id
		employee.add_mob_memory(/datum/memory/key/account, remembered_id = account.account_id)

	if(employee_id.registered_account)
		employee_id.registered_account.bank_cards -= employee_id
	employee_id.registered_account = account
	account.bank_cards |= employee_id
	employee_id.registered_name = employee.real_name
	employee_id.update_label()

/obj/item/card/id/advanced/centcom/ccpost_liaison/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_ID)
		ccpost_initialize_personal_payroll(src, user)
		ccpost_hr_register_employee(user, src)

/obj/item/card/id/advanced/centcom/ccpost_security/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_ID)
		ccpost_initialize_personal_payroll(src, user)
		ccpost_hr_register_employee(user, src)


/obj/structure/closet/secure_closet/centcom_liaison
	name = "CentCom Liaison's locker"
	req_access = list(ACCESS_NT_REPRESENTATVE)
	icon_state = "cc"

/obj/structure/closet/secure_closet/centcom_liaison/PopulateContents()
	..()
	new /obj/item/clothing/suit/armor/vest/nanotrasen_representative/bathrobe(src)
	new /obj/item/clothing/suit/toggle/centcom_jacket(src)
	new /obj/item/clothing/under/rank/centcom/official(src)
	new /obj/item/clothing/under/rank/centcom/official/skirt(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/binoculars(src)

/obj/structure/closet/secure_closet/centcom_security
	name = "CentCom Security Officer's locker"
	req_access = list(ACCESS_NT_REPRESENTATVE)
	icon_state = "cc"

/obj/structure/closet/secure_closet/centcom_security/PopulateContents()
	..()
	new /obj/item/storage/box/handcuffs(src)
	new /obj/item/detective_scanner(src)
	new /obj/item/storage/box/evidence(src)
	new /obj/item/clipboard(src)
	new /obj/item/stamp/centcom(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/box/teargas(src)
	new /obj/item/storage/lockbox/loyalty/ccpost(src)
	new /obj/item/clothing/mask/gas/sechailer/swat(src)
	new /obj/item/clothing/under/rank/centcom/official(src)
	new /obj/item/clothing/under/rank/centcom/official/skirt(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/binoculars(src)


/// Mindshield supplies accessible to authorized outpost personnel, not station Security.
/// Contents inherit vanilla loyalty lockbox population (three implants and one implanter).
/obj/item/storage/lockbox/loyalty/ccpost
	name = "Central Command mindshield implant lockbox"
	desc = "A secured set of mindshield implants for Central Command outpost personnel."
	req_access = list(ACCESS_NT_REPRESENTATVE)

// Restrict the arrival point to a fixed lobby location, independently of station teleporters.

GLOBAL_VAR_INIT(ccpost_lobby_beacon, null)
GLOBAL_LIST_EMPTY(ccpost_beacon_status_displays)

/obj/item/beacon/ccpost_lobby
	name = "Central Command Liaison Outpost Lobby"
	desc = "A fixed arrival beacon controlled from the outpost communications room."
	anchored = TRUE
	enabled = FALSE

/obj/item/beacon/ccpost_lobby/Initialize(mapload)
	. = ..()
	GLOB.ccpost_lobby_beacon = src
	for(var/obj/machinery/status_display/ccpost_beacon_status/display as anything in GLOB.ccpost_beacon_status_displays)
		display.refresh_beacon_state()

/obj/item/beacon/ccpost_lobby/Destroy()
	if(GLOB.ccpost_lobby_beacon == src)
		GLOB.ccpost_lobby_beacon = null
	for(var/obj/machinery/status_display/ccpost_beacon_status/display as anything in GLOB.ccpost_beacon_status_displays)
		if(!QDELETED(display))
			display.refresh_beacon_state()
	return ..()

/obj/item/beacon/ccpost_lobby/attack_hand(mob/user, list/modifiers)
	to_chat(user, span_notice("The fixed arrival beacon is operated by the outpost teleport access switch."))
	return

/obj/item/beacon/ccpost_lobby/attack_self(mob/user)
	to_chat(user, span_warning("Local controls are locked. Use the outpost teleport access switch."))
	return

/obj/item/beacon/ccpost_lobby/proc/set_beacon_state(new_enabled)
	if(enabled == new_enabled)
		return FALSE
	enabled = new_enabled
	icon_state = enabled ? "beacon" : "beacon-off"
	if(enabled)
		GLOB.teleportbeacons |= src
	else
		GLOB.teleportbeacons -= src
	for(var/obj/machinery/status_display/ccpost_beacon_status/display as anything in GLOB.ccpost_beacon_status_displays)
		if(!QDELETED(display))
			display.refresh_beacon_state()
	return TRUE

/obj/machinery/button/ccpost_beacon_control
	name = "outpost teleport access control"
	desc = "An access-restricted switch controlling the lobby tracking beacon."
	skin = "-blue"
	can_alter_skin = FALSE
	req_access = list(ACCESS_NT_REPRESENTATVE)
	silicon_access_disabled = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/button/ccpost_beacon_control, 24)

/obj/machinery/button/ccpost_beacon_control/attack_hand(mob/user, list/modifiers)
	if(panel_open || (machine_stat & (NOPOWER | BROKEN)))
		return ..()
	if(!allowed(user))
		balloon_alert(user, "access denied")
		playsound(src, SFX_BUTTON_FAIL, vol = 45, vary = FALSE)
		return
	var/obj/item/beacon/ccpost_lobby/beacon = GLOB.ccpost_lobby_beacon
	if(!beacon || QDELETED(beacon))
		balloon_alert(user, "arrival beacon unavailable")
		return
	beacon.set_beacon_state(!beacon.enabled)
	playsound(src, SFX_BUTTON_CLICK, vol = 45, vary = FALSE)
	balloon_alert(user, beacon.enabled ? "teleport access enabled" : "teleport access disabled")
	visible_message(span_notice("[src] switches the outpost arrival beacon [beacon.enabled ? "online" : "offline"]."))
	return TRUE

/obj/machinery/status_display/ccpost_beacon_status
	name = "outpost teleport access display"
	desc = "Shows whether the outpost lobby is available as a teleporter destination."
	current_mode = SD_MESSAGE

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/status_display/ccpost_beacon_status, 32)

/obj/machinery/status_display/ccpost_beacon_status/Initialize(mapload)
	. = ..()
	GLOB.ccpost_beacon_status_displays |= src
	refresh_beacon_state()

/obj/machinery/status_display/ccpost_beacon_status/Destroy()
	GLOB.ccpost_beacon_status_displays -= src
	return ..()

/obj/machinery/status_display/ccpost_beacon_status/proc/refresh_beacon_state()
	var/obj/item/beacon/ccpost_lobby/beacon = GLOB.ccpost_lobby_beacon
	set_messages("TELEPORT LINK", beacon?.enabled ? "ACTIVE" : "OFFLINE")

// Central Command Advisor Hologram code

// Central Command Advisor Holopad

/obj/machinery/holopad/tutorial/ccpost_advisor
	play_once = FALSE
	proximity_range = 2
	COOLDOWN_DECLARE(advisor_playback_cooldown)
	var/advisor_playback_cooldown_duration = 3 MINUTES


// Central Command Advisor Holodisk

/obj/item/disk/holodisk/ruin/space/ccpost/advisor
	name = "Central Command Liaison Manager"
	preset_image_type = /datum/preset_holoimage/ccpost_advisor
	preset_record_text = {"
	NAME Liaison Manager Nina C. Trayson
	SAY Remember, you are here to observe, verify, communicate and record.
	DELAY 50
	"}

	var/static/list/advisor_tips = list(
		"Remember, you are here to observe, verify, communicate and record.",
		"A good report distinguishes confirmed information from speculation.",
		"The Captain commands the station. You advise, observe, and report.",
		"Not every irregularity requires Central Command intervention.",
		"Maintain accurate records. Your replacement will thank you.",
		"Professional communication is considerably cheaper than an Emergency Response Team.",
		"If you cannot verify it, do not report it as fact.",
		"Central Command appreciates concise reports. Central Command also appreciates correct reports.",
		"Central Command reminds you that 'I saw it on the cameras' is not a recognized investigative methodology.",
		"Your authority is derived from Central Command. Your good judgement, regrettably, is your own responsibility.",
		"If the Captain disagrees with your recommendation, document it. Do not start a constitutional crisis.",
		"Remember to take regular breaks. Fatigued bureaucrats produce approximately seventeen percent more paperwork.",
		"Remember: an unfiled incident is statistically indistinguishable from an incident that never occurred.",
		"Do not threaten the station with an Emergency Response Team. Emergency Response Teams are expensive.",
		"If three departments give you three different versions of the same incident, congratulations. You now have an investigation.",
		"Request clarification before requesting intervention.",
		"Repeatedly contacting the Captain does not make your request more official.",
		"Multiple explosions may indicate a developing situation.",
		"Take notes during major incidents. Human memory has repeatedly failed company quality assurance testing.",
		"Remain objective. The station is fully capable of embarrassing itself without your assistance.",
		"Please do not classify routine incompetence as sabotage without supporting evidence.",
		"Do not threaten people with paperwork unless you are prepared to actually complete it.",
		"If you write 'situation normal,' please include what definition of normal you are using.",
		"Please do not describe casualties as 'a staffing adjustment.'",
		"Central Command thanks you for your continued compliance with policies you were not consulted on.",
		"Please avoid referring to your assignment as 'remote isolation.' The approved term is 'independent operational posting.'",
		"Corporate policy exists to protect employees, assets, and corporate policy.",
		"Please refrain from describing company policy as 'inhuman' in official correspondence.",
		"Central Command appreciates solutions that fit within the existing budget.",
		"If Engineering has stopped answering, check whether Engineering still exists.",
		"Remember: a satisfied employee is productive. A dissatisfied employee is still scheduled.",
		"Central Command values transparency, provided it has been properly authorized.",
		"Corporate loyalty is its own reward. Additional rewards remain subject to budget approval.",
		"An employee who follows procedure has nothing to fear from an audit.",
		"Remember, Liaison: there is no greater service to Nanotrasen than making someone else's emergency less expensive.",
		"Central Command hears every concern eventually.",
		"An orderly station is a productive station. A productive station is a profitable station. A profitable station is a successful station.",
		"Remain vigilant. Inefficiency can emerge anywhere, at any time, in any department.",
		"Every accurate report is another victory for corporate order.",
		"Remember, Liaison: doubt is temporary. Central Command policy is permanent.",
		"The Logistics Terminal draws from this installation's Operational Allocation. A requisition being affordable does not necessarily make it necessary.",
		"Operational Allocation is finite. Completed tasking orders and approved sector work may replenish it. Poor purchasing decisions are not an emergency.",
		"Every Logistics requisition is recorded. This remains true when procurement safeguards have been bypassed.",
		"Empty Central Command freight containers may be returned for a small allocation credit. Central Command appreciates recycling when it is cheaper than replacement.",
		"Completed Tasking Terminal assignments provide Operational Allocation and may also authorize a grant to the relevant station department. Properly stamped paperwork can, on occasion, be profitable.",
		"The Tasking Terminal does not accept good intentions as supporting documentation. It accepts written reports bearing a Central Command stamp.",
		"The Sector Communications Terminal carries requests and operational updates from nearby installations. Read the transmission before authorizing expenditure.",
		"Authorizing sector assistance may cost Operational Allocation. Denying assistance may cost considerably more, although Finance prefers not to phrase it that way.",
		"Liaison, don't forget to regularly check the tasking terminal for new assignments.",
		"Oversight is not command. Requests for cooperation do not constitute orders.",
		"Review existing records before requesting paperwork. An engineer's time during a reactor emergency is not inexpensive.",
		"A department preventing a catastrophe may be excused from explaining the catastrophe in writing.",
		"A report explaining why information could not be obtained remains a report. Inventing it is a disciplinary matter.",
		"Do not penalize unavailable departments for attending to essential duties.",
		"A concise inquiry is usually preferable to three separate inquiries on the same subject.",
		"Regional records and correspondence are also legitimate administrative work.",
		"Installation Security is responsible for this facility. Station Security remains responsible for the station.",
		"Visiting personnel are entitled to professional treatment, not the contents of our armory.",
		"The emergency armory exists for emergencies. A disagreement over paperwork does not qualify.",
		"Compare inspection consignments with their manifest before returning them to Sector Logistics.",
		"Undeclared equipment belongs in evidence storage, not your personal collection.",
		"A clean freight inspection is a successful inspection. Please do not invent discrepancies.",
		"The original inspection manifest must accompany its declared contents upon return.",
		"A stamped manifest and Security certification are required for onward dispatch.",
		"The NT-ADP-7 authentication disk must remain in the personal custody of authorized personnel.",
		"An unattended authentication disk is not adequately secured, even inside a locker.",
		"Asset denial is a contingency of last resort. It is not an approved method of resolving complaints.",
		"Report missing restricted authentication material immediately.",
		"Keep the authentication disk and authorization information separate. One mistake should not become two.",
		"Should asset denial commence without authorization, prioritize personnel safety and notify Central Command.",
		"Respect a declined visitor invitation. Consent is not an administrative obstacle to be overcome.",
		"Restore power before attempting to recalibrate an unpowered administrative server.",
		"Human Resources records are private. Curiosity does not constitute authorization.",
		"Central Command approves recreational fishing, provided installation readiness is maintained.",
		"The fish have not received security clearance. Their access should remain limited to the aquarium.",
		"Fishing equipment is recreational equipment. A colleague's belongings are not a fishing destination.",
		"Before committing allocation to a requisition, review the installation's actual needs."
	)

/obj/item/disk/holodisk/ruin/space/ccpost/advisor/proc/select_random_tip()
	if(!record)
		return

	record.caller_name = "Liaison Manager Nina C. Trayson"
	record.entries = list(
		list(HOLORECORD_SAY, pick(advisor_tips)),
		list(HOLORECORD_DELAY, 70)
	)

/obj/machinery/holopad/tutorial/ccpost_advisor/replay_start()
	if(replay_mode || !COOLDOWN_FINISHED(src, advisor_playback_cooldown))
		return
	if(!disk?.record || !is_operational)
		return
	COOLDOWN_START(src, advisor_playback_cooldown, advisor_playback_cooldown_duration)
	var/obj/item/disk/holodisk/ruin/space/ccpost/advisor/advisor_disk = disk
	advisor_disk?.select_random_tip()
	return ..()

/obj/machinery/holopad/tutorial/ccpost_advisor/examine(mob/user)
	. = ..()
	. += span_notice("Advisory playback is limited to once every three minutes.")


// Advisor Hologram Preset

/datum/preset_holoimage/ccpost_advisor
	outfit_type = /datum/outfit/centcom/ccpost_advisor

/datum/preset_holoimage/ccpost_advisor/customize_human(mob/living/carbon/human/mannequin)
	mannequin.gender = FEMALE
	mannequin.physique = FEMALE
	mannequin.skin_tone = "caucasian1"

	mannequin.set_haircolor("#443333", update = FALSE)
	mannequin.set_hairstyle("Long Side Part", update = FALSE)
	mannequin.set_hair_gradient_style("None", update = FALSE)

	mannequin.eye_color_left = "#447766"
	mannequin.eye_color_right = "#447766"

	mannequin.set_facial_hairstyle("Shaved", update = FALSE)
	mannequin.set_facial_hair_gradient_style("None", update = FALSE)

	mannequin.underwear = "Bikini"
	mannequin.underwear_color = "#333333"
	mannequin.socks = "Stockings (Fishnet)"
	mannequin.socks_color = "#902DD5"

	mannequin.update_body()


// Advisor Hologram Outfit

/datum/outfit/centcom/ccpost_advisor
	name = "CentCom Liaison Manager"

	uniform = /obj/item/clothing/under/rank/centcom/commander/skirt
	shoes = /obj/item/clothing/shoes/jackboots/heel
	ears = /obj/item/radio/headset/headset_cent/alt
	glasses = /obj/item/clothing/glasses/sunglasses
	head = /obj/item/clothing/head/beret/centcom_formal


// Central Command Escalation Request Button
// note: this button purposefully does nothing.

/obj/machinery/button/ccpost_escalation
	name = "Central Command escalation request"
	desc = "A secure priority request terminal intended for circumstances deemed worthy of direct Central Command attention. A small label reads: 'Submission does not constitute approval.'"

	icon_state = "button-warning"
	skin = "-warning"
	can_alter_skin = FALSE

	COOLDOWN_DECLARE(escalation_cooldown)
	var/escalation_cooldown_duration = 30 SECONDS

	var/static/list/escalation_responses = list(
		"Request received. Estimated review time: two to six business shifts.",
		"Request received. Please remain calm and avoid creating additional billable incidents.",
		"Request received. Please attempt local resolution before requesting additional resources.",
		"Request received. Your request has been forwarded to the appropriate department. The appropriate department has not been identified.",
		"Request received. Your concern has been assigned priority status: Routine.",
		"Request received. Please exhaust cheaper solutions before requesting trained personnel.",
		"Request received. If the station is no longer physically present, discontinue routine monitoring.",
		"Request received. Central Command recognizes the seriousness of the situation and will continue recognizing it.",
		"Request received. Your sense of urgency has not altered the budget.",
		"Request received. Further escalation has been deferred pending evidence of further escalation."
	)

/obj/machinery/button/ccpost_escalation/proc/escalation_authorized()
	return SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED

/obj/machinery/button/ccpost_escalation/attack_hand(mob/user, list/modifiers)
	if(!escalation_authorized())
		var/current_alert = uppertext(SSsecurity_level.get_current_level_as_text())

		balloon_alert(user, "escalation criteria not met")
		playsound(src, SFX_BUTTON_FAIL, vol = 45, vary = TRUE)

		say("Request rejected. Current station alert condition: [current_alert]. Escalation criteria have not been met. Continue routine monitoring.")
		return

	if(!COOLDOWN_FINISHED(src, escalation_cooldown))
		balloon_alert(user, "request already pending")
		playsound(src, SFX_BUTTON_FAIL, vol = 45, vary = TRUE)
		return

	. = ..()
	if(.)
		return

	COOLDOWN_START(src, escalation_cooldown, escalation_cooldown_duration)

	visible_message(
		span_notice("[user] submits a priority escalation request through [src].")
	)

	say("Escalation request transmitted.")

	addtimer(CALLBACK(src, PROC_REF(receive_escalation_response)), 3 SECONDS)

/obj/machinery/button/ccpost_escalation/proc/receive_escalation_response()
	var/response = pick(escalation_responses)

	say(response)

	playsound(src, SFX_BUTTON_CLICK, vol = 35, vary = TRUE)

/obj/projectile/beam/ccpost_perimeter_pulse
	name = "Central Command perimeter pulse"
	icon_state = "u_laser"
	damage = 32
	range = 50
	damage_walls = FALSE
	ricochets_max = 0
	ricochet_chance = 0
	reflectable = FALSE
	light_color = LIGHT_COLOR_BLUE
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	tracer_type = /obj/effect/projectile/tracer/pulse
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	impact_type = /obj/effect/projectile/impact/pulse

/obj/projectile/energy/electrode/ccpost_perimeter
	range = 9

/obj/structure/barricade/security/ccpost
	name = "Central Command security barrier"

/obj/structure/barricade/security/ccpost/attackby(obj/item/tool, mob/living/user, params)
	var/obj/item/card/id/identification = tool.GetID()
	if(istype(identification, /obj/item/card/id/advanced/centcom/ccpost_liaison) || istype(identification, /obj/item/card/id/advanced/centcom/ccpost_security))
		toggle_lock(user)
		return
	return ..()

/obj/structure/barricade/security/ccpost/attack_hand_secondary(mob/living/user, list/modifiers)
	var/obj/item/card/id/identification = user.get_idcard()
	if(istype(identification, /obj/item/card/id/advanced/centcom/ccpost_liaison) || istype(identification, /obj/item/card/id/advanced/centcom/ccpost_security))
		toggle_lock(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	return ..()

/obj/item/grenade/ccpost_barrier
	name = "Central Command barrier grenade"
	desc = "Deploys Central Command security barricades authorized for outpost personnel."
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "wallbang"
	inhand_icon_state = "flashbang"
	actions_types = list(/datum/action/item_action/toggle_barrier_spread)
	var/mode = "single"

/obj/item/grenade/ccpost_barrier/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/item/grenade/ccpost_barrier/examine(mob/user)
	. = ..()
	. += span_notice("Current Mode: [capitalize(mode)]. Alt-click to switch the current mode.")

/obj/item/grenade/ccpost_barrier/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "wallbang-[mode]")
	. += emissive_appearance(icon, "wallbang-[mode]", src, alpha = src.alpha)

/obj/item/grenade/ccpost_barrier/click_alt(mob/living/carbon/user)
	toggle_mode(user)
	return CLICK_ACTION_SUCCESS

/obj/item/grenade/ccpost_barrier/proc/toggle_mode(mob/user)
	switch(mode)
		if("single")
			mode = "vertical"
		if("vertical")
			mode = "horizontal"
		else
			mode = "single"
	playsound(src, 'sound/machines/click.ogg', 50)
	to_chat(user, span_notice("[src] is now in [mode] mode."))
	update_appearance(UPDATE_OVERLAYS)

/obj/item/grenade/ccpost_barrier/ui_action_click(mob/user)
	toggle_mode(user)

/obj/item/grenade/ccpost_barrier/detonate(mob/living/lanced_by)
	. = ..()
	if(!.)
		return
	var/turf/center = get_turf(src)
	if(!center)
		qdel(src)
		return
	new /obj/structure/barricade/security/ccpost(center)
	var/list/directions = list()
	switch(mode)
		if("vertical")
			directions = list(NORTH, SOUTH)
		if("horizontal")
			directions = list(EAST, WEST)
	for(var/direction in directions)
		var/turf/target = get_step(center, direction)
		if(target && !target.is_blocked_turf())
			new /obj/structure/barricade/security/ccpost(target)
	qdel(src)

/obj/structure/closet/secure_closet/ccpost_armory
	name = "Central Command emergency armory"
	desc = "A limited emergency weapons and barricade reserve for Central Command outpost personnel."
	icon_state = "armory"
	req_access = list(ACCESS_NT_REPRESENTATVE, ACCESS_CENT_LIVING)
	anchored = TRUE
	storage_capacity = 100

/obj/structure/closet/secure_closet/ccpost_armory/can_unlock(mob/living/user, obj/item/card/id/player_id, obj/item/card/id/registered_id)
	if(isAdminGhostAI(user))
		return TRUE
	return istype(player_id, /obj/item/card/id/advanced/centcom/ccpost_liaison) || istype(player_id, /obj/item/card/id/advanced/centcom/ccpost_security)

/obj/structure/closet/secure_closet/ccpost_armory/PopulateContents()
	..()
	ccpost_populate_experimental()
	new /obj/item/gun/ballistic/automatic/wt550(src)
	new /obj/item/ammo_box/magazine/wt550m9(src)
	new /obj/item/ammo_box/magazine/wt550m9(src)
	new /obj/item/storage/box/lethalshot(src)
	new /obj/item/grenade/ccpost_barrier(src)
	new /obj/item/grenade/ccpost_barrier(src)
	new /obj/item/stack/sheet/mineral/sandbags(src, 3)
	new /obj/item/gun/energy/ionrifle(src)
	new /obj/item/ammo_box/magazine/wt550m9(src)
	new /obj/item/ammo_box/magazine/wt550m9(src)
	new /obj/item/storage/box/beanbag(src)
	new /obj/item/storage/box/rubbershot(src)
	new /obj/item/shield/riot(src)
	new /obj/item/shield/riot(src)
	new /obj/item/door_seal(src)
	new /obj/item/door_seal(src)
	new /obj/item/grenade/ccpost_barrier(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/clothing/head/helmet/sec(src)
		new /obj/item/clothing/gloves/combat(src)

/obj/structure/closet/secure_closet/ccpost_armory/populate_contents_immediate()
	. = ..()
	new /obj/item/gun/ballistic/shotgun/riot(src)
	new /obj/item/gun/energy/e_gun(src)

#define CCPOST_TURRET_SHOOT_ANOMALOUS (1<<4)
#define CCPOST_TURRET_SHOOT_UNSHIELDED (1<<5)

/obj/machinery/porta_turret/ccpost/perimeter
	name = "Central Command perimeter turret"
	base_icon_state = "syndie"
	icon_state = "syndie_off"
	desc = "An automated lethal-ready pulse defense turret controlled by Central Command Security."
	installation = null
	uses_stored = FALSE
	use_power = NO_POWER_USE
	has_cover = FALSE
	always_up = TRUE
	max_integrity = 200
	scan_range = 9
	shot_delay = 10
	req_access = list(ACCESS_NT_REPRESENTATVE)
	turret_flags = CCPOST_TURRET_SHOOT_UNSHIELDED | CCPOST_TURRET_SHOOT_ANOMALOUS
	faction = list(FACTION_TURRET, FACTION_TAMED, FACTION_SILICON)
	stun_projectile = /obj/projectile/energy/electrode/ccpost_perimeter
	stun_projectile_sound = 'sound/items/weapons/taser.ogg'
	lethal_projectile = /obj/projectile/beam/ccpost_perimeter_pulse
	lethal_projectile_sound = 'sound/items/weapons/pulse.ogg'
	mode = 1
	system_id = "ccpost_perimeter"

/obj/machinery/porta_turret/ccpost/perimeter/setup()
	return

/obj/machinery/porta_turret/ccpost/perimeter/assess_perp(mob/living/carbon/human/perp)
	// Command must NEVER be targeted by this outpost's native threat checks.
	var/datum/job/real_job = perp.mind?.assigned_role
	var/datum/job/apparent_job = SSjob.GetJob(perp.get_assignment())
	if((real_job?.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND) || (apparent_job?.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND))
		return 0
	// Preserve access for this outpost's own Liaisons and Security personnel.
	var/obj/item/card/id/identification = perp.wear_id?.GetID()
	if(istype(identification, /obj/item/card/id/advanced/centcom/ccpost_liaison) || istype(identification, /obj/item/card/id/advanced/centcom/ccpost_security))
		return 0
	if(istype(identification, /obj/item/card/id/advanced/centcom))
		return 0
	return ..()

/obj/machinery/turretid/ccpost/perimeter
	name = "Central Command perimeter defense controller"
	desc = "Controls the external automated defense turrets of this Central Command outpost."
	req_access = list(ACCESS_NT_REPRESENTATVE)
	system_id = "ccpost_perimeter"
	enabled = TRUE
	lethal = TRUE
	// Prevent station AI from bypassing the outpost ID requirement.
	ailock = TRUE

/obj/machinery/turretid/ccpost/perimeter/proc/ccpost_authorized_id(obj/item/card/id/identification)
	return istype(identification, /obj/item/card/id/advanced/centcom/ccpost_liaison) || istype(identification, /obj/item/card/id/advanced/centcom/ccpost_security)

/obj/machinery/turretid/ccpost/perimeter/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	if(machine_stat & BROKEN)
		return

	var/obj/item/card/id/identification = attacking_item.GetID()
	if(!identification)
		return ..()

	// This controller uses its own restricted ID check, rather than the
	// parent controller's ACCESS_NT_REPRESENTATVE check.
	if(!ccpost_authorized_id(identification))
		to_chat(user, span_warning("Access denied: authorized outpost identification required."))
		return

	if(obj_flags & EMAGGED)
		to_chat(user, span_warning("The turret control is unresponsive!"))
		return

	locked = !locked
	to_chat(user, span_notice("You [locked ? "lock" : "unlock"] the panel."))
	SStgui.update_uis(src)

/obj/machinery/turretid/ccpost/perimeter/ui_status(mob/user, datum/ui_state/state)
	if(!isobserver(user) && !ccpost_terminal_in_range(src, user))
		return UI_CLOSE
	return ..()

/obj/machinery/turretid/ccpost/perimeter/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(!ccpost_terminal_in_range(src, ui?.user) || isobserver(ui?.user))
		return TRUE
	// Unlocking is done by swiping an authorized outpost ID, never by UI action.
	if(action == "lock")
		return TRUE

	// Never trust the UI's disabled state as authorization.
	if(action in list("power", "mode", "shoot_silicons"))
		var/mob/living/carbon/human/human_user = ui?.user
		if(!istype(human_user) || locked)
			return TRUE
		var/authorized = FALSE
		for(var/obj/item/card/id/card as anything in ccpost_presented_ids(human_user))
			if(ccpost_authorized_id(card))
				authorized = TRUE
				break
		if(!authorized)
			return TRUE

	return ..()

/obj/machinery/turretid/ccpost/perimeter/multitool_act(mob/living/user, obj/item/multitool/multi_tool)
	// The system_id connects approved perimeter turrets automatically.
	// Do not permit the parent multitool handler to add unrelated turrets.
	balloon_alert(user, "automatic linking only")
	return ITEM_INTERACT_BLOCKING

/obj/machinery/turretid/ccpost/perimeter/post_machine_initialize()
	. = ..()
	// The vanilla controller also tries area-based linking during Initialize.
	// Restrict this subtype's final links to our matching perimeter turrets.
	var/list/valid_turrets = list()
	for(var/datum/weakref/turret_ref as anything in turrets)
		var/obj/machinery/porta_turret/turret = turret_ref.resolve()
		if(istype(turret, /obj/machinery/porta_turret/ccpost/perimeter) && turret.system_id == system_id)
			valid_turrets |= turret_ref
	turrets = valid_turrets

#undef CCPOST_TURRET_SHOOT_ANOMALOUS
#undef CCPOST_TURRET_SHOOT_UNSHIELDED

/obj/machinery/porta_turret/ccpost/perimeter/vault
	name = "Central Command vault defense turret"
	desc = "An automated pulse defense turret assigned to protect classified Central Command assets and records."
	system_id = "ccpost_vault"
	scan_range = 6
	max_integrity = 250

// Dedicated vault turret controller.
// Inherits the existing outpost's restricted ID authentication.

/obj/machinery/turretid/ccpost/perimeter/vault
	name = "Central Command vault defense controller"
	desc = "Controls the automated security turrets protecting classified Central Command assets."
	system_id = "ccpost_vault"
	enabled = TRUE
	lethal = TRUE
	ailock = TRUE

// CENTRAL COMMAND VISITOR RETURN TRANSPORT
// Map one shared visitor pad and the separate departure and retrieval consoles.
// Both consoles discover the same nearby pad; no station teleporter is required for retrieval.
#define CCPOST_VISITOR_CHARGE 5 SECONDS
#define CCPOST_VISITOR_COOLDOWN 5 SECONDS

/// Only a Liaison or Outpost Security credential can operate the console.
/proc/ccpost_visitor_transport_authorized(mob/user)
	for(var/obj/item/card/id/card as anything in ccpost_presented_ids(user))
		if(istype(card, /obj/item/card/id/advanced/centcom/ccpost_liaison) || istype(card, /obj/item/card/id/advanced/centcom/ccpost_security))
			return TRUE
	return FALSE

/// Prevent staff from abusing the visitor shuttle even after dropping their ID.
/// Both authenticated role IDs and mind-bound outpost HR enrollment are checked.
/proc/ccpost_is_outpost_personnel(mob/living/carbon/human/person)
	if(!istype(person))
		return FALSE
	var/obj/item/card/id/card = person.wear_id?.GetID()
	if(istype(card, /obj/item/card/id/advanced/centcom/ccpost_liaison) || istype(card, /obj/item/card/id/advanced/centcom/ccpost_security))
		return TRUE
	if(!person.mind || !GLOB.ccpost_hr_service)
		return FALSE
	var/datum/ccpost_hr_employee/rostered = GLOB.ccpost_hr_service.roster[REF(person.mind)]
	return rostered?.employee_mind == person.mind && (rostered.employee_role == "Central Command Liaison" || rostered.employee_role == "Outpost Security Officer")

/// Distinguishes an invalid tracking beacon from a temporarily blocked landing site.
/// State is recalculated, so a visitor standing on the beacon does not erase its selection.
/proc/ccpost_visitor_beacon_state(obj/item/beacon/beacon)
	if(QDELETED(beacon))
		return "missing"
	if(!beacon.enabled || !(beacon in GLOB.teleportbeacons))
		return "disabled"
	var/turf/center = get_turf(beacon)
	if(!center || !is_station_level(center.z))
		return "offstation"
	var/area/landing_area = get_area(center)
	if(!landing_area || (landing_area.area_flags & NOTELEPORT))
		return "restricted"
	if(is_safe_turf(center, no_teleport = TRUE))
		return "ready"
	// The same environmental checks, without atom density, differentiate crowding
	// from vacuum, fire, invalid floor tiles, and otherwise unsafe destinations.
	if(!is_safe_turf(center, dense_atoms = TRUE, no_teleport = TRUE))
		return "unsafe"
	for(var/direction in GLOB.cardinals)
		var/turf/adjacent = get_step(center, direction)
		if(!adjacent || adjacent.z != center.z || get_area(adjacent) != landing_area)
			continue
		if(is_safe_turf(adjacent, no_teleport = TRUE))
			return "adjacent"
	return "occupied"

/// Prefer the registered beacon tile; use only cardinal tiles in the same station
/// area as a fallback. No diagonal jumps or landing outside the beacon's room.
/proc/ccpost_visitor_landing_turf(obj/item/beacon/beacon)
	var/state = ccpost_visitor_beacon_state(beacon)
	if(state == "ready")
		return get_turf(beacon)
	if(state != "adjacent")
		return null
	var/turf/center = get_turf(beacon)
	var/area/landing_area = get_area(center)
	for(var/direction in GLOB.cardinals)
		var/turf/adjacent = get_step(center, direction)
		if(!adjacent || adjacent.z != center.z || get_area(adjacent) != landing_area)
			continue
		if(is_safe_turf(adjacent, no_teleport = TRUE))
			return adjacent
	return null

/proc/ccpost_visitor_beacon_status_text(state)
	switch(state)
		if("ready")
			return "Beacon landing tile available."
		if("adjacent")
			return "Beacon landing tile occupied. Safe adjacent landing available."
		if("occupied")
			return "Landing area temporarily occupied. Destination remains selected."
		if("disabled")
			return "Tracking beacon disabled or deregistered."
		if("offstation")
			return "Tracking beacon is outside the station."
		if("restricted")
			return "Tracking beacon is in a restricted teleportation area."
		if("unsafe")
			return "Landing area unsafe. Check atmosphere and obstructions."
	return "Tracking beacon no longer exists. Select another destination."

/obj/effect/temp_visual/teleport_abductor/ccpost_departure
	duration = CCPOST_VISITOR_CHARGE

/obj/machinery/ccpost_visitor_pad
	name = "Central Command visitor telepad"
	desc = "A bluespace visitor pad used for supervised arrivals and departures at the outpost."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "broadcast receiver"
	density = FALSE
	anchored = TRUE
	use_power = NO_POWER_USE
	var/mob/living/carbon/human/charging_passenger
	var/obj/machinery/computer/ccpost_visitor_transport/controlling_console
	/// One reservation for inbound and outbound operations across all linked consoles.
	var/obj/machinery/reserved_by

/obj/machinery/ccpost_visitor_pad/Destroy()
	if(controlling_console?.linked_pad == src)
		controlling_console.linked_pad = null
	controlling_console = null
	charging_passenger = null
	reserved_by = null
	return ..()

/obj/machinery/computer/ccpost_visitor_transport
	name = "Central Command visitor transport console"
	desc = "Authorizes supervised departure of station visitors to an active station tracking beacon."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	light_color = LIGHT_COLOR_BLUE
	/// The closest compatible pad is discovered automatically.
	var/obj/machinery/ccpost_visitor_pad/linked_pad
	/// Station teleporter registry, with weak reference to avoid stale destinations.
	var/datum/weakref/selected_beacon
	var/charging = FALSE
	var/next_transport_allowed = 0
	/// Unique sequence prevents cancelled timers from completing a later transport.
	var/transport_sequence = 0
	var/status_message = "Transport system initialized."
	var/destination_refresh_scheduled = FALSE

/obj/machinery/computer/ccpost_visitor_transport/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/ccpost_visitor_transport/LateInitialize(mapload_arg)
	link_visitor_pad()

/obj/machinery/computer/ccpost_visitor_transport/Destroy()
	if(linked_pad?.reserved_by == src)
		linked_pad.reserved_by = null
	if(linked_pad?.controlling_console == src)
		linked_pad.controlling_console = null
	linked_pad = null
	selected_beacon = null
	return ..()

/obj/machinery/computer/ccpost_visitor_transport/proc/link_visitor_pad()
	if(linked_pad && !QDELETED(linked_pad))
		return linked_pad
	var/obj/machinery/ccpost_visitor_pad/best_pad
	var/best_distance = INFINITY
	for(var/obj/machinery/ccpost_visitor_pad/pad as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/ccpost_visitor_pad))
		if(QDELETED(pad) || pad.z != z || (pad.controlling_console && pad.controlling_console != src))
			continue
		var/distance = get_dist(src, pad)
		if(distance > 8 || distance >= best_distance)
			continue
		best_pad = pad
		best_distance = distance
	if(best_pad)
		linked_pad = best_pad
		best_pad.controlling_console = src
	return linked_pad

/obj/machinery/computer/ccpost_visitor_transport/proc/collect_station_beacons()
	var/list/available = list()
	for(var/obj/item/beacon/beacon as anything in GLOB.teleportbeacons)
		if(ccpost_visitor_beacon_state(beacon) in list("missing", "disabled", "offstation", "restricted", "unsafe"))
			continue
		available += beacon
	return available

/obj/machinery/computer/ccpost_visitor_transport/ui_status(mob/user, datum/ui_state/state)
	if(isobserver(user))
		return UI_INTERACTIVE
	if((!ccpost_visitor_transport_authorized(user) || !ccpost_terminal_in_range(src, user)))
		return UI_CLOSE
	return ..()

/obj/machinery/computer/ccpost_visitor_transport/ui_interact(mob/user, datum/tgui/ui)
	if(!isobserver(user) && (!ccpost_visitor_transport_authorized(user) || !ccpost_terminal_in_range(src, user)))
		return
	. = ..()
	link_visitor_pad()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CCPostVisitorTransport", name)
		ui.open()

/obj/machinery/computer/ccpost_visitor_transport/ui_data(mob/user)
	if(!isobserver(user) && (!ccpost_visitor_transport_authorized(user) || !ccpost_terminal_in_range(src, user)))
		return list()
	link_visitor_pad()
	var/list/data = list()
	data["read_only"] = isobserver(user)
	data["outpost_offline"] = GLOB.ccpost_outpost_signal_lost
	data["pad_linked"] = !!linked_pad
	data["charging"] = charging
	data["pad_busy"] = !!linked_pad?.reserved_by && linked_pad.reserved_by != src
	data["cooldown_seconds"] = max(0, round((next_transport_allowed - world.time) / (1 SECONDS)))
	data["console_operational"] = !(machine_stat & (BROKEN | NOPOWER))
	data["status_message"] = status_message

	var/mob/living/carbon/human/passenger = get_single_visitor()
	var/passenger_eligible = passenger && passenger.stat != DEAD && !passenger.buckled
	data["passenger_available"] = !!passenger_eligible
	data["passenger_name"] = passenger_eligible ? passenger.name : "No eligible passenger detected on the pad."

	var/obj/item/beacon/selected = selected_beacon?.resolve()
	data["destination_name"] = selected ? selected.name : "No destination selected"
	data["destination_area"] = selected ? "[get_area(selected)]" : ""
	var/turf/selected_turf = get_turf(selected)
	data["destination_coordinates"] = selected_turf ? "[selected_turf.x], [selected_turf.y], z[selected_turf.z]" : ""
	var/destination_state = selected ? ccpost_visitor_beacon_state(selected) : "missing"
	data["destination_valid"] = !!ccpost_visitor_landing_turf(selected)
	data["destination_state"] = destination_state
	data["destination_status_text"] = selected ? ccpost_visitor_beacon_status_text(destination_state) : "Select a station tracking beacon."
	if(selected && destination_state == "occupied")
		schedule_destination_refresh()
	data["destination_ref"] = selected ? REF(selected) : null

	var/list/available = list()
	for(var/obj/item/beacon/beacon as anything in collect_station_beacons())
		var/turf/position = get_turf(beacon)
		var/area/beacon_area = get_area(beacon)
		available += list(list(
			"ref" = REF(beacon),
			"name" = beacon.name,
			"area" = beacon_area.name,
			"coordinates" = "[position.x], [position.y], z[position.z]",
			"availability" = ccpost_visitor_beacon_state(beacon)
		))
	data["beacons"] = available
	return data

/obj/machinery/computer/ccpost_visitor_transport/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(GLOB.ccpost_outpost_signal_lost)
		return TRUE
	// Enforce permissions at the server, including stale windows and crafted TGUI actions.
	var/mob/user = ui?.user
	if(isobserver(user) || (!ccpost_visitor_transport_authorized(user) || !ccpost_terminal_in_range(src, user)) || !user.can_perform_action(src))
		return TRUE
	if(machine_stat & (BROKEN | NOPOWER))
		return TRUE
	. = ..()
	if(.)
		return
	if(action == "clear_beacon")
		if(charging)
			status_message = "Cannot deselect a destination during an active transport."
			return TRUE
		selected_beacon = null
		status_message = "Tracking beacon selection cleared."
		add_fingerprint(user)
		SStgui.update_uis(src)
		return TRUE
	link_visitor_pad()
	if(!linked_pad)
		status_message = "Transport unavailable: No linked visitor pad detected."
		return TRUE
	switch(action)
		if("select_beacon")
			if(charging)
				status_message = "Destination locked while transport is in progress."
				return TRUE
			var/obj/item/beacon/choice = locate(params["beacon_ref"])
			if(!(choice in collect_station_beacons()))
				status_message = "Destination unavailable: Select an active station beacon."
				return TRUE
			selected_beacon = WEAKREF(choice)
			status_message = "Destination locked: [choice.name]. [ccpost_visitor_beacon_status_text(ccpost_visitor_beacon_state(choice))]"
			add_fingerprint(user)
			log_game("CCPost visitor transport destination selected by [key_name(user)]: [choice] at [loc_name(choice)].")
			return TRUE
		if("begin_transport")
			begin_transport(user)
			return TRUE
		if("cancel_transport")
			if(charging)
				cancel_transport(user)
			return TRUE
	return FALSE

/// A single bounded recheck updates an open interface after the destination clears.
/obj/machinery/computer/ccpost_visitor_transport/proc/schedule_destination_refresh()
	if(destination_refresh_scheduled)
		return
	destination_refresh_scheduled = TRUE
	addtimer(CALLBACK(src, PROC_REF(refresh_destination_status)), 3 SECONDS)

/obj/machinery/computer/ccpost_visitor_transport/proc/refresh_destination_status()
	destination_refresh_scheduled = FALSE
	if(QDELETED(src))
		return
	SStgui.update_uis(src)
	var/obj/item/beacon/beacon = selected_beacon?.resolve()
	if(beacon && ccpost_visitor_beacon_state(beacon) == "occupied")
		schedule_destination_refresh()

/obj/machinery/computer/ccpost_visitor_transport/proc/cancel_transport(mob/user)
	if(!charging)
		return
	charging = FALSE
	transport_sequence++
	if(linked_pad)
		linked_pad.charging_passenger = null
		if(linked_pad.reserved_by == src)
			linked_pad.reserved_by = null
	next_transport_allowed = world.time + CCPOST_VISITOR_COOLDOWN
	status_message = "Transport sequence cancelled."
	visible_message(span_notice("[src] aborts its visitor transport sequence."))
	log_game("CCPost visitor transport cancelled by [key_name(user)].")
	SStgui.update_uis(src)

/obj/machinery/computer/ccpost_visitor_transport/proc/get_single_visitor()
	if(!linked_pad || QDELETED(linked_pad))
		return null
	var/turf/pad_turf = get_turf(linked_pad)
	var/mob/living/carbon/human/passenger
	for(var/mob/living/carbon/human/candidate in pad_turf)
		if(candidate.stat == DEAD || ccpost_is_outpost_personnel(candidate))
			continue
		if(passenger)
			return null // Pad is occupied by more than one eligible visitor.
		passenger = candidate
	return passenger

/obj/machinery/computer/ccpost_visitor_transport/proc/begin_transport(mob/user)
	if(linked_pad?.reserved_by && linked_pad.reserved_by != src)
		status_message = "The telepad is reserved for another transport operation."
		return
	if(charging || world.time < next_transport_allowed)
		status_message = "Transport is charging or cooling down."
		balloon_alert(user, "transport cooling down")
		return
	var/obj/item/beacon/beacon = selected_beacon?.resolve()
	if(!ccpost_visitor_landing_turf(beacon))
		status_message = ccpost_visitor_beacon_status_text(ccpost_visitor_beacon_state(beacon))
		balloon_alert(user, "landing area unavailable")
		return
	var/mob/living/carbon/human/passenger = get_single_visitor()
	if(!passenger || passenger.buckled || passenger == user)
		status_message = "Transport unavailable: No eligible passenger detected on the pad."
		balloon_alert(user, "no eligible passenger detected")
		return
	charging = TRUE
	linked_pad.reserved_by = src
	transport_sequence++
	status_message = "Charging: [passenger.name] to [beacon.name]."
	linked_pad.charging_passenger = passenger
	visible_message(span_notice("[src] initiates visitor transport. The telepad charges."))
	new /obj/effect/temp_visual/teleport_abductor/ccpost_departure(get_turf(linked_pad))
	playsound(linked_pad, 'sound/machines/terminal/terminal_alert.ogg', vol = 65, vary = TRUE)
	log_game("CCPost visitor transport initiated by [key_name(user)] for [key_name(passenger)] to [beacon].")
	addtimer(CALLBACK(src, PROC_REF(finish_transport), WEAKREF(passenger), WEAKREF(beacon), transport_sequence), CCPOST_VISITOR_CHARGE)
	SStgui.update_uis(src)

/obj/machinery/computer/ccpost_visitor_transport/proc/finish_transport(datum/weakref/passenger_ref, datum/weakref/beacon_ref, expected_sequence)
	if(!charging || expected_sequence != transport_sequence)
		return
	charging = FALSE
	next_transport_allowed = world.time + CCPOST_VISITOR_COOLDOWN
	var/mob/living/carbon/human/passenger = passenger_ref?.resolve()
	if(linked_pad)
		linked_pad.charging_passenger = null
		if(linked_pad.reserved_by == src)
			linked_pad.reserved_by = null
	if(QDELETED(passenger) || !linked_pad || QDELETED(linked_pad) || passenger.stat == DEAD || passenger.buckled || ccpost_is_outpost_personnel(passenger) || get_turf(passenger) != get_turf(linked_pad))
		status_message = "Transport cancelled: No eligible passenger detected on the pad."
		say(status_message)
		SStgui.update_uis(src)
		return
	var/obj/item/beacon/beacon = beacon_ref?.resolve()
	if(beacon != selected_beacon?.resolve())
		status_message = "Transport cancelled: Destination was changed."
		say(status_message)
		SStgui.update_uis(src)
		return
	var/turf/landing = ccpost_visitor_landing_turf(beacon)
	if(!landing || (machine_stat & (BROKEN | NOPOWER)))
		status_message = "Transport cancelled: [ccpost_visitor_beacon_status_text(ccpost_visitor_beacon_state(beacon))]"
		say(status_message)
		SStgui.update_uis(src)
		return
	var/turf/departure = get_turf(passenger)
	if(!do_teleport(passenger, landing, channel = TELEPORT_CHANNEL_BLUESPACE))
		status_message = "Transport failed: Bluespace interference detected."
		say(status_message)
		SStgui.update_uis(src)
		return
	new /obj/effect/temp_visual/dir_setting/ninja(departure, passenger.dir)
	new /obj/effect/temp_visual/dir_setting/ninja(landing, passenger.dir)
	playsound(departure, SFX_PORTAL_ENTER, 50, TRUE)
	playsound(landing, SFX_PORTAL_ENTER, 50, TRUE)
	log_game("CCPost visitor transport completed for [key_name(passenger)] from [loc_name(departure)] to [loc_name(landing)].")
	status_message = "Transport successful: [passenger.name] to [beacon.name]."
	if(ccpost_visitor_beacon_state(beacon) == "occupied")
		schedule_destination_refresh()
	visible_message(span_notice("[src] completes the visitor transport sequence."))
	SStgui.update_uis(src)


// CENTRAL COMMAND VISITOR RETRIEVAL
// Separate physical camera console, using the same Visitor Transport TGUI and telepad.
// Does not depend on the station's teleporter, its hub, or a station tracking beacon.
#define CCPOST_RETRIEVAL_INVITATION_TIMEOUT 20 SECONDS
#define CCPOST_RETRIEVAL_DECLINE_COOLDOWN 3 MINUTES
#define CCPOST_RETRIEVAL_TIMEOUT_COOLDOWN 2 MINUTES
#define CCPOST_RETRIEVAL_SHARED_COOLDOWN 30 SECONDS

/// Round-local per-person invitation state shared across every retrieval console.
/// Reference-string keys prevent different consoles from bypassing the same-person cooldown.
GLOBAL_LIST_EMPTY(ccpost_visitor_retrieval_pending)
GLOBAL_LIST_EMPTY(ccpost_visitor_retrieval_cooldowns)
/// Shared by all visitor retrieval consoles so moving to a second desk cannot
/// bypass the administrative recalibration window. Outbound transport is separate.
GLOBAL_VAR_INIT(ccpost_visitor_retrieval_next_allowed, 0)

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval
	name = "Central Command visitor retrieval console"
	desc = "Selects station visitors through the camera network and invites them to Central Command's reception telepad."
	icon_screen = "teleport"
	icon_keyboard = "teleport_key"
	light_color = LIGHT_COLOR_BLUE
	networks = list(CAMERANET_NETWORK_SS13)
	lock_override = CAMERA_LOCK_STATION
	var/obj/machinery/ccpost_visitor_pad/linked_pad
	var/datum/weakref/selected_visitor
	var/awaiting_consent = FALSE
	var/charging = FALSE
	var/transport_sequence = 0
	var/next_transport_allowed = 0
	var/status_message = "Visitor retrieval system initialized."

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/Initialize(mapload)
	. = ..()
	actions += new /datum/action/innate/ccpost_select_retrieval_visitor(src)
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/LateInitialize(mapload_arg)
	link_retrieval_pad()

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/Destroy()
	transport_sequence++
	// A dismantled console must not leave a phantom network-wide pending invite.
	for(var/person_key in GLOB.ccpost_visitor_retrieval_pending)
		if(GLOB.ccpost_visitor_retrieval_pending[person_key] == REF(src))
			GLOB.ccpost_visitor_retrieval_pending -= person_key
	if(linked_pad?.reserved_by == src)
		linked_pad.reserved_by = null
	linked_pad = null
	selected_visitor = null
	return ..()

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/proc/link_retrieval_pad()
	if(linked_pad && !QDELETED(linked_pad))
		return linked_pad
	linked_pad = null
	var/best_distance = INFINITY
	for(var/obj/machinery/ccpost_visitor_pad/pad as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/ccpost_visitor_pad))
		if(QDELETED(pad) || pad.z != z)
			continue
		var/distance = get_dist(src, pad)
		if(distance >= best_distance)
			continue
		best_distance = distance
		linked_pad = pad
	return linked_pad

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/proc/visitor_eligible(mob/living/carbon/human/person)
	// A station employee remains camera-selectable while SSD. They still
	// require explicit consent after reconnecting; no automatic transport.
	if(!istype(person) || QDELETED(person) || person.stat == DEAD || person.buckled || ccpost_is_outpost_personnel(person))
		return FALSE
	var/turf/origin = get_turf(person)
	if(!origin || !is_station_level(origin.z))
		return FALSE
	var/area/origin_area = get_area(origin)
	if(!origin_area || (origin_area.area_flags & (NOTELEPORT | ABDUCTOR_PROOF)))
		return FALSE
	if(!is_safe_turf(origin, dense_atoms = TRUE, no_teleport = TRUE))
		return FALSE
	return camnet && camnet.turf_visible_by_cameras(origin)

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/can_use(mob/living/user)
	return ccpost_visitor_transport_authorized(user) && ..()

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/ui_status(mob/user, datum/ui_state/state)
	if(isobserver(user))
		return UI_INTERACTIVE
	if((!ccpost_visitor_transport_authorized(user) || !ccpost_terminal_in_range(src, user)))
		return UI_CLOSE
	return ..()

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/attack_hand(mob/user, list/modifiers)
	if(!isobserver(user) && !ccpost_visitor_transport_authorized(user))
		balloon_alert(user, "outpost ID required")
		return
	ui_interact(user)

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/ui_interact(mob/user, datum/tgui/ui)
	if(!isobserver(user) && (!ccpost_visitor_transport_authorized(user) || !ccpost_terminal_in_range(src, user)))
		return
	. = ..()
	link_retrieval_pad()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CCPostVisitorTransport", name)
		ui.open()

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/ui_data(mob/user)
	if(!isobserver(user) && (!ccpost_visitor_transport_authorized(user) || !ccpost_terminal_in_range(src, user)))
		return list()
	link_retrieval_pad()
	var/mob/living/carbon/human/person = selected_visitor?.resolve()
	var/list/data = list(
		"retrieval_mode" = TRUE,
		"outpost_offline" = GLOB.ccpost_outpost_signal_lost,
		"read_only" = isobserver(user),
		"console_operational" = !(machine_stat & (BROKEN | NOPOWER)),
		"pad_linked" = !!linked_pad,
		"pad_busy" = !!linked_pad?.reserved_by && linked_pad.reserved_by != src,
		"charging" = charging,
		"request_pending" = awaiting_consent,
		"cooldown_seconds" = max(0, round((max(next_transport_allowed, GLOB.ccpost_visitor_retrieval_next_allowed) - world.time) / (1 SECONDS))),
		"camera_active" = !!current_user,
		"status_message" = status_message,
		"selected_target_name" = person ? person.name : "No visitor selected",
		"selected_target_area" = person ? get_area_name(person) : "",
		"selected_target_valid" = visitor_eligible(person),
		"invitation_cooldown_seconds" = person ? max(0, round((GLOB.ccpost_visitor_retrieval_cooldowns[REF(person)] - world.time) / (1 SECONDS))) : 0
	)
	return data

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(GLOB.ccpost_outpost_signal_lost)
		return TRUE
	var/mob/user = ui?.user
	if(isobserver(user) || (!ccpost_visitor_transport_authorized(user) || !ccpost_terminal_in_range(src, user)) || !user.can_perform_action(src))
		return TRUE
	if(machine_stat & (BROKEN | NOPOWER))
		return TRUE
	. = ..()
	if(.)
		return
	switch(action)
		if("open_camera")
			open_station_camera(user)
			return TRUE
		if("clear_target")
			if(!awaiting_consent && !charging)
				selected_visitor = null
				status_message = "Visitor selection cleared."
			return TRUE
		if("request_retrieval")
			if(!awaiting_consent && !charging)
				INVOKE_ASYNC(src, PROC_REF(request_visitor_consent), WEAKREF(user))
			return TRUE
		if("cancel_retrieval")
			if(charging)
				abort_retrieval("Retrieval cancelled by outpost operator.")
			return TRUE
	return FALSE

/// The normal advanced-camera eye is reused. The console itself has a distinct
/// TGUI, while the eye has a single new selection action.
/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/proc/open_station_camera(mob/living/user)
	if(awaiting_consent || charging || !can_use(user) || !user.client)
		return
	if(current_user)
		status_message = "Camera console already in use."
		return
	if(!eyeobj && !CreateEye())
		return
	var/turf/start_turf
	for(var/obj/machinery/camera/camera as anything in camnet.cameras)
		if(!camera.can_use() || !is_station_level(camera.z) || !length(networks & camera.network))
			continue
		start_turf = get_turf(camera)
		break
	if(!start_turf)
		status_message = "No connected station cameras are available."
		return
	give_eye_control(user)
	eyeobj.setLoc(start_turf, TRUE)
	status_message = "Station camera active. Use the Select Visitor action to designate a person."
	SStgui.update_uis(src)

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/proc/select_camera_visitor(mob/living/user)
	if(user != current_user || !can_use(user) || awaiting_consent || charging)
		return
	var/mob/eye/camera/remote/camera_eye = user.remote_control
	if(camera_eye != eyeobj || !is_station_level(camera_eye.z))
		return
	var/list/possible_visitors = list()
	for(var/mob/living/carbon/human/person in view(5, camera_eye))
		if(visitor_eligible(person))
			possible_visitors += person
	if(!length(possible_visitors))
		to_chat(user, span_warning("No eligible camera-visible station visitors are nearby."))
		return
	var/mob/living/carbon/human/choice = tgui_input_list(user, "Select a camera-visible visitor to invite.", "Visitor Retrieval", possible_visitors, timeout = 20 SECONDS)
	if(!choice || QDELETED(src) || user != current_user || camera_eye != eyeobj || !can_use(user))
		return
	// A stale input window cannot confer eligibility or reach a different subject.
	if(!(choice in possible_visitors) || !visitor_eligible(choice) || get_dist(choice, camera_eye) > 5)
		to_chat(user, span_warning("Selected visitor is no longer in camera view."))
		return
	selected_visitor = WEAKREF(choice)
	status_message = "Selected [choice.name]. Return to the console to send an invitation."
	remove_eye_control(user)
	ui_interact(user)
	SStgui.update_uis(src)

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/proc/request_visitor_consent(datum/weakref/operator_ref)
	if(awaiting_consent || charging || world.time < max(next_transport_allowed, GLOB.ccpost_visitor_retrieval_next_allowed) || (machine_stat & (BROKEN | NOPOWER)))
		return
	link_retrieval_pad()
	if(!linked_pad || linked_pad.reserved_by)
		status_message = "Visitor telepad is disconnected or occupied."
		return
	var/mob/living/operator = operator_ref?.resolve()
	var/mob/living/carbon/human/person = selected_visitor?.resolve()
	if(!operator || !ccpost_visitor_transport_authorized(operator) || !visitor_eligible(person))
		status_message = "Select a valid camera-visible visitor before requesting retrieval."
		return
	var/person_key = REF(person)
	if(GLOB.ccpost_visitor_retrieval_pending[person_key])
		status_message = "This person already has a pending retrieval invitation."
		return
	if(length(GLOB.ccpost_visitor_retrieval_pending))
		status_message = "A visitor invitation is already pending on the retrieval network."
		return
	var/decline_until = GLOB.ccpost_visitor_retrieval_cooldowns[person_key]
	if(decline_until && world.time < decline_until)
		status_message = "This person has declined recently. Please wait before requesting again."
		return
	awaiting_consent = TRUE
	GLOB.ccpost_visitor_retrieval_pending[person_key] = REF(src)
	var/invitation_expires = world.time + CCPOST_RETRIEVAL_INVITATION_TIMEOUT
	status_message = "Invitation registered for [person.name]. Awaiting voluntary confirmation (20 seconds)."
	log_game("CCPost visitor retrieval invitation sent by [key_name(operator)] to [key_name(person)].")
	SStgui.update_uis(src)
	// An SSD target cannot receive a TGUI alert yet. Keep their invitation
	// pending until they reconnect, or until the original expiry is reached.
	// No auto-accept, admin bypass, or timer reset on reconnection.
	while(!QDELETED(src) && !QDELETED(person) && !person.client && world.time < invitation_expires)
		sleep(5)
	var/choice
	if(!QDELETED(src) && !QDELETED(person) && person.client && world.time < invitation_expires)
		choice = tgui_alert(person, "Central Command Liaison [operator.name] invites you to the Liaison Outpost visitor reception. Accepting begins a five-second bluespace transport charge. This invitation is voluntary.", "Central Command Transport Request", list("Accept Transport", "Decline"), timeout = max(1, invitation_expires - world.time))
	if(GLOB.ccpost_visitor_retrieval_pending[person_key] == REF(src))
		GLOB.ccpost_visitor_retrieval_pending -= person_key
	if(QDELETED(src))
		return
	awaiting_consent = FALSE
	if(choice != "Accept Transport")
		GLOB.ccpost_visitor_retrieval_cooldowns[person_key] = world.time + (choice == "Decline" ? CCPOST_RETRIEVAL_DECLINE_COOLDOWN : CCPOST_RETRIEVAL_TIMEOUT_COOLDOWN)
		GLOB.ccpost_visitor_retrieval_next_allowed = world.time + CCPOST_RETRIEVAL_SHARED_COOLDOWN
		status_message = "Invitation declined or expired. Respect the visitor's decision; another invitation is temporarily unavailable."
		log_game("CCPost visitor retrieval invitation declined or expired for [key_name(person)].")
		SStgui.update_uis(src)
		return
	if(!ccpost_visitor_transport_authorized(operator) || !operator.can_perform_action(src) || selected_visitor?.resolve() != person)
		status_message = "Retrieval authorization expired."
	else
		begin_retrieval(person, operator)
	SStgui.update_uis(src)

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/proc/begin_retrieval(mob/living/carbon/human/person, mob/living/operator)
	link_retrieval_pad()
	if(charging || !linked_pad || linked_pad.reserved_by || world.time < max(next_transport_allowed, GLOB.ccpost_visitor_retrieval_next_allowed) || !visitor_eligible(person))
		status_message = "Retrieval cancelled: target or telepad is no longer available."
		return
	var/turf/origin = get_turf(person)
	var/turf/destination = get_turf(linked_pad)
	if(!is_safe_turf(destination, dense_atoms = TRUE, no_teleport = TRUE))
		status_message = "Retrieval cancelled: the outpost landing pad is obstructed or unsafe."
		return
	charging = TRUE
	transport_sequence++
	linked_pad.reserved_by = src
	status_message = "Charging retrieval of [person.name] (five seconds)."
	new /obj/effect/temp_visual/teleport_abductor/ccpost_departure(origin)
	playsound(linked_pad, 'sound/machines/terminal/terminal_alert.ogg', vol = 65, vary = TRUE)
	log_game("CCPost visitor retrieval accepted: [key_name(person)], operator [key_name(operator)], source [loc_name(origin)].")
	addtimer(CALLBACK(src, PROC_REF(finish_retrieval), WEAKREF(person), origin, transport_sequence), CCPOST_VISITOR_CHARGE)
	SStgui.update_uis(src)

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/proc/abort_retrieval(message)
	if(!charging)
		return
	transport_sequence++
	charging = FALSE
	if(linked_pad?.reserved_by == src)
		linked_pad.reserved_by = null
	next_transport_allowed = world.time + CCPOST_VISITOR_COOLDOWN
	status_message = message
	SStgui.update_uis(src)

/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/proc/finish_retrieval(datum/weakref/person_ref, turf/origin, expected_sequence)
	if(!charging || expected_sequence != transport_sequence)
		return
	charging = FALSE
	var/mob/living/carbon/human/person = person_ref?.resolve()
	if(!linked_pad || QDELETED(linked_pad) || linked_pad.reserved_by != src)
		status_message = "Retrieval cancelled: outpost telepad unavailable."
		SStgui.update_uis(src)
		return
	linked_pad.reserved_by = null
	var/turf/arrival = get_turf(linked_pad)
	if(!visitor_eligible(person) || get_turf(person) != origin || !is_safe_turf(arrival, dense_atoms = TRUE, no_teleport = TRUE) || (machine_stat & (BROKEN | NOPOWER)))
		status_message = "Retrieval cancelled: visitor moved, lost camera coverage, or the landing pad is unsafe."
		SStgui.update_uis(src)
		return
	if(!do_teleport(person, arrival, 0, channel = TELEPORT_CHANNEL_BLUESPACE))
		status_message = "Retrieval failed: bluespace interference detected."
		SStgui.update_uis(src)
		return
	// There is no adjacent-tile fallback for incoming outpost retrievals.
	// If the underlying teleport implementation redirects unexpectedly,
	// fail the retrieval and restore the visitor to their safe origin.
	if(get_turf(person) != arrival)
		if(is_safe_turf(origin, dense_atoms = TRUE, no_teleport = TRUE))
			person.forceMove(origin)
		status_message = "Retrieval failed: the receiver pad tile could not be reached precisely."
		SStgui.update_uis(src)
		return
	new /obj/effect/temp_visual/dir_setting/ninja(origin, person.dir)
	new /obj/effect/temp_visual/dir_setting/ninja(arrival, person.dir)
	playsound(origin, SFX_PORTAL_ENTER, 50, TRUE)
	playsound(arrival, SFX_PORTAL_ENTER, 50, TRUE)
	GLOB.ccpost_visitor_retrieval_next_allowed = world.time + CCPOST_RETRIEVAL_SHARED_COOLDOWN
	next_transport_allowed = world.time + CCPOST_RETRIEVAL_SHARED_COOLDOWN
	status_message = "Retrieved [person.name] to the outpost reception pad. Retrieval systems recalibrating for 25 seconds."
	selected_visitor = null
	log_game("CCPost visitor retrieval completed for [key_name(person)] from [loc_name(origin)] to [loc_name(arrival)].")
	visible_message(span_notice("[src] completes its visitor retrieval sequence."))
	SStgui.update_uis(src)

/datum/action/innate/ccpost_select_retrieval_visitor
	name = "Select Visitor"
	button_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	button_icon_state = "beam_up"

/datum/action/innate/ccpost_select_retrieval_visitor/Activate()
	var/obj/machinery/computer/camera_advanced/ccpost_visitor_retrieval/console = target
	if(!console || !isliving(owner))
		return
	console.select_camera_visitor(owner)

#undef CCPOST_RETRIEVAL_INVITATION_TIMEOUT
#undef CCPOST_RETRIEVAL_DECLINE_COOLDOWN

#undef CCPOST_VISITOR_CHARGE
#undef CCPOST_VISITOR_COOLDOWN


/// CENTRAL COMMAND OUTPOST ASSET DENIAL DEVICE
/// Reuses the station self-destruct terminal sprites and interface.
/// This device is independent of the station's nuclear systems.

GLOBAL_VAR_INIT(ccpost_adp7_authorization_code, null)
/// Central Command loses contact with the Liaison Outpost only after confirmed ADP-7 detonation.
/// Round-local flag also prevents duplicate station announcements if an admin spawns multiple devices.
GLOBAL_VAR_INIT(ccpost_outpost_signal_lost, FALSE)

/proc/ccpost_adp7_get_authorization_code()
	if(!GLOB.ccpost_adp7_authorization_code)
		GLOB.ccpost_adp7_authorization_code = random_nukecode()
	return GLOB.ccpost_adp7_authorization_code


// MAP-PLACEABLE ASSET DENIAL BLAST ORIGINS
// Marker placement is intentionally left to the mapper. Register on creation
// so successful detonation never needs to iterate over every world atom.
GLOBAL_LIST_EMPTY(ccpost_primary_blast_markers)
GLOBAL_LIST_EMPTY(ccpost_secondary_blast_markers)
GLOBAL_VAR_INIT(ccpost_adp7_station_update_sent, FALSE)

/obj/effect/landmark/ccpost_blast_center
	name = "NT-ADP-7 primary blast center (map marker)"
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/landmark/ccpost_blast_center/Initialize(mapload)
	. = ..()
	GLOB.ccpost_primary_blast_markers |= src

/obj/effect/landmark/ccpost_blast_center/Destroy()
	GLOB.ccpost_primary_blast_markers -= src
	return ..()

/obj/effect/landmark/ccpost_blast_secondary
	name = "NT-ADP-7 secondary blast (map marker)"
	invisibility = INVISIBILITY_ABSTRACT

/obj/effect/landmark/ccpost_blast_secondary/Initialize(mapload)
	. = ..()
	GLOB.ccpost_secondary_blast_markers |= src

/obj/effect/landmark/ccpost_blast_secondary/Destroy()
	GLOB.ccpost_secondary_blast_markers -= src
	return ..()

/// Non-visible, localized radiation source, with two step-downs and cleanup.
/// Native radioactive_emitter handles shielding, radiation scanners and pulses.
/obj/effect/ccpost_fallout_hotspot
	name = "residual nuclear fallout"
	desc = "Invisible residual contamination from the NT-ADP-7 detonation."
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	var/primary_source = FALSE
	var/fallout_stage = 0

/obj/effect/ccpost_fallout_hotspot/proc/activate(primary = FALSE)
	primary_source = primary
	fallout_stage = 0
	update_fallout()
	addtimer(CALLBACK(src, PROC_REF(decay_fallout)), 5 MINUTES)

/obj/effect/ccpost_fallout_hotspot/proc/update_fallout()
	var/range = primary_source ? 8 : 6
	if(fallout_stage == 1)
		range = primary_source ? 6 : 4
	else if(fallout_stage >= 2)
		range = primary_source ? 4 : 2
	// The existing component updates its arguments via UNIQUE_PASSARGS.
	var/pulse_delay = (primary_source ? (6 + fallout_stage * 3) : (10 + fallout_stage * 4)) * (1 SECONDS)
	AddComponent(/datum/component/radioactive_emitter, pulse_delay, range, RAD_LIGHT_INSULATION, "A radiation counter reports residual nuclear fallout nearby.")

/obj/effect/ccpost_fallout_hotspot/proc/decay_fallout()
	fallout_stage++
	if(fallout_stage >= 3)
		qdel(src)
		return
	update_fallout()
	addtimer(CALLBACK(src, PROC_REF(decay_fallout)), 5 MINUTES)

/// One controller per successful nuke activation. Coordinates are snapshotted
/// before any turf changes, so secondary blasts still work after the primary.
/datum/ccpost_detonation_sequence
	var/list/primary_position
	var/list/secondary_positions = list()
	var/announced = FALSE

/datum/ccpost_detonation_sequence/proc/position_for(turf/location)
	return list("x" = location.x, "y" = location.y, "z" = location.z)

/datum/ccpost_detonation_sequence/proc/turf_for(list/position)
	if(!position)
		return null
	return locate(position["x"], position["y"], position["z"])

/datum/ccpost_detonation_sequence/proc/begin(turf/device_turf)
	if(!device_turf)
		qdel(src)
		return
	var/turf/primary_turf = device_turf
	for(var/obj/effect/landmark/ccpost_blast_center/marker as anything in GLOB.ccpost_primary_blast_markers)
		if(QDELETED(marker))
			continue
		var/turf/candidate = get_turf(marker)
		if(candidate?.z != device_turf.z || get_dist(candidate, device_turf) > 70)
			continue
		primary_turf = candidate
		break
	primary_position = position_for(primary_turf)
	for(var/obj/effect/landmark/ccpost_blast_secondary/marker as anything in GLOB.ccpost_secondary_blast_markers)
		if(length(secondary_positions) >= 4)
			break
		if(QDELETED(marker))
			continue
		var/turf/candidate = get_turf(marker)
		if(candidate?.z != primary_turf.z || get_dist(candidate, primary_turf) > 55)
			continue
		secondary_positions += list(position_for(candidate))
	log_game("NT-ADP-7 blast sequence: primary [primary_turf.x],[primary_turf.y],[primary_turf.z], secondary markers [length(secondary_positions)].")
	// Lock the administrative installation before the blast. The station-wide
	// announcement is intentionally delayed until after the last explosion.
	GLOB.ccpost_outpost_signal_lost = TRUE
	GLOB.ccpost_tasking_network?.note_admin_server_state()
	explosion(primary_turf, devastation_range = 15, heavy_impact_range = 27, light_impact_range = 42, flame_range = 30, flash_range = 46, adminlog = TRUE, ignorecap = TRUE)
	if(length(secondary_positions))
		for(var/index in 1 to length(secondary_positions))
			addtimer(CALLBACK(src, PROC_REF(detonate_secondary), index), index * 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(complete_sequence)), (length(secondary_positions) + 1) * 2 SECONDS)

/datum/ccpost_detonation_sequence/proc/detonate_secondary(index)
	if(index < 1 || index > length(secondary_positions))
		return
	var/turf/location = turf_for(secondary_positions[index])
	if(!location)
		return
	explosion(location, devastation_range = 7, heavy_impact_range = 13, light_impact_range = 20, flame_range = 15, flash_range = 24, adminlog = TRUE, ignorecap = TRUE)

/datum/ccpost_detonation_sequence/proc/complete_sequence()
	var/turf/primary_turf = turf_for(primary_position)
	if(primary_turf)
		var/obj/effect/ccpost_fallout_hotspot/primary_hotspot = new(primary_turf)
		primary_hotspot.activate(TRUE)
	for(var/list/position as anything in secondary_positions)
		var/turf/location = turf_for(position)
		if(!location)
			continue
		var/obj/effect/ccpost_fallout_hotspot/secondary_hotspot = new(location)
		secondary_hotspot.activate(FALSE)
	if(!announced && !GLOB.ccpost_adp7_station_update_sent)
		announced = TRUE
		GLOB.ccpost_adp7_station_update_sent = TRUE
		priority_announce(
			"Central Command has lost all communications and telemetry from the Central Command Liaison Outpost following a major energy event. The installation is now considered OFFLINE. Further information will be provided once the situation has been verified.",
			"Liaison Outpost Communications Lost",
			sender_override = "Central Command Update",
			has_important_message = TRUE,
			color_override = "blue"
		)
		log_game("NT-ADP-7: Primary and [length(secondary_positions)] secondary blasts completed. Outpost offline; station notification sent.")
	qdel(src)

// NT-ADP-7 AUTHENTICATION DISK AND TRACKING SYSTEM


// Dedicated registry for ADP-7 authentication disks.
// Separate from the station's nuclear disk tracking.
GLOBAL_LIST_EMPTY(ccpost_adp7_disks)


// NT-ADP-7 AUTHENTICATION DISK

/obj/item/disk/nuclear/ccpost_nuke
	name = "NT-ADP-7 authentication disk"
	desc = "A classified Central Command authentication disk intended exclusively for the NT-ADP-7 Asset Denial Device."
	icon_state = "nucleardisk"

	// Prevent normal nuclear disk operative-related behavior.
	fake = TRUE


/obj/item/disk/nuclear/ccpost_nuke/Initialize(mapload)
	// Preserve the mapped location before parent initialization.
	var/atom/original_location = loc

	. = ..()

	// Nuclear disks receive stationloving even with fake = TRUE.
	// Remove it so this disk can exist on the outpost z-level.
	var/datum/component/stationloving/location_restriction = GetComponent(/datum/component/stationloving)

	if(location_restriction)
		qdel(location_restriction)

	// Restore its original location if parent initialization
	// relocated the disk to the station.
	if(original_location && loc != original_location)
		forceMove(original_location)

	// Register the disk exclusively with ADP-7 trackers.
	GLOB.ccpost_adp7_disks += src


/obj/item/disk/nuclear/ccpost_nuke/Destroy()
	// Prevent trackers from retaining deleted disk references.
	GLOB.ccpost_adp7_disks -= src

	return ..()

/obj/item/pinpointer/ccpost_adp7
	name = "NT-ADP-7 authentication pinpointer"
	desc = "A classified NanoTrasen tracking device calibrated exclusively to NT-ADP-7 authentication disks."
	icon_state = "pinpointer"
	worn_icon_state = "pinpointer"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

	// Continuously updates its target while activated.
	process_scan = TRUE


/obj/item/pinpointer/ccpost_adp7/scan_for_target()
	target = null

	var/turf/scanner_turf = get_turf(src)
	if(!scanner_turf)
		return

	var/closest_distance = INFINITY

	// Only search the dedicated ADP-7 disk registry.
	// Never consult the station's nuclear disk registry.
	for(var/obj/item/disk/nuclear/ccpost_nuke/disk as anything in GLOB.ccpost_adp7_disks)
		if(QDELETED(disk))
			continue

		var/turf/disk_turf = get_turf(disk)
		if(!disk_turf)
			continue

		// Native pinpointers track within the same z-level.
		if(scanner_turf.z != disk_turf.z)
			continue

		var/distance = get_dist(scanner_turf, disk_turf)

		if(distance < closest_distance)
			closest_distance = distance
			target = disk


/obj/item/pinpointer/ccpost_adp7/examine(mob/user)
	. = ..()

	if(istype(src, /obj/item/pinpointer/ccpost_adp7/syndicate))
		return
	. += span_notice("Tracking frequency: NT-ADP-7 classified authentication signal.")

	if(!active)
		. += span_notice("The tracker is currently inactive.")
	else if(target)
		. += span_notice("An NT-ADP-7 authentication signal has been acquired.")
	else
		. += span_warning("No NT-ADP-7 authentication signal detected on this level.")

/obj/item/pinpointer/ccpost_adp7/syndicate
	name = "Syndicate asset-denial pinpointer"
	desc = "A modified Syndicate tracking device calibrated to intercept the authentication signature of NanoTrasen's NT-ADP-7 Asset Denial Device."
	icon_state = "pinpointer_syndicate"
	worn_icon_state = "pinpointer_black"

/obj/item/pinpointer/ccpost_adp7/syndicate/attack_self(mob/living/user)
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(user.mind != director?.operative_mind_ref?.resolve())
		return
	return ..()

/obj/item/pinpointer/ccpost_adp7/syndicate/proc/contract_tracking_target()
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(!director?.event_started || director.gorlex_victory)
		return null
	var/mob/living/operative = director.operative_ref?.resolve()
	if(!director.asset_acquired || !director.holds_contract_asset(operative) || director.black_warrant)
		return director.primary_target()
	if(!director.nuke_ever_armed)
		return director.get_disk()
	if(director.extraction_turf)
		return director.extraction_turf
	return director.get_contract_nuke()

/obj/item/pinpointer/ccpost_adp7/syndicate/scan_for_target()
	target = null
	var/atom/signal_target = contract_tracking_target()
	var/turf/destination = get_turf(signal_target)
	var/turf/origin = get_turf(src)
	if(destination && origin && !is_station_level(destination.z) && destination.z == origin.z)
		target = signal_target

/obj/item/pinpointer/ccpost_adp7/syndicate/examine(mob/user)
	. = ..()
	. += span_warning("Its tracking hardware bears unauthorized Syndicate modifications.")
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(!active || !director || user.mind != director.operative_mind_ref?.resolve())
		return
	var/atom/signal_target = contract_tracking_target()
	var/list/readout = ccpost_tracking_readout(signal_target, user, signal_target?.name || "Assigned objective")
	if(readout["signal"] != "ACQUIRED")
		. += span_warning("No authorized contract signal detected.")
	else if(!readout["same_level"])
		. += span_notice("Remote signal: [readout["label"]] is on z-level [readout["sector"]]. Consult your uplink to identify the sector.")
	else
		. += span_notice("[readout["label"]] signal acquired on this z-level.")

// Classified authorization paper.
// Place this separately from the authentication disk.

/obj/item/paper/fluff/ruins/ccpost/adp7_authorization
	name = "NT-ADP-7 authorization directive"
	desc = "A classified NanoTrasen document containing asset-denial authorization procedures."

/obj/item/paper/fluff/ruins/ccpost/adp7_authorization/Initialize(mapload)
	default_raw_text = {"<center><b>NANOTRASEN CENTRAL COMMAND</b><br><b>CLASSIFIED: ASSET DENIAL CONTINGENCY</b></center><hr>
	<br><b>Device:</b> NT-ADP-7 Asset Denial Device
	<br><b>Installation:</b> Central Command Liaison Outpost
	<br><b>Authorization Code:</b> [ccpost_adp7_get_authorization_code()]
	<br><br>Both the authentication disk and authorization code are required before activation.
	<br><br><b>WARNING:</b> Activation initiates destruction of the installation.
	<br><br><i>Corporate confidentiality takes precedence over corporate property.</i>"}
	return ..()


// Asset Denial Terminal.
// This is deliberately NOT a /selfdestruct subtype.
// Station nuclear code requests therefore cannot overwrite
// its separate authorization code.

/obj/machinery/nuclearbomb/ccpost_nuke
	name = "NT-ADP-7 Asset Denial Device"
	desc = "A classified NanoTrasen contingency device designed to prevent sensitive corporate intelligence from falling into unauthorized hands. Do not taunt."
	icon = 'icons/obj/machines/nuke_terminal.dmi'
	icon_state = "nuclearbomb_base"
	anchored = TRUE
	timer_set = 180
	minimum_timer_set = 90
	maximum_timer_set = 600
	/// Dedicated NT-ADP-7 CentCom transmitter; never interacts with station nuclear alerts.
	var/obj/item/radio/ccpost_warning_radio
	/// Prevent duplicate transmissions from repeated arming calls.
	var/ccpost_arm_announcement_sent = FALSE

/obj/machinery/nuclearbomb/ccpost_nuke/Initialize(mapload)
	. = ..()
	r_code = ccpost_adp7_get_authorization_code()
	ccpost_warning_radio = new(src)
	ccpost_warning_radio.set_frequency(FREQ_CENTCOM)
	ccpost_warning_radio.independent = TRUE
	ccpost_warning_radio.ignores_radio_jammers = TRUE
	ccpost_warning_radio.canhear_range = 0
	ccpost_warning_radio.set_listening(FALSE)
	ccpost_warning_radio.command = TRUE
	ccpost_warning_radio.use_command = TRUE


// Only the dedicated ADP-7 disk is accepted.

/obj/machinery/nuclearbomb/ccpost_nuke/disk_check(obj/item/disk/nuclear/inserted_disk)
	if(!istype(inserted_disk, /obj/item/disk/nuclear/ccpost_nuke))
		say("Authentication failure: NT-ADP-7 disk required.")
		return FALSE

	auth = inserted_disk
	return TRUE


// The device cannot be moved.

/obj/machinery/nuclearbomb/ccpost_nuke/set_anchor(mob/anchorer)
	return


// Use the original keypad, countdown, and safety controls.
// Do not trigger the station's nuclear alert or round-end systems.

/obj/machinery/nuclearbomb/ccpost_nuke/arm_nuke(mob/armer)
	if(!istype(auth, /obj/item/disk/nuclear/ccpost_nuke) || !yes_code || safety || !timing)
		timing = FALSE
		return

	// Independent Gorlex contract tracking; the main station's nuclear state is untouched.
	var/obj/effect/landmark/ccpost_gorlex_director/gorlex_director = GLOB.ccpost_gorlex_director
	if(gorlex_director && armer?.mind && armer.mind == gorlex_director.operative_mind_ref?.resolve())
		gorlex_director.check_asset_acquired(armer)
		if(gorlex_director.black_warrant || !gorlex_director.asset_acquired || !gorlex_director.holds_contract_asset(armer))
			timing = FALSE
			to_chat(armer, span_warning("GORLEX COMMAND: NT-ADP-7 authorization denied. Recover and retain your assigned asset before arming the device; your contract must remain active."))
			return
	if(gorlex_director)
		gorlex_director.note_arming(armer)
	detonation_timer = world.time + (timer_set * 10)
	countdown.start()
	update_appearance()

	var/turf/device_turf = get_turf(src)

	message_admins("[src] armed by [armer ? ADMIN_LOOKUPFLW(armer) : "unknown"] at [ADMIN_VERBOSEJMP(device_turf)].")
	log_game("NT-ADP-7 armed by [armer ? key_name(armer) : "unknown"] at [loc_name(device_turf)].")

	visible_message(span_bolddanger("[src] begins its asset-denial countdown!"))

	playsound(src, 'sound/announcer/alarm/nuke_alarm.ogg', 65, FALSE)

	// High-volume radio warning on CentCom frequency. Other departments do not receive it.
	// We use the same wording as the existing local warning for consistency.
	if(!ccpost_arm_announcement_sent && ccpost_warning_radio)
		ccpost_arm_announcement_sent = TRUE
		ccpost_warning_radio.talk_into(src, "CENTRAL COMMAND ALERT: NT-ADP-7 ASSET DENIAL ACTIVE. EVACUATE THE OUTPOST. DETONATION IN [timer_set] SECONDS.", RADIO_CHANNEL_CENTCOM)

	for(var/mob/living/person as anything in GLOB.mob_living_list)
		var/turf/person_turf = get_turf(person)
		if(person_turf && istype(get_area(person_turf), /area/ruin/space/has_grav/ccpost))
			to_chat(person, span_boldannounce("CENTRAL COMMAND ALERT: NT-ADP-7 ASSET DENIAL ACTIVE. EVACUATE THE OUTPOST. DETONATION IN [timer_set] SECONDS."))


// Disarming remains possible through the normal interface.

/obj/machinery/nuclearbomb/ccpost_nuke/disarm_nuke(mob/disarmer, change_level_back = TRUE)
	var/obj/effect/landmark/ccpost_gorlex_director/gorlex_director = GLOB.ccpost_gorlex_director
	if(gorlex_director)
		gorlex_director.armed_by_gorlex = FALSE
	ccpost_arm_announcement_sent = FALSE
	detonation_timer = null
	countdown.stop()
	update_appearance()

	if(disarmer)
		message_admins("[src] disarmed by [ADMIN_LOOKUPFLW(disarmer)].")
		log_game("NT-ADP-7 disarmed by [key_name(disarmer)].")

	visible_message(span_notice("[src] aborts its asset-denial countdown."))


// Local explosion only.
// Prevent station nuclear cinematics, round-ending effects,
// and modifications to global station nuclear state.

/obj/machinery/nuclearbomb/ccpost_nuke/explode()
	if(exploded || !timing || safety)
		return FALSE

	if(!core)
		timing = FALSE
		safety = TRUE
		yes_code = FALSE
		detonation_timer = null
		countdown.stop()
		update_ui_mode()
		update_appearance()
		visible_message(span_warning("[src] aborts detonation: the fissile core is missing."))
		return FALSE

	exploding = TRUE
	exploded = TRUE
	timing = FALSE
	safety = TRUE
	yes_code = FALSE
	detonation_timer = null

	countdown.stop()
	update_appearance()

	var/turf/device_turf = get_turf(src)
	if(!device_turf)
		qdel(src)
		return TRUE

	message_admins("[src] DETONATED at [ADMIN_VERBOSEJMP(device_turf)]. Local outpost blast only.")
	log_game("NT-ADP-7 detonated at [loc_name(device_turf)].")

	var/obj/effect/landmark/ccpost_gorlex_director/gorlex_director = GLOB.ccpost_gorlex_director
	if(gorlex_director)
		gorlex_director.note_detonation()
	var/datum/ccpost_detonation_sequence/sequence = new
	sequence.begin(device_turf)
	// The controller owns secondary blasts, fallout and the delayed station notice.
	qdel(src)
	return TRUE

// Reverse Engineered Experimental Tech

// CHIMERA - REVERSE ENGINEERED CYBERSUN WEAPON

// Reusable luminance-to-hue transforms; alpha remains unchanged.
#define CCPOST_CHIMERA_TINT_BLUE list(0.08,0.17,0.33,0, 0.14,0.30,0.59,0, 0.03,0.06,0.11,0, 0,0,0,1, 0,0,0,0)
#define CCPOST_CHIMERA_TINT_GOLD list(0.30,0.25,0.11,0, 0.59,0.48,0.21,0, 0.11,0.09,0.04,0, 0,0,0,1, 0,0,0,0)
#define CCPOST_CHIMERA_TINT_CYAN list(0.13,0.35,0.39,0, 0.23,0.63,0.70,0, 0.04,0.12,0.13,0, 0,0,0,1, 0,0,0,0)
#define CCPOST_CHIMERA_TINT_GREEN list(0.14,0.40,0.18,0, 0.25,0.71,0.32,0, 0.05,0.13,0.06,0, 0,0,0,1, 0,0,0,0)
#define CCPOST_CHIMERA_TINT_VIOLET list(0.30,0.17,0.40,0, 0.54,0.30,0.71,0, 0.10,0.06,0.13,0, 0,0,0,1, 0,0,0,0)


/obj/item/stock_parts/power_store/cell/ccpost_chimera
	name = "Chimera modular plasma core"
	maxcharge = 1000

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera
	name = "\improper NT-X01 Chimera"
	desc = "An experimental multi-configuration energy rifle developed by NanoTrasen through reverse-engineering of Cybersun's Hyeseong weapons platform. Its heavily modified plasma reactor allows it to assume five distinct firing configurations. The original Cybersun Industries insignia, a red circle broken by a hexagonal flower, is still partially visible beneath a crudely riveted NanoTrasen plate. A nearby sticker reads \"PROPRIETARY NANOTRASEN TECHNOLOGY.\""
	expanded_examine_text = "Pulse: rapid conventional bolts. Lance: click to charge a fixed aim point, click again to release early, or wait one second for full discharge. Suppression: five rapid rotating radial sweeps; move to cancel. Graviton: pulls, compresses and ejects targets. Cataclysm: drains all remaining cell charge into a traveling Tesla-like plasma sphere. Output scales with charge; the sphere grows in flight and its electrical tendrils expend energy before the terminal eruption. Minimum 5% charge. Heat cools after two seconds of inactivity. The core recovers 1% per five seconds after ten seconds of inactivity. Vent Plasma Core expends 10% charge to remove 40 heat. Holding the rifle at 60% thermal load or above causes progressively increasing burns."
	cell_type = /obj/item/stock_parts/power_store/cell/ccpost_chimera
	ammo_type = list(/obj/item/ammo_casing/energy/ccpost_chimera/pulse)
	weapon_mode_options = list(/datum/laser_weapon_mode/ccpost_chimera/pulse, /datum/laser_weapon_mode/ccpost_chimera/lance, /datum/laser_weapon_mode/ccpost_chimera/suppression, /datum/laser_weapon_mode/ccpost_chimera/graviton, /datum/laser_weapon_mode/ccpost_chimera/cataclysm)
	default_selected_mode = "Pulse"
	speech_json_file = null
	actions_types = list(/datum/action/item_action/toggle_personality, /datum/action/item_action/ccpost_chimera_vent)
	selfcharge = FALSE
	automatic_charge_overlays = FALSE
	burst_size = 1
	var/chimera_heat = 0
	/// Time of the next heat-contact warning, independent of personality speech.
	var/next_contact_heat_warning = 0
	var/thermal_lockout = FALSE
	var/last_discharge = 0
	var/last_thermal_update = 0
	var/last_core_activity = 0
	var/last_core_update = 0
	var/core_recharge_progress = 0
	var/core_recharging = FALSE
	var/venting = FALSE
	var/sequence = 0
	var/sequence_kind
	var/mob/living/sequence_user
	var/turf/sequence_origin
	var/turf/lance_target
	var/lance_started = 0
	var/obj/effect/ccpost_chimera_well/active_well
	var/datum/ccpost_chimera_attack/sequence_attack
	var/datum/weakref/performance_operator
	var/datum/weakref/recovery_operator
	var/recovery_mode
	var/hit_streak = 0
	var/miss_streak = 0
	var/next_combat_comment = 0
	var/combat_report_serial = 0
	var/next_recovery_comment = 0
	var/next_busy_comment = 0
	var/overheat_count = 0
	var/vent_count = 0
	var/recent_switches = 0
	var/last_switch_time = 0

// Local dialogue bank
/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/speak_up(json_string, ignores_cooldown = FALSE, ignores_personality_toggle = FALSE)
	if(!personality_mode && !ignores_personality_toggle)
		return
	if(!json_string || (!ignores_cooldown && !COOLDOWN_FINISHED(src, last_speech)))
		return
	var/static/list/dialogue = list(
		"pickup" = list("Personnel recognized. CHIMERA weapons platform ready. Your performance will be recorded.", "Greetings, operator. Please remember that this is a prototype, not a toy.", "Operational readiness confirmed. NanoTrasen expects a reasonable return on its investment.", "Operator detected. Evaluating competence. Results inconclusive.", "Welcome back. NanoTrasen appreciates your continued survival.", "Weapon interface synchronized. Please keep the paperwork off my optics."),
		"putdown" = list("I was engineered for advanced combat applications. Not floor storage.", "Discharge systems standing by. Please do not forget where you left me.", "Storage mode engaged. The floor is not an approved armory.", "I shall await a more productive assignment."),
		"worn" = list("Transport configuration recognized. I shall monitor the rear hemisphere.", "A sensible carrying arrangement. Your training appears adequate.", "Magnetic retention confirmed. Try not to walk into anything.", "Transport mode. I was expecting a more exciting assignment."),
		"lowcharge" = list("Power reserves below recommended levels. Your enthusiasm exceeds our available energy.", "Energy reserves critical. I trust you have a contingency plan.", "Power reserves are limited, operator. Recovery requires time."),
		"fullcharge" = list("Core charge at maximum. Please exercise an appropriate degree of restraint.", "Energy reserves restored. A rare example of responsible maintenance.", "Fully charged. The expense has been logged."),
		"pulse" = list("Standard discharge configuration online. Try to hit something.", "NanoTrasen pulse emitter synchronized.", "Standard pulse doctrine engaged. The economical choice.", "Conventional discharge ready. No elaborate justification required."),
		"lance" = list("Focal lens aligned. Please hold still. You, not the target.", "Precision configuration selected. Patience is a valuable asset.", "Precision lens deployed. A steady hand would be beneficial.", "Focal alignment established. Make the expense worthwhile."),
		"suppression" = list("Radial suppression configuration online. Personal space is now enforceable.", "Radial emitters deployed. Everyone is now in the firing arc.", "Perimeter defense mode. Please consider your colleagues."),
		"graviton" = list("Gravitational containment engaged. The laws of physics have been advised.", "Graviton configuration online. Please retain possession of your belongings.", "Localized gravitational manipulation authorized. Do not stand in the field.", "Gravity is now a negotiable condition."),
		"cataclysm" = list("Cataclysm configuration online. All available reserves will be committed to a single discharge.", "High-density plasma emitter ready. Your remaining energy is now expendable."),
		"cataclysm_full" = list("Full reactor discharge authorized. Stand clear.", "Maximum energy committed. This will be expensive."),
		"cataclysm_partial" = list("Residual energy committed. Output proportional to remaining reserves.", "All available power discharged. Recharge recommended."),
		"thermal_elevated" = list("Core temperature rising. Operating within acceptable parameters.", "Thermal load increasing. Please pace yourself.", "Core temperature above nominal. Nothing to celebrate."),
		"thermal_critical" = list("Thermal load approaching critical levels. Recommend reduced discharge frequency.", "Critical thermal load approaching. The warning is not decorative.", "Heat reserves nearly exhausted. Consider a different approach."),
		"thermal_lock" = list("Thermal threshold exceeded. Discharge systems temporarily suspended.", "Thermal containment engaged. I would appreciate a moment to reconsider your decisions.", "Emergency lockout engaged. Your trigger is no longer accepting suggestions.", "The core is at its limit. Kindly stop contributing to the problem."),
		"thermal_recovered" = list("Thermal regulation restored. Your weapon is once again available.", "Core cooled to safe operating temperature. Try to keep it that way.", "Discharge authorization restored. Let us avoid a repeat performance."),
		"vent_start" = list("Emergency thermal discharge initiated. Stand clear.", "Venting plasma core. Do not interrupt the procedure.", "Thermal purge initiated. Remaining stationary is not optional."),
		"vent_done" = list("Thermal load reduced. Thank you for following basic operating procedures.", "Core temperature reduced. An efficient expenditure of energy.", "Maintenance complete. A commendable use of basic training."),
		"vent_aborted" = list("Venting aborted. I would advise completing the procedure next time.", "Thermal purge interrupted. The heat has not disappeared out of courtesy."),
		"suppression_start" = list("Personnel advisory: stand clear. All directions.", "Radial suppression imminent. Stand clear.", "Warning: all-direction discharge. Personnel should seek cover."),
		"suppression_end" = list("Perimeter suppression complete. Collateral assessment pending.", "Radial sequence complete. Assessing the perimeter.", "Emitter rotation complete. Please check your colleagues."),
		"sequence_aborted" = list("Discharge sequence aborted. I was under the impression we were standing still.", "Sequence terminated. Your movement has overridden the firing solution.", "Discharge aborted. Stationary means stationary, operator."),
		"combat_hit" = list("Impact confirmed. Acceptable marksmanship, operator.", "Target impact detected. An adequate return on investment.", "Contact confirmed. Your aim appears functional.", "Successful impact. The expenditure has been justified."),
		"combat_miss" = list("No living target impact detected. Perhaps aim at the target next time.", "Discharge expended without a confirmed hit. How economical.", "No impact on personnel detected. Reconsider your firing solution.", "Target acquisition unsuccessful. I will not be taking responsibility."),
		"combat_blocked" = list("Contact detected. No effective impact confirmed.", "The target appears to have taken precautions. Adjust accordingly."),
		"combat_multi" = list("Multiple impacts confirmed. An efficient use of company resources.", "Several targets struck. A satisfactory distribution of energy.", "Multiple personnel affected. Please review the collateral report."),
		"lance_hit" = list("Precision strike confirmed. A satisfactory application of expensive technology.", "Focal discharge connected. Your patience was not entirely wasted.", "Precision impact confirmed. A measurable improvement."),
		"lance_full_hit" = list("Full-focus impact confirmed. Patience rewarded.", "Maximum focal concentration delivered. An excellent return on investment."),
		"suppression_hit" = list("Perimeter contact confirmed. Radial defense has made an impression.", "Suppression sequence registered contact. Maintain situational awareness."),
		"suppression_multi" = list("Multiple targets struck. Personal space is now enforceable.", "Perimeter engagement registered multiple impacts. Assess collateral."),
		"graviton_multi" = list("Gravitational convergence achieved. How inconvenient for them.", "Multiple personnel displaced. The laws of physics remain cooperative."),
		"hit_streak" = list("Your performance is exceeding initial projections. Unexpected.", "Three consecutive successful discharges. A promising trend.", "Consistent accuracy detected. NanoTrasen may yet recover its investment."),
		"miss_streak" = list("I have reviewed your accuracy statistics. We need to talk.", "Three unsuccessful discharges. Recalibrating my expectations.", "I refuse to believe this is entirely my fault."),
		"cooldown_pulse" = list("Pulse emitter cycling. A brief moment of restraint.", "Standard discharge recovery underway."),
		"cooldown_lance" = list("Focal emitter realigning. Kindly refrain from excessive trigger enthusiasm.", "Precision systems recalibrating. Quality takes time."),
		"cooldown_suppression" = list("Radial emitters cycling. Please enjoy the temporary silence.", "Perimeter discharge complete. Reestablishing emitter alignment."),
		"cooldown_graviton" = list("Gravitational containment stabilizing. Physics remains mostly intact.", "Recharging field generators. The universe can wait."),
		"cooldown_cataclysm" = list("Plasma emitter recalibrating. Energy reserves depleted."),
		"cooldown_ready" = list("Weapons systems ready. Do try to make this one count.", "Operational capacity restored.", "Ready for further corporate negotiations."),
		"cooldown_busy" = list("Your impatience has been documented. The weapon is still cycling.", "Repeated trigger input will not accelerate the recovery process.", "The core is cycling, operator. Kindly wait."),
		"overheat_repeat" = list("Thermal warnings are not decorative, operator.", "Repeated thermal lockout detected. Your training is under review."),
		"vent_repeat" = list("Proactive thermal management. Your training was evidently not wasted.", "Repeated maintenance confirmed. A sensible operating habit."),
		"switch_repeat" = list("All five configurations remain functional. Is there a decision forthcoming?", "Repeated configuration changes detected. Please choose a doctrine."),
		"recharge_start" = list("Energy recovery initiated. Even experimental technology requires a moment of peace.", "Internal power reserves replenishing. I recommend you do the same.", "Passive core recovery online. Please allow the reactor to do its work.")
	)
	var/list/responses = dialogue[json_string]
	if(!length(responses))
		return
	say(pick(responses))
	playsound(src, 'sound/mobs/non-humanoids/tourist/tourist_talk.ogg', 15, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, frequency = rand(2, 2.2))
	Shake(2, 2, 1 SECONDS)
	COOLDOWN_START(src, last_speech, 2 SECONDS)

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/Initialize(mapload)
	. = ..()
	// Replace the inherited manufacturer element, rather than stacking two labels.
	RemoveElement(/datum/element/manufacturer_examine, COMPANY_CYBERSUN)
	AddElement(/datum/element/manufacturer_examine, "It has a NanoTrasen logo crudely affixed over a red circle broken by a hexagonal flower. The words \"Cybersun Industries\" in Konjin remain entirely legible.")
	// Native Pulse and Lance radial images remain unmodified. The Tesla sheet
	// is 96x96; scale only the radial image to fit the ordinary menu slot.
	var/static/icon/cataclysm_radial_icon
	if(!cataclysm_radial_icon)
		cataclysm_radial_icon = icon('icons/obj/machines/engine/energy_ball.dmi', "energy_ball")
		cataclysm_radial_icon.Scale(32, 32)
	radial_menu_data["Cataclysm"] = image(icon = cataclysm_radial_icon)
	for(var/mode_name in list("Suppression", "Graviton"))
		var/image/mode_image = radial_menu_data[mode_name]
		if(mode_image)
			mode_image.color = mode_name == "Suppression" ? CCPOST_CHIMERA_TINT_CYAN : CCPOST_CHIMERA_TINT_GREEN
	last_thermal_update = world.time
	last_core_update = world.time
	last_core_activity = world.time
	START_PROCESSING(SSobj, src)

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/ex_act(severity, target)
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(director?.contract_prototype_ref?.resolve() == src && !director.gorlex_victory && !director.cybersun_recovered)
		return
	return ..()

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/Destroy()
	cancel_sequence(FALSE)
	if(active_well && !QDELETED(active_well))
		active_well.source_rifle = null
	active_well = null
	currently_selected_mode?.remove_from_weapon(src)
	for(var/mode_name in weapon_mode_name_to_path)
		qdel(weapon_mode_name_to_path[mode_name])
	currently_selected_mode = null
	weapon_mode_name_to_path = null
	return ..()

// The parent equips a soulcatcher. Bypass that override while retaining its normal gun equipment behavior and speech. No player souls in this prototype.
/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/equipped(mob/user, slot, initial)
	. = ..()
	QDEL_NULL(tracked_soulcatcher)
	var/obj/effect/landmark/ccpost_gorlex_director/director = GLOB.ccpost_gorlex_director
	if(director?.contract_prototype_ref?.resolve() == src)
		director.check_asset_acquired(user)
	update_slot_icon()

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/click_alt(mob/user)
	return CLICK_ACTION_SUCCESS

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/examine(mob/user)
	. = ..()
	// Remove the inherited soulcatcher instruction, not the native charge readout.
	var/list/examine_lines = .
	for(var/line in examine_lines.Copy())
		if(findtext(line, "internal soulcatcher"))
			. -= line
	update_thermal()
	var/thermal_status = thermal_lockout ? "LOCKED until 40%" : (chimera_heat >= 75 ? "Critical" : (chimera_heat >= 50 ? "Elevated" : "Nominal"))
	. += span_notice("Configuration: [currently_selected_mode?.name]. Core charge: [cell ? round(cell.percent(), 0.1) : 0]%.")
	. += span_notice("Thermal load: [round(chimera_heat, 0.1)]% ([thermal_status]). Personality: [personality_mode ? "Online" : "Muted"].")
	if(chimera_heat >= 60)
		. += span_warning("The rifle is hot enough to burn anyone holding it. Contact burn rate: [round(contact_burn_rate(chimera_heat), 0.1)] per second.")
	if(currently_selected_mode?.name == "Cataclysm")
		. += span_notice("Cataclysm commits the entire remaining charge. Minimum 5%; output scales with charge at firing.")
	if(venting)
		. += span_warning("Manual thermal venting in progress.")
	else if(cell && cell.charge < cell.maxcharge)
		. += span_notice("Passive core recovery: [core_recharging ? "Active" : "Standby"].")

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/process(seconds_per_tick)
	if(cell)
		. = ..()
	var/heat_before_cooling = chimera_heat
	update_thermal()
	apply_contact_heat(seconds_per_tick, heat_before_cooling)
	update_core_recharge()
	if(sequence_kind && (!sequence_user || sequence_user.incapacitated() || !sequence_user.is_holding(src)))
		cancel_sequence()

// Thermal contact hazard: held weapons only, including during thermal lockout.
// Independent of cell charge, personality and the selected firing configuration.
/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/contact_burn_rate(thermal_load)
	if(thermal_load < 60)
		return 0
	if(thermal_load <= 90)
		return 0.5 + (thermal_load - 60) / 30
	return min(2, 1.5 + (thermal_load - 90) / 20)

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/apply_contact_heat(seconds_per_tick, heat_before_cooling)
	var/mob/living/operator = loc
	if(!istype(operator) || QDELETED(operator) || operator.stat == DEAD || !operator.is_holding(src))
		return
	// Average the pre/post cooling rates, and cap catch-up damage during lag.
	var/burn_rate = (contact_burn_rate(heat_before_cooling) + contact_burn_rate(chimera_heat)) / 2
	var/burn_damage = burn_rate * clamp(seconds_per_tick, 0, 2)
	if(burn_damage <= 0)
		return
	operator.adjustFireLoss(burn_damage)
	if(world.time >= next_contact_heat_warning)
		next_contact_heat_warning = world.time + 5 SECONDS
		to_chat(operator, span_warning("The overheated Chimera burns your hands!"))

// Time-based recovery, independent from heat. No accumulated credit during firing or venting.
/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/update_core_recharge()
	var/now = world.time
	var/from = max(last_core_update, last_core_activity + 10 SECONDS)
	last_core_update = now
	if(QDELETED(cell) || cell.charge >= cell.maxcharge || sequence_kind || venting || currently_switching_types)
		core_recharge_progress = 0
		core_recharging = FALSE
		return
	if(now <= from)
		return
	core_recharge_progress += now - from
	var/steps = FLOOR(core_recharge_progress, 5 SECONDS) / (5 SECONDS)
	if(steps < 1)
		return
	core_recharge_progress -= steps * (5 SECONDS)
	var/old_charge = cell.charge
	cell.give(min(cell.maxcharge - cell.charge, cell.maxcharge * 0.01 * steps))
	if(cell.charge <= old_charge)
		return
	if(!core_recharging)
		core_recharging = TRUE
		var/mob/living/operator = loc
		if(istype(operator) && operator.is_holding(src))
			speak_up("recharge_start")
	if(!chambered)
		recharge_newshot(TRUE)
	update_appearance()

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/reset_core_recharge()
	last_core_activity = world.time
	last_core_update = world.time
	core_recharge_progress = 0
	core_recharging = FALSE

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/update_thermal()
	var/now = world.time
	var/cool_from = max(last_thermal_update, last_discharge + 2 SECONDS)
	last_thermal_update = now
	if(!venting && now > cool_from && chimera_heat > 0)
		chimera_heat = max(0, chimera_heat - 12 * (now - cool_from) / (1 SECONDS))
	if(thermal_lockout && chimera_heat <= 40)
		thermal_lockout = FALSE
		playsound(src, 'sound/machines/beep/beep.ogg', 35, FALSE)
		speak_up("thermal_recovered", TRUE)

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/add_heat(amount)
	update_thermal()
	var/old_heat = chimera_heat
	chimera_heat = min(100, chimera_heat + amount)
	last_discharge = world.time
	reset_core_recharge()
	if(chimera_heat >= 100)
		thermal_lockout = TRUE
		overheat_count++
		playsound(src, 'sound/machines/hiss.ogg', 40, TRUE)
		new /obj/effect/temp_visual/steam(get_turf(src))
		speak_up(overheat_count % 3 == 0 ? "overheat_repeat" : "thermal_lock", TRUE)
	else if(old_heat < 75 && chimera_heat >= 75)
		playsound(src, 'sound/machines/beep/beep.ogg', 35, FALSE)
		speak_up("thermal_critical", TRUE)
	else if(old_heat < 50 && chimera_heat >= 50)
		speak_up("thermal_elevated", TRUE)

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/can_trigger_gun(mob/living/user, akimbo_usage)
	. = ..()
	if(!.)
		return FALSE
	update_thermal()
	if(semicd && !thermal_lockout && !venting)
		comment_on_busy(user)
		return FALSE
	if(thermal_lockout || venting || (sequence_kind && sequence_kind != "lance"))
		balloon_alert(user, thermal_lockout ? "thermal lockout!" : "core busy!")
		return FALSE
	return TRUE

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/attack_self(mob/living/user)
	if(venting)
		return
	cancel_sequence()
	return ..()

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/dropped(mob/user, silent)
	cancel_sequence()
	recovery_operator = null
	recovery_mode = null
	performance_operator = null
	combat_report_serial++
	hit_streak = 0
	miss_streak = 0
	return ..()

// ---------------------------------------------------------------------------
// EXPERIMENTAL TECHNOLOGY VISUAL FRAMEWORK (shared, not Chimera-specific)
// Cache immutable icon copies by source, state mask and tint. The source DMI is
// never modified. Dedicated charge overlays are independently luminance-tinted.
// ---------------------------------------------------------------------------
// Explicit palettes are taken from the native Hyeseong DMI states, including
// both hand files and worn sprites. This avoids hue heuristics that recolor
// the physical gold trim or miss darker violet/red emitter shades.
/proc/ccpost_experimental_tinted_icon(source_file, list/source_colors, tint)
	var/static/list/icon_cache = list()
	var/palette_key = jointext(source_colors, ",")
	var/cache_key = "[source_file]|[palette_key]|[tint]"
	if(icon_cache[cache_key])
		return icon_cache[cache_key]
	var/icon/recolored = icon(source_file)
	var/tint_red = hex2num(copytext(tint, 2, 4)) / 255
	var/tint_green = hex2num(copytext(tint, 4, 6)) / 255
	var/tint_blue = hex2num(copytext(tint, 6, 8)) / 255
	for(var/pixel in source_colors)
		var/red = hex2num(copytext(pixel, 2, 4))
		var/green = hex2num(copytext(pixel, 4, 6))
		var/blue = hex2num(copytext(pixel, 6, 8))
		// Convert to neutral luminance first. Peak weighting keeps the original
		// glow shades legible; do not change alpha, dimensions or DMI metadata.
		var/gray = round(0.65 * max(red, green, blue) + 0.35 * (0.2126 * red + 0.7152 * green + 0.0722 * blue))
		var/alpha_value = length(pixel) >= 9 ? hex2num(copytext(pixel, 8, 10)) : 255
		recolored.SwapColor(lowertext(pixel), rgb(round(gray * tint_red), round(gray * tint_green), round(gray * tint_blue), alpha_value))
	icon_cache[cache_key] = recolored
	return recolored

/proc/ccpost_experimental_energy_matrix(tint, red_weight = 0.2126, green_weight = 0.7152, blue_weight = 0.0722)
	var/r = hex2num(copytext(tint, 2, 4)) / 255
	var/g = hex2num(copytext(tint, 4, 6)) / 255
	var/b = hex2num(copytext(tint, 6, 8)) / 255
	return list(red_weight*r,red_weight*g,red_weight*b,0, green_weight*r,green_weight*g,green_weight*b,0, blue_weight*r,blue_weight*g,blue_weight*b,0, 0,0,0,1, 0,0,0,0)

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/energy_palette()
	switch(currently_selected_mode?.name)
		if("Lance")
			return list("#FFD15B", list("#DCA01B", "#F8D860", "#AA6300"))
		if("Suppression")
			return list("#51D9EE", list("#247296", "#47A1B3", "#113961"))
		if("Graviton")
			return list("#39D17B", list("#27895D", "#77BD5D", "#2B575D"))
		if("Cataclysm")
			return list("#C17CFF", list("#7A0BB7", "#9D1DE8", "#500677"))
	return list("#3569D6", list("#A7335B", "#CD4456", "#542A4C"))

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/apply_experimental_sprites()
	if(!currently_selected_mode)
		return
	var/list/palette = energy_palette()
	var/list/source_colors = palette[2]
	if(currently_selected_mode.name == "Lance")
		// Native gold emitter and gold chassis use the SAME three RGB colors.
		// Keep the existing gold held/worn art; tint its isolated charge layer
		// below. This avoids destroying the gold trim on the physical weapon.
		icon = initial(icon)
		lefthand_file = initial(lefthand_file)
		righthand_file = initial(righthand_file)
		worn_icon = initial(worn_icon)
	else
		icon = ccpost_experimental_tinted_icon(initial(icon), source_colors, palette[1])
		lefthand_file = ccpost_experimental_tinted_icon(initial(lefthand_file), source_colors, palette[1])
		righthand_file = ccpost_experimental_tinted_icon(initial(righthand_file), source_colors, palette[1])
		worn_icon = ccpost_experimental_tinted_icon(initial(worn_icon), source_colors, palette[1])
	update_appearance()
	update_slot_icon()

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/update_overlays()
	. = ..()
	// Native charge overlays are disabled only for this subtype. Explicitly
	// attach the correct file and charge state after each appearance update.
	if(currently_switching_types || !currently_selected_mode || !cell)
		return
	var/ratio = get_charge_ratio()
	var/state = ratio ? "[icon_state]_charge[ratio]" : "[icon_state]_empty"
	var/list/palette = energy_palette()
	var/mutable_appearance/charge
	if(currently_selected_mode.name == "Lance")
		charge = mutable_appearance(initial(icon), state)
		charge.color = ccpost_experimental_energy_matrix(palette[1], 0.55, 0.4, 0.05)
	else
		// Use the exact cached recolored DMI, retaining empty-state animation.
		charge = mutable_appearance(ccpost_experimental_tinted_icon(initial(icon), palette[2], palette[1]), state)
	. += charge

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/transform_gun(datum/laser_weapon_mode/new_weapon_mode, replacing = TRUE, dont_speak = FALSE)
	. = ..()
	apply_experimental_sprites()
	// The native mode datum deletes the previous casing; explicitly rechamber.
	chambered = null
	recharge_newshot(TRUE)
	update_appearance()
	if(replacing && !dont_speak)
		if(world.time - last_switch_time > 12 SECONDS)
			recent_switches = 0
		last_switch_time = world.time
		recent_switches++
		if(recent_switches >= 4)
			recent_switches = 0
			addtimer(CALLBACK(src, PROC_REF(comment_switches)), 2.1 SECONDS)

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/valid_operator(mob/living/user)
	if(QDELETED(user) || user.incapacitated() || !user.is_holding(src) || !isturf(user.loc))
		return FALSE
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		return FALSE
	if(!user.has_hand_for_held_index(user.get_inactive_hand_index()))
		return FALSE
	if(user.get_inactive_held_item() && !istype(user.get_inactive_held_item(), /obj/item/offhand))
		return FALSE
	return TRUE

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/begin_sequence(mob/living/user, kind)
	update_core_recharge()
	sequence++
	sequence_kind = kind
	sequence_user = user
	sequence_origin = get_turf(user)
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(operator_moved))
	return sequence

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/operator_moved(datum/source)
	SIGNAL_HANDLER
	cancel_sequence()

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/cancel_sequence(announce = TRUE)
	if(!sequence_kind)
		return
	var/old_kind = sequence_kind
	var/datum/ccpost_chimera_attack/old_attack = sequence_attack
	sequence_attack = null
	if(old_attack)
		old_attack.seal()
	if(sequence_user)
		UnregisterSignal(sequence_user, COMSIG_MOVABLE_MOVED)
	sequence++
	sequence_kind = null
	last_core_update = world.time
	sequence_user = null
	sequence_origin = null
	lance_target = null
	if(announce && old_kind != "vent")
		speak_up("sequence_aborted")
	if(old_kind == "vent")
		last_thermal_update = world.time
		venting = FALSE
		if(announce)
			speak_up("vent_aborted", TRUE)

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/sequence_valid(token, kind)
	return sequence == token && sequence_kind == kind && valid_operator(sequence_user) && get_turf(sequence_user) == sequence_origin && !currently_switching_types

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/spend_core(percent, thermal)
	update_thermal()
	if(QDELETED(cell) || cell.charge < cell.maxcharge * percent / 100 || thermal_lockout)
		return FALSE
	if(!cell.use(cell.maxcharge * percent / 100))
		return FALSE
	chambered = null
	recharge_newshot(TRUE)
	add_heat(thermal)
	update_appearance()
	return TRUE

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/launch_fragment(mob/living/user, turf/start, fire_angle, projectile_path, shot_damage, penetration = 0, datum/ccpost_chimera_attack/attack = null, volley = 0)
	if(!start)
		return
	var/obj/projectile/beam/ccpost_chimera/projectile = new projectile_path(start)
	if(attack)
		projectile.attach_attack(attack)
	projectile.chimera_volley = volley
	projectile.firer = user
	projectile.fired_from = src
	projectile.def_zone = user.zone_selected
	projectile.damage = shot_damage
	projectile.armour_penetration = penetration
	projectile.fire(fire_angle)

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/record_special_fire(mob/living/user, atom/target)
	SEND_SIGNAL(user, COMSIG_MOB_FIRED_GUN, src, target, null, null)
	SEND_SIGNAL(src, COMSIG_GUN_FIRED, user, target, null, null)
	add_fingerprint(user)
	playsound(src, fire_sound, fire_sound_volume, TRUE)
	user.update_held_items()
	SSblackbox.record_feedback("tally", "gun_fired", 1, initial(name))

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(!valid_operator(user) || QDELETED(target) || currently_switching_types || venting || thermal_lockout || semicd)
		return FALSE
	var/turf/aim = get_turf(target)
	if(!aim || aim == get_turf(user) || aim.z != user.z)
		return FALSE
	if(sequence_kind == "lance")
		if(sequence_user == user)
			finish_lance(sequence)
		return TRUE
	if(sequence_kind)
		return FALSE
	switch(currently_selected_mode.name)
		if("Lance")
			if(!can_shoot())
				return FALSE
			var/token = begin_sequence(user, "lance")
			lance_target = aim
			lance_started = world.time
			balloon_alert(user, "focusing lance...")
			playsound(src, 'sound/machines/beep/beep.ogg', 25, FALSE)
			addtimer(CALLBACK(src, PROC_REF(finish_lance), token), 1 SECONDS)
			return TRUE
		if("Suppression")
			if(!can_shoot())
				return FALSE
			var/token = begin_sequence(user, "suppression")
			user.visible_message(span_warning("[user] raises [src] and its emitter begins to charge!"))
			speak_up("suppression_start", TRUE)
			playsound(src, 'sound/items/modsuit/ballin.ogg', 40, TRUE)
			addtimer(CALLBACK(src, PROC_REF(suppression_sweep), token, 1), 0.6 SECONDS)
			return TRUE
		if("Cataclysm")
			return fire_cataclysm(user, target, aim)
		if("Graviton")
			if(active_well && !QDELETED(active_well))
				balloon_alert(user, "gravity well already active!")
				return FALSE
			. = ..()
			if(.)
				add_heat(40)
				begin_recovery(user, "Graviton")
			return .
		else
			. = ..()
			if(.)
				add_heat(8)
				begin_recovery(user, "Pulse")
			return .

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/finish_lance(token)
	if(!sequence_valid(token, "lance"))
		if(sequence == token)
			cancel_sequence()
		return
	var/mob/living/user = sequence_user
	var/turf/aim = lance_target
	var/turf/origin = sequence_origin
	var/fraction = clamp((world.time - lance_started) / (1 SECONDS), 0, 1)
	var/cost = 10 + 5 * fraction
	var/thermal = 15 + 10 * fraction
	cancel_sequence(FALSE)
	// An early release can be cheaper; never debit more charge than available.
	if(!cell || cell.percent() < cost)
		balloon_alert(user, "insufficient core charge!")
		return
	if(!spend_core(cost, thermal))
		return
	record_special_fire(user, aim)
	var/datum/ccpost_chimera_attack/attack = new(src, user, "Lance", fraction >= 1)
	launch_fragment(user, origin, get_angle(origin, aim), /obj/projectile/beam/ccpost_chimera/lance, 20 + 15 * fraction, 20 * fraction, attack)
	attack.seal()
	new /obj/effect/temp_visual/dir_setting/firing_effect/yellow(user, angle2dir(get_angle(origin, aim)))
	semicd = TRUE
	begin_recovery(user, "Lance")
	addtimer(CALLBACK(src, PROC_REF(reset_semicd)), 2 SECONDS)

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/suppression_sweep(token, sweep)
	if(!sequence_valid(token, "suppression"))
		if(sequence == token)
			cancel_sequence()
		return
	var/mob/living/user = sequence_user
	var/turf/origin = sequence_origin
	if(!spend_core(5, 10))
		cancel_sequence()
		return
	record_special_fire(user, origin)
	// Each sweep rotates another nine degrees: 40 distinct trajectories.
	if(!sequence_attack)
		sequence_attack = new(src, user, "Suppression")
	var/offset = (sweep - 1) * 9
	var/projectile_path = /obj/projectile/beam/ccpost_chimera/suppression
	if(sweep == 5)
		projectile_path = /obj/projectile/beam/ccpost_chimera/suppression/overload
		new /obj/effect/temp_visual/ccpost_chimera_radial_flash/overload(origin)
		playsound(src, 'sound/items/weapons/pulse.ogg', 65, TRUE)
	else
		new /obj/effect/temp_visual/ccpost_chimera_radial_flash(origin)
	for(var/i in 0 to 7)
		launch_fragment(user, origin, i * 45 + offset, projectile_path, 4, 0, sequence_attack, sweep)
	if(sweep >= 5 || thermal_lockout)
		cancel_sequence(FALSE)
		// Leave the next optional speech slot for the attack assessment.
		balloon_alert(user, thermal_lockout ? "thermal lockout!" : "radial sequence complete")
		semicd = TRUE
		begin_recovery(user, "Suppression")
		addtimer(CALLBACK(src, PROC_REF(reset_semicd)), 0.5 SECONDS)
		return
	addtimer(CALLBACK(src, PROC_REF(suppression_sweep), token, sweep + 1), 0.2 SECONDS)

// Conservative lateral lane origin check: no bypassing windows, dense objects, or diagonal corners. A blocked side lane is simply omitted.
/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/lane_clear(turf/tile)
	if(!tile || tile.density)
		return FALSE
	for(var/atom/movable/obstacle in tile)
		if(obstacle.density && !isliving(obstacle))
			return FALSE
	return TRUE

// Total discharge: snapshot charge before spending it. The projectile owns its
// budget and effects, and survives dropping, switching or deleting the rifle.
/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/fire_cataclysm(mob/living/user, atom/target, turf/aim)
	update_thermal()
	if(QDELETED(cell) || cell.maxcharge <= 0 || thermal_lockout || cell.percent() < 5)
		balloon_alert(user, "insufficient core charge!")
		return FALSE
	var/turf/origin = get_turf(user)
	if(!origin || !aim || origin == aim)
		return FALSE
	var/charge_fraction = clamp(cell.charge / cell.maxcharge, 0, 1)
	var/charge_spent = cell.charge
	if(!cell.use(charge_spent))
		return FALSE
	chambered = null
	semicd = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_semicd)), 2 SECONDS)
	speak_up(charge_fraction >= 0.95 ? "cataclysm_full" : "cataclysm_partial", TRUE)
	add_heat(round(70 * charge_fraction))
	var/obj/projectile/beam/ccpost_chimera/cataclysm/sphere = new(origin)
	sphere.configure_discharge(charge_fraction)
	sphere.firer = user
	sphere.fired_from = src
	sphere.original = target
	sphere.def_zone = user.zone_selected
	sphere.fire(get_angle(origin, aim))
	record_special_fire(user, target)
	playsound(origin, 'sound/effects/magic/lightningbolt.ogg', 65, TRUE)
	new /obj/effect/temp_visual/dir_setting/firing_effect/ccpost_chimera_violet(user, angle2dir(get_angle(origin, aim)))
	update_appearance()
	return TRUE

/datum/action/item_action/ccpost_chimera_vent
	name = "Vent Plasma Core"
	desc = "Spend 10% of the core's capacity to vent 40 heat over two seconds. Hold the rifle and remain still."
	background_icon_state = "bg_mod"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "smoke"

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/ui_action_click(mob/user, actiontype)
	if(!istype(actiontype, /datum/action/item_action/ccpost_chimera_vent))
		return ..()
	if(!isliving(user) || !user.is_holding(src))
		return
	var/mob/living/vent_user = user
	update_thermal()
	if(vent_user.incapacitated() || venting || sequence_kind || currently_switching_types || chimera_heat < 20 || !cell || cell.percent() < 10)
		balloon_alert(user, "cannot vent core!")
		return
	var/token = begin_sequence(vent_user, "vent")
	venting = TRUE
	speak_up("vent_start", TRUE)
	playsound(src, 'sound/machines/hiss.ogg', 45, TRUE)
	new /obj/effect/temp_visual/steam(get_turf(src))
	addtimer(CALLBACK(src, PROC_REF(finish_vent), token), 2 SECONDS)

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/finish_vent(token)
	if(sequence != token || sequence_kind != "vent")
		return
	var/mob/living/user = sequence_user
	if(QDELETED(user) || user.incapacitated() || !user.is_holding(src) || get_turf(user) != sequence_origin || !cell || cell.percent() < 10)
		cancel_sequence()
		return
	update_thermal()
	if(!cell.use(cell.maxcharge * 0.10))
		cancel_sequence()
		return
	chimera_heat = max(0, chimera_heat - 40)
	reset_core_recharge()
	cancel_sequence(FALSE)
	chambered = null
	recharge_newshot(TRUE)
	update_appearance()
	update_thermal()
	vent_count++
	speak_up(vent_count % 3 == 0 ? "vent_repeat" : "vent_done", TRUE)

// Configuration datums
/datum/laser_weapon_mode/ccpost_chimera
	charge_sections = 5

/datum/laser_weapon_mode/ccpost_chimera/apply_to_weapon(obj/item/gun/energy/applied_gun)
	applied_gun.burst_size = 1

/datum/laser_weapon_mode/ccpost_chimera/pulse
	name = "Pulse"
	casing = /obj/item/ammo_casing/energy/ccpost_chimera/pulse
	weapon_icon_state = "kill"
	shot_delay = 0.3 SECONDS
	json_speech_string = "pulse"
	gun_runetext_color = "#4FA8DD"

/datum/laser_weapon_mode/ccpost_chimera/lance
	name = "Lance"
	casing = /obj/item/ammo_casing/energy/ccpost_chimera/lance
	weapon_icon_state = "sniper"
	shot_delay = 2 SECONDS
	json_speech_string = "lance"
	gun_runetext_color = "#f8d860"
	var/datum/component/scope/chimera_scope

/datum/laser_weapon_mode/ccpost_chimera/lance/apply_to_weapon(obj/item/gun/energy/applied_gun)
	..()
	chimera_scope = applied_gun.AddComponent(/datum/component/scope, 3)

/datum/laser_weapon_mode/ccpost_chimera/lance/remove_from_weapon(obj/item/gun/energy/applied_gun)
	QDEL_NULL(chimera_scope)
	return ..()

/datum/laser_weapon_mode/ccpost_chimera/suppression
	charge_sections = 2
	name = "Suppression"
	casing = /obj/item/ammo_casing/energy/ccpost_chimera/suppression
	weapon_icon_state = "disabler"
	shot_delay = 0.5 SECONDS
	json_speech_string = "suppression"
	gun_runetext_color = "#47a1b3"

/datum/laser_weapon_mode/ccpost_chimera/graviton
	charge_sections = 3
	name = "Graviton"
	casing = /obj/item/ammo_casing/energy/ccpost_chimera/graviton
	weapon_icon_state = "launcher"
	shot_delay = 2 SECONDS
	json_speech_string = "graviton"
	gun_runetext_color = "#77bd5d"

/datum/laser_weapon_mode/ccpost_chimera/cataclysm
	charge_sections = 3
	name = "Cataclysm"
	casing = /obj/item/ammo_casing/energy/ccpost_chimera/cataclysm
	weapon_icon_state = "shot"
	shot_delay = 0.5 SECONDS
	json_speech_string = "cataclysm"
	gun_runetext_color = "#a76bd5"

// All casings use the same 1000-unit cell; custom special modes debit the cell themselves, whereas Pulse and Graviton use the native casing pipeline.
/obj/item/ammo_casing/energy/ccpost_chimera/pulse
	projectile_type = /obj/projectile/beam/ccpost_chimera/pulse
	e_cost = 50
	select_name = "Pulse"
	fire_sound = 'sound/items/weapons/pulse.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/blue

/obj/item/ammo_casing/energy/ccpost_chimera/lance
	projectile_type = /obj/projectile/beam/ccpost_chimera/lance
	e_cost = 100
	select_name = "Lance"
	fire_sound = 'monkestation/code/modules/blueshift/sounds/laser_firing/vaporize.ogg'

/obj/item/ammo_casing/energy/ccpost_chimera/suppression
	projectile_type = /obj/projectile/beam/ccpost_chimera/suppression
	e_cost = 50
	select_name = "Suppression"
	fire_sound = 'sound/items/weapons/gun/energy/Laser2.ogg'

/obj/item/ammo_casing/energy/ccpost_chimera/graviton
	projectile_type = /obj/projectile/beam/ccpost_chimera/graviton
	e_cost = 300
	select_name = "Graviton"
	fire_sound = 'monkestation/code/modules/blueshift/sounds/laser_firing/incinerate.ogg'
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/ccpost_chimera_green

/obj/item/ammo_casing/energy/ccpost_chimera/cataclysm
	projectile_type = /obj/projectile/beam/ccpost_chimera/cataclysm
	// Native chamber/charge eligibility only. The custom fire path spends ALL charge.
	e_cost = 50
	select_name = "Cataclysm"
	fire_sound = 'monkestation/code/modules/blueshift/sounds/laser_firing/melt.ogg'

// Plain beam parent: no inherited pulse explosion or Cybersun grenade.
/obj/projectile/beam/ccpost_chimera
	demolition_mod = 0
	damage_walls = FALSE
	pass_flags = PASSTABLE
	ricochets_max = 0
	reflectable = FALSE
	eyeblur = 0
	wound_bonus = -20
	bare_wound_bonus = 0
	var/datum/ccpost_chimera_attack/chimera_attack
	var/chimera_volley = 0

/obj/projectile/beam/ccpost_chimera/proc/attach_attack(datum/ccpost_chimera_attack/attack)
	if(chimera_attack || QDELETED(attack))
		return
	chimera_attack = attack
	attack.pending++
	attack.launched++

/obj/projectile/beam/ccpost_chimera/fire(fire_angle, atom/direct_target)
	// Native single-shot casings attach here; special sequences attach before firing.
	if(!chimera_attack)
		var/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/rifle = fired_from
		if(istype(rifle) && !QDELETED(rifle) && isliving(firer))
			var/datum/ccpost_chimera_attack/attack = new(rifle, firer, rifle.currently_selected_mode.name)
			attach_attack(attack)
			attack.seal()
	return ..()

/obj/projectile/beam/ccpost_chimera/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!QDELETED(chimera_attack) && isliving(target))
		if(blocked < 100 && . != BULLET_ACT_BLOCK)
			chimera_attack.living_hits |= REF(target)
		else
			chimera_attack.blocked_hits++
	return .

/obj/projectile/beam/ccpost_chimera/Destroy()
	var/datum/ccpost_chimera_attack/attack = chimera_attack
	chimera_attack = null
	if(!QDELETED(attack))
		attack.projectile_finished()
	return ..()

/obj/projectile/beam/ccpost_chimera/pulse
	pass_flags = PASSTABLE | PASSWINDOW
	projectile_phasing = PASSWINDOW
	phasing_ignore_direct_target = TRUE
	name = "Chimera pulse bolt"
	icon_state = "u_laser"
	damage = 18
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/pulse
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	impact_type = /obj/effect/projectile/impact/pulse
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser

/obj/projectile/beam/ccpost_chimera/lance
	pass_flags = PASSTABLE | PASSWINDOW
	projectile_phasing = PASSWINDOW
	phasing_ignore_direct_target = TRUE
	name = "Chimera lance"
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/saibasan/projectiles.dmi'
	icon_state = "sniper"
	damage = 35
	speed = 2.5
	light_color = "#FFD15B"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/yellow_laser

/obj/projectile/beam/ccpost_chimera/suppression
	pass_flags = PASSTABLE | PASSWINDOW
	projectile_phasing = PASSWINDOW
	phasing_ignore_direct_target = TRUE
	name = "Chimera suppression bolt"
	icon_state = "omnilaser"
	damage = 4
	stamina = 18
	armor_flag = ENERGY
	speed = 2
	range = 4
	light_color = "#51D9EE"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/ccpost_chimera_cyan
	color = CCPOST_CHIMERA_TINT_CYAN

// One contact attempt per living target per volley. Duplicate rays pass through the
// already-accounted target instead of multiplying damage on adjacent tiles.
/obj/projectile/beam/ccpost_chimera/suppression/prehit_pierce(atom/target)
	. = ..()
	if(. == PROJECTILE_PIERCE_PHASE || . == PROJECTILE_DELETE_WITHOUT_HITTING || !isliving(target) || QDELETED(chimera_attack) || !chimera_volley)
		return .
	var/key = "[chimera_volley]:[REF(target)]"
	if(chimera_attack.volley_contacts[key])
		return PROJECTILE_PIERCE_PHASE
	chimera_attack.volley_contacts[key] = TRUE

/obj/projectile/beam/ccpost_chimera/suppression/overload
	name = "Chimera suppression overload bolt"
	stamina = 28
	knockdown = 2 SECONDS
	light_color = "#9CF6FF"
	light_outer_range = 2
	light_power = 1.3
	color = CCPOST_CHIMERA_TINT_CYAN

/obj/projectile/beam/ccpost_chimera/suppression/overload/Initialize(mapload)
	. = ..()
	transform = matrix() * 1.25

/obj/projectile/beam/ccpost_chimera/graviton
	name = "Chimera graviton"
	icon = 'monkestation/code/modules/blueshift/icons/obj/company_and_or_faction_based/saibasan/projectiles.dmi'
	icon_state = "grenade"
	damage = 15
	speed = 0.5
	range = 6
	light_color = "#67E68A"
	color = CCPOST_CHIMERA_TINT_GREEN
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	var/formed_well = FALSE

/obj/projectile/beam/ccpost_chimera/graviton/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	form_well(get_turf(target))

/obj/projectile/beam/ccpost_chimera/graviton/on_range()
	form_well(get_turf(src))
	return ..()

/obj/projectile/beam/ccpost_chimera/graviton/proc/form_well(turf/center)
	if(formed_well)
		return
	formed_well = TRUE
	var/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/rifle = fired_from
	if(!istype(rifle) || QDELETED(rifle) || (rifle.active_well && !QDELETED(rifle.active_well)))
		return
	if(!center)
		return
	if(!rifle.lane_clear(center))
		center = get_step(center, angle2dir(angle + 180))
	if(!rifle.lane_clear(center))
		return
	rifle.active_well = new /obj/effect/ccpost_chimera_well(center)
	rifle.active_well.source_rifle = rifle
	if(isliving(firer))
		rifle.active_well.field_operator = WEAKREF(firer)

/obj/effect/ccpost_chimera_well
	name = "localized gravity well"
	desc = "A localized gravitational distortion compresses nearby targets before ejecting them outward."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield2"
	anchored = TRUE
	density = FALSE
	color = CCPOST_CHIMERA_TINT_GREEN
	light_system = OVERLAY_LIGHT
	light_outer_range = 2
	light_power = 0.6
	light_color = "#67E68A"
	var/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/source_rifle
	var/datum/weakref/field_operator
	var/list/displaced_personnel = list()
	var/list/entry_directions = list()
	var/field_reported = FALSE

/obj/effect/ccpost_chimera_well/Destroy()
	if(source_rifle?.active_well == src)
		source_rifle.active_well = null
	source_rifle = null
	return ..()

/obj/effect/ccpost_chimera_well/Initialize(mapload)
	. = ..()
	apply_wibbly_filters(src)
	animate(src, transform = matrix()*1.5, time = 0.3 SECONDS)
	playsound(src, 'sound/effects/gravhit.ogg', 45, TRUE)
	addtimer(CALLBACK(src, PROC_REF(pull_once)), 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(pull_once)), 1.75 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(collapse)), 2.7 SECONDS)
	QDEL_IN(src, 3 SECONDS)

/obj/effect/ccpost_chimera_well/proc/eligible_target(atom/movable/thing)
	if(QDELETED(thing) || !isturf(thing.loc) || thing.anchored || thing == src)
		return FALSE
	if(isliving(thing))
		var/mob/living/person = thing
		return !person.buckled && !person.mob_negates_gravity()
	if(!isitem(thing) || istype(thing, /obj/item/disk/nuclear))
		return FALSE
	// The classified cartridge is defined in the separate Gorlex file.
	return !findtext("[thing.type]", "/obj/item/ccpost_classified_cartridge")

/obj/effect/ccpost_chimera_well/proc/pull_once()
	playsound(src, 'sound/effects/gravhit.ogg', 30, TRUE)
	var/processed = 0
	var/turf/center = get_turf(src)
	// Visible targets only. Snapshot the list before moving anything.
	var/list/targets = list()
	for(var/atom/movable/thing in view(2, src))
		if(eligible_target(thing))
			targets += thing
	for(var/atom/movable/thing as anything in targets)
		if(processed >= 40)
			break
		if(!eligible_target(thing))
			continue
		processed++
		var/turf/old_turf = get_turf(thing)
		var/key = REF(thing)
		if(old_turf != center)
			if(!entry_directions[key])
				entry_directions[key] = get_dir(center, old_turf)
			step_towards(thing, src)
		if(isliving(thing))
			var/mob/living/person = thing
			person.apply_damage(8, BRUTE, BODY_ZONE_CHEST, attacking_item = source_rifle)
			if(get_turf(thing) != old_turf)
				displaced_personnel |= key
	if(!field_reported && length(displaced_personnel) >= 2 && !QDELETED(source_rifle))
		field_reported = TRUE
		var/mob/living/operator = field_operator?.resolve()
		if(!QDELETED(operator) && operator.is_holding(source_rifle))
			source_rifle.combat_comment("graviton_multi", 35)

/obj/effect/ccpost_chimera_well/proc/collapse()
	var/turf/center = get_turf(src)
	if(!center)
		return
	// Native gentle throws respect collisions. No explosion, structural damage,
	// forced movement through walls, or thrown-object collision damage.
	var/list/targets = list()
	for(var/atom/movable/thing in view(2, src))
		if(eligible_target(thing))
			targets += thing
	var/processed = 0
	var/mob/living/operator = field_operator?.resolve()
	for(var/atom/movable/thing as anything in targets)
		if(processed >= 40)
			break
		if(!eligible_target(thing))
			continue
		var/turf/old_turf = get_turf(thing)
		var/direction = get_dir(center, old_turf)
		if(!direction)
			direction = entry_directions[REF(thing)]
			if(!direction)
				direction = pick(NORTH, SOUTH, EAST, WEST)
		var/turf/destination = get_ranged_target_turf(thing, direction, 2)
		if(!destination || destination == old_turf)
			continue
		processed++
		thing.throw_at(destination, 2, 2, operator, spin = FALSE, gentle = TRUE)
	playsound(src, 'sound/effects/gravhit.ogg', 65, TRUE)
	new /obj/effect/temp_visual/ccpost_chimera_radial_flash/graviton(center)
	animate(src, alpha = 0, transform = matrix()*0.2, time = 0.3 SECONDS)

// First experimental pool entry. Add further distinct prototype paths here once implemented; one spawn per armory population, never on locker opening.
/obj/structure/closet/secure_closet/ccpost_armory
	var/ccpost_experimental_populated = FALSE

/obj/structure/closet/secure_closet/ccpost_armory/proc/ccpost_populate_experimental()
	if(ccpost_experimental_populated)
		return
	ccpost_experimental_populated = TRUE
	var/static/list/prototype_pool = list(/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera)
	var/prototype_path = pick(prototype_pool)
	var/obj/item/prototype = new prototype_path(src)
	GLOB.ccpost_severance_prototypes |= WEAKREF(prototype)
	new /obj/item/paper/fluff/ruins/ccpost/chimera_dossier(src)

/obj/item/paper/fluff/ruins/ccpost/chimera_dossier
	name = "NT-X01 experimental armament evaluation"
	default_raw_text = {"<center><b>NANOTRASEN RESEARCH & DEVELOPMENT</b><br>CLASSIFIED - NT-X01 CHIMERA</center><hr>Recovered Cybersun Hyeseong chassis; reconstructed modular plasma core.<br>Authorized for installation defense. Five discharge configurations share one core. CATACLYSM commits all remaining battery charge to a traveling plasma sphere. The sphere grows in flight; electrical tendrils and terminal eruption share a finite energy reserve. Keep friendly personnel clear of the discharge path. Examine the weapon for live charge and thermal load. Thermal lockout at 100%; recovery at 40%. Contact burns begin at 60% thermal load while held. Manual venting consumes 10% charge to remove 40 heat. Passive recovery restores 1% every five seconds after ten seconds without discharge.<br>Return the prototype intact after use. Do not dismantle or remove from the installation."}



// V2 combat telemetry. Each discharge owns one collector, even when its projectiles
// resolve after the rifle switches modes. Seal only after all launches are done.
/datum/ccpost_chimera_attack
	var/datum/weakref/rifle_ref
	var/datum/weakref/operator_ref
	var/configuration
	var/full_focus = FALSE
	var/pending = 0
	var/launched = 0
	var/sealed = FALSE
	var/list/living_hits = list()
	var/list/volley_contacts = list()
	var/blocked_hits = 0

/datum/ccpost_chimera_attack/New(obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/rifle, mob/living/operator, mode_name, fully_charged = FALSE)
	. = ..()
	rifle_ref = WEAKREF(rifle)
	operator_ref = WEAKREF(operator)
	configuration = mode_name
	full_focus = fully_charged

/datum/ccpost_chimera_attack/proc/seal()
	sealed = TRUE
	try_finish()

/datum/ccpost_chimera_attack/proc/projectile_finished()
	pending = max(0, pending - 1)
	try_finish()

/datum/ccpost_chimera_attack/proc/try_finish()
	if(!sealed || pending)
		return
	var/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/rifle = rifle_ref?.resolve()
	var/mob/living/operator = operator_ref?.resolve()
	if(launched && !QDELETED(rifle) && !QDELETED(operator) && operator.is_holding(rifle))
		rifle.assess_attack(src, operator)
	qdel(src)

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/combat_comment(category, chance = 20)
	if(!personality_mode || world.time < next_combat_comment || !prob(chance))
		return FALSE
	var/mob/living/operator = loc
	if(!istype(operator) || !operator.is_holding(src))
		return FALSE
	next_combat_comment = world.time + 4 SECONDS
	combat_report_serial++
	if(COOLDOWN_FINISHED(src, last_speech))
		speak_up(category)
	else
		// In particular, the mandatory 0.6s suppression windup announcement
		// would otherwise mute every report from the 1.4s firing sequence.
		addtimer(CALLBACK(src, PROC_REF(deliver_combat_comment), category, WEAKREF(operator), combat_report_serial), COOLDOWN_TIMELEFT(src, last_speech) + 0.1 SECONDS)
	return TRUE

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/deliver_combat_comment(category, datum/weakref/operator_ref, report_serial)
	var/mob/living/operator = operator_ref?.resolve()
	if(report_serial != combat_report_serial || QDELETED(operator) || !operator.is_holding(src) || !personality_mode || !COOLDOWN_FINISHED(src, last_speech))
		return
	speak_up(category)

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/assess_attack(datum/ccpost_chimera_attack/attack, mob/living/operator)
	if(performance_operator?.resolve() != operator)
		performance_operator = WEAKREF(operator)
		hit_streak = 0
		miss_streak = 0
	var/count = length(attack.living_hits)
	if(count)
		hit_streak++
		miss_streak = 0
		if(hit_streak % 3 == 0 && combat_comment("hit_streak", 70))
			return
		if(count > 1)
			var/category = "combat_multi"
			if(attack.configuration == "Suppression")
				category = "suppression_multi"
			combat_comment(category, 55)
		else if(attack.configuration == "Lance")
			combat_comment(attack.full_focus ? "lance_full_hit" : "lance_hit", 35)
		else if(attack.configuration == "Suppression")
			combat_comment("suppression_hit", 35)
		else
			combat_comment("combat_hit")
	else if(attack.blocked_hits)
		hit_streak = 0
		miss_streak = 0
		combat_comment("combat_blocked", 30)
	else
		miss_streak++
		hit_streak = 0
		if(miss_streak % 3 == 0 && combat_comment("miss_streak", 70))
			return
		combat_comment("combat_miss")

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/begin_recovery(mob/living/operator, mode_name)
	recovery_operator = WEAKREF(operator)
	recovery_mode = mode_name
	if(mode_name == "Pulse" || thermal_lockout || world.time < next_recovery_comment || !COOLDOWN_FINISHED(src, last_speech) || !prob(30))
		return
	next_recovery_comment = world.time + 6 SECONDS
	speak_up("cooldown_[lowertext(mode_name)]")

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/reset_semicd()
	. = ..()
	var/mob/living/operator = recovery_operator?.resolve()
	var/mode_name = recovery_mode
	recovery_operator = null
	recovery_mode = null
	if(QDELETED(operator) || !operator.is_holding(src) || !personality_mode || !mode_name || mode_name == "Pulse" || mode_name != currently_selected_mode?.name || thermal_lockout || venting || currently_switching_types)
		return
	if(world.time >= next_recovery_comment && prob(30))
		if(COOLDOWN_FINISHED(src, last_speech))
			next_recovery_comment = world.time + 6 SECONDS
			speak_up("cooldown_ready")
		else if(mode_name == "Suppression")
			addtimer(CALLBACK(src, PROC_REF(comment_ready), WEAKREF(operator), mode_name), COOLDOWN_TIMELEFT(src, last_speech) + 0.2 SECONDS)

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/comment_ready(datum/weakref/operator_ref, mode_name)
	var/mob/living/operator = operator_ref?.resolve()
	if(QDELETED(operator) || !operator.is_holding(src) || !personality_mode || mode_name != currently_selected_mode?.name || semicd || sequence_kind || thermal_lockout || venting || currently_switching_types)
		return
	if(world.time >= next_recovery_comment && COOLDOWN_FINISHED(src, last_speech))
		next_recovery_comment = world.time + 6 SECONDS
		speak_up("cooldown_ready")

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/comment_on_busy(mob/living/operator)
	if(!personality_mode || !operator.is_holding(src) || world.time < next_busy_comment || !COOLDOWN_FINISHED(src, last_speech))
		return
	next_busy_comment = world.time + 5 SECONDS
	speak_up(currently_selected_mode?.name == "Pulse" && prob(40) ? "cooldown_pulse" : "cooldown_busy")

/obj/item/gun/energy/modular_laser_rifle/ccpost_chimera/proc/comment_switches()
	if(ismob(loc) && !currently_switching_types && !thermal_lockout)
		speak_up("switch_repeat")

// Cosmetic effects only. Native sprites retain their frames and alpha channel.
// Matrices map source luminance into a new hue; extra brightness keeps saturated
// source sprites readable. No changes to global projectiles or Hyeseong sprites.
/obj/effect/temp_visual/impact_effect/ccpost_chimera_cyan
	parent_type = /obj/effect/temp_visual/impact_effect/blue_laser
	color = CCPOST_CHIMERA_TINT_CYAN

/obj/effect/temp_visual/dir_setting/firing_effect/ccpost_chimera_green
	parent_type = /obj/effect/temp_visual/dir_setting/firing_effect/blue
	color = CCPOST_CHIMERA_TINT_GREEN

/obj/effect/temp_visual/dir_setting/firing_effect/ccpost_chimera_violet
	parent_type = /obj/effect/temp_visual/dir_setting/firing_effect/blue
	color = CCPOST_CHIMERA_TINT_VIOLET

/obj/effect/temp_visual/ccpost_chimera_radial_flash
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield2"
	duration = 2
	color = CCPOST_CHIMERA_TINT_CYAN
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/temp_visual/ccpost_chimera_radial_flash/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix()*1.4, alpha = 0, time = 0.2 SECONDS)

/obj/effect/temp_visual/ccpost_chimera_radial_flash/overload
	color = "#A9F9FF"
	light_system = OVERLAY_LIGHT
	light_outer_range = 2
	light_power = 1.5
	light_color = "#9CF6FF"

/obj/effect/temp_visual/ccpost_chimera_radial_flash/overload/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix()*2, alpha = 0, time = 0.2 SECONDS)

/obj/effect/temp_visual/ccpost_chimera_radial_flash/graviton
	duration = 3
	color = CCPOST_CHIMERA_TINT_GREEN
	light_system = OVERLAY_LIGHT
	light_outer_range = 2
	light_power = 1
	light_color = "#67E68A"

/obj/effect/temp_visual/ccpost_chimera_radial_flash/graviton/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix()*2, alpha = 0, time = 0.3 SECONDS)

/proc/ccpost_cataclysm_clear(turf/tile, atom/ignored = null)
	if(!tile || tile.density)
		return FALSE
	for(var/atom/movable/obstacle in tile)
		if(obstacle == ignored || isliving(obstacle) || istype(obstacle, /obj/projectile))
			continue
		if(obstacle.density)
			return FALSE
	return TRUE

/proc/ccpost_cataclysm_step_clear(turf/start_tile, turf/end_tile, atom/ignored = null)
	if(!start_tile || !end_tile || start_tile.z != end_tile.z || !ccpost_cataclysm_clear(end_tile, ignored))
		return FALSE
	var/direction = get_dir(start_tile, end_tile)
	if((direction & (NORTH|SOUTH)) && (direction & (EAST|WEST)))
		if(!ccpost_cataclysm_clear(get_step(start_tile, direction & (NORTH|SOUTH)), ignored) || !ccpost_cataclysm_clear(get_step(start_tile, direction & (EAST|WEST)), ignored))
			return FALSE
	return TRUE

// ---------------------------------------------------------------------------
// CATACLYSM - full-cell Tesla-inspired plasma discharge (configuration V)
// A finite, per-shot damage budget. Native collision handles the main hit;
// controlled arcs/eruption use armor-aware plasma and native electrical shocks.
// Visual growth is tied to distance travelled, not elapsed time or extra energy.
// No Tesla engine processing or engine contact destruction.
// ---------------------------------------------------------------------------
/obj/projectile/beam/ccpost_chimera/cataclysm
	name = "Cataclysm plasma sphere"
	icon_state = null
	nondirectional_sprite = TRUE
	can_hit_turfs = TRUE
	pass_flags = NONE
	speed = 1
	range = 10
	damage = 0
	light_color = "#D5B5FF"
	light_outer_range = 2
	light_power = 1.5
	impact_effect_type = null
	var/discharge_fraction = 0
	var/energy_budget = 0
	var/initial_budget = 0
	var/tendril_radius = 1
	var/tendril_limit = 0
	var/tendril_count = 0
	var/terminal_radius = 1
	var/satellite_count = 0
	var/orbit_phase = 0
	var/tiles_travelled = 0
	var/growth_tiles = 4
	var/pending_direct_shock = 0
	var/list/shocked_targets = list()
	var/turf/last_arc_tile
	var/turf/last_open_tile
	var/list/arc_targets = list()
	var/list/visual_parts = list()
	var/terminal_done = FALSE

/obj/projectile/beam/ccpost_chimera/cataclysm/proc/configure_discharge(fraction)
	discharge_fraction = clamp(fraction, 0.05, 1)
	initial_budget = round(180 * discharge_fraction, 0.1)
	energy_budget = initial_budget
	damage = min(energy_budget, 90 * discharge_fraction)
	range = round(3 + 7 * discharge_fraction)
	maximum_range = range
	// Residual shots mature earlier; full power takes several tiles to bloom.
	growth_tiles = round(2 + 2 * discharge_fraction)
	tendril_radius = discharge_fraction >= 0.75 ? 3 : (discharge_fraction >= 0.3 ? 2 : 1)
	tendril_limit = FLOOR(discharge_fraction * 6, 1)
	terminal_radius = discharge_fraction >= 0.85 ? 3 : (discharge_fraction >= 0.4 ? 2 : 1)
	satellite_count = FLOOR(discharge_fraction * 3.34, 1)
	last_open_tile = get_turf(src)
	update_plasma_visual()

/obj/projectile/beam/ccpost_chimera/cataclysm/proc/update_plasma_visual()
	for(var/mutable_appearance/part in visual_parts)
		cut_overlay(part)
	visual_parts.Cut()
	var/relative_energy = clamp(energy_budget / max(1, initial_budget), 0, 1)
	var/growth = clamp(tiles_travelled / max(1, growth_tiles), 0, 1)
	// Start compact, then expand to the charge-scaled size as the sphere travels.
	// Energy loss dims/shrinks the mature sphere but cannot reverse its growth stage.
	var/visual_scale = (0.27 + 0.62 * discharge_fraction) * (0.35 + 0.65 * growth) * (0.80 + 0.20 * relative_energy)
	var/mutable_appearance/core = mutable_appearance('icons/obj/machines/engine/energy_ball.dmi', "energy_ball")
	core.pixel_x = -32
	core.pixel_y = -32
	core.transform = matrix() * visual_scale
	// Native Tesla has a white core and lavender arcs. Keep brightness intact.
	visual_parts += core
	add_overlay(core)
	var/developed_satellites = FLOOR(satellite_count * growth + 0.001, 1)
	var/satellites = min(developed_satellites, CEILING(satellite_count * relative_energy, 1))
	if(satellites <= 0)
		return
	for(var/i in 1 to satellites)
		var/orbit_angle = orbit_phase + (i - 1) * 120
		var/mutable_appearance/satellite = mutable_appearance('icons/obj/machines/engine/energy_ball.dmi', "energy_ball")
		satellite.transform = matrix() * 0.24 * (0.7 + 0.3 * relative_energy)
		satellite.pixel_x = -32 + round(cos(orbit_angle) * 23 * visual_scale)
		satellite.pixel_y = -32 + round(sin(orbit_angle) * 23 * visual_scale)
		visual_parts += satellite
		add_overlay(satellite)

/obj/projectile/beam/ccpost_chimera/cataclysm/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(QDELETED(src) || !fired || deletion_queued || terminal_done)
		return
	var/turf/current = get_turf(src)
	if(!current || current == last_arc_tile)
		return
	last_arc_tile = current
	tiles_travelled++
	if(ccpost_cataclysm_clear(current, src))
		last_open_tile = current
	// One bounded scan per tile, never a global Tesla process.
	emit_tendrils(current)
	orbit_phase += 65
	update_plasma_visual()

/obj/projectile/beam/ccpost_chimera/cataclysm/proc/clear_path(turf/start_tile, turf/end_tile)
	if(!start_tile || !end_tile || start_tile.z != end_tile.z)
		return FALSE
	if(start_tile == end_tile)
		return TRUE
	var/turf/previous = start_tile
	for(var/turf/path_tile in get_line(start_tile, end_tile))
		if(path_tile == previous)
			continue
		if(!ccpost_cataclysm_step_clear(previous, path_tile, src))
			return FALSE
		previous = path_tile
	return previous == end_tile

/obj/projectile/beam/ccpost_chimera/cataclysm/proc/emit_tendrils(turf/center)
	if(tendril_count >= tendril_limit || energy_budget <= 0)
		return
	var/list/candidates = list()
	for(var/mob/living/target in range(tendril_radius, center))
		// Do not immediately drain into the operator behind the muzzle. Terminal
		// splash can hit the operator, and all other living players are eligible.
		if(target == firer || target.stat == DEAD || !isturf(target.loc) || arc_targets[REF(target)] || !clear_path(center, get_turf(target)))
			continue
		candidates += target
	// One arc per entered tile, choosing the nearest reachable target.
	var/mob/living/chosen
	var/best_distance = 999
	for(var/mob/living/candidate in candidates)
		var/distance = get_dist(center, candidate)
		if(distance < best_distance)
			chosen = candidate
			best_distance = distance
	if(!chosen)
		return
	// Preserve at least one quarter of initial energy for impact/eruption.
	var/amount = min(max(0, energy_budget - initial_budget * 0.25), 25 * discharge_fraction)
	if(amount <= 0)
		return
	arc_targets[REF(chosen)] = amount
	tendril_count++
	energy_budget -= amount
	damage = min(energy_budget, 90 * discharge_fraction)
	Beam(chosen, icon_state = "lightning[rand(1,12)]", time = 5)
	apply_plasma_damage(chosen, amount, 8 * discharge_fraction)
	playsound(center, 'sound/effects/magic/lightningbolt.ogg', 28, TRUE)

/obj/projectile/beam/ccpost_chimera/cataclysm/proc/shock_target(mob/living/target, amount)
	if(QDELETED(target) || target.stat == DEAD || amount < 1 || shocked_targets[REF(target)])
		return
	// One direct shock application per target per discharge. Native Tesla
	// insulation, shock immunity and contact propagation remain intact.
	shocked_targets[REF(target)] = TRUE
	target.electrocute_act(amount, src, 1, SHOCK_TESLA | SHOCK_NOSTUN)

/obj/projectile/beam/ccpost_chimera/cataclysm/proc/apply_plasma_damage(mob/living/target, amount, shock_ceiling = 0)
	if(QDELETED(target) || amount <= 0 || !isturf(target.loc))
		return
	if(!QDELETED(firer) && isliving(firer))
		log_combat(firer, target, "struck with Cataclysm", src)
	var/blocked = target.run_armor_check(BODY_ZONE_CHEST, LASER)
	// Electrical damage is a portion of the allocated energy, not a bonus
	// on top of it. It uses native insulation rather than laser armor.
	var/shock_amount = shocked_targets[REF(target)] ? 0 : min(shock_ceiling, amount * 0.32)
	if(shock_amount < 1)
		shock_amount = 0
	target.apply_damage(amount - shock_amount, BURN, BODY_ZONE_CHEST, blocked, attacking_item = fired_from)
	if(blocked < 100)
		shock_target(target, shock_amount)
	if(!QDELETED(chimera_attack) && !QDELETED(target))
		if(blocked < 100)
			chimera_attack.living_hits |= REF(target)
		else
			chimera_attack.blocked_hits++

/obj/projectile/beam/ccpost_chimera/cataclysm/prehit_pierce(atom/target)
	// Native direct damage consumes the same finite budget; a target already
	// arced cannot receive more than the full direct-hit ceiling in total.
	pending_direct_shock = 0
	if(isliving(target))
		var/allocated = min(energy_budget, max(0, 90 * discharge_fraction - (arc_targets[REF(target)] || 0)))
		if(!shocked_targets[REF(target)])
			pending_direct_shock = min(12 * discharge_fraction, allocated * 0.25)
			if(pending_direct_shock < 1)
				pending_direct_shock = 0
		damage = allocated - pending_direct_shock
	else
		damage = 0
	return ..()

/obj/projectile/beam/ccpost_chimera/cataclysm/on_hit(atom/target, blocked = 0, pierce_hit)
	var/turf/center = get_turf(target)
	var/shock_amount = pending_direct_shock
	pending_direct_shock = 0
	if(isliving(target))
		energy_budget = max(0, energy_budget - damage - shock_amount)
	. = ..()
	if(!QDELETED(src))
		if(isliving(target) && !QDELETED(target) && blocked < 100 && . != BULLET_ACT_BLOCK)
			shock_target(target, shock_amount)
		detonate_plasma(center, target)
	return .

/obj/projectile/beam/ccpost_chimera/cataclysm/impact(atom/target)
	// Catch blocked impacts as well as normal on_hit; no duplicate eruption.
	var/turf/center = get_turf(target)
	. = ..()
	if(!QDELETED(src) && deletion_queued && !terminal_done)
		detonate_plasma(center, target)
	return .

/obj/projectile/beam/ccpost_chimera/cataclysm/on_range()
	detonate_plasma(get_turf(src))
	return ..()

/obj/projectile/beam/ccpost_chimera/cataclysm/proc/detonate_plasma(turf/center, atom/direct_target)
	if(terminal_done)
		return
	terminal_done = TRUE
	if(!ccpost_cataclysm_clear(center, src))
		center = last_open_tile
	if(!ccpost_cataclysm_clear(center, src))
		return
	new /obj/effect/temp_visual/ccpost_cataclysm_eruption(center, discharge_fraction, energy_budget / max(1, initial_budget))
	playsound(center, 'sound/effects/gravhit.ogg', round(35 + 35 * discharge_fraction), TRUE)
	var/list/targets = list()
	for(var/mob/living/target in range(terminal_radius, center))
		if(target == direct_target || target.stat == DEAD || !isturf(target.loc) || !clear_path(center, get_turf(target)))
			continue
		targets += target
	// Divide remaining energy across all reachable targets. Hard cap per
	// individual, including their earlier tendril damage. No explosion().
	if(length(targets) && energy_budget > 0)
		var/share = energy_budget / length(targets)
		for(var/mob/living/target in targets)
			var/amount = min(share, max(0, 50 * discharge_fraction - (arc_targets[REF(target)] || 0)))
			if(amount > 0)
				energy_budget -= amount
				apply_plasma_damage(target, amount, 8 * discharge_fraction)

/obj/effect/temp_visual/ccpost_cataclysm_eruption
	icon = 'icons/obj/machines/engine/energy_ball.dmi'
	icon_state = "energy_ball"
	pixel_x = -32
	pixel_y = -32
	duration = 0.5 SECONDS
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	light_system = OVERLAY_LIGHT
	light_color = "#E7D0FF"
	light_outer_range = 2
	light_power = 2

/obj/effect/temp_visual/ccpost_cataclysm_eruption/Initialize(mapload, fraction = 1, remaining = 1)
	. = ..()
	var/scale = (0.35 + 1.25 * fraction) * (0.5 + 0.5 * clamp(remaining, 0, 1))
	transform = matrix() * 0.25
	animate(src, transform = matrix() * scale, time = 0.2 SECONDS)
	animate(transform = matrix() * (scale * 1.2), alpha = 0, time = 0.3 SECONDS)

#undef CCPOST_CHIMERA_TINT_GOLD
#undef CCPOST_CHIMERA_TINT_BLUE
#undef CCPOST_CHIMERA_TINT_CYAN
#undef CCPOST_CHIMERA_TINT_GREEN
#undef CCPOST_CHIMERA_TINT_VIOLET
