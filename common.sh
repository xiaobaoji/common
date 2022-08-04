#!/usr/bin/env bash
#====================================================
#!/bin/bash
# https://github.com/shidahuilang/openwrt
# common Module by 大灰狼
# matrix.target=${Modelfile}
#====================================================

function TIME() {
Compte=$(date +%Y年%m月%d号%H时%M分)
  [[ -z "$1" ]] && {
    echo -ne " "
    } || {
    case $1 in
    r) export Color="\e[31m";;
    g) export Color="\e[32m";;
    b) export Color="\e[34m";;
    y) export Color="\e[33m";;
    z) export Color="\e[35m";;
    l) export Color="\e[36m";;
    esac
      [[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
        echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
      }
    }
}

function Diy_repo_url() {
if [ -z "$(ls -A "${GITHUB_WORKSPACE}/build/${matrixtarget}/settings.ini" 2>/dev/null)" ]; then
  TIME r "错误提示：编译脚本缺少[settings.ini]名称的配置文件,请在[build/${matrixtarget}]文件夹内补齐"
  exit 1
else
  source "${GITHUB_WORKSPACE}/build/${matrixtarget}/settings.ini"
fi
echo "REPO_URL=${REPO_URL}" >> $GITHUB_ENV
echo "REPO_BRANCH=${REPO_BRANCH}" >> $GITHUB_ENV
echo "CONFIG_FILE=${CONFIG_FILE}" >> $GITHUB_ENV
echo "DIY_PART_SH=${DIY_PART_SH}" >> $GITHUB_ENV
echo "UPLOAD_CONFIG=${UPLOAD_CONFIG}" >> $GITHUB_ENV
echo "UPLOAD_FIRMWARE=${UPLOAD_FIRMWARE}" >> $GITHUB_ENV
echo "UPLOAD_WETRANSFER=${UPLOAD_WETRANSFER}" >> $GITHUB_ENV
echo "UPLOAD_RELEASE=${UPLOAD_RELEASE}" >> $GITHUB_ENV
echo "SERVERCHAN_SCKEY=${SERVERCHAN_SCKEY}" >> $GITHUB_ENV
echo "REGULAR_UPDATE=${REGULAR_UPDATE}" >> $GITHUB_ENV
echo "USE_CACHEWRTBUILD=${USE_CACHEWRTBUILD}" >> $GITHUB_ENV
echo "AUTOMATIC_AMLOGIC=${AUTOMATIC_AMLOGIC}" >> $GITHUB_ENV
echo "BY_INFORMATION=${BY_INFORMATION}" >> $GITHUB_ENV
echo "Library=${Warehouse##*/}" >> $GITHUB_ENV
echo "matrixtarget=${matrixtarget}" >> $GITHUB_ENV
}

function Diy_settings() {
echo "正在执行：随便判断一下是不是缺少文件了"
  [[ -d "${OP_DIY}" ]] && {
    if [ -z "$(ls -A "${OP_DIY}/${matrixtarget}/${CONFIG_FILE}" 2>/dev/null)" ]; then
      TIME r "错误提示：编译脚本缺少[${CONFIG_FILE}]名称的配置文件,请在[${OP_DIY}/${matrixtarget}]文件夹内补齐"
      exit 1
    fi
    if [ -z "$(ls -A "${OP_DIY}/${matrixtarget}/${DIY_PART_SH}" 2>/dev/null)" ]; then
      TIME r "错误提示：编译脚本缺少[${DIY_PART_SH}]名称的自定义设置文件,请在[${OP_DIY}/${matrixtarget}]文件夹内补齐"
      exit 1
    fi
    if [ -z "$(ls -A "${OP_DIY}/${matrixtarget}/settings.ini" 2>/dev/null)" ]; then
      TIME r "错误提示：编译脚本缺少[settings.ini]名称的设置文件,请在[${OP_DIY}/${matrixtarget}]文件夹内补齐"
      exit 1
    fi
  } || {
    if [ -z "$(ls -A "$GITHUB_WORKSPACE/build/${matrixtarget}/${CONFIG_FILE}" 2>/dev/null)" ]; then
      TIME r "错误提示：编译脚本缺少[${CONFIG_FILE}]名称的配置文件,请在[build/${matrixtarget}]文件夹内补齐"
      exit 1
    fi
    if [ -z "$(ls -A "$GITHUB_WORKSPACE/build/${matrixtarget}/${DIY_PART_SH}" 2>/dev/null)" ]; then
      TIME r "错误提示：编译脚本缺少[${DIY_PART_SH}]名称的自定义设置文件,请在[build/${matrixtarget}]文件夹内补齐"
      exit 1
    fi
  }
}

function Diy_update() {
sudo rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /usr/local/lib/android /usr/lib/jvm /opt/ghc
sudo -E apt-get -qq update -y
sudo -E apt-get -qq full-upgrade -y
sudo -E apt-get -qq install -y build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 lib32stdc++6 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl rename libpcap0.8-dev swig rsync
sudo -E apt-get -qq autoremove -y --purge
sudo -E apt-get -qq clean
sudo timedatectl set-timezone "$TZ"
sudo mkdir -p /${matrixtarget}
sudo chown $USER:$GROUPS /${matrixtarget}
if [[ "${matrixtarget}" == "openwrt_amlogic" ]]; then
docker rmi $(docker images -q)
sudo -E apt-get remove -y --purge azure-cli ghc zulu* hhvm llvm* firefox google* dotnet* powershell mysql* php* mssql-tools msodbcsql17 android*
sudo rm -rf /etc/mysql /etc/php /swapfile
fi
}

function Diy_variable() {
cp -Rf `find ./ -maxdepth 1 -type d ! -path './openwrt' ! -path './'` openwrt
echo "HOME_PATH=${GITHUB_WORKSPACE}/openwrt" >> $GITHUB_ENV
echo "BUILD_PATH=${GITHUB_WORKSPACE}/openwrt/build/${matrixtarget}" >> $GITHUB_ENV
echo "BASE_PATH=${GITHUB_WORKSPACE}/openwrt/package/base-files/files" >> $GITHUB_ENV
echo "NETIP=${GITHUB_WORKSPACE}/openwrt/package/base-files/files/etc/networkip" >> $GITHUB_ENV
echo "DELETE=${GITHUB_WORKSPACE}/openwrt/package/base-files/files/etc/deletefile" >> $GITHUB_ENV
echo "Convert_path=${GITHUB_WORKSPACE}/openwrt/build/common/Convert" >> $GITHUB_ENV
echo "Upgrade_Date=$(date +%Y%m%d%H%M)" >> $GITHUB_ENV
echo "Firmware_Date=$(date +%Y-%m%d-%H%M)" >> $GITHUB_ENV
echo "Compte_Date=$(date +%Y年%m月%d号%H时%M分)" >> $GITHUB_ENV
echo "Tongzhi_Date=$(date +%Y年%m月%d日)" >> $GITHUB_ENV


# github用的变量，如果有修改，下面Bendi_variable也要同步修改

if [[ "${REPO_BRANCH}" == "master" ]]; then
  echo "ZZZ_PATH=${GITHUB_WORKSPACE}/openwrt/package/lean/default-settings/files/zzz-default-settings" >> $GITHUB_ENV
  if [[ ! -f "${GITHUB_WORKSPACE}/openwrt/package/lean/default-settings/files/zzz-default-settings" ]]; then
    TIME r "上游源码作者修改了zzz-default-settings文件的路径或者名称，找编译脚本的作者及时修改"
    exit 1
  fi
  echo "SOURCE=Lede" >> $GITHUB_ENV
  echo "LUCI_EDITION=18.06" >> $GITHUB_ENV
  echo "MAINTAIN=Lean's" >> $GITHUB_ENV
  
  
elif [[ "${REPO_BRANCH}" == "22.03" ]]; then
  echo "ZZZ_PATH=${GITHUB_WORKSPACE}/openwrt/package/default-settings/files/zzz-default-settings" >> $GITHUB_ENV
  if [[ ! -f "${GITHUB_WORKSPACE}/openwrt/package/default-settings/files/zzz-default-settings" ]]; then
    TIME r "上游源码作者修改了zzz-default-settings文件的路径或者名称，找编译脚本的作者及时修改"
    exit 1
  fi
  echo "SOURCE=Lienol" >> $GITHUB_ENV
  echo "LUCI_EDITION=22.03" >> $GITHUB_ENV
  echo "MAINTAIN=Lienol's" >> $GITHUB_ENV
elif [[ "${REPO_BRANCH}" == "openwrt-18.06" ]]; then
  echo "ZZZ_PATH=${GITHUB_WORKSPACE}/openwrt/package/emortal/default-settings/files/99-default-settings" >> $GITHUB_ENV
  if [[ ! -f "${GITHUB_WORKSPACE}/openwrt/package/emortal/default-settings/files/99-default-settings" ]]; then
    TIME r "上游源码作者修改了zzz-default-settings文件的路径或者名称，找编译脚本的作者及时修改"
    exit 1
  fi
  echo "SOURCE=Tianling" >> $GITHUB_ENV
  echo "LUCI_EDITION=18.06" >> $GITHUB_ENV
  echo "MAINTAIN=CTCGFW's" >> $GITHUB_ENV
elif [[ "${REPO_BRANCH}" == "openwrt-21.02" ]]; then
  echo "ZZZ_PATH=${GITHUB_WORKSPACE}/openwrt/package/emortal/default-settings/files/99-default-settings" >> $GITHUB_ENV
  if [[ ! -f "${GITHUB_WORKSPACE}/openwrt/package/emortal/default-settings/files/99-default-settings" ]]; then
    TIME r "上游源码作者修改了zzz-default-settings文件的路径或者名称，找编译脚本的作者及时修改"
    exit 1
  fi
  echo "SOURCE=Mortal" >> $GITHUB_ENV
  echo "LUCI_EDITION=21.02" >> $GITHUB_ENV
  echo "MAINTAIN=CTCGFW's" >> $GITHUB_ENV
else
  echo "没发现该源码的分支，如果您没更改过的话，应该是上游仓库修改了，请同步上游仓库"
  exit 1
fi
}

function Bendi_variable() {
# 本地用的变量，如果上面Diy_variable有修改，下面也要同步修改
if [[ "${matrixtarget}" == "Lede_source" ]]; then
  export ZZZ_PATH="${HOME_PATH}/package/lean/default-settings/files/zzz-default-settings"
  if [[ ! -f "${ZZZ_PATH}" ]]; then
    TIME r "上游源码作者修改了zzz-default-settings文件的路径或者名称，找编译脚本的作者及时修改"
    exit 1
  fi
  export SOURCE="Lede"
  export LUCI_EDITION="18.06"
  

elif [[ "${matrixtarget}" == "Lienol_source" ]]; then
  export ZZZ_PATH="${HOME_PATH}/package/default-settings/files/zzz-default-settings"
  if [[ ! -f "${ZZZ_PATH}" ]]; then
    TIME r "上游源码作者修改了zzz-default-settings文件的路径或者名称，找编译脚本的作者及时修改"
    exit 1
  fi
  export SOURCE="Lienol"
  export LUCI_EDITION="22.03"
elif [[ "${matrixtarget}" == "Tianling_source" ]]; then
  export ZZZ_PATH="${HOME_PATH}/package/emortal/default-settings/files/99-default-settings"
  if [[ ! -f "${ZZZ_PATH}" ]]; then
    TIME r "上游源码作者修改了zzz-default-settings文件的路径或者名称，找编译脚本的作者及时修改"
    exit 1
  fi
  export SOURCE="Tianling"
  export LUCI_EDITION="18.06"
elif [[ "${matrixtarget}" == "Mortal_source" ]]; then
  export ZZZ_PATH="${HOME_PATH}/package/emortal/default-settings/files/99-default-settings"
  if [[ ! -f "${ZZZ_PATH}" ]]; then
    TIME r "上游源码作者修改了zzz-default-settings文件的路径或者名称，找编译脚本的作者及时修改"
    exit 1
  fi
  export SOURCE="Mortal"
  export LUCI_EDITION="21.02"
elif [[ "${matrixtarget}" == "openwrt_amlogic" ]]; then
  export ZZZ_PATH="${HOME_PATH}/package/lean/default-settings/files/zzz-default-settings"
  if [[ ! -f "${ZZZ_PATH}" ]]; then
    TIME r "上游源码作者修改了zzz-default-settings文件的路径或者名称，找编译脚本的作者及时修改"
    exit 1
  fi
  export SOURCE="Lede"
  export LUCI_EDITION="18.06"
fi
}

function Diy_feeds() {
echo "正在执行：更新插件源,让源码更多插件存在"
# 拉库和做标记

./scripts/feeds clean && ./scripts/feeds update -a > /dev/null 2>&1

case "${REPO_BRANCH}" in
master)
  
 # 删除重复插件（LEDE）
  find . -name 'luci-theme-argon' -o -name 'mentohust' | xargs -i rm -rf {}
  find . -name 'luci-app-wrtbwmon' -o -name 'wrtbwmon' -o -name 'luci-app-eqos' | xargs -i rm -rf {}
  find . -name 'adguardhome' -o -name 'luci-app-adguardhome' -o -name 'luci-app-wol' | xargs -i rm -rf {}

;;
22.03)
  
  # 删除重复插件（Lienol-22.03）
  find . -name 'luci-app-ttyd' -o -name 'luci-app-eqos' -o -name 'luci-theme-argon' | xargs -i rm -rf {}
  find . -name 'adguardhome' -o -name 'luci-app-adguardhome' -o -name 'luci-app-wol' -o -name 'luci-app-dockerman' -o -name 'luci-app-frpc' | xargs -i rm -rf {}
  find . -name 'luci-app-wrtbwmon' -o -name 'wrtbwmon' | xargs -i rm -rf {}

;;
openwrt-18.06)

  # 删除重复插件（天灵18.06）
  find . -name 'luci-app-argon-config' -o -name 'luci-theme-argon' -o -name 'luci-theme-argonv3' -o -name 'luci-app-eqos' | xargs -i rm -rf {}
  find . -name 'luci-app-cifs' | xargs -i rm -rf {}
  find . -name 'luci-app-wrtbwmon' -o -name 'wrtbwmon' -o -name 'luci-app-wol' | xargs -i rm -rf {}
  find . -name 'luci-app-adguardhome' -o -name 'adguardhome' -o -name 'luci-theme-opentomato' | xargs -i rm -rf {}

;;
openwrt-21.02)

  # 删除重复插件（天灵21.02）
  find . -name 'luci-app-cifs' -o -name 'luci-app-eqos' -o -name 'luci-theme-argon' | xargs -i rm -rf {}
  find . -name 'luci-app-adguardhome' -o -name 'adguardhome' -o -name 'luci-app-wol' | xargs -i rm -rf {}
  find . -name 'luci-app-wrtbwmon' -o -name 'wrtbwmon' | xargs -i rm -rf {}

;;
esac
}


function Diy_conf() {
case "${REPO_BRANCH}" in
master)
  
  # 给固件LUCI做个标记
 sed -i '/DISTRIB_RECOGNIZE/d' "$BASE_PATH/etc/openwrt_release"
 echo -e "\nDISTRIB_RECOGNIZE='18'" >> "$BASE_PATH/etc/openwrt_release" && sed -i '/^\s*$/d' "$BASE_PATH/etc/openwrt_release"

;;
22.03)
  
  # 给固件LUCI做个标记
  sed -i '/DISTRIB_RECOGNIZE/d' "$BASE_PATH/etc/openwrt_release"
  echo -e "\nDISTRIB_RECOGNIZE='20'" >> "$BASE_PATH/etc/openwrt_release" && sed -i '/^\s*$/d' "$BASE_PATH/etc/openwrt_release"
  
  # 给源码增加passwall为默认自选
  sed  -i  's/ luci-app-passwall//g' target/linux/*/Makefile
  sed -i 's?DEFAULT_PACKAGES +=?DEFAULT_PACKAGES += luci-app-passwall?g' target/linux/*/Makefile
  
  # 修改DISTRIB_DESCRIPTION
  DISTRIB="$(grep DISTRIB_DESCRIPTION= $ZZZ_PATH |cut -d "=" -f2 |cut -d "'" -f2)"
  [[ -n "${DISTRIB}" ]] && sed -i "s?${DISTRIB}?OpenWrt ?g" "$ZZZ_PATH"

;;
openwrt-18.06)
  
  # 给固件LUCI做个标记
  sed -i '/DISTRIB_RECOGNIZE/d' "$BASE_PATH/etc/openwrt_release"
  echo -e "\nDISTRIB_RECOGNIZE='18'" >> "$BASE_PATH/etc/openwrt_release" && sed -i '/^\s*$/d' "$BASE_PATH/etc/openwrt_release"
  
  # 给源码增加luci-app-ssr-plus为默认自选
  sed  -i  's/ luci-app-ssr-plus//g' target/linux/*/Makefile
  sed -i 's?DEFAULT_PACKAGES +=?DEFAULT_PACKAGES += luci-app-ssr-plus?g' target/linux/*/Makefile
  
  # 替换99-default-settings
  chmod -R 777 $HOME_PATH/build/common/Convert
  cp -Rf $HOME_PATH/build/common/Convert/1806-default-settings "$ZZZ_PATH"

;;
openwrt-21.02)
  
  # 给固件LUCI做个标记
  sed -i '/DISTRIB_RECOGNIZE/d' "$BASE_PATH/etc/openwrt_release"
  echo -e "\nDISTRIB_RECOGNIZE='20'" >> "$BASE_PATH/etc/openwrt_release" && sed -i '/^\s*$/d' "$BASE_PATH/etc/openwrt_release"
  
  # 给源码增加luci-app-ssr-plus为默认自选
  sed  -i  's/ luci-app-ssr-plus//g' target/linux/*/Makefile
  sed -i 's?DEFAULT_PACKAGES +=?DEFAULT_PACKAGES += luci-app-ssr-plus?g' target/linux/*/Makefile
  
  # 替换99-default-settings
  chmod -R 775 $HOME_PATH/build/common/Convert
  source $HOME_PATH/build/common/Convert/Convert.sh

;;
esac


# 给feeds.conf.default增加插件源
# 这里增加了源,要对应的删除/etc/opkg/distfeeds.conf插件源
echo "
src-git helloworld https://github.com/fw876/helloworld
src-git passwall https://github.com/xiaorouji/openwrt-passwall;packages
src-git passwall1 https://github.com/xiaorouji/openwrt-passwall;luci
src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2;main
src-git dahuilang https://github.com/shidahuilang/openwrt-package.git;${REPO_BRANCH}
" >> $HOME_PATH/feeds.conf.default
sed -i '/^#/d' "$HOME_PATH/feeds.conf.default"
sed -i '/^$/d' "$HOME_PATH/feeds.conf.default"
}

function sbin_openwrt() {
echo "正在执行：给固件增加[openwrt和tools和qinglong]命令"
[[ -f $BUILD_PATH/openwrt.sh ]] && cp -Rf $BUILD_PATH/openwrt.sh $BASE_PATH/sbin/openwrt
[[ -f $BUILD_PATH/tools.sh ]] && cp -Rf $BUILD_PATH/tools.sh $BASE_PATH/sbin/tools
[[ -f $BUILD_PATH/qinglong.sh ]] && cp -Rf $BUILD_PATH/qinglong.sh $BASE_PATH/sbin/qinglong
chmod 777 $BASE_PATH/sbin/tools
chmod 777 $BASE_PATH/sbin/openwrt
chmod 777 $BASE_PATH/sbin/qinglong
}

function Diy_Lede() {
echo "正在执行：Lede专用自定义"
}

function Diy_Lienol() {
echo "正在执行：Lienol专用自定义"
}

function Diy_Tianling() {
echo "正在执行：Tianling专用自定义"
}

function Diy_Mortal() {
echo "正在执行：Mortal专用自定义"
}

function Diy_amlogic() {
if [[ "${matrixtarget}" == "openwrt_amlogic" ]]; then
  echo "正在执行：修复NTFS格式优盘不自动挂载，适配cpufreq，添加autocore支持"
  # 修复NTFS格式优盘不自动挂载
  packages=" \
  block-mount fdisk usbutils badblocks ntfs-3g kmod-scsi-core kmod-usb-core \
  kmod-usb-ohci kmod-usb-uhci kmod-usb-storage kmod-usb-storage-extras kmod-usb2 kmod-usb3 \
  kmod-fs-ext4 kmod-fs-vfat kmod-fuse luci-app-amlogic unzip curl \
  brcmfmac-firmware-43430-sdio brcmfmac-firmware-43455-sdio kmod-brcmfmac wpad \
  lscpu htop iperf3 curl lm-sensors python3 losetup resize2fs tune2fs pv blkid lsblk parted \
  kmod-usb-net kmod-usb-net-asix-ax88179 kmod-usb-net-rtl8150 kmod-usb-net-rtl8152
  "
  sed -i '/FEATURES+=/ { s/cpiogz //; s/ext4 //; s/ramdisk //; s/squashfs //; }' \
  target/linux/armvirt/Makefile
  for x in $packages; do
    sed -i "/DEFAULT_PACKAGES/ s/$/ $x/" $HOME_PATH/target/linux/armvirt/Makefile
  done

  echo "修改luci-app-cpufreq一些代码适配amlogic"
  sed -i 's/LUCI_DEPENDS.*/LUCI_DEPENDS:=\@\(arm\|\|aarch64\)/g' $HOME_PATH/feeds/luci/applications/luci-app-cpufreq/Makefile
  echo "为 armvirt 添加 autocore 支持"
  sed -i 's/TARGET_rockchip/TARGET_rockchip\|\|TARGET_armvirt/g' $HOME_PATH/package/lean/autocore/Makefile
fi
}

function Package_amlogic() {
echo "正在执行：打包N1和景晨系列固件"
# 下载上游仓库
cd ${GITHUB_WORKSPACE}
git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git ${GITHUB_WORKSPACE}/amlogic
[ ! -d ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt ] && mkdir -p ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt
if [[ `ls -1 "${TARGET_BSGET}" |grep -c ".*default-rootfs.tar.gz"` == '1' ]]; then
  cp -Rf ${TARGET_BSGET}/*default-rootfs.tar.gz ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz && sync
else
  armvirtargz="$(ls -1 "${TARGET_BSGET}" |grep ".*tar.gz" |awk 'END {print}')"
  cp -Rf ${TARGET_BSGET}/${armvirtargz} ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt/openwrt-armvirt-64-default-rootfs.tar.gz && sync
fi
# 自定义机型,内核,分区
if [[ -f "${AMLOGIC_SH_PATH}" ]]; then
  export amlogic_model="$(grep "amlogic_model=" "${AMLOGIC_SH_PATH}" 2>&1 | cut -d "=" -f2 |sed 's/\"//g' |sed "s/'//g")"
  [[ -z "${amlogic_model}" ]] && export amlogic_model="all"
  export amlogic_kernel="$(grep "amlogic_kernel=" "${AMLOGIC_SH_PATH}" 2>&1 | cut -d "=" -f2 |sed 's/\"//g' |sed "s/'//g")"
  [[ -z "${amlogic_kernel}" ]] && export amlogic_kernel="5.15.25 -a true"
  export rootfs_size="$(grep "rootfs_size=" "${AMLOGIC_SH_PATH}" 2>&1 | cut -d "=" -f2 |sed 's/\"//g' |sed "s/'//g")"
  [[ -z "${rootfs_size}" ]] && export rootfs_size="1024"
else
  export amlogic_model="all"
  export amlogic_kernel="5.15.25 -a true"
  export rootfs_size="1024"
fi
# 开始打包
cd ${GITHUB_WORKSPACE}/amlogic
sudo chmod +x make
sudo ./make -d -b ${amlogic_model} -k ${amlogic_kernel} -s ${rootfs_size}
sudo mv -f $GITHUB_WORKSPACE/amlogic/out/* $TARGET_BSGET/ && sync
sudo rm -rf $GITHUB_WORKSPACE/amlogic
}

function Diy_indexhtm() {
echo "正在执行：去除主页一串的LUCI版本号显示"
if [[ "${REPO_BRANCH}" == "master" ]]; then
  sed -i 's/distversion)%>/distversion)%><!--/g' package/lean/autocore/files/*/index.htm
  sed -i 's/luciversion)%>)/luciversion)%>)-->/g' package/lean/autocore/files/*/index.htm
  sed -i 's#localtime  = os.date()#localtime  = os.date("%Y-%m-%d") .. " " .. translate(os.date("%A")) .. " " .. os.date("%X")#g' package/lean/autocore/files/*/index.htm
fi
if [[ "${REPO_BRANCH}" == "openwrt-18.06" ]]; then
  sed -i 's/distversion)%>/distversion)%><!--/g' package/emortal/autocore/files/*/index.htm
  sed -i 's/luciversion)%>)/luciversion)%>)-->/g' package/emortal/autocore/files/*/index.htm
  sed -i 's#localtime  = os.date()#localtime  = os.date("%Y-%m-%d") .. " " .. translate(os.date("%A")) .. " " .. os.date("%X")#g' package/emortal/autocore/files/*/index.htm
fi
}

function Diy_patches() {
echo "正在执行：如果有补丁文件，给源码打补丁"
if [[ -d "${GITHUB_WORKSPACE}/OP_DIY" ]]; then
  cp -Rf $HOME_PATH/build/common/${SOURCE}/* $BUILD_PATH
  cp -Rf ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/* $BUILD_PATH
else
  cp -Rf $HOME_PATH/build/common/${SOURCE}/* $BUILD_PATH
fi

if [ -n "$(ls -A "$BUILD_PATH/patches" 2>/dev/null)" ]; then
  find "$BUILD_PATH/patches" -type f -name '*.patch' -print0 | sort -z | xargs -I % -t -0 -n 1 sh -c "cat '%'  | patch -d './' -p1 --forward --no-backup-if-mismatch"
fi
}

function Diy_upgrade1() {
if [[ "${REGULAR_UPDATE}" == "true" ]]; then
  source $BUILD_PATH/upgrade.sh && Diy_Part1
fi
}

function Diy_prevent() {
echo "正在执行：判断插件有否冲突减少编译错误"
make defconfig > /dev/null 2>&1
echo "TIME b \"					插件冲突信息\"" > ${HOME_PATH}/CHONGTU

if [[ `grep -c "CONFIG_PACKAGE_luci-app-docker=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-dockerman=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-docker=y/# CONFIG_PACKAGE_luci-app-docker is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_luci-i18n-docker-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-docker-zh-cn is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-docker和luci-app-dockerman，插件有冲突，相同功能插件只能二选一，已删除luci-app-docker\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-advanced=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-fileassistant=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-fileassistant=y/# CONFIG_PACKAGE_luci-app-fileassistant is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-advanced和luci-app-fileassistant，luci-app-advanced已附带luci-app-fileassistant，所以删除了luci-app-fileassistant\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
   fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-adblock-plus=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-adblock=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-adblock=y/# CONFIG_PACKAGE_luci-app-adblock is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_adblock=y/# CONFIG_PACKAGE_adblock is not set/g' ${HOME_PATH}/.config
    sed -i '/luci-i18n-adblock/d' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-adblock-plus和luci-app-adblock，插件有依赖冲突，只能二选一，已删除luci-app-adblock\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-kodexplorer=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-vnstat=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-vnstat=y/# CONFIG_PACKAGE_luci-app-vnstat is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_vnstat=y/# CONFIG_PACKAGE_vnstat is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_vnstati=y/# CONFIG_PACKAGE_vnstati is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_libgd=y/# CONFIG_PACKAGE_libgd is not set/g' ${HOME_PATH}/.config
    sed -i '/luci-i18n-vnstat/d' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-kodexplorer和luci-app-vnstat，插件有依赖冲突，只能二选一，已删除luci-app-vnstat\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-ssr-plus=y" ${HOME_PATH}/.config` -ge '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-cshark=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-cshark=y/# CONFIG_PACKAGE_luci-app-cshark is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_cshark=y/# CONFIG_PACKAGE_cshark is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_libustream-mbedtls=y/# CONFIG_PACKAGE_libustream-mbedtls is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-ssr-plus和luci-app-cshark，插件有依赖冲突，只能二选一，已删除luci-app-cshark\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_wpad-openssl=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_wpad=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_wpad=y/# CONFIG_PACKAGE_wpad is not set/g' ${HOME_PATH}/.config
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_dnsmasq-full=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_dnsmasq=y" ${HOME_PATH}/.config` -eq '1' ]] || [[ `grep -c "CONFIG_PACKAGE_dnsmasq-dhcpv6=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_dnsmasq=y/# CONFIG_PACKAGE_dnsmasq is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_dnsmasq-dhcpv6=y/# CONFIG_PACKAGE_dnsmasq-dhcpv6 is not set/g' ${HOME_PATH}/.config
  fi
  if [[ `grep -c "CONFIG_PACKAGE_dnsmasq_full_conntrack=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_dnsmasq_full_conntrack=y/# CONFIG_PACKAGE_dnsmasq_full_conntrack is not set/g' ${HOME_PATH}/.config
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-samba4=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-samba=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_autosamba=y/# CONFIG_PACKAGE_autosamba is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_luci-app-samba=y/# CONFIG_PACKAGE_luci-app-samba is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_luci-i18n-samba-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-samba-zh-cn is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_samba36-server=y/# CONFIG_PACKAGE_samba36-server is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-app-samba和luci-app-samba4，插件有冲突，相同功能插件只能二选一，已删除luci-app-samba\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-theme-argon=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  pmg="$(echo "$(date +%d)" | sed 's/^.//g')"
  mkdir -p $HOME_PATH/files/www/luci-static/argon/background
  curl -fsSL  https://raw.githubusercontent.com/shidahuilang/openwrt-package/usb/argon/jpg/${pmg}.jpg > $HOME_PATH/files/www/luci-static/argon/background/moren.jpg
  if [[ $? -ne 0 ]]; then
    echo "拉取文件错误,请检测网络"
    exit 1
  fi
  if [[ `grep -c "CONFIG_PACKAGE_luci-theme-argon_new=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-theme-argon_new=y/# CONFIG_PACKAGE_luci-theme-argon_new is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您同时选择luci-theme-argon和luci-theme-argon_new，插件有冲突，相同功能插件只能二选一，已删除luci-theme-argon_new\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-sfe=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-flowoffload=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_DEFAULT_luci-app-flowoffload=y/# CONFIG_DEFAULT_luci-app-flowoffload is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_luci-app-flowoffload=y/# CONFIG_PACKAGE_luci-app-flowoffload is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_luci-i18n-flowoffload-zh-cn=y/# CONFIG_PACKAGE_luci-i18n-flowoffload-zh-cn is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"提示：您同时选择了luci-app-sfe和luci-app-flowoffload，两个ACC网络加速，已删除luci-app-flowoffload\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-ssl=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_libustream-wolfssl=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-ssl=y/# CONFIG_PACKAGE_luci-ssl is not set/g' ${HOME_PATH}/.config
    sed -i 's/CONFIG_PACKAGE_libustream-wolfssl=y/CONFIG_PACKAGE_libustream-wolfssl=m/g' ${HOME_PATH}/.config
    echo "TIME r \"您选择了luci-ssl会自带libustream-wolfssl，会和libustream-openssl冲突导致编译错误，已删除luci-ssl\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_luci-app-unblockneteasemusic=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-unblockneteasemusic-go=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-unblockneteasemusic-go=y/# CONFIG_PACKAGE_luci-app-unblockneteasemusic-go is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您选择了luci-app-unblockneteasemusic-go，会和luci-app-unblockneteasemusic冲突导致编译错误，已删除luci-app-unblockneteasemusic-go\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
  if [[ `grep -c "CONFIG_PACKAGE_luci-app-unblockmusic=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    sed -i 's/CONFIG_PACKAGE_luci-app-unblockmusic=y/# CONFIG_PACKAGE_luci-app-unblockmusic is not set/g' ${HOME_PATH}/.config
    echo "TIME r \"您选择了luci-app-unblockmusic，会和luci-app-unblockneteasemusic冲突导致编译错误，已删除luci-app-unblockmusic\"" >>CHONGTU
    echo "TIME z \"\"" >>CHONGTU
    echo "TIME b \"插件冲突信息\"" > ${HOME_PATH}/Chajianlibiao
  fi
fi

if [[ `grep -c "CONFIG_PACKAGE_ntfs-3g=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  mkdir -p ${HOME_PATH}/files/etc/hotplug.d/block && curl -fsSL  https://raw.githubusercontent.com/shidahuilang/openwrt-package/usb/block/10-mount > ${HOME_PATH}/files/etc/hotplug.d/block/10-mount
  if [[ $? -ne 0 ]]; then
    echo "拉取文件错误,请检测网络"
    exit 1
  fi
fi

if [[ `grep -c "CONFIG_TARGET_x86=y" ${HOME_PATH}/.config` -eq '1' ]] || [[ `grep -c "CONFIG_TARGET_rockchip=y" ${HOME_PATH}/.config` -eq '1' ]] || [[ `grep -c "CONFIG_TARGET_bcm27xx=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  sed -i '/IMAGES_GZIP/d' "${HOME_PATH}/.config"
  echo -e "\nCONFIG_TARGET_IMAGES_GZIP=y" >> "${HOME_PATH}/.config"
  sed -i '/CONFIG_PACKAGE_openssh-sftp-server/d' "${HOME_PATH}/.config"
  echo -e "\nCONFIG_PACKAGE_openssh-sftp-server=y" >> "${HOME_PATH}/.config"
  sed -i '/CONFIG_GRUB_IMAGES/d' "${HOME_PATH}/.config"
  echo -e "\nCONFIG_GRUB_IMAGES=y" >> "${HOME_PATH}/.config"
fi
if [[ `grep -c "CONFIG_TARGET_mxs=y" ${HOME_PATH}/.config` -eq '1' ]] || [[ `grep -c "CONFIG_TARGET_sunxi=y" ${HOME_PATH}/.config` -eq '1' ]] || [[ `grep -c "CONFIG_TARGET_zynq=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  sed -i '/IMAGES_GZIP/d' "${HOME_PATH}/.config"
  echo -e "\nCONFIG_TARGET_IMAGES_GZIP=y" >> "${HOME_PATH}/.config"
  sed -i '/CONFIG_PACKAGE_openssh-sftp-server/d' "${HOME_PATH}/.config"
  echo -e "\nCONFIG_PACKAGE_openssh-sftp-server=y" >> "${HOME_PATH}/.config"
  sed -i '/CONFIG_GRUB_IMAGES/d' "${HOME_PATH}/.config"
  echo -e "\nCONFIG_GRUB_IMAGES=y" >> "${HOME_PATH}/.config"
fi

if [[ `grep -c "CONFIG_TARGET_armvirt=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  sed -i 's/CONFIG_PACKAGE_luci-app-autoupdate=y/# CONFIG_PACKAGE_luci-app-autoupdate is not set/g' ${HOME_PATH}/.config
  export REGULAR_UPDATE="false"
  echo "REGULAR_UPDATE=false" >> $GITHUB_ENV
  sed -i '/CONFIG_PACKAGE_openssh-sftp-server/d' "${HOME_PATH}/.config"
  echo -e "\nCONFIG_PACKAGE_openssh-sftp-server=y" >> "${HOME_PATH}/.config"
fi

if [[ `grep -c "CONFIG_PACKAGE_odhcp6c=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  sed -i '/CONFIG_PACKAGE_odhcpd=y/d' "${HOME_PATH}/.config"
  sed -i '/CONFIG_PACKAGE_odhcpd_full_ext_cer_id=0/d' "${HOME_PATH}/.config"
fi

if [[ ! "${REGULAR_UPDATE}" == "true" ]] || [[ -z "${REPO_TOKEN}" ]]; then
  sed -i 's/CONFIG_PACKAGE_luci-app-autoupdate=y/# CONFIG_PACKAGE_luci-app-autoupdate is not set/g' ${HOME_PATH}/.config
fi

if [[ `grep -c "CONFIG_TARGET_ROOTFS_EXT4FS=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  PARTSIZE="$(egrep -o "CONFIG_TARGET_ROOTFS_PARTSIZE=[0-9]+" ${HOME_PATH}/.config |cut -f2 -d=)"
  if [[ "${PARTSIZE}" -lt "950" ]];then
    sed -i '/CONFIG_TARGET_ROOTFS_PARTSIZE/d' ${HOME_PATH}/.config
    echo -e "\nCONFIG_TARGET_ROOTFS_PARTSIZE=950" >> ${HOME_PATH}/.config
    echo "TIME g \" \"" > ${HOME_PATH}/EXT4
    echo "TIME r \"EXT4提示：请注意，您选择了ext4安装的固件格式,而检测到您的分配的固件系统分区过小\"" >> ${HOME_PATH}/EXT4
    echo "TIME y \"为避免编译出错,建议修改成950或者以上比较好,已自动帮您修改成950M\"" >> ${HOME_PATH}/EXT4
    echo "TIME g \" \"" >> ${HOME_PATH}/EXT4
  fi
fi

if [ -n "$(ls -A "${HOME_PATH}/Chajianlibiao" 2>/dev/null)" ]; then
  echo "TIME y \"  插件冲突会导致编译失败，以上操作如非您所需，请关闭此次编译，重新开始编译，避开冲突重新选择插件\"" >>CHONGTU
  echo "TIME z \"\"" >>CHONGTU
else
  rm -rf CHONGTU
fi
make defconfig > /dev/null 2>&1
echo
echo
if [ -n "$(ls -A "${HOME_PATH}/EXT4" 2>/dev/null)" ]; then
  chmod -R +x ${HOME_PATH}/EXT4
  source ${HOME_PATH}/EXT4
  echo
fi
if [ -n "$(ls -A "${HOME_PATH}/Chajianlibiao" 2>/dev/null)" ]; then
  chmod -R +x ${HOME_PATH}/CHONGTU
  source ${HOME_PATH}/CHONGTU
  echo
fi
}

function Diy_adguardhome() {
if [[ `grep -c "CONFIG_PACKAGE_luci-app-adguardhome=y" ${HOME_PATH}/.config` -eq '1' ]]; then
  echo "正在执行：给adguardhome下载核心"
  if [[ `grep -c "CONFIG_ARCH=\"x86_64\"" ${HOME_PATH}/.config` -eq '1' ]]; then
    Arch="amd64"
    echo "X86_64"
  elif [[ `grep -c "CONFIG_ARCH=\"i386\"" ${HOME_PATH}/.config` -eq '1' ]]; then
    Arch="i386"
    echo "X86_32"
  elif [[ `grep -c "CONFIG_ARCH=\"aarch64\"" ${HOME_PATH}/.config` -eq '1' ]]; then
    Arch="arm64"
    echo "armv8"
  elif [[ `grep -c "CONFIG_ARCH=\"arm\"" ${HOME_PATH}/.config` -eq '1' ]] && [[ `grep -c "CONFIG_arm_v7=y" ${HOME_PATH}/.config` -eq '1' ]]; then
    Arch="armv7"
    echo "armv7"
  else
    echo "This model does not support automatic core download"
  fi
	
  if [[ "${Arch}" =~ (amd64|i386|arm64|armv7) ]]; then
    downloader="curl -L -k --retry 2 --connect-timeout 20 -o"
    latest_ver="$($downloader - https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest 2>/dev/null|grep -E 'tag_name' |grep -E 'v[0-9.]+' -o 2>/dev/null)"
    wget -q https://github.com/AdguardTeam/AdGuardHome/releases/download/${latest_ver}/AdGuardHome_linux_${Arch}.tar.gz
    if [[ -f "AdGuardHome_linux_${Arch}.tar.gz" ]]; then
      tar -zxvf AdGuardHome_linux_${Arch}.tar.gz -C $HOME_PATH
      echo "核心下载成功"
    else
      echo "下载核心不成功"
    fi
    mkdir -p $HOME_PATH/files/usr/bin
    if [[ -f "$HOME_PATH/AdGuardHome/AdGuardHome" ]]; then
      mv -f $HOME_PATH/AdGuardHome/AdGuardHome $HOME_PATH/files/usr/bin
      chmod 777 $HOME_PATH/files/usr/bin/AdGuardHome
      echo "解压核心包成功,完成增加AdGuardHome核心工作"
    else
      echo "解压核心包失败,没能增加AdGuardHome核心"
    fi
    rm -rf $HOME_PATH/{AdGuardHome_linux_${Arch}.tar.gz,AdGuardHome}
  fi
fi
}

function Diy_files() {
echo "正在执行：files大法，设置固件无烦恼"
if [[ -d "${GITHUB_WORKSPACE}/OP_DIY" ]]; then
  cp -Rf $HOME_PATH/build/common/${SOURCE}/* $BUILD_PATH
  cp -Rf ${GITHUB_WORKSPACE}/OP_DIY/${matrixtarget}/* $BUILD_PATH
  
 elif [[ ${matrixtarget} == "nanopi_r2s" ]]; then
  cp -Rf $HOME_PATH/build/common/nanopi_r2s/* $BUILD_PATH
  
elif [[ ${matrixtarget} == "nanopi_r4s" ]]; then
  cp -Rf $HOME_PATH/build/common/nanopi_r4s/* $BUILD_PATH 
  
else
  cp -Rf $HOME_PATH/build/common/${SOURCE}/* $BUILD_PATH
fi

if [ -n "$(ls -A "$BUILD_PATH/diy" 2>/dev/null)" ]; then
  cp -Rf $BUILD_PATH/diy/* $HOME_PATH
fi
if [ -n "$(ls -A "$BUILD_PATH/files" 2>/dev/null)" ]; then
  cp -Rf $BUILD_PATH/files $HOME_PATH
fi
chmod -R 775 $HOME_PATH/files
rm -rf $HOME_PATH/files/{LICENSE,README,REA*.md}
}

function Diy_zzz() {
echo "正在执行：在zzz-default-settings文件加条执行命令"

curl -fsSL https://raw.githubusercontent.com/shidahuilang/common/main/Custom/FinishIng.sh > $BASE_PATH/etc/FinishIng.sh
if [[ $? -ne 0 ]]; then
  wget -q -O FinishIng.sh -P $BASE_PATH/etc https://raw.githubusercontent.com/shidahuilang/common/main/Custom/FinishIng.sh
fi
chmod 775 $BASE_PATH/etc/FinishIng.sh
 curl -fsSL https://raw.githubusercontent.com/shidahuilang/common/main/Custom/webweb.sh > $BASE_PATH/etc/webweb.sh
 if [[ $? -ne 0 ]]; then
   wget -q -O webweb.sh -P $BASE_PATH/etc https://raw.githubusercontent.com/shidahuilang/common/main/Custom/webweb.sh
 fi
 chmod 775 $BASE_PATH/etc/webweb.sh
 sed -i '/webweb.sh/d' "$ZZZ_PATH"
 sed -i "/exit 0/i\source /etc/webweb.sh" "$ZZZ_PATH"

sed -i '/etc\/init.d\/uhttpd\ restart/d' "$BASE_PATH/etc/rc.local"
sed -i "/exit 0/i\/etc/init.d/uhttpd restart" "$BASE_PATH/etc/rc.local"

sed -i '/etc\/init.d\/network\ restart/d' "$BASE_PATH/etc/rc.local"
sed -i "/exit 0/i\/etc/init.d/network restart" "$BASE_PATH/etc/rc.local"

sed -i '/service dnsmasq restart/d' "$BASE_PATH/etc/rc.local"
sed -i "/exit 0/i\service dnsmasq restart" "$BASE_PATH/etc/rc.local"

sed -i '/FinishIng.sh/d' "$BASE_PATH/etc/rc.local"
sed -i "/exit 0/i\[[ -f '/etc/FinishIng.sh' ]] && source /etc/FinishIng.sh" "$BASE_PATH/etc/rc.local"
}

function Make_defconfig() {
echo "正在执行：加载机型中..."
export TAR_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' $HOME_PATH/.config)"
export TAR_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' $HOME_PATH/.config)"
echo "TARGET_BOARD=$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' $HOME_PATH/.config)" >> $GITHUB_ENV
echo "TARGET_SUBTARGET=$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' $HOME_PATH/.config)" >> $GITHUB_ENV
if [ `grep -c "CONFIG_TARGET_x86_64=y" $HOME_PATH/.config` -eq '1' ]; then
  echo "TARGET_PROFILE=x86-64" >> $GITHUB_ENV
elif [[ `grep -c "CONFIG_TARGET_x86=y" $HOME_PATH/.config` == '1' ]] && [[ `grep -c "CONFIG_TARGET_x86_64=y" $HOME_PATH/.config` == '0' ]]; then
  echo "TARGET_PROFILE=x86_32" >> $GITHUB_ENV
elif [ `grep -c "CONFIG_TARGET.*DEVICE.*=y" $HOME_PATH/.config` -eq '1' ]; then
  grep '^CONFIG_TARGET.*DEVICE.*=y' $HOME_PATH/.config | sed -r 's/.*DEVICE_(.*)=y/\1/' > DEVICE_NAME
  [ -s DEVICE_NAME ] && echo "TARGET_PROFILE=$(cat DEVICE_NAME)" >> $GITHUB_ENV
else
  echo "TARGET_PROFILE=$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' $HOME_PATH/.config)" >> $GITHUB_ENV
fi
echo "TARGET_BSGET=$HOME_PATH/bin/targets/$TAR_BOARD/$TAR_SUBTARGET" >> $GITHUB_ENV
echo "FIRMWARE=$HOME_PATH/bin/targets/$TAR_BOARD/$TAR_SUBTARGET" >> $GITHUB_ENV
}

function Make_upgrade() {
## 本地编译加载机型用
export TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' $HOME_PATH/.config)"
export TARGET_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' $HOME_PATH/.config)"
if [[ `grep -c "CONFIG_TARGET_x86_64=y" $HOME_PATH/.config` -eq '1' ]]; then
  export TARGET_PROFILE="x86-64"
elif [[ `grep -c "CONFIG_TARGET_x86=y" $HOME_PATH/.config` == '1' ]] && [[ `grep -c "CONFIG_TARGET_x86_64=y" $HOME_PATH/.config` == '0' ]]; then
  export TARGET_PROFILE="x86_32"
elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" $HOME_PATH/.config` -eq '1' ]]; then
  export TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" $HOME_PATH/.config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
else
  export TARGET_PROFILE="${TARGET_BOARD}"
fi
export TARGET_BSGET="$HOME_PATH/bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET"
export TARGET_OPENWRT="openwrt/bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET"
}

function Diy_upgrade3() {
if [ "${REGULAR_UPDATE}" == "true" ]; then
  cp -Rf ${TARGET_BSGET} $HOME_PATH/upgrade
  source $BUILD_PATH/upgrade.sh && Diy_Part3
fi
}

function Diy_organize() {
cd ${TARGET_BSGET}
mkdir -p ipk
cp -rf $(find $HOME_PATH/bin/packages/ -type f -name "*.ipk") ipk/ && sync
sudo tar -czf ipk.tar.gz ipk && sudo rm -rf ipk && sync
rename -v "s/^immortalwrt/openwrt/" *
if [[ -f ${GITHUB_WORKSPACE}/Clear ]]; then
  cp -Rf ${GITHUB_WORKSPACE}/Clear ${TARGET_BSGET}/Clear.sh
  chmod +x ${TARGET_BSGET}/Clear.sh && source ${TARGET_BSGET}/Clear.sh
  rm -rf ${TARGET_BSGET}/Clear.sh
fi
rename -v "s/^openwrt/${SOURCE}/" *
echo "FIRMWARE=$PWD" >> $GITHUB_ENV

cd $HOME_PATH
# 发布用的update_log.txt
if [ "${UPLOAD_RELEASE}" == "true" ]; then
  echo "### $(date +"%Y年%m月%d号-%H点%M分")" > ${GITHUB_WORKSPACE}/update_log.txt
fi
}

function Diy_firmware() {
echo "正在执行：整理固件,您不想要啥就删啥,删删删"
Diy_upgrade3
Diy_organize
}

function Diy_Language() {
if [[ "${REPO_BRANCH}" == "22.03" ]] || [[ "${REPO_BRANCH}" == "openwrt-21.02" ]]; then
  echo "正在执行：把插件语言转换成zh_Hans"
  cd $HOME_PATH
  cp -Rf $HOME_PATH/build/common/Convert/zh_Hans.sh $HOME_PATH/zh_Hans.sh
  chmod +x $HOME_PATH/zh_Hans.sh
  /bin/bash $HOME_PATH/zh_Hans.sh
  rm -rf $HOME_PATH/zh_Hans.sh
fi
}

function Diy_part_sh() {
echo "正在执行：运行$DIY_PART_SH文件"
cd $HOME_PATH
rm -rf master > /dev/null 2>&1
rm -rf dev > /dev/null 2>&1
/bin/bash $BUILD_PATH/$DIY_PART_SH
rm -rf package/luci-app-openclash > /dev/null 2>&1
if [ -n "$(ls -A "master" 2>/dev/null)" ]; then
  git clone -b master --depth 1 https://github.com/vernesong/OpenClash package/luci-app-openclash
  echo "正在使用master分支的openclash"
elif [ -n "$(ls -A "dev" 2>/dev/null)" ]; then
  git clone -b dev --depth 1 https://github.com/vernesong/OpenClash package/luci-app-openclash
  echo "正在使用dev分支的openclash"
else
  echo "没发现该分支的openclash，默认使用master分支"
  git clone -b master --depth 1 https://github.com/vernesong/OpenClash package/luci-app-openclash
  echo "正在使用master分支的openclash"
fi
rm -rf master > /dev/null 2>&1
rm -rf dev > /dev/null 2>&1
}


function Diy_Notice() {
TIME y "第一次用我仓库的，请不要拉取任何插件，先SSH进入固件配置那里看过我脚本实在是没有你要的插件才再拉取"
TIME y "拉取插件应该单独拉取某一个你需要的插件，别一下子就拉取别人一个插件包，这样容易增加编译失败概率"
TIME r "修改IP、DNS、网关，请输入命令：openwrt"
TIME r "在线更新命令：openwrt，工具箱输入命令：tools"
}


function Diy_xinxi() {
Plug_in="$(grep -i 'CONFIG_PACKAGE_luci-app' $HOME_PATH/.config && grep -i 'CONFIG_PACKAGE_luci-theme' $HOME_PATH/.config)"
Plug_in2="$(echo "${Plug_in}" | grep -v '^#' |sed '/INCLUDE/d' |sed '/_Transparent_Proxy/d' |sed '/qbittorrent_static/d' |sed 's/CONFIG_PACKAGE_//g' |sed 's/=y//g' |sed 's/^/、/g' |sed 's/$/\"/g' |awk '$0=NR$0' |sed 's/^/TIME g \"       /g')"
echo "${Plug_in2}" >Plug-in
sed -i '/qbittorrent-simple_dynamic/d' Plug-in > /dev/null 2>&1
CPUNAME="$(cat /proc/cpuinfo |grep 'model name' |awk 'END {print}' |cut -f2 -d: |sed 's/^[ ]*//g')"
CPUCORES="$(cat /proc/cpuinfo | grep 'cpu cores' |awk 'END {print}' | cut -f2 -d: | sed 's/^[ ]*//g')"


if [[ "${REPO_BRANCH}" == "openwrt-18.06" ]] || [[ "${REPO_BRANCH}" == "openwrt-21.02" ]]; then
  export KERNEL_PATC=""
  export KERNEL_PATC="$(egrep KERNEL_PATCHVER:=[0-9]+\.[0-9]+ $HOME_PATH/target/linux/${TARGET_BOARD}/Makefile |cut -d "=" -f2)"
  [[ -z ${KERNEL_PATC} ]] && export KERNEL_PATC="$(egrep KERNEL_PATCHVER=[0-9]+\.[0-9]+ $HOME_PATH/target/linux/${TARGET_BOARD}/Makefile |cut -d "=" -f2)"
  [[ -n ${KERNEL_PATC} ]] && export LINUX_KERNEL="$(egrep -o LINUX_KERNEL_HASH-${KERNEL_PATC}\.[0-9]+ $HOME_PATH/include/kernel-version.mk |cut -d "-" -f2)"
  [[ -z ${LINUX_KERNEL} ]] && export LINUX_KERNEL="nono"
else
  export KERNEL_PATC=""
  export KERNEL_PATC="$(egrep KERNEL_PATCHVER:=[0-9]+\.[0-9]+ $HOME_PATH/target/linux/${TARGET_BOARD}/Makefile |cut -d "=" -f2)"
  [[ -z ${KERNEL_PATC} ]] && export KERNEL_PATC="$(egrep KERNEL_PATCHVER=[0-9]+\.[0-9]+ $HOME_PATH/target/linux/${TARGET_BOARD}/Makefile |cut -d "=" -f2)"
  [[ -n ${KERNEL_PATC} ]] && export LINUX_KERNEL="$(egrep -o LINUX_KERNEL_HASH-${KERNEL_PATC}\.[0-9]+ $HOME_PATH/include/kernel-${KERNEL_PATC} |cut -d "-" -f2)"
  [[ -z ${LINUX_KERNEL} ]] && export LINUX_KERNEL="nono"
fi

if [[ "${matrixtarget}" == "openwrt_amlogic" ]]; then
  export TARGET_DHL="晶晨系列"
else
  export TARGET_DHL="${TARGET_PROFILE}"
fi


echo
TIME b "编译源码: ${SOURCE}"
TIME b "源码链接: ${REPO_URL}"
TIME b "源码分支: ${REPO_BRANCH}"
TIME b "源码作者: ${MAINTAIN}"
TIME b "内核版本: ${LINUX_KERNEL}"
TIME b "Luci版本: ${LUCI_EDITION}"
if [[ "${matrixtarget}" == "openwrt_amlogic" ]]; then
  TIME b "编译机型: 晶晨系列"
  if [[ "${AUTOMATIC_AMLOGIC}" == "true" ]]; then
    if [[ -f "${AMLOGIC_SH_PATH}" ]]; then
      amlogic_model="$(grep "amlogic_model=" "${AMLOGIC_SH_PATH}" 2>&1 | cut -d "=" -f2 |sed 's/ [  \t]*$//g' |sed 's/\"//g' |sed "s/'//g")"
      [[ -z "${amlogic_model}" ]] && amlogic_model="填写格式错误,未获取到数据,脚本默认打包全机型"
      amlogic_kernel="$(grep "amlogic_kernel=" "${AMLOGIC_SH_PATH}" 2>&1 | cut -d "=" -f2 |sed 's/ [  \t]*$//g' |sed 's/\"//g' |sed "s/'//g")"
      [[ -z "${amlogic_kernel}" ]] && amlogic_kernel="填写格式错误,未获取到数据,脚本默认5.15.xx"
      rootfs_size="$(grep "rootfs_size=" "${AMLOGIC_SH_PATH}" 2>&1 | cut -d "=" -f2 |sed 's/ [  \t]*$//g' |sed 's/\"//g' |sed "s/'//g")"
      [[ -z "${rootfs_size}" ]] && rootfs_size="填写格式错误,未获取到数据,脚本默认1024"
      TIME g "打包机型: ${amlogic_model}"
      TIME g "打包内核: ${amlogic_kernel}"
      TIME g "分区大小: ${rootfs_size}"
    else
      TIME r "打包数据：没发现打包数据文件存在，使用脚本默认数值打包"
    fi
  fi
else
  TIME b "编译机型: ${TARGET_PROFILE}"
fi
TIME b "固件作者: ${Author}"
TIME b "仓库地址: ${Github}"
TIME b "启动编号: #${Run_number}（${Library}仓库第${Run_number}次启动[${Run_workflow}]工作流程）"
TIME b "编译时间: ${Compte_Date}"
TIME g "友情提示：您当前使用【${matrixtarget}】文件夹编译【${TARGET_PROFILE}】固件"
echo
echo
if [[ ${UPLOAD_FIRMWARE} == "true" ]]; then
  TIME y "上传固件在github actions: 开启"
else
  TIME r "上传固件在github actions: 关闭"
fi
if [[ ${UPLOAD_CONFIG} == "true" ]]; then
  TIME y "上传[.config]配置文件: 开启"
else
  TIME r "上传[.config]配置文件: 关闭"
fi
if [[ ${UPLOAD_BIN_DIR} == "true" ]]; then
  TIME y "上传BIN文件夹(固件+IPK): 开启"
else
  TIME r "上传BIN文件夹(固件+IPK): 关闭"
fi
if [[ ${UPLOAD_WETRANSFER} == "true" ]]; then
  TIME y "上传固件至【WETRANSFER】: 开启"
else
  TIME r "上传固件至【WETRANSFER】: 关闭"
fi
if [[ ${UPLOAD_RELEASE} == "true" ]]; then
  TIME y "发布固件: 开启"
else
  TIME r "发布固件: 关闭"
fi
if [[ ${SERVERCHAN_SCKEY} == "true" ]]; then
  TIME y "微信/电报通知: 开启"
else
  TIME r "微信/电报通知: 关闭"
fi
if [[ ${BY_INFORMATION} == "true" ]]; then
  TIME y "编译信息显示: 开启"
fi
if [[ ${REGULAR_UPDATE} == "true" ]]; then
  TIME y "把定时自动更新插件编译进固件: 开启"
else
  TIME r "把定时自动更新插件编译进固件: 关闭"
fi

if [[ "${REGULAR_UPDATE}" == "true" ]] && [[ -z "${REPO_TOKEN}" ]]; then
  echo
  echo
  TIME r "您虽然开启了编译在线更新固件操作,但是您的[REPO_TOKEN]密匙为空,"
  TIME r "无法将固件发布至云端,已为您自动关闭了编译在线更新固件"
  echo
elif [[ "${REGULAR_UPDATE}" == "true" ]] && [[ -n "${REPO_TOKEN}" ]]; then
  echo
  TIME l "定时自动更新信息"
  TIME z "插件版本: ${AutoUpdate_Version}"
  if [[ ${Firmware_SFX} == ".img.gz" ]]; then
    TIME b "传统固件: ${Legacy_Firmware}"
    TIME b "UEFI固件: ${UEFI_Firmware}"
    TIME b "固件后缀: ${Firmware_SFX}"
  else
    TIME b "固件名称: ${Up_Firmware}"
    TIME b "固件后缀: ${Firmware_SFX}"
  fi
  TIME b "固件版本: ${Openwrt_Version}"
  TIME b "云端路径: ${Github_Release}"
  TIME g "《编译成功后，会自动把固件发布到指定地址，然后才会生成云端路径》"
  TIME g "《普通的那个发布固件跟云端的发布路径是两码事，如果你不需要普通发布的可以不用打开发布功能》"
  TIME g "修改IP、DNS、网关或者在线更新，请输入命令：openwrt或者tools"
  echo
else
  echo
fi
echo
TIME z " 系统空间      类型   总数  已用  可用 使用率"
cd ../ && df -hT $PWD && cd $HOME_PATH
echo
TIME z "  本编译 服务器的 CPU型号为 [ ${CPUNAME} ]"
echo
TIME z "  使用 核心数 为 [ ${CPUCORES} ], 线程数为 [ $(nproc) ]"
echo
if [ -n "$(ls -A "${HOME_PATH}/EXT4" 2>/dev/null)" ]; then
  chmod -R +x ${HOME_PATH}/EXT4
  source ${HOME_PATH}/EXT4
  rm -rf ${HOME_PATH}/{CHONGTU,Chajianlibiao,EXT4}
  echo
fi
if [ -n "$(ls -A "${HOME_PATH}/Chajianlibiao" 2>/dev/null)" ]; then
  chmod -R +x ${HOME_PATH}/CHONGTU
  source ${HOME_PATH}/CHONGTU
  rm -rf ${HOME_PATH}/{CHONGTU,Chajianlibiao}
  echo
fi
if [ -n "$(ls -A "${HOME_PATH}/Plug-in" 2>/dev/null)" ]; then
  TIME r "	      已选插件列表"
  chmod -R +x ${HOME_PATH}/Plug-in
  source ${HOME_PATH}/Plug-in
  rm -rf ${HOME_PATH}/{Plug-in,Plug-2}
  echo
fi
}

function Diy_menu2() {
if [[ ! "${bendi_script}" == "1" ]]; then
  Diy_prevent
fi
Diy_files
Diy_zzz
sbin_openwrt
Diy_adguardhome
Diy_Language
if [[ ! "${bendi_script}" == "1" ]]; then
  Make_defconfig
else
  Make_upgrade
fi
}

function Diy_menu() {
if [[ ! ${Tishi} == "1" ]]; then
  Diy_feeds
fi
Diy_conf
Diy_${SOURCE}
Diy_amlogic
Diy_part_sh
/bin/bash $BUILD_PATH/$DIY_PART_SH
Diy_indexhtm
Diy_patches
Diy_upgrade1

echo "正在执行：更新feeds,请耐心等待..."
./scripts/feeds update -a
./scripts/feeds install -a > /dev/null 2>&1
./scripts/feeds install -a
mv $BUILD_PATH/$CONFIG_FILE .config
make defconfig > /dev/null 2>&1
}
