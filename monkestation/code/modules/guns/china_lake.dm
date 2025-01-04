/obj/item/gun/ballistic/shotgun/china_lake
	name = "\improper China Lake 40mm"
	desc = "Oh, they're goin' ta have to glue you back together...IN HELL!"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/china_lake

	icon = 'monkestation/icons/misc/china_lake/china_lake_obj.dmi'
	icon_state = "china_lake"

	lefthand_file = 'monkestation/icons/misc/china_lake/china_lake_lefthand.dmi'
	righthand_file = 'monkestation/icons/misc/china_lake/china_lake_righthand.dmi'
	inhand_icon_state = "china_lake"
	inhand_x_dimension = 32
	inhand_y_dimension = 32

	fire_sound = 'monkestation/sound/misc/china_lake_sfx/china_lake_fire.ogg'
	fire_sound_volume = 90
	rack_sound = 'monkestation/sound/misc/china_lake_sfx/china_lake_rack.ogg'
	rack_delay = 1.5 SECONDS

/obj/item/gun/ballistic/shotgun/china_lake/Initialize()
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE, force_unwielded = 10, force_wielded = 10, unwieldsound = 'monkestation/sound/misc/china_lake_sfx/china_lake_drop.ogg')

/obj/item/gun/ballistic/shotgun/china_lake/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HANDS)
		playsound(src, 'monkestation/sound/misc/china_lake_sfx/china_lake_pickup.ogg', 50, TRUE)

/obj/item/ammo_box/magazine/internal/china_lake
	name = "china lake internal magazine"
	ammo_type = /obj/item/ammo_casing/a40mm
	caliber = CALIBER_40MM
	max_ammo = 3
	multiload = FALSE

/obj/item/ammo_casing/a40mm/weak
	name = "light 40mm HE shell"
	desc = "A cased high explosive grenade that can only be activated once fired out of a grenade launcher. This one seems rather light."
	projectile_type = /obj/projectile/bullet/a40mm/weak
	color = "#d3bd8c"

/obj/projectile/bullet/a40mm/weak
	name ="light 40mm grenade"
	desc = "use a weel gun"
	damage = 30

/obj/projectile/bullet/a40mm/weak/explosive_power(atom/target)
	explosion(target, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 3, flame_range = 0, flash_range = 1, adminlog = FALSE, explosion_cause = src)
