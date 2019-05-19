# TODO remove when no longer publishing to emberfire-exp
export EMBER_CLI_IGNORE_ADDON_NAME_MISMATCH=true

wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list

apt-get -y update
apt-get -y install google-chrome-stable

# Already built, don't need to do that again
npx ember test