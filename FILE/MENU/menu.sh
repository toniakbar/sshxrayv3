#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
###########- COLOR CODE -##############
colornow=$(cat /etc/alexxa/theme/color.conf)
export NC="\e[0m"
export YELLOW='\033[0;33m';
export RED="\033[0;31m" 
export COLOR1="$(cat /etc/alexxa/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
export COLBG1="$(cat /etc/alexxa/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')" 
WH='\033[1;37m'                   
###########- END COLOR CODE -##########
tram=$( free -h | awk 'NR==2 {print $2}' )
uram=$( free -h | awk 'NR==2 {print $3}' )
ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10 )
CITY=$(curl -s ipinfo.io/city )


export RED='\033[0;31m'
export GREEN='\033[0;32m'

# usage
vnstat_profile=$(vnstat | sed -n '3p' | awk '{print $1}' | grep -o '[^:]*')
vnstat -i ${vnstat_profile} >/root/t1
bulan=$(date +%b)
today=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $8}')
todayd=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $8}')
today_v=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $9}')
today_rx=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $2}')
today_rxv=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $3}')
today_tx=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $5}')
today_txv=$(vnstat -i ${vnstat_profile} | grep today | awk '{print $6}')
if [ "$(grep -wc ${bulan} /root/t1)" != '0' ]; then
    bulan=$(date +%b)
    month=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $9}')
    month_v=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $10}')
    month_rx=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $3}')
    month_rxv=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $4}')
    month_tx=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $6}')
    month_txv=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $7}')
else
    bulan=$(date +%Y-%m)
    month=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $8}')
    month_v=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $9}')
    month_rx=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $2}')
    month_rxv=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $3}')
    month_tx=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $5}')
    month_txv=$(vnstat -i ${vnstat_profile} | grep "$bulan " | awk '{print $6}')
fi
if [ "$(grep -wc yesterday /root/t1)" != '0' ]; then
    yesterday=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $8}')
    yesterday_v=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $9}')
    yesterday_rx=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $2}')
    yesterday_rxv=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $3}')
    yesterday_tx=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $5}')
    yesterday_txv=$(vnstat -i ${vnstat_profile} | grep yesterday | awk '{print $6}')
else
    yesterday=NULL
    yesterday_v=NULL
    yesterday_rx=NULL
    yesterday_rxv=NULL
    yesterday_tx=NULL
    yesterday_txv=NULL
fi

# // SSH Websocket Proxy
ssh_ws=$( systemctl status ws-stunnel | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
if [[ $ssh_ws == "running" ]]; then
    status_ws="${COLOR1}ON${NC}"
else
    status_ws="${RED}OFF${NC}"
fi

# // nginx
nginx=$( systemctl status nginx | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
if [[ $nginx == "running" ]]; then
    status_nginx="${COLOR1}ON${NC}"
else
    status_nginx="${RED}OFF${NC}"
fi

# // SSH Websocket Proxy
xray=$( systemctl status xray | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
if [[ $xray == "running" ]]; then
    status_xray="${COLOR1}ON${NC}"
else
    status_xray="${RED}OFF${NC}"
fi

function add-host(){
clear
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}               ${WH}• ADD VPS HOST •                ${NC} $COLOR1 $NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
read -rp "  New Host Name : " -e host
echo ""
if [ -z $host ]; then
echo -e "  [INFO] Type Your Domain/sub domain"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "  Press any key to back on menu"
menu
else
echo "IP=$host" > /var/lib/alexxa-pro/ipvps.conf
echo ""
echo "  [INFO] Dont forget to renew cert"
echo ""
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "  Press any key to Renew Cret"
crtxray
fi
}
function updatews(){
clear

echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}            ${WH}• UPDATE SCRIPT VPS •              ${NC} $COLOR1 $NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 ${NC}  $COLOR1[INFO]${NC} Check for Script updates"
sleep 2
wget -q -O /root/install_up.sh "https://raw.githubusercontent.com/sreyaeve/sshxrayv3/main/FILE/PLUGINS/install-up.sh" && chmod +x /root/install_up.sh
sleep 2
./install_up.sh
sleep 5
rm /root/install_up.sh
rm /opt/.ver
version_up=$( curl -sS https://raw.githubusercontent.com/sreyaeve/sshxrayv3/main/FILE/PLUGINS/versi)
echo "$version_up" > /opt/.ver
echo -e "$COLOR1 ${NC}  $COLOR1[INFO]${NC} Successfully Up To Date!"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌────────────────────── ${WH}BY${NC} ${COLOR1}───────────────────────┐${NC}"
echo -e "\e[32m            ❇ \e[34mD\033[0m \e[32mI\033[0m \e[33mG\033[0m \e[31mI\033[0m \e[32mT\033[0m \e[35mA\033[0m \e[36mL\033[0m \e[37m-\033[0m \e[34mN\033[0m \e[33mE\033[0m \e[31mT\033[0m \e[32m❇              \033[0m"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo ""
read -n 1 -s -r -p "  Press any key to back on menu"
menu
}
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "\e[32m          C\033[0m \e[31mE\033[0m \e[33mL\033[0m \e[34mL\033[0m \e[35mU\033[0m \e[36mL\033[0m \e[32mA\033[0m \e[31mR\033[0m   \e[33mF\033[0m \e[34mR\033[0m \e[35mE\033[0m \e[36mE\033[0m \e[32mD\033[0m O\033[0m \e[32mM\033[0m"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "\e[32m                  ❇  \e[31mV\033[0m\e[33mP\033[0m\e[34mS\033[0m \e[35mI\033[0m\e[36mN\033[0m\e[37mF\033[0m\e[31mO\033[0m \e[32m❇                  \033[0m"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
uphours=`uptime -p | awk '{print $2,$3}' | cut -d , -f1`
upminutes=`uptime -p | awk '{print $4,$5}' | cut -d , -f1`
uptimecek=`uptime -p | awk '{print $6,$7}' | cut -d , -f1`
cekup=`uptime -p | grep -ow "day"`
IPVPS=$(curl -s ipinfo.io/ip )
serverV=$( curl -sS https://raw.githubusercontent.com/sreyaeve/sshxrayv3/main/FILE/PLUGINS/versi)
if [ "$Isadmin" = "ON" ]; then
uis="${COLOR1}Premium User$NC"
else
uis="${COLOR1}Premium Version$NC"
fi
echo -e "$COLOR1 $NC ${WH}User Roles       ${COLOR1}\e[31m:\033[0m ${WH}$uis"
if [ "$cekup" = "day" ]; then
echo -e "$COLOR1 $NC ${WH}System Uptime    ${COLOR1}\e[31m:\033[0m ${WH}$uphours $upminutes $uptimecek"
else
echo -e "$COLOR1 $NC ${WH}System Uptime    ${COLOR1}\e[31m:\033[0m ${WH}$uphours $upminutes"
fi
echo -e "$COLOR1 $NC ${WH}Operating System ${COLOR1}\e[31m:\033[0m "`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`
echo -e "$COLOR1 $NC ${WH}Memory Usage     ${COLOR1}\e[31m:\033[0m ${WH}$uram / $tram"
echo -e "$COLOR1 $NC ${WH}ISP              ${COLOR1}\e[31m:\033[0m ${WH}$ISP "
echo -e "$COLOR1 $NC ${WH}City             ${COLOR1}\e[31m:\033[0m ${WH}$CITY"
echo -e "$COLOR1 $NC ${WH}Current Domain   ${COLOR1}\e[31m:\033[0m ${WH}$(cat /etc/xray/domain)"
echo -e "$COLOR1 $NC ${WH}IP-VPS           ${COLOR1}\e[31m:\033[0m ${WH}$IPVPS${NC}"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 $NC ${WH}[ SSH WS \e[31m:\033[0m ${status_ws} ${WH}]  ${WH}[ XRAY \e[31m:\033[0m ${status_xray} ${WH}]   ${WH}[ NGINX \e[31m:\033[0m ${status_nginx} ${WH}] $COLOR1 $NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 ${COLOR1}Traffic${NC}      ${COLOR1}Today      Yesterday      Month   ${NC}"
echo -e "$COLOR1 ${WH}Download${NC}   ${WH}$today_tx $today_txv     $yesterday_tx $yesterday_txv     $month_tx $month_txv   ${NC}"
echo -e "$COLOR1 ${WH}Upload${NC}     ${WH}$today_rx $today_rxv     $yesterday_rx $yesterday_rxv     $month_rx $month_rxv   ${NC}"
echo -e "$COLOR1 ${COLOR1}Total${NC}    ${COLOR1}  $todayd $today_v    $yesterday $yesterday_v     $month $month_v  ${NC} "
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e "\e[32m                  ❇  \e[31mM\033[0m\e[33m-\033[0m\e[34mE\033[0m\e[35m-\033[0m\e[36mN\033[0m\e[37m-\033[0m\e[31mU\033[0m\e[32m ❇                   \033[0m"
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "  ${WH}[${COLOR1}01${WH}]${NC} ${COLOR1}\e[31m•\033[0m ${WH}SSHWS   ${WH}[${COLOR1}${status_ws}${WH}]   ${WH}[${COLOR1}07${WH}]${NC} ${COLOR1}\e[31m•\033[0m ${WH}THEME    ${WH}[${COLOR1}Menu${WH}]  $COLOR1 $NC"   
echo -e "  ${WH}[${COLOR1}02${WH}]${NC} ${COLOR1}\e[31m•\033[0m ${WH}VMESS   ${WH}[${COLOR1}${status_xray}${WH}]   ${WH}[${COLOR1}08${WH}]${NC} ${COLOR1}\e[31m•\033[0m ${WH}BACKUP   ${WH}[${COLOR1}Menu${WH}]  $COLOR1 $NC"  
echo -e "  ${WH}[${COLOR1}03${WH}]${NC} ${COLOR1}\e[31m•\033[0m ${WH}VLESS   ${WH}[${COLOR1}${status_xray}${WH}]   ${WH}[${COLOR1}09${WH}]${NC} ${COLOR1}\e[31m•\033[0m ${WH}ADD HOST/DOMAIN  $COLOR1 $NC"  
echo -e "  ${WH}[${COLOR1}04${WH}]${NC} ${COLOR1}\e[31m•\033[0m ${WH}TROJAN  ${WH}[${COLOR1}${status_xray}${WH}]   ${WH}[${COLOR1}10${WH}]${NC} ${COLOR1}\e[31m•\033[0m ${WH}RENEW CERT       $COLOR1 $NC"  
echo -e "  ${WH}[${COLOR1}05${WH}]${NC} ${COLOR1}\e[31m•\033[0m ${WH}SS WS   ${WH}[${COLOR1}ON${WH}]   ${WH}[${COLOR1}11${WH}]${NC} ${COLOR1}\e[31m•\033[0m ${WH}SETTINGS ${WH}[${COLOR1}Menu${WH}]  $COLOR1 $NC"
echo -e "  ${WH}[${COLOR1}06${WH}]${NC} ${COLOR1}\e[31m•\033[0m ${WH}SET DNS ${WH}[${COLOR1}Menu${WH}] ${WH}[${COLOR1}12${WH}]${NC} ${COLOR1}\e[31m•\033[0m ${WH}INFO     ${WH}[${COLOR1}Menu${WH}]  $COLOR1 $NC"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
myver="$(cat /opt/.ver)"

if [[ $serverV > $myver ]]; then
echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 $NC ${WH}[${COLOR1}100${WH}]${NC} ${COLOR1}• ${WH}UPDATE TO V$serverV${NC}" 
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
up2u="updatews"
else
up2u="menu"
fi

DATE=$(date +'%Y-%m-%d')
datediff() {
    d1=$(date -d "$1" +%s)
    d2=$(date -d "$2" +%s)
    echo -e "$COLOR1 $NC Expiry In   : $(( (d1 - d2) / 86400 )) Days"
}
mai="datediff "$Exp" "$DATE""

today=`date -d "0 days" +"%Y-%m-%d"`

# CERTIFICATE STATUS
d1=$(date -d "$exp" +%s)
d2=$(date -d "$today" +%s)
certificate=$(( (d1 - d2) / 86400 ))

echo -e "$COLOR1┌─────────────────────────────────────────────────┐${NC}"
echo -e "$COLOR1 $NC ${WH}Version     ${COLOR1}: ${WH} 4.0 Latest Version${NC}"
echo -e "$COLOR1 $NC ${WH}Client Name ${COLOR1}: ${WH} Digital-Net${NC}"
echo -e "$COLOR1 $NC ${WH}License     ${COLOR1}: ${WH} Lifetime${NC}"
echo -e "$COLOR1└─────────────────────────────────────────────────┘$NC"
echo -e "$COLOR1┌────────────────────── ${WH}BY${NC} ${COLOR1}───────────────────────┐${NC}"
echo -e "\e[32m            ❇ \e[34mD\033[0m \e[32mI\033[0m \e[33mG\033[0m \e[31mI\033[0m \e[32mT\033[0m \e[35mA\033[0m \e[36mL\033[0m \e[37m-\033[0m \e[34mN\033[0m \e[33mE\033[0m \e[31mT\033[0m \e[32m❇              \033[0m"
echo -e "$COLOR1└─────────────────────────────────────────────────┘${NC}"
echo -e ""
echo -ne " ${WH}Select menu ${COLOR1}: ${WH}"; read opt
case $opt in
01 | 1) clear ; menu-ssh ;;
02 | 2) clear ; menu-vmess ;;
03 | 3) clear ; menu-vless ;;
04 | 4) clear ; menu-trojan ;;
05 | 5) clear ; menu-ss ;;
06 | 6) clear ; menu-dns ;;
07 | 7) clear ; menu-theme ;;
08 | 8) clear ; menu-backup ;;
09 | 9) clear ; add-host ;;
10) clear ; crtxray ;;
11) clear ; menu-set ;;
12) clear ; info ;;
100) clear ; $up2u ;;
00 | 0) clear ; menu ;;
*) clear ; menu ;;
esac
