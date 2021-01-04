#! /bin/sh
# usage: ./build-crx.sh [--generate-key] [OUTPUT_DIR [TABFS_SOURCE_DIR]]
set -efu

# TODO keep in sync with ./install-crx.sh
source_dir=${2-$(dirname "$0")}
out_dir=${1-$source_dir/out}
crx_file=$out_dir/TabFS.crx
update_file=$out_dir/TabFS.xml
policy_file=$out_dir/TabFS.json

# TODO keep in sync with system_extensions_dir and system_update_dir in
# ./install-crx.sh
crx_url=file:///etc/chromium/extensions/TabFS.crx
update_url=file:///etc/chromium/extensions/TabFS.xml

key_file=$out_dir/TabFS.pem
key_size=2048


mkdir -p "$out_dir"

if ! test -e "$key_file" || printf %s $* | grep -q -- '--generate-key\>'; then
  openssl genrsa -out "$key_file" "$key_size"
fi

ext_dir=$source_dir/extension

crxmake "$ext_dir" "$key_file" "$crx_file"

appid=$(crxid "$key_file")
version=$(jq -r .version "$ext_dir"/manifest.json)

cat > "$update_file" <<EOF
<?xml version='1.0' encoding='UTF-8'?>
<gupdate xmlns='http://www.google.com/update2/response' protocol='2.0'>
  <app appid='$appid'>
    <updatecheck codebase='$crx_url' version='$version' />
  </app>
</gupdate>
EOF

jq > "$policy_file" \
--null-input \
--arg appid "$appid" \
--arg update_url "$update_url" \
'
{
  ExtensionSettings: {
    "\($appid)": {
      installation_mode: "normal_installed",
      $update_url
    }
  }
}
'
