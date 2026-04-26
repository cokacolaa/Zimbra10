#!/bin/bash
sleep 1

echo "Add host , sua hostname ,comment toan bo ipv6 trong /etc/hosts truoc khi  chay script nhe AE "
echo "Dung quen buoc tren "
sleep 5
echo " Update OS"
apt update && apt upgrade -y

echo "Turn off IPv6"

cat << EOF >> /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

sysctl -p


echo "Change nameserver resolv.conf"

sudo rm -f /etc/resolv.conf

sudo bash -c 'cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF'


apt remove  exim4* -y
IP=$(curl ifconfig.me)
HOSTNAME=$(hostname -a)
DOMAIN=$(hostname -d)

echo "Dang chuan bi cai dat Zimbra 10.1.0 + Update tinh nang dang nhap xac minh 2 buoc"
sleep 1


mkdir -p  /opt/zimbra/libexec
cd /opt/zimbra/libexec
wget https://raw.githubusercontent.com/cokacolaa/Zimbra10/refs/heads/main/zmsetup.pl
chmod 777 zmsetup.pl

## Preparing all the variables like IP, Hostname, etc, all of them from the container
sleep 3

LENGTH=10


PASSWORD=$(< /dev/urandom tr -dc 'A-Za-z0-9' | head -c $LENGTH)
echo "Random Password : $PASSWORD"


HOSTNAME=$(hostname -a)
DOMAIN=$(hostname -d)
RANDOMHAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMSPAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMVIRUS=$(date +%s|sha256sum|base64|head -c 10)
mkdir -p /opt/zimbra-install/


touch /opt/zimbra-install/installZimbra-keystrokes
cat << EOF >> /opt/zimbra-install/installZimbra-keystrokes
Y
Y
Y
Y
Y
N
Y
Y
Y
Y
Y
Y
Y
Y
Y
Y
EOF

IP=$(curl ifconfig.me)
##Creating the Zimbra Collaboration Config File ##
touch /opt/zimbra-install/installZimbraScript
cat <<EOF >/opt/zimbra-install/installZimbraScript
AVDOMAIN="$DOMAIN"
AVUSER="admin@$DOMAIN"
CREATEADMIN="admin@$DOMAIN"
CREATEADMINPASS="$PASSWORD"
CREATEDOMAIN="$DOMAIN"
DOCREATEADMIN="yes"
DOCREATEDOMAIN="yes"
DOTRAINSA="yes"
EXPANDMENU="no"
HOSTNAME="$HOSTNAME.$DOMAIN"
HTTPPORT="8080"
HTTPPROXY="TRUE"
HTTPPROXYPORT="80"
HTTPSPORT="8443"
HTTPSPROXYPORT="443"
IMAPPORT="7143"
IMAPPROXYPORT="143"
IMAPSSLPORT="7993"
IMAPSSLPROXYPORT="993"
INSTALL_WEBAPPS="service zimlet zimbra zimbraAdmin"
JAVAHOME="/opt/zimbra/common/lib/jvm/java"
LDAPAMAVISPASS="$PASSWORD"
LDAPPOSTPASS="$PASSWORD"
LDAPROOTPASS="$PASSWORD"
LDAPADMINPASS="$PASSWORD"
LDAPREPPASS="$PASSWORD"
LDAPBESSEARCHSET="set"
LDAPDEFAULTSLOADED="1"
LDAPHOST="$HOSTNAME.$DOMAIN"
LDAPPORT="389"
LDAPREPLICATIONTYPE="master"
LDAPSERVERID="2"
MAILBOXDMEMORY="512"
MAILPROXY="TRUE"
MODE="https"
MYSQLMEMORYPERCENT="30"
POPPORT="7110"
POPPROXYPORT="110"
POPSSLPORT="7995"
POPSSLPROXYPORT="995"
PROXYMODE="https"
REMOVE="no"
RUNARCHIVING="no"
RUNAV="yes"
RUNCBPOLICYD="no"
RUNDKIM="yes"
RUNSA="yes"
RUNVMHA="no"
SERVICEWEBAPP="yes"
SMTPDEST="admin@$DOMAIN"
SMTPHOST="$HOSTNAME.$DOMAIN"
SMTPNOTIFY="yes"
SMTPSOURCE="admin@$DOMAIN"
SNMPNOTIFY="yes"
SNMPTRAPHOST="$HOSTNAME.$DOMAIN"
SPELLURL="http://$HOSTNAME.$DOMAIN:7780/aspell.php"
STARTSERVERS="yes"
SYSTEMMEMORY="3.8"
TRAINSAHAM="ham.$RANDOMHAM@$DOMAIN"
TRAINSASPAM="spam.$RANDOMSPAM@$DOMAIN"
UIWEBAPPS="yes"
UPGRADE="yes"
USEKBSHORTCUTS="TRUE"
USESPELL="yes"
VERSIONUPDATECHECKS="TRUE"
VIRUSQUARANTINE="virus-quarantine.$RANDOMVIRUS@$DOMAIN"
ZIMBRA_REQ_SECURITY="yes"
ldap_bes_searcher_password="$PASSWORD"
ldap_dit_base_dn_config="cn=zimbra"
ldap_nginx_password="$PASSWORD"
ldap_url="ldap://$HOSTNAME.$DOMAIN:389"
mailboxd_directory="/opt/zimbra/mailboxd"
mailboxd_keystore="/opt/zimbra/mailboxd/etc/keystore"
mailboxd_keystore_password="$PASSWORD"
mailboxd_server="jetty"
mailboxd_truststore="/opt/zimbra/common/lib/jvm/java/lib/security/cacerts"
mailboxd_truststore_password="changeit"
postfix_mail_owner="postfix"
postfix_setgid_group="postdrop"
ssl_default_digest="sha256"
zimbraDNSMasterIP=""
zimbraDNSTCPUpstream="no"
zimbraDNSUseTCP="yes"
zimbraDNSUseUDP="yes"
zimbraDefaultDomainName="$DOMAIN"
zimbraFeatureBriefcasesEnabled="Enabled"
zimbraFeatureTasksEnabled="Enabled"
zimbraIPMode="ipv4"
zimbraMailProxy="FALSE"

#zimbraMtaMyNetworks="127.0.0.0/8 $CONTAINERIP/32 [::1]/128 [fe80::]/64"
zimbraMtaMyNetworks="127.0.0.0/8 $IP/32 [::1]/128 [fe80::]/64"
zimbraPrefTimeZoneId="Bangkok/Hanoi/Jakarta"
zimbraReverseProxyLookupTarget="TRUE"
zimbraVersionCheckInterval="1d"
zimbraVersionCheckNotificationEmail="admin@$DOMAIN"
zimbraVersionCheckNotificationEmailFrom="admin@$DOMAIN"
zimbraVersionCheckSendNotifications="TRUE"
zimbraWebProxy="FALSE"
zimbra_ldap_userdn="uid=zimbra,cn=admins,cn=zimbra"
zimbra_require_interprocess_security="1"
zimbra_server_hostname="$HOSTNAME.$DOMAIN"
INSTALL_PACKAGES="zimbra-core zimbra-ldap zimbra-logger zimbra-mta zimbra-snmp zimbra-store zimbra-apache zimbra-spell zimbra-memcached zimbra-proxy"
EOF

apt update -y && apt-get update -y


#service themdns restart
cd /opt/zimbra-install
echo "Downloading Zimbra 10.1.16"

wget https://cdn.techfiles.online/ubuntu/zcs-10.1.16_GA_0226.UBUNTU22_64.20260409134039.tgz

tar -xzvf zcs-10.1.16_GA_0226.UBUNTU22_64.20260409134039.tgz
cd zcs-10.1.16_GA_0226.UBUNTU22_64.20260409134039

echo "Installing Zimbra Collaboration just the Software"
./install.sh -s < /opt/zimbra-install/installZimbra-keystrokes

echo "Installing Zimbra Collaboration injecting the configuration"
/opt/zimbra/libexec/zmsetup.pl -c /opt/zimbra-install/installZimbraScript

su - zimbra -c 'zmupdateauthkeys'



/opt/zimbra/libexec/zmsyslogsetup

#service themdns restart
echo  "Load libphp7.so:"
cd /opt/zimbra/common/lib/apache2/modules/
wget https://github.com/cokacolaa/Zimbra10/blob/main/libphp7.so
#echo " Dang cai dat va thiet lap policyD"
#cd /tmp
#wget http://45.117.80.173/policyd.sh
#chmod 777 policyd.sh
#./policyd.sh
#su - zimbra -c 'zmprov ms $(zmhostname) +zimbraServiceEnabled cbpolicyd'
#su - zimbra -c 'zmprov ms $(zmhostname) zimbraCBPolicydQuotasEnabled TRUE'
#su - zimbra -c 'zmmtactl restart'
#su - zimbra -c 'zmcbpolicydctl start'
#sleep 10
#Thiet lap chinh sach password toi thieu 10 ky tu bao gom it nhat 1 chu Hoa 1 chu so va do dai toi thieu bang 10, han su dung 180 ngay

su - zimbra -c 'zmprov mc default zimbraPasswordMinNumericChars 1'
su - zimbra -c 'zmprov mc default zimbraPasswordMinLowerCaseChars 1'
su - zimbra -c 'zmprov mc default zimbraPasswordMinUpperCaseChars 1'
su - zimbra -c 'zmprov mc default zimbraPasswordMinLength 10'
su - zimbra -c 'zmprov mc default zimbraPasswordMaxAge 180'
#Dinh kem 25Mb
su - zimbra -c 'zmprov modifyConfig zimbraMtaMaxMessageSize 50000000'
su - zimbra -c 'zmprov modifyConfig zimbraFileUploadMaxSize 50000000'
su - zimbra -c 'zmprov modifyConfig zimbraMailContentMaxSize 50000000'

#service themdns restart

echo "Thiet lap blacklist reject_rbl_client= zen.spamhaus.org + bl.spamcorp.net"

su - zimbra -c 'zmprov mcf zimbraMtaRestriction "reject_rbl_client zen.spamhaus.org"'
su - zimbra -c 'zmprov mcf +zimbraMtaRestriction "reject_rbl_client bl.spamcorp.net"'
su - zimbra -c 'zmprov mcf +zimbraMtaRestriction reject_unknown_client_hostname'
su - zimbra -c 'zmprov mcf +zimbraMtaRestriction reject_unknown_sender_domain'
su - zimbra -c 'zmprov mcf +zimbraMtaRestriction reject_unverified_recipient'
# Make Zimbra only accept mail for existing accounts
#su - zimbra -c 'zmprov mcf +zimbraMtaRestriction reject_unverified_recipient'


su - zimbra -c 'zmlocalconfig -e antispam_enable_rule_updates=true'
su - zimbra -c 'zmlocalconfig -e antispam_enable_restarts=true'
su - zimbra -c 'zmlocalconfig -e antispam_enable_rule_compilation=true'

#Allow file ma hoa VirusHeu
sed -i 's/%%uncomment VAR:zimbraVirusBlockEncryptedArchive%%AlertEncrypted yes/%%uncomment VAR:zimbraVirusBlockEncryptedArchive%%AlertEncrypted no/g' /opt/zimbra/conf/clamd.conf.in

echo "Dang them tinh nang chong khai thac memcached"

su - zimbra -c '/opt/zimbra/bin/zmprov ms `zmhostname` zimbraMemcachedBindAddress 127.0.0.1' 
su - zimbra -c '/opt/zimbra/bin/zmprov ms `zmhostname` zimbraMemcachedClientServerList 127.0.0.1'

#service themdns restart


chattr +i /etc/hosts

################################################################

#echo "Thiet lap tu choi nhan email authen sasl_ "
#su - zimbra -c 'zmprov mcf zimbraMtaSmtpdRejectUnlistedRecipient yes'
#su - zimbra -c 'zmprov mcf zimbraMtaSmtpdRejectUnlistedSender yes'

#su - zimbra -c 'zmprov mcf zimbraMtaSmtpdSenderLoginMaps proxy:ldap:/opt/zimbra/conf/ldap-slm.cf +zimbraMtaSmtpdSenderRestrictions reject_authenticated_sender_login_mismatch'

#sed -i 's/permit_mynetworks/permit_mynetworks, reject_sender_login_mismatch/' /opt/zimbra/conf/zmconfigd/smtpd_sender_restrictions.cf

##########################################################################################################################################
#su - zimbra -c 'zmprov mcf +zimbraMtaBlockedExtension exe'
#su - zimbra -c 'zmprov mcf +zimbraMtaBlockedExtension bat'

su - zimbra -c 'zmprov mcf zimbraMtaRestriction reject_unknown_sender_domain'

echo "Gui thong bao cho nguoi dung ngay khi mailbox sap day"

su - zimbra -c 'zmprov mcf zimbraLmtpPermanentFailureWhenOverQuota TRUE'
#################################################################
#echo "Thong bao cho nguoi dung khi email khong gui di duoc "

#su - zimbra -c 'zmprov mcf zimbraMtaDelayWarningTime 10m'
##################################################################


#service themdns restart
#lsof -ti tcp:389 | xargs kill -9

echo "Test report lan dau tien"

IP=$(curl ifconfig.me)
TOKEN="7369190083:AAHk6hmI5Maj9YY54C7Xg4ErNBHhOcjvzyE"
CHAT_ID="-4268880510"
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
curl -s -X POST $URL -d chat_id=$CHAT_ID -d text=" $IP $(hostname -a).$(hostname -d) dang cai dat Zimbra10.1"

cd /tmp
wget 'https://github.com/maldua-suite/zimbra-maldua-2fa/releases/download/v0.9.5/zimbra-maldua-2fa_0.9.5.tar.gz'
tar xzf zimbra-maldua-2fa_0.9.5.tar.gz
cd zimbra-maldua-2fa_0.9.5
./install.sh

cd /opt
echo "=== Setup Zimbra Monitor Scripts ==="


echo "Dang tai script..."

wget -q -O checkservicezimbra2.sh https://raw.githubusercontent.com/cokacolaa/Zimbra10/refs/heads/main/checkservicezimbra2.sh
wget -q -O bashqueuezimbra.sh https://raw.githubusercontent.com/cokacolaa/Zimbra10/refs/heads/main/bashqueuezimbra.sh

chmod +x checkservicezimbra2.sh bashqueuezimbra.sh

echo "Dang cai dat cron..."

CRON1="*/10 * * * * /opt/checkservicezimbra2.sh >/dev/null 2>&1"
CRON2="*/10 * * * * /opt/bashqueuezimbra.sh >/dev/null 2>&1"

(crontab -l 2>/dev/null | grep -v "checkservicezimbra2.sh" | grep -v "bashqueuezimbra.sh"; echo "$CRON1"; echo "$CRON2") | crontab -

echo "=== DONE ==="
echo "Cron job da duoc cai dat moi 10 phut"

su - zimbra -c 'zmprov mcf zimbraModernWebClientDisabled TRUE'


#lsof -ti tcp:389 | xargs kill -9

su - zimbra -c 'zmcontrol restart'
echo "Neu nhu cai dat thanh cong bang co the dang nhap https://$IP:7071 voi tai khoan admin,passsword $PASSWORD cung voi cac chinh sach:"
echo "Da thiet lap chinh sach gui 300 email 1h va nhan 1000 email 1h, vi pham thi tai khoan khong the gui email , bao loi tai giao dien nguoi dung khi click sent"
echo "Rate limit any sender from sending more then 300  emails every 3600 seconds. Messages beyond this limit are deferred. Rate limit any @domain from receiving more then 1000 emails in a 3600 second period. Messages beyond this rate are rejected."
echo "Da thiet lap chinh sach password toi thieu 10 ky tu bao gom it nhat 1 chu hoa 1 chu so, han su dung 180 ngay"
echo "Da thiet lap chinh sach email dinh kem ~ 35MB "
echo "Da thiet lap 1 reject_rbl_client= zen.spamhaus.org "
echo "Da them script check service,ban canh bao telegram moi 10 phut"
echo "Da them script check mail queue, ban canh bao telegam moi 10 phut"
echo "Cac viec co the con phai lam la tro ban ghi, add PTR, add CheckMK va Zabbix.  >> Cap nhat cau hinh gui nguoi phu trach quan ly email"

#echo " Tat giao dien modern "
#su - zimbra -c 'zmprov mcf zimbraModernWebClientDisabled TRUE'
echo "Enable DKIM:"
su - zimbra -c '/opt/zimbra/libexec/zmdkimkeyutil -a -d $(hostname -d)' 
echo "GET DKIM:"
su - zimbra -c '/opt/zimbra/libexec/zmdkimkeyutil -q -d $(hostname -d)' 
echo "SPF tai relay Ha Noi ,HCM thay include tuong ung"
echo "  @  TXT v=spf1 +mx +ip4:$IP include:spf.nhanhoa.com -all "
echo "_dmarc tieu chuan chung"
echo "  _dmarc  TXT v=DMARC1;p=none;pct=100;rua=mailto:postmaster@$(hostname -d) "

su - zimbra -c 'zmcontrol status'

apt install locales -y
locale-gen vi_VN.UTF-8

mv /etc/localtime /etc/localtime.Old && ln -s /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi








