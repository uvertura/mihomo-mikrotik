#!/bin/sh

# ADDRESS_LIST="toEustratiusMark"
# FORWARD_TO="fwdEustratius"
# COMMENT_PREFIX="Evstratius-"
# FILE_URL="https://static.eustratius.ru/mikrotik_dns_rules.csv"

if [ -z "${ADDRESS_LIST}" ]; then
    echo "Ошибка: переменная окружения ADDRESS_LIST не задана" >&2
    echo "Использование: ADDRESS_LIST=... FORWARD_TO=... COMMENT_PREFIX=... FILE_URL=... $0" >&2
    exit 1
fi

if [ -z "${FORWARD_TO}" ]; then
    echo "Ошибка: переменная окружения FORWARD_TO не задана" >&2
    echo "Использование: ADDRESS_LIST=... FORWARD_TO=... COMMENT_PREFIX=... FILE_URL=... $0" >&2
    exit 1
fi

if [ -z "${COMMENT_PREFIX}" ]; then
    echo "Ошибка: переменная окружения COMMENT_PREFIX не задана" >&2
    echo "Использование: ADDRESS_LIST=... FORWARD_TO=... COMMENT_PREFIX=... FILE_URL=... $0" >&2
    exit 1
fi

if [ -z "${FILE_URL}" ]; then
    echo "Ошибка: переменная окружения FILE_URL не задана" >&2
    echo "Использование: ADDRESS_LIST=... FORWARD_TO=... COMMENT_PREFIX=... FILE_URL=... $0" >&2
    exit 1
fi


command -v wget >/dev/null 2>&1 || { echo "Ошибка: wget не найден!" >&2; exit 1; }

wget -q -O - "$FILE_URL" | while IFS= read -r line; do
    [ -z "$line" ] && continue
    case "$line" in \#*) continue ;; esac

    OLDIFS="$IFS"; IFS=","; set -- $line; IFS="$OLDIFS"
    [ $# -lt 3 ] && continue

    domain="$1"
    comment_suffix="$2"
    match_subdomain="$3"

    case "$match_subdomain" in
        yes|no)
            comment="${COMMENT_PREFIX}${comment_suffix}"
            echo "/ip/dns/static/ add address-list=$ADDRESS_LIST forward-to=$FORWARD_TO match-subdomain=$match_subdomain type=FWD comment=\"$comment\" name=$domain"
            ;;
    esac
done
