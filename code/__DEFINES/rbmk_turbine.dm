#ifndef RBMK_TURBINE_DEFINES
#define RBMK_TURBINE_DEFINES

/// Minimum useful inlet temperature before the turbine bothers extracting energy.
#define RBMK_TURBINE_MIN_TEMP T20C

/// Turbine will not try to cool gas below this target.
#define RBMK_TURBINE_EXHAUST_TARGET_TEMP T20C

/// Fraction of available heat above target exhaust temp extracted per atmos tick.
#define RBMK_TURBINE_EXTRACTION_RATIO 0.18

/// Fraction of extracted heat converted into usable generated energy.
#define RBMK_TURBINE_EFFICIENCY 0.32

/// Stored generation payout smoothing divisor.
/// Higher = smoother/slower payout.
#define RBMK_TURBINE_POWER_PAYOUT_DIVISOR 10

/// Intake pressure multiplier used when moving gas through the turbine.
#define RBMK_TURBINE_INTAKE_RATIO 0.5

/// Cosmetic RPM scaling.
/// This does not create power; it only turns output into a readable turbine speed.
#define RBMK_TURBINE_POWER_PER_RPM 250

/// Maximum displayed RPM for V1.
#define RBMK_TURBINE_MAX_RPM 3600

/// How quickly RPM changes toward target RPM.
#define RBMK_TURBINE_RPM_STEP 120

/// Basic V1 safety limits.
#define RBMK_TURBINE_SAFE_TEMP 2500
#define RBMK_TURBINE_SAFE_PRESSURE 5000
#define RBMK_TURBINE_SAFE_RPM 3600

/// Simple V1 damage values.
#define RBMK_TURBINE_TEMP_DAMAGE 0.1
#define RBMK_TURBINE_PRESSURE_DAMAGE 0.1
#define RBMK_TURBINE_RPM_DAMAGE 0.1

#endif
