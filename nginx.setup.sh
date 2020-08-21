cat > /etc/nginx/sites-enabled/default <<EOF
        server {
        listen   80;
        server_name  nginx.osauer.local;
        access_log  /var/logs;
        root   /var/www/html/;
        location / {
        index  index.php index.html index.htm;
        }
        location /var/www/html/ {
               autoindex on;
        }

}
EOF

apt  install nginx -y
/etc/init.d/nginx restart


 cat > /root/vsphere/append-bootstrap.ign <<EOF
{
  "ignition": {
    "config": {
      "append": [
        {
          "source": "http://192.168.1.14/bootstrap.ign", 
          "verification": {}
        }
      ]
    },
    "timeouts": {},
    "version": "2.1.0"
  },
  "networkd": {},
  "passwd": {},
  "storage": {},
  "systemd": {}
}
EOF


 base64 -w0 /root/vsphere/master.ign > /root/vsphere/master.64
 base64 -w0 /root/vsphere/worker.ign  > /root/vsphere/worker.64
 base64 -w0 /root/vsphere/append-bootstrap.ign  > /root/vsphere/append-bootstrap.64
  
cp *.ign /var/www/html/
chmod 664 /var/www/html/*
