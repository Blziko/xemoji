#!/usr/bin/env bash

src="${BASH_SOURCE[0]}"
while [[ -h "${src}" ]]; do
    dir="$(
        cd -P "$(
            command dirname "${src}"
        )" >/dev/null 2>&1 && pwd
    )"

    src="$(command readlink "${src}")"
    [[ "${src}" != /* ]] && src="${dir}/${src}"
done

dir="$(
    cd -P "$(
        command dirname "${src}"
    )" >/dev/null 2>&1 && pwd
)"

BASE_DIR="${dir}"
DB_DIR="${BASE_DIR}/database"

function get_categories() {
    command find "$DB_DIR" -type f -name "*.txt" | \
        command sed "s|$DB_DIR/||" | \
        command sed 's|\.txt$||' | \
        command sort -f
}

function get_items() {
    local file="$1"
    local path="${DB_DIR}/${file}.txt"
    [[ ! -f "$path" ]] && return 1
    command grep -vE '^\s*$|^#' "$path"
}

category="$(
    get_categories | \
    command fzf \
        --prompt="Select category > " \
        --height=30% \
        --border
    )"

[[ -z "${category}" ]] && exit 0

item="$(
    get_items "$category" | \
    command fzf \
        --prompt="Select item > " \
        --height=30% \
        --border
    )"

[[ -z "${item}" ]] && exit 0

echo -e "\n\033[1;34m[*] \033[0mSelected: \033[0;32m${item}\033[0m"
read -rp "$(echo -e "\033[0mPress \033[0;32mENTER \033[0mto copy...")"

echo -ne "${item}" | command xclip -selection clipboard
echo -e "\033[0;32m[+] \033[0mCopied to clipboard${N}"