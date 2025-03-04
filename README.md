# repaso-nginx

# Guía Completa de Instalación y Configuración de Nginx en Debian

Configura y administrar un servidor web **Nginx** en un sistema Debian, incluyendo autenticación, FTPS y restricciones de acceso.

---

## 1. Instalación del Servidor Web Nginx

### Requisitos Previos
- Sistema operativo **Debian** (recomendado: **Debian Bookworm 64-bit**).
- Acceso a un usuario con privilegios `sudo`.
- Conexión a internet para descargar paquetes.

### Pasos de Instalación
1. **Actualizar los repositorios del sistema:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Instalar Nginx:**
   ```bash
   sudo apt install nginx -y
   ```

3. **Verificar que el servicio está en ejecución:**
   ```bash
   systemctl status nginx
   ```
   Si el servicio no está activo, inícialo con:
   ```bash
   sudo systemctl start nginx
   ```

4. **Habilitar Nginx para que inicie automáticamente al arrancar el sistema:**
   ```bash
   sudo systemctl enable nginx
   ```

5. **Abrir el firewall para permitir tráfico HTTP y HTTPS:**
   ```bash
   sudo ufw allow 'Nginx Full'
   ```

---

## 2. Configuración del Sitio Web en Nginx

### Requisitos Previos
- Servidor **Nginx** instalado y en ejecución.
- Acceso con privilegios `sudo`.
- **Git** instalado en el servidor (`sudo apt install git -y`).

### Pasos para Configurar el Sitio Web
1. **Crear la carpeta del sitio web y establecer los permisos adecuados:**
   ```bash
   sudo mkdir -p /var/www/servidor_nginx/html
   sudo chown -R www-data:www-data /var/www/servidor_nginx/html
   sudo chmod -R 755 /var/www/servidor_nginx/html
   ```

2. **Clonar el repositorio del sitio web:**
   ```bash
   git clone https://github.com/cloudacademy/static-website-example /var/www/servidor_nginx/html
   ```

3. **Verificar el sitio web accediendo a:**
   ```
   http://<IP_DEL_SERVIDOR>
   ```

---

## 3. Configuración de un Servidor Virtual en Nginx

1. **Crear un archivo de configuración del sitio:**
   ```bash
   sudo nano /etc/nginx/sites-available/servidor_nginx
   ```

   Copia y pega la siguiente configuración:
   ```nginx
   server {
      listen 80;
      root /var/www/servidor_nginx/html;
      index index.html;
      server_name servidor_nginx;

      location / {
         try_files $uri $uri/ =404;
      }
   }
   ```

2. **Activar la configuración del sitio:**
   ```bash
   sudo ln -s /etc/nginx/sites-available/servidor_nginx /etc/nginx/sites-enabled/
   ```

3. **Probar la configuración para evitar errores:**
   ```bash
   sudo nginx -t
   ```

4. **Reiniciar Nginx para aplicar cambios:**
   ```bash
   sudo systemctl restart nginx
   ```

---

## 4. Configuración de un Servidor FTPS (FTP Seguro) en Debian

### Instalación de VSFTPD y Configuración de FTPS

1. **Instalar VSFTPD:**
   ```bash
   sudo apt install vsftpd -y
   ```

2. **Crear un directorio para FTP:**
   ```bash
   sudo mkdir -p /home/usuario/ftp
   sudo chown usuario:usuario /home/usuario/ftp
   ```

3. **Generar certificados SSL para FTPS:**
   ```bash
   sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.key -out /etc/ssl/certs/vsftpd.crt
   ```

4. **Configurar VSFTPD:**
   ```bash
   sudo nano /etc/vsftpd.conf
   ```
   - Asegúrate de incluir las siguientes líneas:
     ```
     rsa_cert_file=/etc/ssl/certs/vsftpd.crt
     rsa_private_key_file=/etc/ssl/private/vsftpd.key
     ssl_enable=YES
     allow_anon_ssl=NO
     force_local_data_ssl=YES
     force_local_logins_ssl=YES
     ```

5. **Reiniciar el servicio VSFTPD:**
   ```bash
   sudo systemctl restart vsftpd
   ```

---

## 5. Configuración de Autenticación Básica en Nginx

### Creación de Usuarios para la Autenticación

1. **Instalar OpenSSL si no está instalado:**
   ```bash
   sudo apt install openssl -y
   ```

2. **Crear un archivo `.htpasswd` para usuarios y contraseñas cifradas:**
   ```bash
   sudo htpasswd -c /etc/nginx/.htpasswd usuario
   ```
   - Se solicitará la contraseña del usuario.
   - Para agregar más usuarios:
     ```bash
     sudo htpasswd /etc/nginx/.htpasswd otro_usuario
     ```

3. **Configurar Nginx para proteger el acceso:**
   ```bash
   sudo nano /etc/nginx/sites-available/servidor_nginx
   ```
   - Dentro del bloque `location /`, añade:
     ```nginx
     auth_basic "Acceso Restringido";
     auth_basic_user_file /etc/nginx/.htpasswd;
     ```

4. **Reiniciar Nginx para aplicar los cambios:**
   ```bash
   sudo systemctl restart nginx
   ```

---

## 6. Restricción de Acceso por IP en Nginx

Para limitar el acceso a ciertas IPs:
```nginx
location /admin {
   allow 192.168.1.100;
   deny all;
}
```

Si se quiere combinar con autenticación:
```nginx
location /api {
   satisfy all;
   allow 192.168.1.0/24;
   deny all;
   auth_basic "Zona Restringida";
   auth_basic_user_file /etc/nginx/.htpasswd;
}
```

Reiniciar Nginx tras cualquier cambio:
```bash
sudo systemctl restart nginx
```

---

## 7. Solución de Problemas

- **Error 403 Forbidden**: Verifica permisos con `ls -ld /var/www/servidor_nginx/html`.
- **Error 404 Not Found**: Asegura que el archivo `index.html` existe en la carpeta del sitio web.
- **Problemas con FTP**: Revisa logs en `/var/log/vsftpd.log`.

---

