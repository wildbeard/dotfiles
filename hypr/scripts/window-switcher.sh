#!/usr/bin/env bash
selection=$(
  hyprctl clients -j \
	  | jq -r '.[]
  		| select(.mapped)
		| "\(.address)\t[\(.workspace.name)] \(.class): \(.title)"' \
	  | fuzzel --dmenu --with-nth=2 --accept-nth=1 --prompt="window > "
)

[ -z "$selection" ] && exit 0

hyprctl dispatch "hl.dsp.focus({ window = \"address:$selection\" })"
