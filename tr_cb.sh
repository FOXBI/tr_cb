#!/bin/bash
ver="0.9.9-r02"
#
# Made by FOXBI
# 2022.04.27
#
# ==============================================================================
# Y or N Function
# ==============================================================================
READ_YN () { # $1:question $2:default
   read -n1 -p "$1" Y_N
    case "$Y_N" in
    y) Y_N="y"
         echo -e "\n" ;;
    n) Y_N="n"
         echo -e "\n" ;;        
    q) echo -e "\n"
       exit 0 ;;
    *) echo -e "\n" ;;
    esac
}
# ==============================================================================
# Color Function
# ==============================================================================
cecho () {
    if [ -n "$3" ]
    then
        case "$3" in
            black  | bk) bgcolor="40";;
            red    |  r) bgcolor="41";;
            green  |  g) bgcolor="42";;
            yellow |  y) bgcolor="43";;
            blue   |  b) bgcolor="44";;
            purple |  p) bgcolor="45";;
            cyan   |  c) bgcolor="46";;
            gray   | gr) bgcolor="47";;
        esac        
    else
        bgcolor="0"
    fi
    code="\033["
    case "$1" in
        black  | bk) color="${code}${bgcolor};30m";;
        red    |  r) color="${code}${bgcolor};31m";;
        green  |  g) color="${code}${bgcolor};32m";;
        yellow |  y) color="${code}${bgcolor};33m";;
        blue   |  b) color="${code}${bgcolor};34m";;
        purple |  p) color="${code}${bgcolor};35m";;
        cyan   |  c) color="${code}${bgcolor};36m";;
        gray   | gr) color="${code}${bgcolor};37m";;
    esac

    text="$color$2${code}0m"
    echo -e "$text"
}
# ==============================================================================
# Extra Boot image or USB Create Action
# ==============================================================================
clear
CURDIR=`pwd`
if [ "$CURDIR" != "/home/tc" ]
then
    cd /home/tc
    CURDIR=`pwd`
fi
echo ""
cecho c "Tinycore Rploader Create Boot Image & USB ver. \033[0;31m"$ver"\033[00m - FOXBI"
echo ""
UCHK=`lsblk -So NAME,TRAN | grep usb | awk '{print $1}'`
if [ "$UCHK" == "" ]
then
    PCHK=`sudo fdisk -l | grep "*" | grep "dev" | grep -v "img" | awk '{print $1}' | sed "s/\/dev\///g"`
else
    PCHK=`sudo fdisk -l | grep "*" | grep "dev" | grep -v "img" | grep -v "$UCHK" | awk '{print $1}' | sed "s/\/dev\///g"`
fi

if [ ! -d /mnt/$PCHK/boot/grub ]
then
    sudo mount /dev/$PCHK
fi

FNAME=`cat /mnt/$PCHK/boot/grub/grub.cfg | grep menuentry | head -1 | awk '{print $3"_"$4}'`
if [ "$FNAME" == "Core_Image" ]
then
    echo ""
    echo "The built bootloader does not exist. please run again after build..."
    echo ""    
    exit 0
else
    echo ""
    cecho c "Extra Boot image or USB Create"
    echo ""
    READ_YN "Do you want Extra boot image create ? Y/N : "
    EXCHK=$Y_N
    MCHK="/mnt/tmp"
    if [ "$EXCHK" == "y" ] || [ "$EXCHK" == "Y" ]
    then
        echo ""
        cecho c "Now Select Create *.img or USB Create"
        echo ""    
        echo "1) ${FNAME}.img   2) ${FNAME} Boot USB Create"
        echo ""
        read -n2 -p " -> Select Number Enter : " X_O
        echo ""
        RCHK=`echo $PCHK | sed "s/[0-9].*$//g"`
        if [ "$X_O" == "1" ]
        then
            echo ""
            cecho c "Create /home/tc/${FNAME}.img"
            echo "" 
            sudo umount /dev/$PCHK > /dev/null 2>&1        
            sudo dd if=/dev/$RCHK of=/home/tc/${FNAME}.img count=292500 > /dev/null 2>&1

sudo fdisk /home/tc/${FNAME}.img > /dev/null 2>&1 << EOF
d
3

wq
EOF
sudo fdisk /home/tc/${FNAME}.img > /dev/null 2>&1 << EOF
n
p
3


n
wq
EOF
            sudo chown tc:staff /home/tc/${FNAME}.img

            echo ""
            cecho c "Config grub.cfg..."
            echo "" 
            sleep 1
            SCHK=`fdisk -l ${FNAME}.img | grep "*" | grep img | awk '{print $3}'`
            sudo mkdir -p $MCHK
            sudo mount -o loop,offset=$((512*$SCHK)) ${FNAME}.img $MCHK > /dev/null 2>&1  

            LNUM=`cat $MCHK/boot/grub/grub.cfg | grep -n "Tiny Core Image Build" | awk -F: '{print $1}'`
            if [ "$LNUM" != "" ]
            then
                sudo sed -i "$LNUM,\$d" $MCHK/boot/grub/grub.cfg
            fi
            sudo umount $MCHK > /dev/null 2>&1  

            echo ""
            cecho c "Create completed /home/tc/${FNAME}.img"
            echo "" 
            read -n1 -p "When the SFTP download is complete, press any key."
            echo ""
        elif [ "$X_O" == "2" ]
        then
            if [ "$UCHK" == "" ]
            then
                echo ""
                echo "Do not Ready USB...Check Please..."
                echo ""    
            else
                echo ""
                cecho c "Create $FNAME Bootable USB(/dev/$UCHK) - Takes a few seconds..."
                echo "" 
                sudo umount /dev/$PCHK > /dev/null 2>&1   
                sudo dd if=/dev/$RCHK of=/dev/$UCHK count=292500 > /dev/null 2>&1

sudo fdisk /dev/$UCHK > /dev/null 2>&1 << EOF
d
3

wq
EOF

sudo fdisk /dev/$UCHK > /dev/null 2>&1 << EOF
n
p
3


n
wq
EOF

                echo ""
                cecho c "Config grub.cfg..."
                echo "" 

                LCHK=`find /sys -name $UCHK | grep usb`
                cd $LCHK
                cd ../../../../../../
                PID=`cat idProduct`
                VID=`cat idVendor`
                sleep 1
                BCHK=`fdisk -l /dev/$UCHK | grep "*" | grep $UCHK | awk '{print $1}'`
                sudo mkdir -p $MCHK
                sudo mount $BCHK $MCHK

                LNUM=`cat $MCHK/boot/grub/grub.cfg | grep -n "Tiny Core Image Build" | awk -F: '{print $1}'`
                if [ "$LNUM" != "" ]
                then
                    sudo sed -i "$LNUM,\$d" $MCHK/boot/grub/grub.cfg
                fi

                sudo sed -i "s/pid=0x.... earlycon/pid=0x$PID earlycon/g" $MCHK/boot/grub/grub.cfg
                sudo sed -i "s/vid=0x.... elevator/vid=0x$VID elevator/g" $MCHK/boot/grub/grub.cfg
                sudo sed -i "s/default=\"1\"/default=\"0\"/g" $MCHK/boot/grub/grub.cfg
                sudo sed -i "s/hd1,msdos/hd0,msdos/g" $MCHK/boot/grub/grub.cfg
                sudo umount $MCHK > /dev/null 2>&1   

                echo ""
                cecho c "Create completed USB"
                echo "" 
                read -n1 -p "Proceed with DSM installation using USB. press any key."
                echo ""
            fi
        else
            echo ""
            echo "Wrong choice. please run again..."
            echo ""    
            exit 0    
        fi
    fi
fi   
# ==============================================================================
# End
# ==============================================================================