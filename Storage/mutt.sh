#!/bin/bash

#Setup Commands
mkdir -p ~/.mutt/cache
mkdir -p ~/.mutt/certificates
mkdir -p ~/.mutt/accounts

# BGSU Account file #############################################
echo '
set realname = "Stephen Rush"
set from = "srrush@bgsu.edu"
set imap_user = "srrush@bgsu.edu"
set imap_pass = "D6Qb#hBD8e"

# Remote Folders
set folder="imaps://outlook.office365.com/"
set spoolfile = "+INBOX"
set postponed = "+Drafts"
set record = "+Sent Items"

# SMTP SETTINGS
set smtp_url = "smtps://srrush@bgsu.edu@smtp.outlook.office365.com/"
set smtp_pass = "D6Qb#hBD8e" # use the same password as for IMAP
set record=""

color status green default

macro index D \
    "<save-message>+BGSU/Deleted Items<enter>" \
    "move message to the trash"

macro index S \
    "<save-message>+BGSU/Junk Email<enter>" \
    "mark message as spam"

# Configuration
set ssl_starttls=yes
set ssl_force_tls=yes
' >> ~/.mutt/accounts/BGSU

# Stephen Account ##############################################
echo '
# Use an application password if 2F authentication is enabled
set realname = "Stephen Rush"
set from = "stephen.r.rush@gmail.com"
set imap_user = "stephen.r.rush@gmail.com"
set imap_pass = "tcsaluhwbbodphvi"

# Remote Folders
set folder = "imaps://imap.gmail.com/"
set spoolfile = "+INBOX"
set postponed = "+[Gmail]/Drafts"
set record = "+[Gmail]/Sent Mail"

# SMTP SETTINGS
set smtp_url = "smtps://stephen.r.rush@smtp.gmail.com/"
set smtp_pass = "tcsaluhwbbodphvi" # use the same password as for IMAP
set record=""

color status green default

macro index D \
    "<save-message>+Gmail-Stephen/Trash<enter>" \
    "move message to the trash"

macro index S \
    "<save-message>+Gmail-Stephen/Spam<enter>" \
    "mark message as spam"

# Configuration
set ssl_starttls=yes
set ssl_force_tls=yes
' >> ~/.mutt/accounts/Gmail-Stephen

# mutt configuration ########################################################
echo '
# Accounts and Configuration Files
# stephen.r.rush@gmail.com
folder-hook Gmail-Stephen source ~/.mutt/accounts/Gmail-Stephen
# BGSU srrush@bgsu.edu
folder-hook BGSU source ~/.mutt/accounts/BGSU

# Open default account
source ~/.mutt/accounts/Gmail-Stephen

# LOCAL FOLDERS FOR CACHED HEADERS AND CERTIFICATES
set header_cache = "~/.mutt/cache/headers"
set message_cachedir = "~/.mutt/cache/bodies"
set certificate_file = "~/.mutt/certificates"

# SECURING
set move = no #Stop asking to move read messages to mbox!
set imap_keepalive = 900

# Usage
set editor = "nano"
' >> ~/.mutt/muttrc
