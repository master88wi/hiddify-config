HEX_TELEGRAM_DOMAIN=$(echo -n "$TELEGRAM_FAKE_TLS_DOMAIN" | xxd -ps | tr -d '\n')
CLOUD_PROVIDER=${CLOUD_PROVIDER:-$MAIN_DOMAIN}
GUID_SECRET="${USER_SECRET:0:8}-${USER_SECRET:8:4}-${USER_SECRET:12:4}-${USER_SECRET:16:4}-${USER_SECRET:20:12}"

PANEL_STATIC_ROOT=$(python3 -c 'import os,hiddifypanel;print(os.path.dirname(hiddifypanel.__file__)+"/static")')

for template_file in $(find . -name "*.template"); do
    out_file=${template_file/.template/}
    cp $template_file $out_file

    # if [[ "$ENABLE_HTTP_PROXY" == "true" ]];then
    #     # sed -i 's|"port": 499,|"port": 80,|g' $out_file
    #     # sed -i 's|listen 80;|listen 82;|g' $out_file
    #     echo "http proxy on port 80 is temporary disabled"
    # fi

    # sed -i "s|defaultusersecret|$USER_SECRET|g" $out_file
    sed -i "s|ADMIN_SECRET|$ADMIN_SECRET|g" $out_file
    # sed -i "s|defaultuserguidsecret|$GUID_SECRET|g" $out_file
    sed -i "s|TELEGRAM_USER_SECRET|$TELEGRAM_USER_SECRET|g" $out_file
    sed -i "s|defaultcloudprovider|$CLOUD_PROVIDER|g" $out_file
    sed -i "s|defaultserverip|$SERVER_IP|g" $out_file
    sed -i "s|DECOY_DOMAIN|$DECOY_DOMAIN|g" $out_file
    sed -i "s|NO_CDN_DOMAIN|$NO_CDN_DOMAIN|g" $out_file
    sed -i "s|defaultserverhost|$MAIN_DOMAIN|g" $out_file
    sed -i "s|TELEGRAM_AD_TAG|$TELEGRAM_AD_TAG|g" $out_file
    sed -i "s|TELEGRAM_FAKE_TLS_DOMAIN|${TELEGRAM_FAKE_TLS_DOMAIN:-localhost}|g" $out_file
    sed -i "s|PANEL_STATIC_ROOT|${PANEL_STATIC_ROOT:-/usr/local/lib/python3.10/dist-packages/hiddifypanel/static/}|g" $out_file
    sed -i "s|sstlsdomain|${SS_FAKE_TLS_DOMAIN:-localhost}|g" $out_file
    sed -i "s|shadowtlsdomain|${SHADOWTLS_FAKEDOMAIN:-localhost}|g" $out_file
    sed -i "s|ssrtlsdomain|${SSR_FAKEDOMAIN:-localhost}|g" $out_file
    sed -i "s|hextelegramdomain|${HEX_TELEGRAM_DOMAIN:-localhost}|g" $out_file
    sed -i "s|CDN_NAME|${CDN_NAME:-ar}|g" $out_file
    sed -i "s|GITHUB_REPOSITORY|$GITHUB_REPOSITORY|g" $out_file
    sed -i "s|GITHUB_USER|$GITHUB_USER|g" $out_file
    sed -i "s|GITHUB_BRANCH_OR_TAG|$GITHUB_BRANCH_OR_TAG|g" $out_file
    sed -i "s|BASE_PROXY_PATH|$BASE_PROXY_PATH|g" $out_file
    sed -i "s|//$COUNTRY||g" $out_file
    sed -i "s|#$COUNTRY||g" $out_file

    sed -i "s|PATH_VLESS|$PATH_VLESS|g" $out_file
    sed -i "s|PATH_VMESS|$PATH_VMESS|g" $out_file
    sed -i "s|PATH_TROJAN|$PATH_TROJAN|g" $out_file
    sed -i "s|PATH_SS|$PATH_SS|g" $out_file

    sed -i "s|PATH_TCP|$PATH_TCP|g" $out_file
    sed -i "s|PATH_WS|$PATH_WS|g" $out_file
    sed -i "s|PATH_GRPC|$PATH_GRPC|g" $out_file

done

rm /opt/hiddify-server/xray/configs/*.json
rm /opt/hiddify-server/singbox/configs/*.json
rm /opt/hiddify-server/haproxy/*.cfg
python -c "import json5;import jinja2" || pip install json5 jinja2
python3 /opt/hiddify-server/common/jinja.py
