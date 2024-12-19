// This file contains experimental flags that may not be production ready yet,
// but that we want to be able to easily flip as well as run on CI.
// Any flag you see here can be flipped with the `-D` CLI argument.
// For example, if you want to enable EXPERIMENT_MY_COOL_FEATURE, compile with -DEXPERIMENT_MY_COOL_FEATURE


/*
#if DM_VERSION < 515

	// You can't X-macro custom names :(
	#ifdef EXPERIMENT_MY_COOL_FEATURE
		#warn EXPERIMENT_MY_COOL_FEATURE is only available on 515+
		#undef EXPERIMENT_MY_COOL_FEATURE
	#endif
#elif defined(UNIT_TESTS)
	#define EXPERIMENT_MY_COOL_FEATURE
#endif

#if DM_VERSION >= 516
	#warn "Remove all 515 experiments"
#endif
*/
