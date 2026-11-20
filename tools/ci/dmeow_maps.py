"""Say what fills a 32-bit DreamDaemon's address space, from saved copies of
`/proc/<pid>/maps` (Linux). The server dies when the space runs out, and
`VmRSS` cannot see that: space that is reserved but never touched counts here
and not there.

	python dmeow_maps.py maps-1.txt maps-2.txt maps-3.txt
	python dmeow_maps.py maps-1.txt --jit-log dmeow_debug.dmeowlog

dmeow takes the snapshots itself on Linux: it writes `maps-<time>-<pid>.txt`
and `status-<time>-<pid>.txt` into a `dmeow_maps` folder beside its debug log
(`jit/dmeow_commands.md`, `DMEOW_MEM_SNAPSHOT_SECS`). Pass one pid's `maps-*`
files; the shell sorts them by time. The snapshot thread shows up in these
numbers: a 256 KB stack and probably one `1MB-aligned anon` block (a guess, like
that bucket's own label). Both are constant, so growth still reads right.

Against a server that is not running dmeow, take them by hand from a shell as
the server's user, with `PID` set to DreamDaemon's pid:

	while sleep 300; do t=$(date +%s); cp /proc/$PID/maps maps-$t.txt; grep Vm /proc/$PID/status > status-$t.txt; done

Give the files in time order. The first column set is the first file; later
files print growth against it, so the bucket that grows is the answer.

Buckets, tested in this order:

- `heap`: `[heap]`, the main thread's heap. Mostly the game's own objects.
- `stacks`: `[stack]`.
- `compiled code`: anonymous read+write+execute. dmeow's code, in 1 MB blocks.
- `files`: anything mapped from a file, libraries included.
- `1MB-aligned anon`: anonymous, starts on a 1 MB boundary. **A guess**: on
  32-bit glibc the extra threads' heaps look like this, so these are probably
  the compile workers' memory. Nothing here proves it.
- `other anon`: the rest. Thread stacks land here.

`--jit-log` checks the bucket rule against a debug log, using the last
snapshot. Every `jit_load` address from one session of the log (`--session`,
counting from 1, default the last) that falls inside a mapped region must fall
inside a `compiled code` one. A build that finished after the snapshot is in no
region and is skipped. At least one address has to match, or the check proved
nothing. Exits non-zero otherwise. A harness log holds several sessions, so
name the one the snapshots came from.
"""

import argparse
import json
import sys
from pathlib import Path

ADDRESS_SPACE = 1 << 32
LOW_ADDRESS = 0x10000
MB = 1 << 20

BUCKETS = [
	"heap",
	"stacks",
	"compiled code",
	"files",
	"1MB-aligned anon",
	"other anon",
]


def parse_maps(path: Path) -> list[tuple[int, int, str]]:
	"""Each region as (start, end, bucket)."""
	regions = []
	for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
		fields = line.split(None, 5)
		if len(fields) < 5 or "-" not in fields[0]:
			continue
		start, end = (int(part, 16) for part in fields[0].split("-"))
		name = fields[5].strip() if len(fields) > 5 else ""
		regions.append((start, end, classify(start, fields[1], name)))
	return regions


def classify(start: int, perms: str, name: str) -> str:
	if name == "[heap]":
		return "heap"
	if name.startswith("[stack"):
		return "stacks"
	if not name and perms[:3] == "rwx":
		return "compiled code"
	if name:
		return "files"
	if start % MB == 0:
		return "1MB-aligned anon"
	return "other anon"


def totals(regions: list[tuple[int, int, str]]) -> dict[str, int]:
	sums = dict.fromkeys(BUCKETS, 0)
	for start, end, bucket in regions:
		sums[bucket] += end - start
	return sums


def largest_gap(regions: list[tuple[int, int, str]]) -> int:
	"""The biggest hole an allocation could still land in."""
	best, cursor = 0, LOW_ADDRESS
	for start, end, _ in sorted(regions):
		best = max(best, start - cursor)
		cursor = max(cursor, end)
	return max(best, ADDRESS_SPACE - cursor)


def check_jit_log(regions: list[tuple[int, int, str]], log: Path, session: int) -> bool:
	# here and not at the top, so this file runs alone when copied into a CI repo
	from dmeowlog import jsonl_path

	sessions: list[list[int]] = []
	for line in jsonl_path(log).read_text(encoding="utf-8").splitlines():
		if '"cat":"session_init"' in line:
			sessions.append([])
		elif '"cat":"jit_load"' in line and sessions:
			sessions[-1].append(int(json.loads(line)["addr"], 16))
	if not sessions or session > len(sessions):
		print(f"FAIL: the log has {len(sessions)} sessions, no session {session}")
		return False
	addrs = sessions[session - 1] if session else sessions[-1]

	sorted_regions = sorted(regions)
	matched = wrong = 0
	for addr in addrs:
		hit = next((r for r in sorted_regions if r[0] <= addr < r[1]), None)
		if hit is None:
			continue
		if hit[2] == "compiled code":
			matched += 1
		else:
			wrong += 1
	print(
		f"jit_load check: {len(addrs)} installs in that session, "
		f"{matched} inside compiled code, {wrong} inside another bucket, "
		f"{len(addrs) - matched - wrong} not in the snapshot"
	)
	if wrong:
		print("FAIL: an install landed in a region the bucket rule filed elsewhere")
	if not matched:
		print("FAIL: no install matched, so this check proved nothing")
	return not wrong and matched > 0


def main() -> int:
	parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
	parser.add_argument("maps", nargs="+", type=Path, help="saved /proc/<pid>/maps files")
	parser.add_argument("--jit-log", type=Path, help="debug log to check the compiled code bucket against")
	parser.add_argument(
		"--session",
		type=int,
		default=0,
		help="which session of the log the snapshots came from, counting from 1 (default: the last)",
	)
	args = parser.parse_args()

	snapshots = []
	for path in args.maps:
		regions = parse_maps(path)
		if not regions:
			print(f"{path}: no regions parsed, is this a maps file?", file=sys.stderr)
			return 1
		snapshots.append(regions)

	sums = [totals(regions) for regions in snapshots]
	header = f"{'bucket':18}" + "".join(f"{p.name[:14]:>16}" for p in args.maps)
	print(header)
	for bucket in BUCKETS:
		cells = []
		for i, snap in enumerate(sums):
			cell = f"{snap[bucket] / MB:.1f} MB"
			if i:
				cell += f" ({(snap[bucket] - sums[0][bucket]) / MB:+.1f})"
			cells.append(f"{cell:>16}")
		print(f"{bucket:18}" + "".join(cells))
	mapped = [sum(snap.values()) for snap in sums]
	print(f"{'mapped':18}" + "".join(f"{m / MB:>13.1f} MB" for m in mapped))
	print(f"{'largest free gap':18}" + "".join(f"{largest_gap(r) / MB:>13.1f} MB" for r in snapshots))

	if args.jit_log and not check_jit_log(snapshots[-1], args.jit_log, args.session):
		return 1
	return 0


if __name__ == "__main__":
	sys.exit(main())
