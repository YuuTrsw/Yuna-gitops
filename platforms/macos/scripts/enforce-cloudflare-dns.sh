#!/bin/bash

set -euo pipefail

readonly CLOUDFLARE_DNS="1.1.1.1"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "This script must run as root." >&2
  exit 1
fi

configured_services=0

while IFS= read -r service; do
  [[ -z "$service" ]] && continue
  [[ "$service" == \** ]] && continue

  /usr/sbin/networksetup -setdnsservers "$service" "$CLOUDFLARE_DNS"
  configured_services=$((configured_services + 1))
done < <(/usr/sbin/networksetup -listallnetworkservices | /usr/bin/tail -n +2)

if [[ "$configured_services" -eq 0 ]]; then
  echo "No enabled network services were found." >&2
  exit 1
fi

/usr/bin/dscacheutil -flushcache
/usr/bin/killall -HUP mDNSResponder 2>/dev/null || true

if ! /usr/sbin/scutil --dns | /usr/bin/grep -Eq 'nameserver\[[0-9]+\] : 1\.1\.1\.1'; then
  echo "Cloudflare DNS was configured but could not be verified." >&2
  exit 1
fi

echo "Configured Cloudflare DNS ($CLOUDFLARE_DNS) on $configured_services network service(s)."
