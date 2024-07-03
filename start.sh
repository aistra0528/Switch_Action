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
ENABLE_TESLA=$(cat config.env | grep -w "ENABLE_TESLA" | head -n 1 | cut -d "=" -f 2)
TESLA_LOADER_RELEASE=$(cat config.env | grep -w "TESLA_LOADER_RELEASE" | head -n 1 | cut -d "=" -f 2)
TESLA_MENU_RELEASE=$(cat config.env | grep -w "TESLA_MENU_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_LOCKPICK_RCM=$(cat config.env | grep -w "ENABLE_LOCKPICK_RCM" | head -n 1 | cut -d "=" -f 2)
LOCKPICK_RCM_RELEASE=$(cat config.env | grep -w "LOCKPICK_RCM_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_TEGRA_EXPLORER=$(cat config.env | grep -w "ENABLE_TEGRA_EXPLORER" | head -n 1 | cut -d "=" -f 2)
TEGRA_EXPLORER_RELEASE=$(cat config.env | grep -w "TEGRA_EXPLORER_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_GOLDLEAF=$(cat config.env | grep -w "ENABLE_GOLDLEAF" | head -n 1 | cut -d "=" -f 2)
GOLDLEAF_RELEASE=$(cat config.env | grep -w "GOLDLEAF_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_JKSV=$(cat config.env | grep -w "ENABLE_JKSV" | head -n 1 | cut -d "=" -f 2)
JKSV_RELEASE=$(cat config.env | grep -w "JKSV_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_WILIWILI=$(cat config.env | grep -w "ENABLE_WILIWILI" | head -n 1 | cut -d "=" -f 2)
WILIWILI_RELEASE=$(cat config.env | grep -w "WILIWILI_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_STATUS_MONITOR=$(cat config.env | grep -w "ENABLE_STATUS_MONITOR" | head -n 1 | cut -d "=" -f 2)
STATUS_MONITOR_RELEASE=$(cat config.env | grep -w "STATUS_MONITOR_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_SYS_CLK=$(cat config.env | grep -w "ENABLE_SYS_CLK" | head -n 1 | cut -d "=" -f 2)
SYS_CLK_RELEASE=$(cat config.env | grep -w "SYS_CLK_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_EMUIIBO=$(cat config.env | grep -w "ENABLE_EMUIIBO" | head -n 1 | cut -d "=" -f 2)
EMUIIBO_RELEASE=$(cat config.env | grep -w "EMUIIBO_RELEASE" | head -n 1 | cut -d "=" -f 2)

echo "Preparing..."
rm -r ./sdmc/

curl -sL $HEKATE_RELEASE \
  | jq '.tag_name' \
  | xargs -I {} echo "Downloading hekate & Nyx: {}"
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
    curl -sL $ATMOSPHERE_RELEASE \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading Atmosphère: {}"
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

if [ $ENABLE_TESLA = "true" ]; then
    curl -sL $TESLA_LOADER_RELEASE \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading nx-ovlloader: {}"
    curl -sL $TESLA_LOADER_RELEASE \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o nx-ovlloader.zip
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Unzipping files..."
        unzip -uq nx-ovlloader.zip -d ./sdmc/
        rm nx-ovlloader.zip
        echo "Imported: nx-ovlloader"
    fi
    curl -sL $TESLA_MENU_RELEASE \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading Tesla-Menu: {}"
    curl -sL $TESLA_MENU_RELEASE \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o ovlmenu.zip
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Unzipping files..."
        unzip -uq ovlmenu.zip -d ./sdmc/
        rm ovlmenu.zip
        echo "Overlay Imported: Tesla-Menu"
    fi
fi

if [ $ENABLE_LOCKPICK_RCM = "true" ]; then
    curl -sL $LOCKPICK_RCM_RELEASE \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading Lockpick_RCM: {}"
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
    curl -sL $TEGRA_EXPLORER_RELEASE \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading TegraExplorer: {}"
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
    curl -sL $GOLDLEAF_RELEASE \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading Goldleaf: {}"
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
    curl -sL $JKSV_RELEASE \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading JKSV: {}"
    curl -sL $JKSV_RELEASE \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o ./sdmc/switch/JKSV.nro
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Application imported: JKSV"
    fi
fi

if [ $ENABLE_WILIWILI = "true" ]; then
    curl -sL $WILIWILI_RELEASE \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading wiliwili: {}"
    curl -sL $WILIWILI_RELEASE \
      | jq '.assets' | jq '.[8].browser_download_url' \
      | xargs -I {} curl -sL {} -o wiliwili.zip
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Unzipping files..."
        unzip -uqj wiliwili.zip "wiliwili/wiliwili.nro" -d ./sdmc/switch/
        rm wiliwili.zip
        echo "Application imported: wiliwili"
    fi
fi

if [ $ENABLE_STATUS_MONITOR = "true" ]; then
    curl -sL $STATUS_MONITOR_RELEASE \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading Status Monitor Overlay: {}"
    curl -sL $STATUS_MONITOR_RELEASE \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o Status-Monitor-Overlay.zip
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Unzipping files..."
        unzip -uq Status-Monitor-Overlay.zip -d ./sdmc/
        rm Status-Monitor-Overlay.zip
        echo "Overlay Imported: Status Monitor Overlay"
    fi
fi

if [ $ENABLE_SYS_CLK = "true" ]; then
    curl -sL $SYS_CLK_RELEASE \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading sys-clk: {}"
    curl -sL $SYS_CLK_RELEASE \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o sys-clk.zip
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Unzipping files..."
        unzip -uq sys-clk.zip -d ./sdmc/
        rm sys-clk.zip
        echo "Overlay Imported: sys-clk"
    fi
fi

if [ $ENABLE_EMUIIBO = "true" ]; then
    curl -sL $EMUIIBO_RELEASE \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading emuiibo: {}"
    curl -sL $EMUIIBO_RELEASE \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o emuiibo.zip
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Unzipping files..."
        unzip -uq emuiibo.zip -d ./sdmc/
        rm emuiibo.zip
        mv -f ./sdmc/SdOut/* ./sdmc/
        rm -r ./sdmc/SdOut/
        echo "Overlay Imported: emuiibo"
    fi
fi

echo "Merge custom into sdmc..."
rsync -rv --exclude ".gitkeep" ./custom/ ./sdmc

echo "All prepared."
