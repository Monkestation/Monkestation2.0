/datum/robot_model
	/// The display name that appears when examining cyborgs.
	var/name = "Default"
	/// The icon state that [/atom/movable/screen/robot/module] will use.
	var/hud_icon_state = "nomod"
	/// The default skin to use.
	var/datum/robot_skin/default_skin = /datum/robot_skin/standard/default
	/// The list of all skins. Optional.
	var/list/datum/robot_skin/available_skins
	/// The cyborg that is using this robot model.
	var/mob/living/silicon/robot/cyborg_owner = null
	/// The list of modules that can be used by the owner.
	var/list/obj/item/usable_modules = list()
	/// The list of modules that are given.
	var/list/obj/item/basic_modules = list()
	/// The list of modules that are given only if the cyborg is emagged.
	var/list/obj/item/emagged_modules = list()
	/// The list of modules that are given only if the cyborg is part of the clockwork cult.
	var/list/obj/item/clockwork_modules = list()
	/// The list of modules that are given only if the cyborg is upgraded through external means.
	var/list/obj/item/external_modules = list()
	/// The list of energy storages to keep track of.
	var/list/datum/robot_energy_storage/energy_storages = list()
	/// The radio channels that are given.
	var/list/radio_channels = list()
	/// The traits that are given
	var/list/traits = list()
	/// The weakref to the ability that toggles their sight vision, if any.
	var/datum/weakref/sight_vision_ref

/datum/robot_model/New()
	LAZYOR(available_skins, default_skin)

/datum/robot_model/Destroy()
	QDEL_NULL(sight_vision_ref)
	return ..()

/// Gets all modules that should be accessible to the owner.
/datum/robot_model/proc/get_usable_modules()
	return usable_modules.Copy()

/// Rebuilds the usable module list.
/datum/robot_model/proc/rebuild_usable_modules()
	if(!cyborg_owner)
		return
	usable_modules.Cut()
	for(var/obj/item/possible_module as anything in basic_modules)
		if(ispath(possible_module))
			continue
		add_module(possible_module)
	if(cyborg_owner.emagged)
		for(var/obj/item/possible_module as anything in emagged_modules)
			if(ispath(possible_module))
				continue
			add_module(possible_module)
	if(cyborg_owner.clockwork)
		for(var/obj/item/possible_module as anything in clockwork_modules)
			if(ispath(possible_module))
				continue
			add_module(possible_module)
	for(var/obj/item/possible_module as anything in external_modules)
		if(ispath(possible_module))
			continue
		add_module(possible_module)

/// Initializes any typepaths for many module lists. This does not include the usable module list.
/datum/robot_model/proc/initialize_all_modules()
	if(!cyborg_owner)
		return
	for(var/obj/item/possible_module as anything in basic_modules)
		if(!ispath(possible_module))
			continue
		var/obj/item/itemized_module = new possible_module(cyborg_owner) // Some items want to be created on the cyborg first.
		itemized_module.moveToNullspace()
		basic_modules += itemized_module
		basic_modules -= possible_module
	for(var/obj/item/possible_module as anything in emagged_modules)
		if(!ispath(possible_module))
			continue
		var/obj/item/itemized_module = new possible_module(cyborg_owner)
		itemized_module.moveToNullspace()
		emagged_modules += itemized_module
		emagged_modules -= possible_module
	for(var/obj/item/possible_module as anything in clockwork_modules)
		if(!ispath(possible_module))
			continue
		var/obj/item/itemized_module = new possible_module(cyborg_owner)
		itemized_module.moveToNullspace()
		clockwork_modules += itemized_module
		clockwork_modules -= possible_module
	for(var/obj/item/possible_module as anything in external_modules)
		if(!ispath(possible_module))
			continue
		var/obj/item/itemized_module = new possible_module(cyborg_owner)
		itemized_module.moveToNullspace()
		external_modules += itemized_module
		external_modules -= possible_module

/// Adds an module.
/datum/robot_model/proc/add_module(obj/item/module_to_add, externally_added, requires_rebuild)
	if(isstack(module_to_add))
		var/obj/item/stack/sheet_module = module_to_add
		if(ispath(sheet_module.source, /datum/robot_energy_storage))
			sheet_module.source = get_or_create_estorage(sheet_module.source)
		if(istype(sheet_module.source))
			sheet_module.cost = max(sheet_module.cost, 1) // Must not cost 0 to prevent div/0 errors.
			sheet_module.is_cyborg = TRUE
	module_to_add.moveToNullspace()
	module_to_add.mouse_opacity = MOUSE_OPACITY_OPAQUE
	module_to_add.obj_flags |= ABSTRACT
	usable_modules += module_to_add
	if(externally_added)
		external_modules += module_to_add
	if(requires_rebuild)
		rebuild_usable_modules()
	return module_to_add

/// Removes a module.
/datum/robot_model/proc/remove_module(obj/item/removed_module)
	basic_modules -= removed_module
	emagged_modules -= removed_module
	clockwork_modules -= removed_module
	external_modules -= removed_module
	qdel(removed_module)
	rebuild_usable_modules()


/// Gets an energy storage with a specific type. If it cannot, creates it.
/datum/robot_model/proc/get_or_create_estorage(estorage_type)
	return (locate(estorage_type) in energy_storages) || new estorage_type(src)

/// Recharges renewable energy storages and various modules.
/datum/robot_model/proc/on_cyborg_charge(coeff = 1)
	SHOULD_CALL_PARENT(TRUE)
	if(!cyborg_owner)
		return FALSE
	for(var/datum/robot_energy_storage/energy_storage as anything in energy_storages)
		if(energy_storage.renewable == FALSE)
			continue
		energy_storage.energy = min(energy_storage.max_energy, energy_storage.energy + (coeff * energy_storage.recharge_rate))
	for(var/obj/item/usable_module in get_usable_modules())
		if(istype(usable_module, /obj/item/assembly/flash))
			var/obj/item/assembly/flash/flash = usable_module
			flash.times_used = 0
			flash.burnt_out = FALSE
			flash.update_appearance()
			continue
		if(istype(usable_module, /obj/item/reagent_containers/condiment/enzyme))
			var/obj/item/reagent_containers/condiment/enzyme/enzyme_container = usable_module
			enzyme_container.reagents.add_reagent(/datum/reagent/consumable/enzyme, 2 * coeff)
			continue
		if(istype(usable_module, /obj/item/soap/nanotrasen/cyborg))
			var/obj/item/soap/nanotrasen/cyborg/cyborg_soap = usable_module
			if(cyborg_soap.uses < initial(cyborg_soap.uses))
				cyborg_soap.uses = min(initial(cyborg_soap.uses), cyborg_soap.uses + (ROUND_UP(initial(cyborg_soap.uses) / 100) * coeff))
			continue
		if(istype(usable_module, /obj/item/hand_labeler/cyborg))
			var/obj/item/hand_labeler/cyborg/labeler = usable_module
			labeler.labels_left = 30
			continue
		if(istype(usable_module, /obj/item/lightreplacer))
			var/obj/item/lightreplacer/light_replacer = usable_module
			light_replacer.Charge(cyborg_owner, max(1, coeff))
			continue
		if(istype(usable_module, /obj/item/melee/baton/security))
			var/obj/item/melee/baton/security/security_baton = usable_module
			security_baton.cell?.charge = security_baton.cell.maxcharge
			continue
		if(istype(usable_module, /obj/item/gun/energy))
			var/obj/item/gun/energy/energy_gun = usable_module
			if(!energy_gun.chambered)
				energy_gun.recharge_newshot() // Try to reload a new shot.
			continue
	cyborg_owner.toner = cyborg_owner.tonermax
	return TRUE

/// Restocks non-renewable energy storages that the owner may have.
/datum/robot_model/proc/on_cyborg_restock()
	if(!cyborg_owner)
		return
	var/obj/machinery/recharge_station/charger = cyborg_owner.loc
	if(!istype(charger))
		return
	var/datum/component/material_container/mat_container = charger.materials.mat_container
	if(!mat_container || charger.materials.on_hold())
		charger.sendmats = FALSE
		return
	for(var/datum/robot_energy_storage/energy_storage as anything in energy_storages)
		if(energy_storage.renewable == TRUE) // Skipping renewables. Already handled in [/datum/robot_model/proc/on_cyborg_charge].
			continue
		if(energy_storage.max_energy == energy_storage.energy) // Skipping full.
			continue
		var/to_stock = min(energy_storage.max_energy / 8, energy_storage.max_energy - energy_storage.energy, mat_container.get_material_amount(energy_storage.mat_type))
		if(!to_stock) // Silo doesn't have what we want.
			continue
		energy_storage.energy += charger.materials.use_materials(list(GET_MATERIAL_REF(energy_storage.mat_type) = to_stock), action = "resupplied", name = "units")
		charger.balloon_alert(cyborg_owner, "+ [to_stock]u [initial(energy_storage.mat_type.name)]")
		playsound(charger, 'sound/weapons/gun/general/mag_bullet_insert.ogg', 50, vary = FALSE)
		return
	charger.balloon_alert(cyborg_owner, "restock process complete")
	charger.sendmats = FALSE


///Whether the borg loses tool slots with damage.
//var/breakable_modules = TRUE
///Whether swapping to this configuration should lockcharge the borg
//var/locked_transform = TRUE
