#!/bin/bash
set -eou pipefail

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
ENABLE_SPHAIRA=$(cat config.env | grep -w "ENABLE_SPHAIRA" | head -n 1 | cut -d "=" -f 2)
SPHAIRA_RELEASE=$(cat config.env | grep -w "SPHAIRA_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_GOLDLEAF=$(cat config.env | grep -w "ENABLE_GOLDLEAF" | head -n 1 | cut -d "=" -f 2)
GOLDLEAF_RELEASE=$(cat config.env | grep -w "GOLDLEAF_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_JKSV=$(cat config.env | grep -w "ENABLE_JKSV" | head -n 1 | cut -d "=" -f 2)
JKSV_RELEASE=$(cat config.env | grep -w "JKSV_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_WILIWILI=$(cat config.env | grep -w "ENABLE_WILIWILI" | head -n 1 | cut -d "=" -f 2)
WILIWILI_RELEASE=$(cat config.env | grep -w "WILIWILI_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_STATUS_MONITOR=$(cat config.env | grep -w "ENABLE_STATUS_MONITOR" | head -n 1 | cut -d "=" -f 2)
STATUS_MONITOR_RELEASE=$(cat config.env | grep -w "STATUS_MONITOR_RELEASE" | head -n 1 | cut -d "=" -f 2)
SALTYNX_RELEASE=$(cat config.env | grep -w "SALTYNX_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_SYS_CLK=$(cat config.env | grep -w "ENABLE_SYS_CLK" | head -n 1 | cut -d "=" -f 2)
SYS_CLK_RELEASE=$(cat config.env | grep -w "SYS_CLK_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_QUICK_NTP=$(cat config.env | grep -w "ENABLE_QUICK_NTP" | head -n 1 | cut -d "=" -f 2)
QUICK_NTP_RELEASE=$(cat config.env | grep -w "QUICK_NTP_RELEASE" | head -n 1 | cut -d "=" -f 2)
ENABLE_EMUIIBO=$(cat config.env | grep -w "ENABLE_EMUIIBO" | head -n 1 | cut -d "=" -f 2)
EMUIIBO_RELEASE=$(cat config.env | grep -w "EMUIIBO_RELEASE" | head -n 1 | cut -d "=" -f 2)

echo "Preparing..."
rm -r ./sdmc/

release=$(curl -sL $HEKATE_RELEASE)
echo $release \
  | jq '.tag_name' \
  | xargs -I {} echo "Downloading hekate & Nyx: {}"
echo $release \
  | jq '.assets' | jq '.[1].browser_download_url' \
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
    release=$(curl -sL $ATMOSPHERE_RELEASE)
    echo $release \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading Atmosphère: {}"
    echo $release \
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
    release=$(curl -sL $TESLA_LOADER_RELEASE)
    echo $release \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading nx-ovlloader: {}"
    echo $release \
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
    release=$(curl -sL $TESLA_MENU_RELEASE)
    echo $release \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading Tesla-Menu: {}"
    echo $release \
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
    release=$(curl -sL $LOCKPICK_RCM_RELEASE)
    echo $release \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading Lockpick_RCM: {}"
    echo $release \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o Lockpick_RCM.zip
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Unzipping files..."
        unzip -uq Lockpick_RCM.zip -d ./sdmc/bootloader/payloads/
        rm Lockpick_RCM.zip
        echo "Payload imported: Lockpick_RCM"
    fi
fi

if [ $ENABLE_TEGRA_EXPLORER = "true" ]; then
    release=$(curl -sL $TEGRA_EXPLORER_RELEASE)
    echo $release \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading TegraExplorer: {}"
    echo $release \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o ./sdmc/bootloader/payloads/TegraExplorer.bin
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Payload imported: TegraExplorer"
    fi
fi

if [ $ENABLE_SPHAIRA = "true" ]; then
    release=$(curl -sL $SPHAIRA_RELEASE)
    echo $release \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading Sphaira: {}"
    echo $release \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o sphaira.zip
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Unzipping files..."
        unzip -uq sphaira.zip -d ./sdmc/
        rm sphaira.zip
        echo "Application imported: Sphaira"
    fi
fi

if [ $ENABLE_GOLDLEAF = "true" ]; then
    release=$(curl -sL $GOLDLEAF_RELEASE)
    echo $release \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading Goldleaf: {}"
    echo $release \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o ./sdmc/switch/Goldleaf.nro
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Application imported: Goldleaf"
    fi
fi

if [ $ENABLE_JKSV = "true" ]; then
    release=$(curl -sL $JKSV_RELEASE)
    echo $release \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading JKSV: {}"
    echo $release \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o ./sdmc/switch/JKSV.nro
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Application imported: JKSV"
    fi
fi

if [ $ENABLE_WILIWILI = "true" ]; then
    release=$(curl -sL $WILIWILI_RELEASE)
    echo $release \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading wiliwili: {}"
    echo $release \
      | jq '.assets' | jq '.[9].browser_download_url' \
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
    release=$(curl -sL $STATUS_MONITOR_RELEASE)
    echo $release \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading Status Monitor Overlay: {}"
    echo $release \
      | jq '.assets' | jq '.[1].browser_download_url' \
      | xargs -I {} curl -sL {} -o Status-Monitor-Overlay.zip
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Unzipping files..."
        unzip -uq Status-Monitor-Overlay.zip -d ./sdmc/
        rm Status-Monitor-Overlay.zip
        echo "Overlay Imported: Status Monitor Overlay"
    fi
    release=$(curl -sL $SALTYNX_RELEASE)
    echo $release \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading SaltyNX: {}"
    echo $release \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o SaltyNX.zip
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Unzipping files..."
        unzip -uq SaltyNX.zip -d ./sdmc/
        rm SaltyNX.zip
        echo "Imported: SaltyNX"
    fi
fi

if [ $ENABLE_SYS_CLK = "true" ]; then
    release=$(curl -sL $SYS_CLK_RELEASE)
    echo $release \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading sys-clk: {}"
    echo $release \
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

if [ $ENABLE_QUICK_NTP = "true" ]; then
    release=$(curl -sL $QUICK_NTP_RELEASE)
    echo $release \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading QuickNTP: {}"
    echo $release \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o quickntp.zip
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Unzipping files..."
        unzip -uq quickntp.zip -d ./sdmc/
        rm quickntp.zip
        echo "Overlay Imported: QuickNTP"
    fi
fi

if [ $ENABLE_EMUIIBO = "true" ]; then
    release=$(curl -sL $EMUIIBO_RELEASE)
    echo $release \
      | jq '.tag_name' \
      | xargs -I {} echo "Downloading emuiibo: {}"
    echo $release \
      | jq '.assets' | jq '.[0].browser_download_url' \
      | xargs -I {} curl -sL {} -o emuiibo.zip
    if [ $? -ne 0 ]; then
        echo "Download failed."
    else
        echo "Unzipping files..."
        unzip -uq emuiibo.zip -d ./sdmc/
        rm emuiibo.zip
        cp -r ./sdmc/SdOut/* ./sdmc/
        rm -r ./sdmc/SdOut/
        echo "Overlay Imported: emuiibo"
    fi
fi

echo "Merge custom into sdmc..."
rsync -rv --exclude ".gitkeep" ./custom/ ./sdmc

echo "All prepared."
