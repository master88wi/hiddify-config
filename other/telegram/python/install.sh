source /opt/hiddify-server/common/utils.sh
install_package python3 python3-uvloop python3-cryptography python3-socks libcap2-bin

useradd --no-create-home -s /usr/sbin/nologin tgproxy
git clone https://github.com/alexbers/mtprotoproxy
cp config.default mtprotoproxy/config.py.template
