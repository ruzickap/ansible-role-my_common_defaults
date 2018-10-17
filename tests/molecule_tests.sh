#!/bin/bash -eu

cd ..

MOLECULE_DISTROS="ubuntu1804 ubuntu1604 centos6"

for MOLECULE_DISTRO in $MOLECULE_DISTROS; do
  echo "*** $MOLECULE_DISTRO"
  export MOLECULE_DISTRO
  molecule test
done


MOLECULE_DISTROS="centos7"
MOLECULE_DOCKER_COMMAND="/usr/lib/systemd/systemd"

for MOLECULE_DISTRO in $MOLECULE_DISTROS; do
  echo "*** $MOLECULE_DISTRO"
  export MOLECULE_DISTRO
  molecule test
done
