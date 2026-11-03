///The standard amount of bodyparts a carbon has. Currently 6, HEAD/L_ARM/R_ARM/CHEST/L_LEG/R_LEG
#define BODYPARTS_DEFAULT_MAXIMUM 6

// Color priorities for bodyparts
#define LIMB_COLOR_HULK 10
/// Fish infusion color priority
#define LIMB_COLOR_FISH_INFUSION 15
#define LIMB_COLOR_CARP_INFUSION 20
/// Base priority for atom colors, gets atom priorities added to it
#define LIMB_COLOR_ATOM_COLOR 30

// Overlay priorities
#define BODYPART_OVERLAY_FISH_INFUSION 1
#define BODYPART_OVERLAY_CARP_INFUSION 2
#define BODYPART_OVERLAY_MESH 3

// Flag associatd with specific overlays on bodyparts
// Used to determine how the overlay is handled in rendering
/// Apply bodypart textures to this
#define LIMB_OVERLAY_TEXTURED (1<<0)
/// Contains meta-info used for rendering (i.e. emissives)
#define LIMB_OVERLAY_META (1<<1)
/// Overlay is chonky, at least 48 pixels wide
#define LIMB_OVERLAY_WIDE_ICON (1<<2)
/// Overlay is toll, at least 48 pixels tall
#define LIMB_OVERLAY_TALL_ICON (1<<3)
/// Core part of the bodypart, like the actual bodypart icon
#define LIMB_OVERLAY_CORE (1<<4)
