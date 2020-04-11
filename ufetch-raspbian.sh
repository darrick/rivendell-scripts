#!/bin/sh
#
# ufetch-raspbian - tiny system info for raspbian

## INFO

# user is already defined
host="$(hostname)"
hardware="$(cat /sys/firmware/devicetree/base/model)"
os='Raspbian'
kernel="$(uname -sr)"
memory="$(free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')"
disk="$(df -h | awk '$NF=="/"{printf "%d/%dGB (%s)\n", $3,$2,$5}')"
cpuload="$(top -bn1 | grep load | awk '{printf "%.2f\n", $(NF-2)}')"
uptime="$(uptime -p | sed 's/up //')"
packages="$(dpkg -l | wc -l)"
shell="$(basename "$SHELL")"

## UI DETECTION

if [ -n "${DE}" ]; then
	ui="${DE}"
	uitype='DE'
elif [ -n "${WM}" ]; then
	ui="${WM}"
	uitype='WM'
elif [ -n "${XDG_CURRENT_DESKTOP}" ]; then
	ui="${XDG_CURRENT_DESKTOP}"
	uitype='DE'
elif [ -n "${DESKTOP_SESSION}" ]; then
	ui="${DESKTOP_SESSION}"
	uitype='DE'
elif [ -f "${HOME}/.xinitrc" ]; then
	ui="$(tail -n 1 "${HOME}/.xinitrc" | cut -d ' ' -f 2)"
	uitype='WM'
elif [ -f "${HOME}/.xsession" ]; then
	ui="$(tail -n 1 "${HOME}/.xsession" | cut -d ' ' -f 2)"
	uitype='WM'
else
	ui='unknown'
	uitype='UI'
fi

## DEFINE COLORS

# probably don't change these
if [ -x "$(command -v tput)" ]; then
	bold="$(tput bold)"
	black="$(tput setaf 0)"
	red="$(tput setaf 1)"
	green="$(tput setaf 2)"
	yellow="$(tput setaf 3)"
	blue="$(tput setaf 4)"
	magenta="$(tput setaf 5)"
	cyan="$(tput setaf 6)"
	white="$(tput setaf 7)"
	reset="$(tput sgr0)"
fi

# you can change these
lc="${reset}${bold}${red}"          # labels
nc="${reset}${bold}${red}"          # user and hostname
ic="${reset}"                       # info
c0="${reset}${green}"               # first color
c1="${reset}${red}"                 # second color

## OUTPUT

cat <<EOF

${c0}              ${nc}${USER}${ic}@${nc}${host}${reset}
${c0}	      ${lc}OS:        	${ic}${os}${reset}
${c0}    __  __    ${lc}HOST:      	${ic}${hardware}${reset}
${c1}   (_\\)(/_)   ${lc}KERNEL:    	${ic}${kernel}${reset}
${c1}   (_(__)_)   ${lc}MEMORY USAGE:     ${ic}${memory}${reset}
${c1}  (_(_)(_)_)  ${lc}DISK USAGE:	${ic}${disk}${reset}
${c1}   (_(__)_)   ${lc}CPU LOAD:         ${ic}${cpuload}${reset}
${c1}     (__)     ${lc}UPTIME:    	${ic}${uptime}${reset}
${c1}	      ${lc}PACKAGES:  	${ic}${packages}${reset}
${c1}	      ${lc}SHELL:     	${ic}${shell}${reset}
${c1}	      ${lc}${uitype}:      	        ${ic}${ui}${reset}

EOF
