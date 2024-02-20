# Switch Action

## How to use

### GitHub Actions
1. Fork your own copy and edit `config.env`.
2. Click `Actions` > `Buddle sdmc` > `Run workflows`.
3. Download `sdmc.zip` and unzip it to your sdcard.

### Shell
1. Clone this repo and edit `config.env`.
2. Put your own files in the `custom` folder. They will merge into the `sdmc` folder in the next step.
3. Run `start.sh`.
4. Copy files in the `sdmc` folder to your sdcard.

## Features
### [hekate - Nyx](https://github.com/CTCaer/hekate)

| Config option | Description |
| - | - |
| HEKATE_RELEASE | Custom release of hekate |

### [Atmosphère](https://github.com/Atmosphere-NX/Atmosphere)
- Place fusée in `sdmc:/bootloader/payloads`

| Config option | Description |
| - | - |
| ATMOSPHERE_RELEASE | Custom release of Atmosphère |
| CFW_EMU_BOOT | Add `Atmosphère emuMMC` boot entry in `sdmc:/bootloader/hekate_ipl.ini` |
| CFW_SYS_BOOT | Add `Atmosphère sysMMC` boot entry in `sdmc:/bootloader/hekate_ipl.ini` |
| OFW_SYS_BOOT | Add `Stock sysMMC` boot entry in `sdmc:/bootloader/hekate_ipl.ini` |
| DNS_MITM_EMU | Enable DNS.mitm for `emuMMC` in `sdmc:/atmosphere/hosts/emummc.txt` |
| DNS_MITM_SYS | Enable DNS.mitm for `sysMMC` in `sdmc:/atmosphere/hosts/sysmmc.txt` |
| ENABLE_EXOSPHERE | Use Exosphère config template in `sdmc:/exosphere.ini` |
| BLANK_PRODINFO_EMU | Blank prodinfo for `emuMMC` in `sdmc:/exosphere.ini` |
| BLANK_PRODINFO_SYS | Blank prodinfo for `sysMMC` in `sdmc:/exosphere.ini` |

### Payloads
- Place payloads in `sdmc:/bootloader/payloads`
- [x] [Lockpick_RCM](https://github.com/Decscots/Lockpick_RCM)
- [x] [TegraExplorer](https://github.com/suchmememanyskill/TegraExplorer)

| Config option | Description |
| - | - |
| {PAYLOAD}_RELEASE | Custom release of payload |

### Homebrew Applications
- Place applications in `sdmc:/switch`
- [x] [Goldleaf](https://github.com/XorTroll/Goldleaf)
- [x] [JKSV](https://github.com/J-D-K/JKSV)

| Config option | Description |
| - | - |
| {APPLICATION}_RELEASE | Custom release of application |
