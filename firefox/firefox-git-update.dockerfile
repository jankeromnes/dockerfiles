FROM janitortechnology/firefox
MAINTAINER Jan Keromnes "janx@linux.com"

# Upgrade all packages.
RUN sudo apt-get update -q && sudo apt-get upgrade -qy && rustup update

# Update and rebuild Firefox's source code.
RUN cd /home/user/firefox \
 && git remote update \
 && git rebase mozilla/bookmarks/central \
 && git fetch tags \
 && ./mach build
