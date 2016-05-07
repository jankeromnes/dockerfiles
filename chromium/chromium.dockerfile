FROM janx/ubuntu-dev
MAINTAINER Jan Keromnes "janx@linux.com"

# Enable extended "multiverse" Ubuntu packages.
RUN echo "deb http://archive.ubuntu.com/ubuntu xenial multiverse" >> /etc/apt/sources.list

# Don't be root.
USER user
WORKDIR /home/user

# Install Chromium's depot_tools.
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
ENV PATH $PATH:/home/user/depot_tools
RUN echo "\n# Add Chromium's depot_tools to the PATH." >> .bashrc \
 && echo "export PATH=\"\$PATH:/home/user/depot_tools\"" >> .bashrc

# Disable gyp_chromium for faster updates.
ENV GYP_CHROMIUM_NO_ACTION 1
RUN echo "\n# Disable gyp_chromium for faster updates." >> .bashrc \
 && echo "export GYP_CHROMIUM_NO_ACTION=1" >> .bashrc

# Create the Chromium directory.
RUN mkdir /home/user/chromium
WORKDIR chromium

# Download Chromium's source code.
RUN fetch --nohooks chromium --nosvn=True

# Install Chromium build dependencies (with administrator privileges).
RUN echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections \
 && sudo src/build/install-build-deps.sh --no-prompt --no-arm --no-chromeos-fonts --no-nacl

# Update Chromium third_party repos and run pre-compile hooks.
WORKDIR src
RUN gclient sync --delete --jobs=18

# Configure Chromium build.
RUN gn gen out/Default

# Build Chromium.
RUN ninja -C out/Default chrome -j18