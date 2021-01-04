#! /bin/sh
# usage: sudo ./install-crx.sh [OUTPUT_DIR]
set -efu

# TODO keep in sync with ./build-crx.sh
out_dir=${1-$(dirname "$0")}
crx_file=$out_dir/TabFS.crx
update_file=$out_dir/TabFS.xml
policy_file=$out_dir/TabFS.json

# TODO keep in sync with crx_url and update_url n ./build-crx.sh
system_extensions_dir=/etc/chromium/extensions
system_update_dir=/etc/chromium/extensions
system_policies_dir=/etc/chromium/policies/managed


mkdir -p "$system_extensions_dir"
mkdir -p "$system_update_dir"
mkdir -p "$system_policies_dir"

cp "$crx_file" "$system_extensions_dir"
cp "$update_file" "$system_update_dir"

# Remove existing policy to force reloading the extensions
rm -f "$system_policies_dir"/TabFS.json
cp "$policy_file" "$system_policies_dir"/TabFS.json
