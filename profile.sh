set -e -o pipefail

ps aux | grep python3 | grep profile

while true
do
  ps aux | grep python3 | grep profile | cut -c -200
  sleep 1m
done