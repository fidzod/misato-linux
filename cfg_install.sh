#!/bin/bash
declare ST_KEYBOARD="Keyboard"
declare ST_HOSTNAME="Hostname"
declare ST_TIME="Timezone"
declare ST_DISKS="Disk Partitioning and Filesystems"
declare ST_PASSWD="Root Password"
declare ST_USER="User Account"
declare ST_QUIT="Install"

declare -A CONFIG_STATUS=(
    ["$ST_KEYBOARD"]=
    ["$ST_HOSTNAME"]=
    ["$ST_TIME"]=
    ["$ST_DISKS"]=
    ["$ST_PASSWD"]=
    ["$ST_USER"]=
    ["$ST_QUIT"]=
)

declare QUIT=

declare CF_KEYBOARD=
declare CF_HOSTNAME=
declare CF_TIME=
declare CF_DISKS=
declare CF_PASSWD=
declare CF_USERNAME=
declare CF_USERPASSWD=

check_progress () { [[ ${CONFIG_STATUS["$1"]} ]] && echo "$1" || echo "*$1"; }

st_keyboard () {
    KEYMAPS=$(find /usr/share/kbd/keymaps/ -type f \
        -name "*.map.gz" -printf "%f\n" \
        | sed 's/\.map\.gz$//' \
        | sort
    )

    CF_KEYBOARD=$(gum choose \
        --header "Choose keyboard layout: " \
        --height=7 \
        --cursor.background="#b78db7" \
        --cursor.foreground="#d3d3d3" \
        --header.foreground="#b78db7" \
        --item.foreground="#d3d3d3" \
        $KEYMAPS
    )

    CONFIG_STATUS["$ST_KEYBOARD"]=true
}

st_hostname () {
    CF_HOSTNAME=$(gum input \
        --prompt="Hostname: " \
        --prompt.foreground="#b78db7" \
        --value="misato"
    )

    CONFIG_STATUS["$ST_HOSTNAME"]=true
}

st_disks () {
    CF_DISKS=$(gum choose \
        --header "Disk Partioning" \
        --height=7 \
        --cursor.background="#b78db7" \
        --cursor.foreground="#d3d3d3" \
        --header.foreground="#b78db7" \
        --item.foreground="#d3d3d3" \
        "Automatic (Best effort)" \
        "Manual (Bash prompt, cfdisk and fdisk available)"
    )

    CONFIG_STATUS["$ST_DISKS"]=true
}

st_password () {
    CF_PASSWD=$(gum input \
        --prompt="Root Password: " \
        --password \
        --prompt.foreground="#b78db7"
    )

    CONFIG_STATUS["$ST_PASSWD"]=true
}

st_time () {
    CF_TIME=$(gum file \
        --height=10 \
        --no-permissions \
        --no-size \
        --cursor.foreground="#b78db7" \
        --selected.foreground="#b78db7" \
        --directory.foreground="#5a5a97" \
        --file.foreground="#d3d3d3" \
        /usr/share/zoneinfo 
    )

    CONFIG_STATUS["$ST_TIME"]=true
}

make_user () {
    CF_USERNAME=$(gum input \
        --prompt="Account username: " \
        --prompt.foreground="#b78db7" \
        --header.foreground="#c5b0c5" \
        --header="Create a user"
    )
    CF_USERPASSWD=$(gum input \
        --prompt="Account password: " \
        --prompt.foreground="#b78db7" \
        --header.foreground="#c5b0c5" \
        --header="Create a user" \
        --password
    )
    
    CONFIG_STATUS["$ST_USER"]=true
}

banner () {
    BANNER_HEAD=$(gum style \
        --width=50 \
        --align center \
        --foreground="#b78db7" \
        "Misato Linux"
    )
    BANNER_SUBH=$(gum style \
        --width=50 \
        --align center \
        --foreground="#d3d3d3" \
        "Welcome to the Misato Installer for Void Linux!"
    )

    gum style \
        --border rounded \
        --padding "1 4" \
        --border-foreground "#c5b0c5" \
        "$(gum join --vertical "$BANNER_HEAD" "" "$BANNER_SUBH")"

    echo ""
}

main () {
    clear

    banner

    OPTION=$(gum choose \
        --header="Configure Installation:" \
        --height=7 \
        --cursor.background="#b78db7" \
        --cursor.foreground="#d3d3d3" \
        --header.foreground="#b78db7" \
        --item.foreground="#d3d3d3" \
        --label-delimiter=":" \
        "$(check_progress "$ST_KEYBOARD"):$ST_KEYBOARD" \
        "$(check_progress "$ST_HOSTNAME"):$ST_HOSTNAME" \
        "$(check_progress "$ST_TIME"):$ST_TIME" \
        "$(check_progress "$ST_DISKS"):$ST_DISKS" \
        "$(check_progress "$ST_PASSWD"):$ST_PASSWD" \
        "$(check_progress "$ST_USER"):$ST_USER" \
        "$(check_progress "$ST_QUIT"):$ST_QUIT")

    case $OPTION in
        "$ST_KEYBOARD") st_keyboard ;;
        "$ST_HOSTNAME") st_hostname ;;
        "$ST_TIME") st_time ;;
        "$ST_DISKS") st_disks ;;
        "$ST_PASSWD") st_password ;;
        "$ST_USER") make_user ;;
        "$ST_QUIT") QUIT=1 ;;
    esac

    [[ -z "$QUIT" ]] && main
}

main

gum pager --height=14 --width=60 <<EOF
# ========================== #
# Misato Linux Configuration #
# ========================== #

# (press `esc` or `q` to proceed with installation.)

CF_KEYBOARD=$CF_KEYBOARD
CF_HOSTNAME=$CF_HOSTNAME
CF_TIME=$CF_TIME
CF_DISKS=$CF_DISKS
CF_PASSWD=$CF_PASSWD
CF_USERNAME=$CF_USERNAME
CF_USERPASSWD=$CF_USERPASSWD
EOF
