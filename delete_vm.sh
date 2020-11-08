#!/bin/sh

if [[ $1 = "help" ]]
then
	echo "./$(basename $0) [KVM_DomainName|ALL]"
	exit 1
fi

NAME=$1

if [[ ${NAME} = "ALL" ]]
then
	VMS=$( virsh list --all | tail -n +3 | awk '{ print $2 }' | tr "\n" " " )
else
	VMS=$*
fi

for VM in ${VMS}
do
	VMNUM=$( virsh list --all | grep -w -c ${VM} )
	if [[ ${VMNUM} != 1 ]]
	then
		echo "VM (${VM}) not found"
		exit 1
	fi

	echo "VM: ${VM}"

	echo "Disable autostart"	
	virsh autostart --disable ${VM}

	echo "Undefine ${VM}"
	virsh undefine ${VM}

	VOLNAME=$( virsh vol-list default | grep -w ${VM} | awk '{ print $1 }' )
	echo "Delete Volume : ${VOLNAME} for ${VM}"
	virsh vol-delete --pool default ${VOLNAME}

	echo
done

echo
echo "Done!"

