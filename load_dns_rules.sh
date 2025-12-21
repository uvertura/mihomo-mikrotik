#!/bin/sh

#FILE_URL="https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-doh.list"
#COMMENT_PREFIX="Evstratius-"
#ADDRESS_LIST="doh-domains"
#FORWARD_TO="fwdEustratius"

if [ -z "${ADDRESS_LIST}" ]; then
    echo "Error: variable ADDRESS_LIST not set" >&2
    echo "Use: ADDRESS_LIST=... COMMENT_PREFIX=... FILE_URL=... [FORWARD_TO=...] $0" >&2
    exit 1
fi

if [ -z "${COMMENT_PREFIX}" ]; then
    echo "Error: variable COMMENT_PREFIX not set" >&2
    echo "Use: ADDRESS_LIST=... COMMENT_PREFIX=... FILE_URL=... [FORWARD_TO=...] $0" >&2
    exit 1
fi

if [ -z "${FILE_URL}" ]; then
    echo "Error: variable FILE_URL not set" >&2
    echo "Use: ADDRESS_LIST=... COMMENT_PREFIX=... FILE_URL=... [FORWARD_TO=...] $0" >&2
    exit 1
fi


valFile="${FILE_URL##*/}"
valFileName="${valFile%.*}"
valComment="${COMMENT_PREFIX}${valFileName}"


wget -q -O - "$FILE_URL" | while IFS= read -r line; do
    # Remove spaces
    line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Skip empty strings
    [ -z "$line" ] && continue

    # Detect match-subdomain and domain
    case "$line" in
        +.*)
            subDomains="yes"
            domain="${line#+.}"
            ;;
        *)
            subDomains="no"
            domain="$line"
            ;;
    esac

    resultLine=":do { /ip/dns/static/add type=\"FWD\" comment=\"$valComment\" address-list=\"$ADDRESS_LIST\"" \
    resultLine="$resultLine name=\"$domain\" match-subdomain=\"$subDomains\""
    if [ -n "${FORWARD_TO:-}" ]; then
      resultLine="$resultLine forward-to=\"$FORWARD_TO\""
    fi
    echo "$resultLine } on-error={ :log error \"Failed add static dns FWD rule for domain: $domain\"}"

done

