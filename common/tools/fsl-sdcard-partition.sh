#!/bin/bash

# files to be put into sd-card partition
waveform="epdc_E060SCM.fw"
logo="nx_logo.bmp"

# partition size in MB
BOOTLOAD_RESERVE=8
BOOT_ROM_SIZE=8
SYSTEM_ROM_SIZE=512
CACHE_SIZE=512
RECOVERY_ROM_SIZE=8
VENDER_SIZE=8
MISC_SIZE=8

help() {

bn=`basename $0`
cat << EOF
usage $bn <option> device_node

options:
  -h				displays this help message
  -s				only get partition size
  -np 				not partition.
  -f 				flash android image.
EOF

}



# parse command line
moreoptions=1
node="na"
cal_only=0
flash_images=0
not_partition=0
not_format_fs=0
while [ "$moreoptions" = 1 -a $# -gt 0 ]; do
	case $1 in
	    -h) help; exit ;;
	    -s) cal_only=1 ;;
	    -f) flash_images=1 ;;
	    -np) not_partition=1 ;;
	    -nf) not_format_fs=1 ;;
	    *)  moreoptions=0; node=$1 ;;
	esac
	[ "$moreoptions" = 0 ] && [ $# -gt 1 ] && help && exit
	[ "$moreoptions" = 1 ] && shift
done

if [ ! -e ${node} ]; then
	help
	exit
fi


# call sfdisk to create partition table
# get total card size
seprate=40
total_size=`sudo sfdisk -s ${node}`
total_size=`expr ${total_size} / 1024`
boot_rom_sizeb=`expr ${BOOT_ROM_SIZE} + ${BOOTLOAD_RESERVE}`
extend_size=`expr ${SYSTEM_ROM_SIZE} + ${CACHE_SIZE} + ${VENDER_SIZE} + ${MISC_SIZE} + ${seprate}`
data_size=`expr ${total_size} - ${boot_rom_sizeb} - ${RECOVERY_ROM_SIZE} - ${extend_size} + ${seprate}`

# create partitions
if [ "${cal_only}" -eq "1" ]; then
cat << EOF
BOOT   : ${boot_rom_sizeb}MB
RECOVERY: ${RECOVERY_ROM_SIZE}MB
SYSTEM : ${SYSTEM_ROM_SIZE}MB
CACHE  : ${CACHE_SIZE}MB
DATA   : ${data_size}MB
MISC   : ${MISC_SIZE}MB
EOF
exit
fi

function format_android
{
    echo "formating android images"
    sudo mkfs.ext4 ${node}${part}4 -Ldata
    sudo mkfs.ext4 ${node}${part}5 -Lsystem
    sudo mkfs.ext4 ${node}${part}6 -Lcache
    sudo mkfs.ext4 ${node}${part}7 -Lvender
    sudo mkdir -p /media/tmp
    sudo mount ${node}${part}4 /media/tmp
    amount=$(df -k | grep ${node}${part}4 | awk '{print $2}')
    stag=$amount
    stag=$((stag-32))
    kilo=K
    amountkilo=$stag$kilo
    sleep 1s
    sudo umount /media/tmp
    sudo rm -rf /media/tmp
    sudo e2fsck -f ${node}${part}4
    sudo resize2fs ${node}${part}4 $amountkilo
}

function flash_android
{
if [ "${flash_images}" -eq "1" ]; then
    echo "flashing android images..."    
    sudo dd if=/dev/zero of=${node} bs=512 seek=1536 count=16
    sudo dd if=boot.img of=${node}${part}1
    sudo dd if=recovery.img of=${node}${part}2
    sudo dd if=system.img of=${node}${part}5
    sudo dd if=u-boot.bin of=${node} bs=1k seek=1 skip=1
    sudo dd if=${waveform} of=${node} bs=1M seek=1 conv=fsync
    sudo dd if=${logo} of=${node} bs=1M seek=7 conv=fsync
fi
}

if [[ "${not_partition}" -eq "1" && "${flash_images}" -eq "1" ]] ; then
    flash_android
    exit
fi

# destroy the partition table
sudo dd if=/dev/zero of=${node} bs=1024 count=1

sudo sfdisk --force -uM ${node} << EOF
,${boot_rom_sizeb},83
,${RECOVERY_ROM_SIZE},83
,${extend_size},5
,${data_size},83
,${SYSTEM_ROM_SIZE},83
,${CACHE_SIZE},83
,${VENDER_SIZE},83
,${MISC_SIZE},83
EOF

# adjust the partition reserve for bootloader.
# if you don't put the uboot on same device, you can remove the BOOTLOADER_ERSERVE
# to have 8M space.
# the minimal sylinder for some card is 4M, maybe some was 8M
# just 8M for some big eMMC 's sylinder
sudo sfdisk --force -uM ${node} -N1 << EOF
${BOOTLOAD_RESERVE},${BOOT_ROM_SIZE},83
EOF

# format the SDCARD/DATA/CACHE partition
part=""
echo ${node} | grep mmcblk > /dev/null
if [ "$?" -eq "0" ]; then
	part="p"
fi

format_android
flash_android


# For MFGTool Notes:
# MFGTool use mksdcard-android.tar store this script
# if you want change it.
# do following:
#   tar xf mksdcard-android.sh.tar
#   vi mksdcard-android.sh 
#   [ edit want you want to change ]
#   rm mksdcard-android.sh.tar; tar cf mksdcard-android.sh.tar mksdcard-android.sh
