source ./lib/acme.sh.env

# MAIN_DOMAIN="$MAIN_DOMAIN;$SERVER_IP.sslip.io"
DOMAINS=${MAIN_DOMAIN//;/ }

#echo "location /.well-known/acme-challenge {proxy_pass http://127.0.0.1:81;}" >/opt/hiddify-server/nginx/parts/acme.conf
mkdir -p /opt/hiddify-server/acme.sh/www/.well-known/acme-challenge
echo "location /.well-known/acme-challenge {root /opt/hiddify-server/acme.sh/www/;}" >/opt/hiddify-server/nginx/parts/acme.conf
systemctl reload hiddify-nginx

# echo -e "Permanent Admin link: \n   http://$SERVER_IP/$BASE_PROXY_PATH/$ADMIN_SECRET/admin/ \n" >>$DST
# echo -e "Secure Admin links: \n" >>$DST

ssl_cert_path=../ssl
for file in "$ssl_cert_path"/*; do
	filename=$(basename "$file")
	if [[ ! " ${DOMAINS[*]} " =~ "${filename}" ]]; then
		echo "Removing $filename"
		rm "$file"
	fi
done
for DOMAIN in $DOMAINS; do
	DOMAIN_IP=$(dig +short -t a $DOMAIN.)
	echo "resolving domain $DOMAIN -> IP= $DOMAIN_IP ServerIP-> $SERVER_IP"
	if [[ $SERVER_IP != $DOMAIN_IP ]]; then
		echo "maybe it is an error! make sure that it is correct"
		#sleep 10
	fi

	flags=
	if [ "$SERVER_IPv6" != "" ]; then
		flags="--listen-v6"
	fi
	# --server  letsencrypt
	# ./lib/acme.sh --issue --standalone --local-address 127.0.0.1 --httpport 81 -d $DOMAIN --log $(pwd)/../log/system/acme.log --server letsencrypt
	# ./lib/acme.sh --issue --standalone --local-address 127.0.0.1 --httpport 81 -d $DOMAIN --log $(pwd)/../log/system/acme.log
	./lib/acme.sh --issue -w /opt/hiddify-server/acme.sh/www/ -d $DOMAIN --log $(pwd)/../log/system/acme.log --server letsencrypt
	./lib/acme.sh --issue -w /opt/hiddify-server/acme.sh/www/ -d $DOMAIN --log $(pwd)/../log/system/acme.log

	# ./lib/acme.sh --issue --nginx -d $DOMAIN --log $(pwd)/../log/system/acme.log $flags --server letsencrypt
	# ./lib/acme.sh --issue --nginx -d $DOMAIN --log $(pwd)/../log/system/acme.log $flags

	# pids=$(/usr/bin/lsof -t -i:80 2>/dev/null | tr '\n' ' ')
	# # ./lib/acme.sh --issue  --standalone  -d $DOMAIN --log $(pwd)/../log/system/acme.log $flags --server letsencrypt --pre-hook "/usr/bin/systemctl stop hiddify-xray;if [ -n '$pids' ]; then /usr/bin/kill -9 $pids; fi || echo 'nothing to kill'"
	# ./lib/acme.sh --issue --standalone -d $DOMAIN --log $(pwd)/../log/system/acme.log $flags --server letsencrypt --pre-hook "if [ -n '$pids' ]; then /usr/bin/kill -9 $pids; fi || echo 'nothing to kill'"
	# pids=$(/usr/bin/lsof -t -i:80 2>/dev/null | tr '\n' ' ')
	# #if [[ $? != 130 && $? != 0 ]];then
	# # ./lib/acme.sh --issue  --standalone  -d $DOMAIN --log $(pwd)/../log/system/acme.log $flags --pre-hook "/usr/bin/systemctl stop hiddify-xray;if [ -n '$pids' ]; then /usr/bin/kill -9 $pids; fi || echo 'nothing to kill'"
	# ./lib/acme.sh --issue --standalone -d $DOMAIN --log $(pwd)/../log/system/acme.log $flags --pre-hook "if [ -n '$pids' ]; then /usr/bin/kill -9 $pids; fi || echo 'nothing to kill'"
	#fi
	./lib/acme.sh --installcert -d $DOMAIN \
		--fullchainpath $ssl_cert_path/$DOMAIN.crt \
		--keypath $ssl_cert_path/$DOMAIN.crt.key \
		--reloadcmd "echo success"

	# if [[ $(dig +short -t a $DOMAIN.) ]];then

	if [[ $? != 0 ]]; then
		rm $ssl_cert_path/$DOMAIN.key $ssl_cert_path/$DOMAIN.crt
		openssl req -x509 -newkey rsa:2048 -keyout $ssl_cert_path/$DOMAIN.crt.key -out $ssl_cert_path/$DOMAIN.crt -days 3650 -nodes -subj "/C=GB/ST=London/L=London/O=Google Trust Services LLC/CN=www.google.com"
	fi
	rm $ssl_cert_path/$DOMAIN.key
	# 	certbot certonly --standalone --http-01-port 80 --register-unsafely-without-email -d $DOMAIN --non-interactive --agree-tos --logs-dir $(pwd)/../log/system/
	# fi
	# if [[ -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem && -f /etc/letsencrypt/live/$DOMAIN/privkey.pem ]];then
	# 	rm $ssl_cert_path/$DOMAIN.key $ssl_cert_path/$DOMAIN.crt
	# 	ln -sf /etc/letsencrypt/live/$DOMAIN/fullchain.pem $ssl_cert_path/$DOMAIN.crt
	# 	ln -sf /etc/letsencrypt/live/$DOMAIN/privkey.pem $ssl_cert_path/$DOMAIN.key

	# fi
	chmod 644 $ssl_cert_path/$DOMAIN.crt.key
done
# systemctl start hiddify-xray
systemctl reload hiddify-haproxy

./lib/acme.sh --uninstall-cronjob
echo "" >/opt/hiddify-server/nginx/parts/acme.conf
systemctl reload hiddify-nginx
