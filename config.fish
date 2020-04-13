# startup command
sh /home/pi/.config/fish/ufetch-raspbian.sh

# list Rivendell details
echo Your Current Rivendell Install Details
sh /home/pi/pkgupdate.sh
sudo rddbmgr

# pointless greeting
set fish_greeting

# alias commands
alias ls="exa -l"
alias ..="cd .."
alias mv="mv -i"
alias rm="rm -i"
