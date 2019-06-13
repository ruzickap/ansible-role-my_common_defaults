#!/bin/bash -eu

TEMP_PATH="/tmp/vagrant_test_windows/"
VAGRANT_BOXES="peru/windows-server-2012_r2-standard-x64-eval peru/windows-server-2016-standard-x64-eval peru/windows-10-enterprise-x64-eval"
ANSIBLE_ROLE_DIR="$PWD/../"

HOSTS=""
for VAGRANT_BOX in $VAGRANT_BOXES; do
  BOX="${VAGRANT_BOX##*/}"
  echo "*** $VAGRANT_BOX : $BOX"

  HOSTS="$HOSTS,$BOX"

  if [ ! -f $TEMP_PATH/$BOX/Vagrantfile ]; then
    test -d "$TEMP_PATH/$BOX" || mkdir -v -p "$TEMP_PATH/$BOX"

    docker pull peru/vagrant_libvirt_virtualbox
    docker run --rm -it -u $(id -u):$(id -g) --privileged --net=host \
    -e HOME=/home/docker \
    -e VAGRANT_DEFAULT_PROVIDER=libvirt \
    -e ANSIBLE_HOST_KEY_CHECKING=False \
    -v /dev/vboxdrv:/dev/vboxdrv \
    -v /var/run/libvirt/libvirt-sock:/var/run/libvirt/libvirt-sock \
    -v $TEMP_PATH/$BOX:/home/docker/vagrant \
    -v $ANSIBLE_ROLE_DIR:/home/docker/ansible_role \
    -v $HOME/.vagrant.d/boxes:/home/docker/.vagrant.d/boxes \
    peru/vagrant_libvirt_virtualbox "\
    set -ux \
    && vagrant init $VAGRANT_BOX \
    && vagrant up \
    && VAGRANT_HOST=\`vagrant ssh-config | awk '/HostName / { print \$2 }'\` \
    && ansible-playbook --extra-vars \"ansible_user=Administrator ansible_password=vagrant ansible_connection=winrm ansible_winrm_server_cert_validation=ignore\" -i \$VAGRANT_HOST, \$HOME/ansible_role/tests/test.yml \
    && ansible-playbook --extra-vars \"ansible_user=Administrator ansible_password=vagrant ansible_connection=winrm ansible_winrm_server_cert_validation=ignore\" -i \$VAGRANT_HOST, \$HOME/ansible_role/tests/test.yml \
    && bash \
    ;  vagrant destroy -f \
    "

  echo "*** Removing $VAGRANT_BOX : $BOX: $TEMP_PATH/$BOX"
  rm -rf "$TEMP_PATH/$BOX/"{Vagrantfile,.vagrant}
  rmdir "$TEMP_PATH/$BOX"

  else
    echo "*** $TEMP_PATH/$BOX/Vagrantfile exists... skipping provisioning"
  fi
done
