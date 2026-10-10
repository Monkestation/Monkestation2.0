///This slime is a baby
#define SLIME_LIFE_STAGE_BABY "baby"
///This slime is an adult
#define SLIME_LIFE_STAGE_ADULT "adult"

///This lowest charge a slime can have
#define SLIME_MIN_POWER 0
///Dangerous levels of charge
#define SLIME_MEDIUM_POWER 5
///The highest level of charge a slime can have
#define SLIME_MAX_POWER 10

///The maximum amount of nutrition a slime can contain
#define SLIME_MAX_NUTRITION 200
///The starting nutrition of a slime
#define SLIME_STARTING_NUTRITION 100
/// Above it we grow our amount_grown and our power_level, below it we can eat
#define SLIME_GROW_NUTRITION 150
/// Below this, we feel hungry
#define SLIME_HUNGER_NUTRITION 50
/// Below this, we feel starving
#define SLIME_STARVE_NUTRITION 10
///How much nutrition growing up from a baby costs
#define SLIME_EVOLUTION_COST 100
///How many other slimes on our tile stop us from splitting
#define SLIME_OVERCROWD_AMOUNT 2
///How many transformative extracts one slime can hold
#define SLIME_MAX_TRANSFORMATIONS 3

///The slime is not hungry. It might try to feed anyways.
#define SLIME_HUNGER_NONE 0
///The slime is more likely to feed on people
#define SLIME_HUNGER_HUNGRY 1
///The slime is very likely to feed on anything
#define SLIME_HUNGER_STARVING 2

#define SLIME_MOOD_NONE "none"
#define SLIME_MOOD_ANGRY "angry"
#define SLIME_MOOD_MISCHIEVOUS "mischievous"
#define SLIME_MOOD_POUT "pout"
#define SLIME_MOOD_SAD "sad"
#define SLIME_MOOD_SMILE ":3"
/// The cat face. Core only defines the faces its own AI used, and this one's cuter.
#define SLIME_MOOD_CAT ":33"

// These are used for slime icon states, so if you touch these names,
// remember to update icons/obj/xenobiology/slime_rancher/slimes.dmi!
#define SLIME_TYPE_ADAMANTINE "adamantine"
#define SLIME_TYPE_BLACK "black"
#define SLIME_TYPE_BLUE "blue"
#define SLIME_TYPE_BLUESPACE "bluespace"
#define SLIME_TYPE_CERULEAN "cerulean"
#define SLIME_TYPE_DARK_BLUE "dark-blue"
#define SLIME_TYPE_DARK_PURPLE "dark-purple"
#define SLIME_TYPE_GOLD "gold"
#define SLIME_TYPE_GREEN "green"
#define SLIME_TYPE_GREY "grey"
#define SLIME_TYPE_LIGHT_PINK "light-pink"
#define SLIME_TYPE_METAL "metal"
#define SLIME_TYPE_OIL "oil"
#define SLIME_TYPE_ORANGE "orange"
#define SLIME_TYPE_PINK "pink"
#define SLIME_TYPE_PURPLE "purple"
#define SLIME_TYPE_PYRITE "pyrite"
#define SLIME_TYPE_RAINBOW "rainbow"
#define SLIME_TYPE_RED "red"
#define SLIME_TYPE_SEPIA "sepia"
#define SLIME_TYPE_SILVER "silver"
#define SLIME_TYPE_YELLOW "yellow"

/// Not a real slime type, used to create random slimes
#define SLIME_TYPE_RANDOM "random"

/// The alpha value of transparent slime types
#define SLIME_TRANSPARENCY_ALPHA 180

#define COLOR_SLIME_ADAMANTINE "#135f49"
#define COLOR_SLIME_BLACK "#3b3b3b"
#define COLOR_SLIME_BLUE "#19ffff"
#define COLOR_SLIME_BLUESPACE "#ebebeb"
#define COLOR_SLIME_CERULEAN "#5783aa"
#define COLOR_SLIME_DARK_BLUE "#2e9dff"
#define COLOR_SLIME_DARK_PURPLE "#9948f7"
#define COLOR_SLIME_GOLD "#c38b07"
#define COLOR_SLIME_GREEN "#07f024"
#define COLOR_SLIME_GREY "#c2c2c2"
#define COLOR_SLIME_LIGHT_PINK "#ffe1fa"
#define COLOR_SLIME_METAL "#676767"
#define COLOR_SLIME_OIL "#242424"
#define COLOR_SLIME_ORANGE "#ffb445"
#define COLOR_SLIME_PINK "#fe5bbd"
#define COLOR_SLIME_PURPLE "#d138ff"
#define COLOR_SLIME_PYRITE "#ffc427"
#define COLOR_SLIME_RAINBOW COLOR_SLIME_GREY // only for consistency
#define COLOR_SLIME_RED "#fb4848"
#define COLOR_SLIME_SEPIA "#9b8a7a"
#define COLOR_SLIME_SILVER "#dadada"
#define COLOR_SLIME_YELLOW "#fff419"

/// Vacuum can suck up rabid slimes, and calms them when it does.
#define VACUUM_CAN_PACIFY (1<<0)
/// Vacuum can print things using a biomass recycler.
#define VACUUM_CAN_PRINT (1<<1)

/// How far the vacuum can fling things, in tiles.
#define VACUUM_LAUNCH_RANGE 5
/// Throw speed of things the vacuum flings.
#define VACUUM_LAUNCH_SPEED 2

// these control how long slimes jiggle when splitting or mutating
#define SLIME_SPLIT_WINDUP (5 SECONDS)
#define SLIME_MUTATE_WINDUP (8 SECONDS)

/// Health an adult slime has to drain to secrete one extract (or roll a mutation)
#define SLIME_RANCH_EXTRACT_COST 50
/// Health a slime told to split by a friend has to drain first
#define SLIME_RANCH_COMMAND_SPLIT_COST 50
/// Health a slime that ate a breeding pellet has to drain first
#define SLIME_RANCH_PELLET_SPLIT_COST 100
/// How long a refused or interrupted split/mutation waits before trying again
#define SLIME_RANCH_RETRY_COOLDOWN (5 SECONDS)
/// How long a slime ignores a target it couldn't path to
#define SLIME_CHASE_GIVE_UP_TIME (5 SECONDS)
/// How long a slime holds a grudge after the last hit
#define SLIME_GRUDGE_DURATION (1 MINUTES)
/// How many damaging hits a cat slime shrugs off before it holds a grudge
#define SLIME_CAT_PATIENCE_HITS 3
/// Hits further apart than this don't add up against a cat slime's patience
#define SLIME_CAT_PATIENCE_WINDOW (10 SECONDS)

/// The fence sprite's own blue. A pen set to this color skips the recolor filter entirely, so the default look is the sprite as drawn.
#define SLIME_PEN_DEFAULT_COLOR "#4dc8e8"
/// How far away other slimes notice a monkey attacking a slime and join in.
#define SLIME_MONKEY_RALLY_RANGE 5

/// How many tiles away can an extract compressor link to a extract fridge or biomass recycler thingy
#define COMPRESSOR_LINK_RANGE 7
