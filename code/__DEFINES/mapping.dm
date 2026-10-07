// Defines for SSmapping's multiz_levels
/// TRUE if we're ok with going up
#define Z_LEVEL_UP 1
/// TRUE if we're ok with going down
#define Z_LEVEL_DOWN 2
#define LARGEST_Z_LEVEL_INDEX Z_LEVEL_DOWN

/// Uses the left operator when compiling, uses the right operator when not compiling.
// Currently uses the CBT macro, but if http://www.byond.com/forum/post/2831057 is ever added,
// or if map tools ever agree on a standard, this should switch to use that.
#ifdef CBT
#define MAP_SWITCH(compile_time, map_time) ##compile_time
#else
#define MAP_SWITCH(compile_time, map_time) ##map_time
#endif

/// Set the icon state for preview map_icons, used so we can unit test the given icon_state
#if defined(UNIT_TESTS)
#define SETUP_MAP_ICONS(compile_icon_state, map_icon_state) \
	icon_state = ##compile_icon_state; \
	icon_state_map = ##map_icon_state;
#else
#define SETUP_MAP_ICONS(compile_icon_state, map_icon_state) icon_state = MAP_SWITCH(##compile_icon_state, ##map_icon_state)
#endif
