#!/bin/sh
# Keep only the "using <defconfig>" lines of builds that produced no errors.
#
# Usage: filter_defconfigs.sh [-l] [-n] [-o output] logfile
#   -l          lenient: discard a defconfig only if its block contains "error"
#               (default: any non-empty line after "using" discards it)
#   -n          print only the defconfig names
#   -o output   write to file instead of stdout

usage() {
    echo "Usage: $0 [-l] [-n] [-o output] logfile" >&2
    exit 1
}

lenient=0
names=0
output=""

while getopts "lno:h" opt; do
    case "$opt" in
        l) lenient=1 ;;
        n) names=1 ;;
        o) output="$OPTARG" ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))

[ $# -eq 1 ] || usage
[ -r "$1" ] || { echo "Error: cannot read '$1'" >&2; exit 1; }

run() {
    awk -v lenient="$lenient" -v names="$names" '
        function out(line) {
            if (line == "") return
            if (names) sub(/^.*using[ \t]+/, "", line)
            print line
        }
        /^([0-9]+:)?[ \t]*using[ \t]/ { out(p); p = $0; next }
        lenient && tolower($0) ~ /(^|[^a-z0-9_])error([^a-z0-9_]|$)/ { p = ""; next }
        !lenient && NF { p = "" }
        END { out(p) }
    ' "$1"
}

if [ -n "$output" ]; then
    run "$1" > "$output"
else
    run "$1"
fi
