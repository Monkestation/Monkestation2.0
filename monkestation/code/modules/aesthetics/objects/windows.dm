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
    smoothing_flags = SMOOTH_BITMASK
    smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
    canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
    smooth_adapters = SMOOTH_ADAPTERS_WALLS

/obj/structure/window/reinforced/plasma/fulltile
    icon = 'icons/obj/smooth_structures/rplasma_window.dmi'
    icon_state = "rplasma_window-0"
    base_icon_state = "rplasma_window"
    smoothing_flags = SMOOTH_BITMASK
    smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
    canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
    smooth_adapters = SMOOTH_ADAPTERS_WALLS

/obj/structure/window/reinforced/fulltile
    icon = 'icons/obj/smooth_structures/reinforced_window.dmi'
    icon_state = "reinforced_window-0"
    base_icon_state = "reinforced_window"
    smoothing_flags = SMOOTH_BITMASK
    smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
    canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
    smooth_adapters = SMOOTH_ADAPTERS_WALLS

/obj/structure/window/plasma/fulltile
    icon = 'icons/obj/smooth_structures/plasma_window.dmi'
    icon_state = "plasma_window-0"
    base_icon_state = "plasma_window"
    smoothing_flags = SMOOTH_BITMASK
    smoothing_groups = SMOOTH_GROUP_WINDOW_FULLTILE
    canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE
    smooth_adapters = SMOOTH_ADAPTERS_WALLS

/obj/structure/grille
    icon = 'icons/obj/structures.dmi'
    icon_state = "grille"
    base_icon_state = "grille"
    layer = ABOVE_OBJ_LAYER - 0.01
    smoothing_flags = SMOOTH_BITMASK
    smoothing_groups = SMOOTH_GROUP_GRILLE
    canSmoothWith = SMOOTH_GROUP_WINDOW_FULLTILE

/obj/structure/grille/update_overlays(updates=ALL)
    . = ..()
    if((updates & UPDATE_SMOOTHING) && (smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)))
        QUEUE_SMOOTH(src)
