#!/bin/sh

for countdown in $(seq 15 -1 1); do
	case $countdown in
		15 | 5 | 1)
			minecraftd command /say The server is shutting down in "$countdown" minutes.
			;;
	esac
	sleep 60
done

minecraftd stop
