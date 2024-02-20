#!/bin/bash

HEKATE_RELEASE=$(cat config.env | grep -w "HEKATE_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_ATMOSPHERE=$(cat config.env | grep -w "ENABLE_ATMOSPHERE" | head -n 1 | cut -d "=" -f 2)
ATMOSPHERE_RELEASE=$(cat config.env | grep -w "ATMOSPHERE_RELEASE" | head -n 1 | cut -d "=" -f 2)
CFW_EMU_BOOT=$(cat config.env | grep -w "CFW_EMU_BOOT" | head -n 1 | cut -d "=" -f 2)
CFW_SYS_BOOT=$(cat config.env | grep -w "CFW_SYS_BOOT" | head -n 1 | cut -d "=" -f 2)
OFW_SYS_BOOT=$(cat config.env | grep -w "OFW_SYS_BOOT" | head -n 1 | cut -d "=" -f 2)
DNS_MITM_EMU=$(cat config.env | grep -w "DNS_MITM_EMU" | head -n 1 | cut -d "=" -f 2)
DNS_MITM_SYS=$(cat config.env | grep -w "DNS_MITM_SYS" | head -n 1 | cut -d "=" -f 2)
ENABLE_EXOSPHERE=$(cat config.env | grep -w "ENABLE_EXOSPHERE" | head -n 1 | cut -d "=" -f 2)
BLANK_PRODINFO_EMU=$(cat config.env | grep -w "BLANK_PRODINFO_EMU" | head -n 1 | cut -d "=" -f 2)
BLANK_PRODINFO_SYS=$(cat config.env | grep -w "BLANK_PRODINFO_SYS" | head -n 1 | cut -d "=" -f 2)
ENABLE_LOCKPICK_RCM=$(cat config.env | grep -w "ENABLE_LOCKPICK_RCM" | head -n 1 | cut -d "=" -f 2)
LOCKPICK_RCM_RELEASE=$(cat config.env | grep -w "LOCKPICK_RCM_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_TEGRA_EXPLORER=$(cat config.env | grep -w "ENABLE_TEGRA_EXPLORER" | head -n 1 | cut -d "=" -f 2)
TEGRA_EXPLORER_RELEASE=$(cat config.env | grep -w "TEGRA_EXPLORER_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_GOLDLEAF=$(cat config.env | grep -w "ENABLE_GOLDLEAF" | head -n 1 | cut -d "=" -f 2)
GOLDLEAF_RELEASE=$(cat config.env | grep -w "GOLDLEAF_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_JKSV=$(cat config.env | grep -w "ENABLE_JKSV" | head -n 1 | cut -d "=" -f 2)
JKSV_RELEASE=$(cat config.env | grep -w "JKSV_RELEASE" | head -n 1 | cut -d "=" -f 2)

echo "Preparing..."
rm -r ./sdmc/

echo "Downloading hekate & Nyx..."
curl -sL $HEKATE_RELEASE \
  | jq '.assets' | jq '.[0].browser_download_url' \
  | xargs -I {} curl -sL {} -o hekate.zip
if [ $? -ne 0 ]; then
    echo "Download failed."
else
    echo "Unzipping files..."
    unzip -uq hekate.zip "bootloader/*" -d ./sdmc/
    rm hekate.zip
    echo "Importing hekate config..."
    cp ./res/hekate_ipl_config.ini ./sdmc/bootloader/hekate_ipl.ini
fi

if [ $ENABLE_ATMOSPHERE = "true" ]; then
    echo "Downloading Atmosphère..."
    curl -sL $ATMOSPHERE_RELEASE \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o atmosphere.zip
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Unzipping files..."
        unzip -uq atmosphere.zip -d ./sdmc/
        rm atmosphere.zip
        cp ./sdmc/atmosphere/reboot_payload.bin ./sdmc/bootloader/payloads/fusee.bin
        echo "Payload imported: fusée"
        if [ $CFW_EMU_BOOT = "true" ]; then
            echo "Updating hekate config: Atmosphère emuMMC"
            cp ./res/cfw_emu.bmp ./sdmc/bootloader/res/cfw_emu.bmp
            cat ./res/cfw_emu.ini >> ./sdmc/bootloader/hekate_ipl.ini
        fi
        if [ $CFW_SYS_BOOT = "true" ]; then
            echo "Updating hekate config: Atmosphère sysMMC"
            cp ./res/cfw_sys.bmp ./sdmc/bootloader/res/cfw_sys.bmp
            cat ./res/cfw_sys.ini >> ./sdmc/bootloader/hekate_ipl.ini
        fi
        if [ $OFW_SYS_BOOT = "true" ]; then
            echo "Updating hekate config: Stock sysMMC"
            cp ./res/ofw_sys.bmp ./sdmc/bootloader/res/ofw_sys.bmp
            cat ./res/ofw_sys.ini >> ./sdmc/bootloader/hekate_ipl.ini
        fi
        if [ $DNS_MITM_EMU = "true" ]; then
            mkdir -p ./sdmc/atmosphere/hosts
            cp ./res/hosts.txt ./sdmc/atmosphere/hosts/emummc.txt
            echo "DNS.mitm enabled for emuMMC."
        fi
        if [ $DNS_MITM_SYS = "true" ]; then
            mkdir -p ./sdmc/atmosphere/hosts
            cp ./res/hosts.txt ./sdmc/atmosphere/hosts/sysmmc.txt
            echo "DNS.mitm enabled for sysMMC."
        fi
        if [ $ENABLE_EXOSPHERE = "true" ]; then
            echo "Importing Exosphère config..."
            cp ./sdmc/atmosphere/config_templates/exosphere.ini ./sdmc/exosphere.ini
            if [ $BLANK_PRODINFO_EMU = "true" ]; then
                sed -i "s/blank_prodinfo_emummc=0/blank_prodinfo_emummc=1/g" ./sdmc/exosphere.ini
                echo "Blank prodinfo for emuMMC."
            fi
            if [ $BLANK_PRODINFO_SYS = "true" ]; then
                sed -i "s/blank_prodinfo_sysmmc=0/blank_prodinfo_sysmmc=1/g" ./sdmc/exosphere.ini
                echo "Blank prodinfo for sysMMC."
            fi
        fi
    fi
fi

if [ $ENABLE_LOCKPICK_RCM = "true" ]; then
    echo "Downloading Lockpick_RCM..."
    curl -sL $LOCKPICK_RCM_RELEASE \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o ./sdmc/bootloader/payloads/Lockpick_RCM.bin
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Payload imported: Lockpick_RCM"
    fi
fi

if [ $ENABLE_TEGRA_EXPLORER = "true" ]; then
    echo "Downloading TegraExplorer..."
    curl -sL $TEGRA_EXPLORER_RELEASE \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o ./sdmc/bootloader/payloads/TegraExplorer.bin
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Payload imported: TegraExplorer"
    fi
fi

if [ $ENABLE_GOLDLEAF = "true" ]; then
    echo "Downloading Goldleaf..."
    curl -sL $GOLDLEAF_RELEASE \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o ./sdmc/switch/Goldleaf.nro
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Application imported: Goldleaf"
    fi
fi

if [ $ENABLE_JKSV = "true" ]; then
    echo "Downloading JKSV..."
    curl -sL $JKSV_RELEASE \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o ./sdmc/switch/JKSV.nro
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Application imported: JKSV"
    fi
fi

echo "Merge custom into sdmc..."
rsync -rv --exclude ".gitkeep" ./custom/ ./sdmc

echo "All prepared."
