/obj/structure/window
    var/glass_color
    var/glass_color_blend_to_color
    var/glass_color_blend_to_ratio

/obj/structure/window/proc/change_color(new_color)
    // Do nothing to prevent color changes

/obj/structure/window/fulltile
    icon = 'icons/obj/smooth_structures/window.dmi'
    icon_state = "window-0"
    base_icon_state = "window"
    canSmoothWith = MOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS
    smooth_adapters = SMOOTH_ADAPTERS_WALLS

/obj/structure/window/reinforced/plasma/fulltile
    icon = 'icons/obj/smooth_structures/rplasma_window.dmi'
    canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS
    icon_state = "rplasma_window-0"
    base_icon_state = "rplasma_window"
    smooth_adapters = SMOOTH_ADAPTERS_WALLS

/obj/structure/window/reinforced/fulltile
    icon = 'icons/obj/smooth_structures/reinforced_window.dmi'
    canSmoothWith = SMOOTH_GROUP_WALLS
    icon_state = "reinforced_window-0"
    base_icon_state = "reinforced_window"
    smooth_adapters = SMOOTH_ADAPTERS_WALLS

/obj/structure/window/plasma/fulltile
    icon = 'icons/obj/smooth_structures/plasma_window.dmi'
    canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE + SMOOTH_GROUP_WALLS
    icon_state = "plasma_window-0"
    base_icon_state = "plasma_window"
    smooth_adapters = SMOOTH_ADAPTERS_WALLS

/obj/structure/grille
    icon = 'icons/obj/structures.dmi'
    icon_state = "grille"
    base_icon_state = "grille"
    layer = ABOVE_OBJ_LAYER - 0.01
    canSmoothWith = SMOOTH_GROUP_GRILLE + SMOOTH_GROUP_WALLS
    smoothing_flags = SMOOTH_BITMASK
    smoothing_groups = SMOOTH_GROUP_GRILLE

/obj/structure/grille/update_overlays(updates=ALL)
    . = ..()
    if((updates & UPDATE_SMOOTHING) && (smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)))
        QUEUE_SMOOTH(src)
