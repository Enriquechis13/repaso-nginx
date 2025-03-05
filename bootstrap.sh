#
# Script de instalación del website
# Joseph Leak <how.i.wish.i.were.in@caribbean.com>
#

set -xau pipefail

SITE=iwata.192.168.57.10.nip.io
DOCUMENT_ROOT=/var/www/${SITE}/html

apt-get update
apt-get install -y nginx vsftpd git dos2unix

# Crear usuario
if id satoru >/dev/null 2>&1; then
    echo "User already exists"
else
    useradd -m nintendo
    echo "nintendo:satoru" | chpasswd
    mkdir /home/nintendo/ftp
    chown nintendo:nintendo /home/nintendo/ftp
fi

# Descarga website mockup para pruebas
HTDOCS=/vagrant/htdocs
if [ ! -d "$HTDOCS" ]; then
    git clone https://github.com/seanmiles/example-webpage ${HTDOCS}
fi

rm /etc/nginx/sites-enabled/default
cp -v /vagrant/${SITE}.conf /etc/nginx/sites-available/

cp -v /vagrant/vsftpd.conf  
# Convertir fichero a Unix por si Windows ha cambiado los CR/LF
dos2unix /etc/vsftpd.conf

# A ver que pasa ...
systemctl restart nginx
systemctl restart vsftpd
systemctl status nginx
systemctl status vsftpd

