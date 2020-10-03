#!/bin/sh

NAME=testsvr01
RAM=2048
VCPUS=2
ARCH=x86_64
MACHINE=centos8
OS_TYPE=linux
OS_VARIANT=centos8
BOOT=hd
DISK="/var/lib/libvirt/images/${NAME}.qcow2"
DISK_SIZE=5G
NETWORK="bridge:br0"
GRAHPICS=none
SERIAL=pty
CONSOLE=pty
LOCATION="/data/media/CentOS-8.1.1911-x86_64-dvd1.iso"
CDROM="/data/media/CentOS-8.1.1911-x86_64-dvd1.iso"
INITRD_INJECT="/data/kickstart/centos8.ks.cfg"
EXTRA_ARGS="inst.ks=file:/$(basename ${INITRD_INJECT}) console=ttyS0"
#EXTRA_ARGS="ks=file:/$(basename ${INITRD_INJECT}) console=ttyS0"

#DIR check
for DIR in $( dirname ${DISK} )
do
        if [[ ! -d ${DIR} ]]
        then
                echo "directory ${DIR} not found"
                exit 2
        fi
done

#FILE check
for FILE in ${LOCATION} ${INITRD_INJECT}
do
        if [[ ! -r ${FILE} ]]
        then
                echo "file ${FILE} not found"
                exit 2
        fi
done

#Create Disk Image
if [[ ! -r ${DISK} ]]
then
        echo "Create Disk Image..."
        qemu-img create -f qcow2 ${DISK} ${DISK_SIZE}
        if [[ $? != 0 ]]
        then
                echo "Failed to create disk image..."
                exit 2
        fi
fi


#virt-install
echo "Installing ${NAME}..."
echo

echo virt-install \
        --name ${NAME} \
        --memory ${RAM} \
        --vcpus ${VCPUS} \
        --disk ${DISK} \
        --os-variant ${OS_VARIANT} \
        --graphics none \
        --serial ${SERIAL} \
        --console ${CONSOLE} \
        --network="${NETWORK}" \
        --location ${LOCATION} \
        --initrd-inject ${INITRD_INJECT} \
        --extra-args "${EXTRA_ARGS}"

virt-install \
        --name ${NAME} \
        --memory ${RAM} \
        --vcpus ${VCPUS} \
        --disk ${DISK} \
        --os-variant ${OS_VARIANT} \
        --graphics none \
        --serial ${SERIAL} \
        --console ${CONSOLE} \
        --network=bridge:br0 \
        --location ${LOCATION} \
        --initrd-inject ${INITRD_INJECT} \
        --extra-args "${EXTRA_ARGS}"

#       --hvm \
#       --virt-type kvm \
#       --ram ${RAM} \
#       --arch ${ARCH} \
#       --os-type ${OS_TYPE} \
#       --boot hd \

echo
echo "Done!"

