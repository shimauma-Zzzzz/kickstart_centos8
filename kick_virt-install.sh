#!/bin/sh

if [[ $1 = "help" ]]
then
	echo ./$(basename $0) KVM_DomainName
	exit 1
fi

RAM=4096
VCPUS=2
ARCH=x86_64
MACHINE=centos8
OS_TYPE=linux
OS_VARIANT=centos8
BOOT=hd
DISK_SIZE=10G
NETWORK="bridge:br0"
GRAHPICS=none
SERIAL=pty
CONSOLE=pty
LOCATION="/data/media/CentOS-8.1.1911-x86_64-dvd1.iso"
CDROM="/data/media/CentOS-8.1.1911-x86_64-dvd1.iso"
KICKSTART_TEMPLATE=/data/kickstart/centos8.ks.cfg

## check template
if [[ ! -r ${KICKSTART_TEMPLATE} ]]
then
	echo "${KICKSTART_TEMPLATE} not found"
	exit 1
fi

#FILE check
for FILE in ${LOCATION}
do
        if [[ ! -r ${FILE} ]]
       	then
                echo "file ${FILE} not found"
                exit 2
        fi
done
	
for VM in $*
do

	IP_ADDR=$( grep -w ${VM} /etc/hosts | awk '{ print $1 }' | head -n 1 )

	if [[ x${IP_ADDR} = x ]]
	then
		echo "IP address for ${VM} not found in /etc/hosts"
		exit 1
	else
		echo "${VM} : ${IP_ADDR}"
	fi

	VM_HOSTNAME=${VM}

	DISK="/var/lib/libvirt/images/${VM}.qcow2"
	#INITRD_INJECT="/data/kickstart/centos8.ks.cfg"
	INITRD_INJECT=$( pwd )/centos8.${VM}.ks.cfg
	EXTRA_ARGS="inst.ks=file:/$(basename ${INITRD_INJECT}) console=ttyS0"
	#EXTRA_ARGS="ks=file:/$(basename ${INITRD_INJECT}) console=ttyS0"
	
	#INITRD_INJECT Generation
	cat ${KICKSTART_TEMPLATE} | sed 's/IP_ADDR/'${IP_ADDR}'/g' | sed 's/VM_HOSTNAME/'${VM_HOSTNAME}'/g' > ${INITRD_INJECT}
	
	#DIR check
	for DIR in $( dirname ${DISK} )
	do
	   	if [[ ! -d ${DIR} ]]
	        then
	                echo "directory ${DIR} not found"
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
	echo "Installing ${VM}..."
	echo
	
	echo virt-install \
	        --name ${VM} \
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
	        --name ${VM} \
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


done

echo
echo "Done!"

