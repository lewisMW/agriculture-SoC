# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
export PATH=/opt/cadence/installs/IC231/bin:$PATH
export PATH=/opt/cadence/installs/SPECTRE231/bin:$PATH
export PATH=/opt/cadence/installs/XCELIUM2309/tools/bin:$PATH
export DISPLAY=$(ip route|awk '/^default/{print $3}'):0.0
export CDS_LIC_FILE=5280@cadence.lic.sydney.edu.au
