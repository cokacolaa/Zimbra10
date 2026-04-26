#Bash queues zimbra

IP=$(curl ifconfig.me)

TOKEN="7369190083:AAHk6hmI5Maj9YY54C7Xg4ErNBHhOcjvzyE"
CHAT_ID="-4268880510"
URL="https://api.telegram.org/bot$TOKEN/sendMessage"
count=$(/opt/zimbra/libexec/zmqstat |grep -i deferred |cut -d "=" -f2)

if [ "$count" -ge "50" ];then
curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="[WARNING QUEUE ], Mail queue $IP $(hostname -a).$(hostname -d)  la '$count' ,Hay xu ly!!!"
fi
