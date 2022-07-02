#!/bin/bash

#
# Prepare a Venus image for MoaT and whatnot

d="$(cd "$(dirname $0)"; pwd)"
cd $d

set -ex
trap 'echo ERROR' 0 1 2

echo "Victron/MoaT setup"
/opt/victronenergy/swupdate-scripts/resize2fs.sh

# Packages

opkg update
opkg install \
	python3-pip \
	python3-venv \
	python3-modules \
	findutils \
	python3-dataclasses \
	psmisc \
	git \
	vim \
	binutils \

# venv
if test ! -d env; then
	python3 -mvenv --without-pip --system-site-packages env
fi


ln -sf /usr/bin/pip3 /$d/env/bin/
ln -sf /usr/bin/pip3 /$d/env/bin/pip

set +x
. $d/env/bin/activate
set -x

pip3 install asyncdbus trio pytest

cp -r dbus-modbus-local.serial/. /opt/victronenergy/service-templates/dbus-modbus-local.serial
sed -i -e "s!DIR!$d!" /opt/victronenergy/service-templates/dbus-modbus-local.serial/run

mkdir -p /data/conf/serial-starter.d
echo <<_ >>/data/conf/serial-starter.d/lmodbus.conf
service lmodbus         dbus-modbus-local.serial
_

cp modbus/udev.rules /etc/udev/rules.d/serial-starter-aux.rules
