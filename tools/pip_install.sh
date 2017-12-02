#!/bin/sh -e
# pip installs packages using pinned package versions. If CERTBOT_OLDEST is set
# to 1, a combination of tools/oldest_constraints.txt and
# tools/dev_constraints.txt is used, otherwise, a combination of certbot-auto's
# requirements file and tools/dev_constraints.txt is used. The other file
# always takes precedence over tools/dev_constraints.txt.

# get the root of the Certbot repo
tools_dir=$(dirname $("$(dirname $0)/readlink.py" $0))
dev_constraints="tools_dir/dev_constraints.txt"
constraints=$(mktemp)
trap "rm -f $constraints" EXIT

if [ "$CERTBOT_OLDEST" = 1; ]; then
    cat "$tools_dir/oldest_constraints.txt" > "$constraints"
else
    repo_root=$(dirname "$tools_dir")
    certbot_requirements="$repo_root/letsencrypt-auto-source/pieces/dependency-requirements.txt"
    sed -n -e 's/^\([^[:space:]]*==[^[:space:]]*\).*$/\1/p' "$certbot_requirements" > "$constraints"
fi
"$tools_dir/merge_requirements.py" "$dev_constraints" "$constraints" > "$constraints"

# install the requested packages using the pinned requirements as constraints
pip install --constraint "$constraint" "$@"
