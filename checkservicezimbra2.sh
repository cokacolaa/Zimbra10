#!/bin/bash
clear
#IP=$(curl ifconfig.me)
IP=$(hostname -I | awk '{print $2}')
yes | rm /tmp/status-ZCS.txt
su - zimbra -c 'zmcontrol status' > /tmp/status-ZCS.txt
#Report telegram
send_telegram_message() {
    # Replace 'YOUR_BOT_TOKEN' and 'YOUR_CHAT_ID' with actual values
    BOT_TOKEN="7369190083:AAHk6hmI5Maj9YY54C7Xg4ErNBHhOcjvzyE"
    CHAT_ID="-4268880510"
    MESSAGE="$1"
    curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"
}

#Check LDAP
if grep -q "ldap *Stopped" "/tmp/status-ZCS.txt"; then
    echo "LDAP is stopped. Sending Telegram notification."
    send_telegram_message "LDAP khong hoat dong tai Zimbra https://$IP:7071 ,ky thuat hay ssh kiem tra gap."
else
    echo "LDAP is running. Proceeding with service check."
    # Liet ke danh sach dich vu
    #services="amavis antispam antivirus cbpolicyd logger mailbox memcached mta opendkim proxy snmp zmconfigd stats spel"
    services="zmconfigd logger mailbox memcached  proxy amavis antispam antivirus opendkim snmp spell mta stats cbpolicyd "
    # Kiem tra tung dich vu
    for service in $services; do
        if grep -q "$service *Stopped" "/tmp/status-ZCS.txt"; then
            echo "Da tim thay : $service Stopped"
            echo "Restart service $service"
        case $service in
            zmconfigd)
                su - zimbra -c 'zmconfigdctl restart'
                ;;
            logger)
                su - zimbra -c 'zmloggerctl restart'
                ;;
            mailbox)
                su - zimbra -c 'zmmailboxdctl restart'
                ;;
            memcached)
                su - zimbra -c 'zmmemcachedctl restart'
                ;;
            proxy)
                su - zimbra -c 'zmproxyctl restart'
                ;;
            amavis) 
                su - zimbra -c 'zmamavisdctl restart'
                ;;
            antispam) 
                su - zimbra -c 'zmantispamctl restart'
                ;;
            antivirus)
                su - zimbra -c 'zmantivirusctl restart'
                ;;
            opendkim)
                su - zimbra -c 'zmopendkimctl restart'
                ;;
            snmp)
                su - zimbra -c 'zmswatchctl restart'
                ;;
            spell)
                su - zimbra -c 'zmspellctl restart'
                ;;
            mta)
                su - zimbra -c 'zmmtactl restart'
                ;;
            stats)
                su - zimbra -c 'zmstatctl restart'
                ;;
            cbpolicyd)
                su - zimbra -c 'zmcbpolicydctl restart'
                ;;
        esac
            send_telegram_message "Kiem tra dich vu $service khong hoat dong tai $IP hostname https://$(hostname -a).$(hostname -d) >> Da khoi dong lai dich vụ $service"
        else
            echo "Status service $service OK"
        fi
    done
fi


