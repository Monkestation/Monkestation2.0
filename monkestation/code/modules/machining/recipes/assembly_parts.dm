/datum/machining_recipe/wylom_amr
    name = "Wylom AMR"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/gun/ballistic/automatic/wylom
    reqs = list(
        /obj/item/machining_intermediates/stock_polymer = 1,
        /obj/item/machining_intermediates/gunbarrel_rifle = 1,
        /obj/item/machining_intermediates/firearm_bolt = 2,
        /obj/item/machining_intermediates/handle_polymer = 1,
        /obj/item/stack/machining_intermediates/hardsteel = 4,
        /obj/item/stack/machining_intermediates/screwbolt = 8,
        /obj/item/machining_intermediates/moltenplastic = 2,
    )
    machining_skill_required = 5

/datum/machining_recipe/wylom_magazine
    name = "Wylom Magazine"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_NORMAL
    result = /obj/item/ammo_box/magazine/wylom
    reqs = list(
        /obj/item/machining_intermediates/moltenplastic = 4,
        /obj/item/stack/rods = 2,
        /obj/item/stack/machining_intermediates/screwbolt = 4,
    )
    machining_skill_required = 5

/datum/machining_recipe/revolver_38
    name = ".38 Revolver"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/gun/ballistic/revolver/c38
    reqs = list(
        /obj/item/machining_intermediates/firearm_hammer = 1,
        /obj/item/machining_intermediates/gunbarrel_pistol = 1,
        /obj/item/machining_intermediates/handle_wood = 1,
        /obj/item/stack/machining_intermediates/steel = 4,
        /obj/item/machining_intermediates/trigger = 1,
        /obj/item/stack/machining_intermediates/screwbolt = 4,
		/obj/item/machining_intermediates/bullet_small = 6,
    )
    machining_skill_required = 3

/datum/machining_recipe/paco_pistol
    name = "Paco Pistol"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/gun/ballistic/automatic/pistol/paco/no_mag
    reqs = list(
        /obj/item/machining_intermediates/firearm_bolt = 1,
        /obj/item/machining_intermediates/gunbarrel_pistol = 1,
        /obj/item/machining_intermediates/handle_polymer = 1,
        /obj/item/stack/machining_intermediates/steel = 4,
        /obj/item/machining_intermediates/trigger = 1,
        /obj/item/stack/machining_intermediates/screwbolt = 8,
    )
    machining_skill_required = 3

/datum/machining_recipe/paco_magazine
    name = "Paco Magazine"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_NORMAL
    result = /obj/item/ammo_box/magazine/m35
    reqs = list(
        /obj/item/machining_intermediates/moltenplastic = 2,
        /obj/item/stack/rods = 2,
        /obj/item/stack/machining_intermediates/screwbolt = 4,
		/obj/item/machining_intermediates/bullet_small = 12,
    )
    machining_skill_required = 3

/datum/machining_recipe/disabler_pistol
    name = "Disabler Pistol"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/gun/energy/disabler
    reqs = list(
        /obj/item/machining_intermediates/lasercavity = 1,
        /obj/item/machining_intermediates/handle_polymer = 1,
        /obj/item/stack/sheet/iron = 4,
        /obj/item/machining_intermediates/universalcircuit = 1,
        /obj/item/stock_parts/cell = 1,
        /obj/item/stack/machining_intermediates/smallwire = 4,
        /obj/item/stack/machining_intermediates/screwbolt = 6,
        /obj/item/machining_intermediates/moltenplastic = 2,
    )
    machining_skill_required = 3

/datum/machining_recipe/laser_gun
    name = "Laser Gun"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/gun/energy/laser
    reqs = list(
        /obj/item/machining_intermediates/lasercavity = 2,
        /obj/item/machining_intermediates/lens = 1,
        /obj/item/machining_intermediates/handle_polymer = 1,
        /obj/item/machining_intermediates/stock_polymer = 1,
        /obj/item/stack/sheet/iron = 4,
        /obj/item/machining_intermediates/universalcircuit = 2,
        /obj/item/stock_parts/cell = 1,
        /obj/item/stack/machining_intermediates/smallwire = 4,
        /obj/item/stack/machining_intermediates/screwbolt = 10,
        /obj/item/machining_intermediates/moltenplastic = 2,
    )
    machining_skill_required = 4

/datum/machining_recipe/energy_gun
    name = "Energy Gun"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/gun/energy
    reqs = list(
        /obj/item/machining_intermediates/lasercavity = 2,
        /obj/item/machining_intermediates/lens = 2,
        /obj/item/machining_intermediates/handle_polymer = 1,
        /obj/item/machining_intermediates/stock_polymer = 1,
        /obj/item/stack/sheet/iron = 4,
        /obj/item/machining_intermediates/universalcircuit = 3,
        /obj/item/stock_parts/cell = 1,
        /obj/item/stack/machining_intermediates/smallwire = 8,
        /obj/item/stack/machining_intermediates/screwbolt = 10,
        /obj/item/machining_intermediates/moltenplastic = 2,
    )
    machining_skill_required = 4

/datum/machining_recipe/makeshift_pulse_gun
    name = "Makeshift Pulse Gun"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_EXCRUCIATINGLY_SLOW
    result = /obj/item/pulsepack
    reqs = list(
        /obj/item/machining_intermediates/lasercavity = 8,
        /obj/item/machining_intermediates/lens = 6,
        /obj/item/machining_intermediates/handle_polymer = 1,
        /obj/item/machining_intermediates/stock_polymer = 1,
        /obj/item/machining_intermediates/universalcircuit = 4,
        /obj/item/stack/machining_intermediates/hardsteel = 4,
        /obj/item/machining_intermediates/moltenplastic = 6,
    )
    machining_skill_required = 5

//etc
/datum/machining_recipe/knockoff_jewelry
    name = "Knockoff Jewelry"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_NORMAL
    result = /obj/item/machining_intermediates/crappyring
    reqs = list(
        /obj/item/stack/sheet/iron = 1,
        /obj/item/stack/sheet/glass = 2,
    )
    machining_skill_required = 2

/datum/machining_recipe/quality_jewelry
    name = "Quality Jewelry"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_NORMAL
    result = /obj/item/machining_intermediates/fancyring
    reqs = list(
        /obj/item/stack/sheet/mineral/gold  = 1,
		/obj/item/stack/sheet/iron = 1,
    )
    machining_skill_required = 3

/datum/machining_recipe/artisan_jewelry
    name = "Artisan Jewelry"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_NORMAL
    result = /obj/item/machining_intermediates/fancyring
    reqs = list(
        /obj/item/machining_intermediates/fancyring = 1,
		/obj/item/stack/sheet/mineral/gold  = 2,
        /obj/item/stack/sheet/mineral/diamond = 1,
    )
    machining_skill_required = 4

/datum/machining_recipe/gas_pump
    name = "Gas Pump"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/machinery/portable_atmospherics/pump
    reqs = list(
        /obj/item/machining_intermediates/smallmotor = 6,
        /obj/item/stack/sheet/iron = 10,
        /obj/item/machining_intermediates/moltenplastic = 2,
        /obj/item/stack/machining_intermediates/screwbolt = 8,
    )
    machining_skill_required = 2

/datum/machining_recipe/portable_scrubber
    name = "Portable Scrubber"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/machinery/portable_atmospherics/scrubber
    reqs = list(
        /obj/item/machining_intermediates/smallmotor = 8,
        /obj/item/stack/sheet/iron = 10,
        /obj/item/machining_intermediates/moltenplastic = 2,
        /obj/item/stack/machining_intermediates/screwbolt = 6,
    )
    machining_skill_required = 2

/datum/machining_recipe/jaws_of_life
    name = "Jaws of Life"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/crowbar/power
    reqs = list(
        /obj/item/machining_intermediates/smallmotor = 4,
        /obj/item/stack/machining_intermediates/steel = 2,
        /obj/item/stack/sheet/iron = 4,
        /obj/item/stack/machining_intermediates/screwbolt = 4,
        /obj/item/machining_intermediates/universalcircuit = 1,
        /obj/item/stack/machining_intermediates/smallwire = 4,
        /obj/item/machining_intermediates/handle_polymer = 2,
    )
    machining_skill_required = 3

/datum/machining_recipe/hand_drill
    name = "Hand Drill"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_NORMAL
    result = /obj/item/screwdriver/power
    reqs = list(
        /obj/item/machining_intermediates/smallmotor = 2,
        /obj/item/stack/machining_intermediates/steel = 1,
        /obj/item/stack/sheet/iron = 2,
        /obj/item/stack/machining_intermediates/screwbolt = 4,
        /obj/item/machining_intermediates/universalcircuit = 1,
        /obj/item/stack/machining_intermediates/smallwire = 4,
        /obj/item/machining_intermediates/handle_polymer = 1,
    )
    machining_skill_required = 3

/datum/machining_recipe/fire_axe
    name = "Fire Axe"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/fireaxe
    reqs = list(
        /obj/item/machining_intermediates/axehead = 1,
        /obj/item/machining_intermediates/handle_wood = 2,
        /obj/item/stack/machining_intermediates/screwbolt = 4,
        /obj/item/machining_intermediates/dye = 1,
    )
    machining_skill_required = 4

/datum/machining_recipe/sledgehammer
    name = "Sledgehammer"
    category = TAB_ASSEMBLY_PARTS
    machinery_type = MACHINING_WORKSTATION
    crafting_time = MACHINING_DELAY_SLOW
    result = /obj/item/melee/sledgehammer
    reqs = list(
        /obj/item/stack/machining_intermediates/steel = 4,
        /obj/item/machining_intermediates/handle_wood = 2,
        /obj/item/stack/machining_intermediates/screwbolt = 4,
    )
    machining_skill_required = 2
