#!/usr/bin/env bash
# noctalia [hooks] colors_changed → hot-reload opencode TUI themes.
#
# opencode's TUI registers process.on("SIGUSR2", refresh) in its theme context
# (packages/tui/src/context/theme.tsx): refresh re-scans themes/*.json within
# ~250ms-1s and re-renders. The background service ("serve --service") does NOT
# handle SIGUSR2 — an unhandled USR2 there would TERMINATE it and kill sessions,
# so serve processes are explicitly skipped below.
#
# Covers both binaries: beta ~/.opencode/bin/opencode2 and stable /usr/bin/opencode.
# Called by [hooks] colors_changed in ~/.config/noctalia/config.toml.

LOG="$HOME/.cache/noctalia-opencode-reload.log"

{
	echo "[$(date '+%F %T')] colors_changed → signaling opencode TUIs"
	for pid in $(pgrep -x opencode2 2>/dev/null; pgrep -x opencode 2>/dev/null); do
		[ -r "/proc/$pid/cmdline" ] || continue
		cmd="$(tr '\0' ' ' <"/proc/$pid/cmdline")"
		case "$cmd" in
		*serve* | *--service*) continue ;;
		esac
		# Structural guard: the TUI always runs attached to a terminal; the
		# background service runs detached ("?" tty). Survives future renames
		# of the serve subcommand/flags.
		tty="$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')"
		[ -n "$tty" ] && [ "$tty" != "?" ] || continue
		if kill -USR2 "$pid" 2>/dev/null; then
			echo "  USR2 → $pid [$cmd]"
		fi
	done
} >>"$LOG" 2>&1

# keep log bounded at ~1MB
if [ "$(stat -c%s "$LOG" 2>/dev/null || echo 0)" -gt 1048576 ]; then
	tail -n 200 "$LOG" >"$LOG.tmp" && mv "$LOG.tmp" "$LOG"
fi
