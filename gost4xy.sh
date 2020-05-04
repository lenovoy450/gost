#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

filepath=$(cd "$(dirname "$0")"; pwd)
file_1=$(echo -e "${filepath}"|awk -F "$0" '{print $1}')

gost_file="/usr/local/sbin/gost4xy"
gost_conf="/root/gost4xy.json"
demain_conf="/root/gost4xy.conf"
gost_log="/root/gost4xy.log"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

check_sys(){
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
    elif cat /etc/issue | grep -q -E -i "debian"; then
        release="debian"
    elif cat /etc/issue | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    elif cat /proc/version | grep -q -E -i "debian"; then
        release="debian"
    elif cat /proc/version | grep -q -E -i "ubuntu"; then
        release="ubuntu"
    elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
        release="centos"
    fi
    bit=`uname -m`
}

check_installed_status(){
    [[ ! -e ${gost_file} ]] && echo -e "${Error} Gost 没有安装，请检查 !" && exit 1
}

Install_gost(){
	cd /usr/local/sbin && wget https://app.mytomato.xyz/shell-node/gost -O gost4xy && chmod +x gost4xy && cd
	cd /root && wget https://raw.githubusercontent.com/lenovoy450/gost/master/gost.json -O gost4xy.json && cd
	if [[ ${release} = "centos" ]]; then
		dnf install bind-utils
		yum install bind-utils
		cd /usr/lib/systemd/system && wget https://raw.githubusercontent.com/lenovoy450/gost/master/gost4xy.service -O gost4xy.service && systemctl enable gost4xy && systemctl restart gost4xy && cd
	else
		apt install dnsutils
		cd /etc/systemd/system && wget https://raw.githubusercontent.com/lenovoy450/gost/master/gost4xy.service -O gost4xy.service && systemctl enable gost4xy && systemctl restart gost4xy && cd
	fi
	apt autoremove apache2 nginx apache
	yum autoremove apache2 nginx apache
	echo -e "${Info} Gost 安装完成 ! "
}

del_gost(){
systemctl disable gost4xy
systemctl stop gost4xy
rm -rf /usr/lib/systemd/system/gost4xy.service
rm -rf /etc/systemd/system/gost4xy.service
rm -rf /usr/local/sbin/gost4xy
rm -rf /root/gost4xy.json
}

update_gost(){
systemctl stop gost4xy
cd /usr/local/sbin && wget https://app.mytomato.xyz/shell-node/gost -O gost4xy && chmod +x gost4xy && cd
systemctl restart gost4xy
sleep 1
}

re_gost(){
systemctl restart gost4xy
sleep 1
}

check_pid(){
    PID=$(ps -ef| grep "gost4xy"| grep -v grep| grep -v ".sh"| grep -v "init.d"| grep -v "service"| awk '{print $2}')
}

check_sys

echo && echo -e "
————————————
 ${Green_font_prefix}0.${Font_color_suffix} 安装Gost
 ${Green_font_prefix}1.${Font_color_suffix} 升级Gost
 ${Green_font_prefix}2.${Font_color_suffix} 卸载Gost
————————————
 ${Green_font_prefix}3.${Font_color_suffix} 重启Gost
————————————" && 
echo
stty erase '^H' && read -p " 请输入数字 [0-8]:" num
case "$num" in
    0)
	Install_gost
	check_pid
	echo "${PID}"
    ;;
    1)
	update_gost
	check_pid
	echo "${PID}"
    ;;
    2)
	del_gost
    ;;
    3)
	re_gost
	check_pid
	echo "${PID}"
    ;;
    *)
    echo "请输入正确数字 [0-0]"
    ;;
esac