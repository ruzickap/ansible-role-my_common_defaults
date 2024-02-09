#!/bin/bash -eu

TEMP_PATH="/tmp/vagrant_test_linux/"
VAGRANT_BOXES="centos/7 peru/ubuntu-18.04-server-amd64 peru/ubuntu-16.04-server-amd64"
ANSIBLE_ROLE_DIR="$PWD/../"

HOSTS=""
for VAGRANT_BOX in $VAGRANT_BOXES; do
  BOX="${VAGRANT_BOX##*/}"
  echo "*** $VAGRANT_BOX : $BOX"

  HOSTS="$HOSTS,$BOX"

  if [ ! -f "$TEMP_PATH/$BOX/Vagrantfile" ]; then
    test -d "$TEMP_PATH/$BOX" || mkdir -v -p "$TEMP_PATH/$BOX"

    docker pull peru/vagrant_libvirt_virtualbox
    docker run --rm -it -u "$(id -u):$(id -g)" --privileged --net=host \
      -e HOME=/home/docker \
      -e VAGRANT_DEFAULT_PROVIDER=libvirt \
      -e ANSIBLE_HOST_KEY_CHECKING=False \
      -v /dev/vboxdrv:/dev/vboxdrv \
      -v /var/run/libvirt/libvirt-sock:/var/run/libvirt/libvirt-sock \
      -v "$TEMP_PATH/$BOX":/home/docker/vagrant \
      -v "$ANSIBLE_ROLE_DIR":/home/docker/ansible_role \
      -v "$HOME/.vagrant.d/boxes":/home/docker/.vagrant.d/boxes \
      peru/vagrant_libvirt_virtualbox "\
      set -ux \
      && vagrant init $VAGRANT_BOX \
      && vagrant up \
      && VAGRANT_USER=\`vagrant ssh-config | awk '/User / { print \$2 }'\` \
      && VAGRANT_HOST=\`vagrant ssh-config | awk '/HostName / { print \$2 }'\` \
      && VAGRANT_PRIVATE_SSH_KEY=\`vagrant ssh-config | awk '/IdentityFile/ { print \$2 }'\` \
      && vagrant ssh --command \"test -e /usr/bin/python || ( test -x /usr/bin/apt && ( sudo apt -qqy update && sudo apt install -y python-minimal ) || ( test -x /usr/bin/yum && sudo yum install -y python ))\" \
      && ansible-playbook --become --private-key \$VAGRANT_PRIVATE_SSH_KEY --extra-vars \"ansible_user=\$VAGRANT_USER\" -i \$VAGRANT_HOST, \$HOME/ansible_role/tests/test.yml \
      && ansible-playbook --become --private-key \$VAGRANT_PRIVATE_SSH_KEY --extra-vars \"ansible_user=\$VAGRANT_USER\" -i \$VAGRANT_HOST, \$HOME/ansible_role/tests/test.yml \
      ;  vagrant destroy -f \
      "

    echo "*** Removing $VAGRANT_BOX : $BOX: $TEMP_PATH/$BOX"
    rm -rf "$TEMP_PATH/$BOX/"{Vagrantfile,.vagrant}
    rmdir "$TEMP_PATH/$BOX"

  else
    echo "*** $TEMP_PATH/$BOX/Vagrantfile exists... skipping provisioning"
  fi
done
