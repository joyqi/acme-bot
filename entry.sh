#!/usr/bin/env bash

# Load domains from environment variable
# Format: ISSUE_METHOD:DOMAIN1,DOMAIN2/DEPLOY_HOOK;ISSUE_METHOD:DOMAIN3,DOMAIN4/DEPLOY_HOOK
# Issue command: --issue --dns $ISSUE_METHOD -d $DOMAIN1 -d $DOMAIN2
init_domains() {
    # Check if the environment variable is set
    if [ -z "$DOMAINS" ]; then
        return 0
    fi

    local domains
    domains=$(echo "$DOMAINS" | tr ';' '\n')
    for domain in $domains; do
        local first_part=$(echo "$domain" | cut -d '/' -f 1)
        local last_part=$(echo "$domain" | awk -F"/" '{print (NF>1)?$2:""}')
        local issue_method=$(echo "$first_part" | cut -d ':' -f 1)
        local domain_list=$(echo "$first_part" | cut -d ':' -f 2)
        local domain_args=$(expand_to_args "$domain_list" "-d")

        echo "Issue certificate for $domain_list using $issue_method"
        --issue --dns $issue_method $domain_args `$deploy_hook`

        if [ -n "$last_part" ]; then
            --deploy $domain_args --deploy-hook $last_part
        fi
    done
}

init_ca() {
    if [ -z "$CA" ]; then
        return 0
    fi

    --set-default-ca --server $CA
}

init_email() {
    if [ -z "$EMAIL" ]; then
        echo "Please set the EMAIL environment variable"
        exit 1
    fi

    --register-account -m $EMAIL
}

init_notify() {
    if [ -z "$NOTIFY" ]; then
        return 0
    fi

    local notify_hook=$(expand_to_args "$NOTIFY" "--notify-hook")
    local notify_level=""
    local notify_mode=""
    local notify_source=""

    if [ -n "$NOTIFY_LEVEL" ]; then
        notify_level="--notify-level $NOTIFY_LEVEL"
    fi

    if [ -n "$NOTIFY_MODE" ]; then
        notify_mode="--notify-mode $NOTIFY_MODE"
    fi

    if [ -n "$NOTIFY_SOURCE" ]; then
        notify_source="--notify-source $NOTIFY_SOURCE"
    fi

    --set-notify $notify_hook $notify_level $notify_mode $notify_source
}

expand_to_args() {
    local domain_list=$(echo "$1" | tr ',' '\n')
    for domain in $domain_list; do
        echo " $2 $domain"
    done
}

if [ "$1" = "daemon" ]; then
    init_ca
    init_email
    init_notify
    init_domains
    exec crond -n -s -m off
else
    exec -- "$@"
fi
