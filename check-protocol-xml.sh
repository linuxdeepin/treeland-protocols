#!/bin/sh -eu

# Check Wayland protocol XML files using wayland-scanner.
# Usage: ./check-protocol-xml.sh [file...]
#        ./check-protocol-xml.sh              # checks xml/*.xml

if ! command -v wayland-scanner >/dev/null 2>&1; then
	echo "Error: wayland-scanner not found" >&2
	exit 1
fi

if [ $# -gt 0 ]; then
	files="$@"
else
	files=$(find public dde internal wine deprecated -name '*.xml' -type f | sort)
fi

for f in $files; do
	echo "Checking $f"
	wayland-scanner client-header  "$f" /dev/null
	wayland-scanner server-header  "$f" /dev/null
	wayland-scanner public-code   "$f" /dev/null
	wayland-scanner private-code  "$f" /dev/null
done
