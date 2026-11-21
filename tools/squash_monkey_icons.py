"""
Bakes the medium monkey height filter (the monkey_medium state of icons/effects/cut.dmi) into copies of the
monkey art, so a monkey draws without a displacement filter. Rerun after editing any of the source files:

	uv run --with avulto python -I tools/squash_monkey_icons.py
	meowvorbis --dmi icons/mob/effects/dam_mob_squashed.dmi icons/mob/human/species/monkey/bodyparts_squashed.dmi icons/mob/human/species/monkey/monkey_tail_squashed.dmi
"""

from pathlib import Path

from avulto import DMI, IconState

ROOT = Path(__file__).resolve().parent.parent

SOURCES = {
	"icons/mob/human/species/monkey/bodyparts.dmi": "icons/mob/human/species/monkey/bodyparts_squashed.dmi",
	"icons/mob/human/species/monkey/monkey_tail.dmi": "icons/mob/human/species/monkey/monkey_tail_squashed.dmi",
	"icons/mob/effects/dam_mob.dmi": "icons/mob/effects/dam_mob_squashed.dmi",
}

CHANNELS = 4


def row_shifts(width: int, height: int) -> list[int]:
	mask = DMI.from_file(str(ROOT / "icons/effects/cut.dmi")).state("monkey_medium")
	data = mask.data_rgba8(1, mask.dirs[0])
	shifts = []
	for y in range(height):
		red, green, _blue, alpha = data[y * width * CHANNELS : y * width * CHANNELS + CHANNELS]
		if not alpha:
			shifts.append(0)
			continue
		assert red == 128, "mask moves things sideways, which this script does not handle"
		shifts.append(green - 128)
	return shifts


def squash(data: bytes, width: int, height: int, shifts: list[int]) -> bytes:
	row_bytes = width * CHANNELS
	blank = bytes(row_bytes)
	rows = []
	for y in range(height):
		source_y = y + shifts[y]
		if 0 <= source_y < height:
			rows.append(data[source_y * row_bytes : (source_y + 1) * row_bytes])
		else:
			rows.append(blank)
	return b"".join(rows)


def main() -> None:
	for source_path, squashed_path in SOURCES.items():
		source = DMI.from_file(str(ROOT / source_path))
		width, height = source.icon_dims
		shifts = row_shifts(width, height)
		squashed = DMI.new((width, height))
		for state in source.states:
			if state.frames != 1:
				raise SystemExit(f"{source_path}: state {state.name} has {state.frames} frames, avulto scrambles those")
			data = {direction: [squash(state.data_rgba8(1, direction), width, height, shifts)] for direction in state.dirs}
			squashed.states.append(IconState.from_data(data, width, height, state.name))
		squashed.save_to(str(ROOT / squashed_path))
		print(f"{squashed_path}: {len(source.states)} states")


if __name__ == "__main__":
	main()
