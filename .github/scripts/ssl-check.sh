#!/bin/bash

SLACK_WEBHOOK_URL=$SLACK_WEBHOOK_URL

DOMAINS_FILE=".github/scripts/domains.txt"
DOMAINS=($(cat "${DOMAINS_FILE}"))

for domain in "${DOMAINS[@]}"; do
  expiry_date=$(echo | openssl s_client -connect "${domain}:443" 2>/dev/null | openssl x509 -noout -dates | grep "notAfter" | cut -d= -f2)
  expiry_epoch=$(date -d "${expiry_date}" +%s)
  current_epoch=$(date +%s)
  days_remaining=$(( (expiry_epoch - current_epoch) / 86400 ))

    message="⚠ SSL Expiry Alert\n   * Domain : ${domain}\n   * Warning : The SSL certificate for ${domain} will expire in ${days_remaining} days."
    payload="payload={\"text\":\"${message}\"}"
    curl -s -X POST --data-urlencode "$payload" "$SLACK_WEBHOOK_URL"
done
