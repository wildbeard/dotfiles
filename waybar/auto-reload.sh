#!/usr/bin/env bash
inotifywait -mqre close_write,moved_to \
	--include '\.(jsonc?|css)$' ~/.config/waybar/ |
while read -r _; do
	killall -SIGUSR2 waybar
done
