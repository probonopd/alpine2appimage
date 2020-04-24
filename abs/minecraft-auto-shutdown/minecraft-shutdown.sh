#!/bin/sh

for countdown in $(seq 15 -1 1); do
	case $countdown in
		15 | 5)
			minecraftd command /say Shutting down in "$countdown" minutes.
			;;
		1)
			minecraftd command /say Shutting down in 1 minute.
			;;
	esac
	sleep 60
done

minecraftd stop
