#!/bin/sh

if ! command -v stow $>/dev/null; then 
	echo "stow not installed";
	exit 1;
fi

for DIR in *;
do
	[ -d $DIR ] && stow -R $DIR;
done
