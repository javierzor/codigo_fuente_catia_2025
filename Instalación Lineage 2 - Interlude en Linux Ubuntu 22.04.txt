# Instalación Lineage 2 - Interlude en Linux Ubuntu 22.04🐧💡 0101LAND

## Pre Requisitos
Lo primero que tendremos que hacer es comprobar que nuestro sistema operativo GNU/Linux este actualizado, en mi caso estoy utilizando Ubunto Server 22.04

`sudo apt-get update`

`sudo apt-get upgrade`

`sudo apt install -y git`

`sudo apt-get install unzip`

`sudo apt-get install neofetch`

## Instalación de MariaDB 💥
Procederemos con la instalación de nuestra base de datos MySQL, la cual 
almacenara y administrara los datos de nuestros sitios web.

`sudo apt install -y mariadb-server`

### Securizar MariaDB
Desde julio 2022 arrojaba error cuando se ejecutaba el script "mysql_secure_installation" sin hacer configuraciones adicionales. Esto pasaba, 
debido a que el script intentaba establecer una contraseña para la cuenta ROOT de 
MariaDB, pero de forma predeterminada en las instalaciones de Ubuntu, esta cuenta 
no esta configurada con una contraseña por lo que debemos hacer lo siguiente:

`sudo mysql -u root -p`

`GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;`

`FLUSH PRIVILEGES;`

`exit`

Ahora comenzamos con el script:

`sudo mysql_secure_installation`

### Permitir conexión externa (opcional)
`sudo vim /etc/mysql/mariadb.conf.d/50-server.cnf`

`bind-address = 0.0.0.0`

`sudo systemctl restart mariadb`

## Instalación de JAVA OpenJDK 17 💥
`echo $JAVA_HOME`

`sudo apt install -y openjdk-17-jdk`

`sudo vim /etc/environment`

`JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"`

`source /etc/environment`

`echo $JAVA_HOME`

## Creación de base de datos 💥
`sudo mariadb -u root -p`

`CREATE OR REPLACE USER 'l2j'@'%' IDENTIFIED BY 'l2jserver2019';`

`GRANT ALL PRIVILEGES ON *.* TO 'l2j'@'%' IDENTIFIED BY 'l2jserver2019';`

`FLUSH PRIVILEGES;`

`exit;`

## Descarga de código fuente de L2j Interlude 💥

`sudo mkdir -p /opt/l2j/git`

`cd /opt/l2j/git`

`sudo git clone -b master https://bitbucket.org/l2jserver/l2j-server-login.git`

`sudo git clone -b Interlude https://bitbucket.org/l2jserver/l2j-server-game.git`

`sudo git clone -b Interlude https://bitbucket.org/l2jserver/l2j-server-datapack.git`

`sudo mkdir complemento`

`cd /opt/l2j/git/complemento`

`sudo git clone -b master https://bitbucket.org/l2jserver/l2j-server-datapack.git`

## Configuración de servidor
`cd /opt/l2j/git/l2j-server-login`

`sudo chmod 755 mvnw`

`sudo ./mvnw install`

`cd /opt/l2j/git/l2j-server-game`

`sudo chmod 755 mvnw`

`sudo ./mvnw install`

`cd /opt/l2j/git/l2j-server-datapack`

`sudo chmod 755 mvnw`

`sudo ./mvnw install`

`cd /opt/l2j/git/complemento/l2j-server-datapack/src/main/resources`

## Descomprimir compilaciones

### Login Server
`sudo mkdir -p /opt/l2j/server/login`

`cd /opt/l2j/server/login`

`sudo unzip /opt/l2j/git/l2j-server-login/target/l2j-server-login-*.zip -d /opt/l2j/server/login`

### Game Server

`sudo mkdir -p /opt/l2j/server/game`

`cd /opt/l2j/server/game`

`sudo unzip /opt/l2j/git/l2j-server-game/target/l2j-server-game-*.zip -d /opt/l2j/server/game`

`sudo unzip /opt/l2j/git/l2j-server-datapack/target/l2j-server-datapack-*.zip -d /opt/l2j/server/game`

### Carpeta cleanup SQL

`cd /opt/l2j/git/complemento/l2j-server-datapack/src/main/resources/sql && sudo cp -rf cleanup -d /opt/l2j/server/game/sql/`


## Instalación de base de datos de L2 Interlude
### Instalación de l2j CLI
`sudo mkdir -p /opt/l2j/cli`

`cd /opt/l2j/cli`

`sudo wget https://l2jserver.com/files/binary/cli/l2jcli-1.1.0.zip -P /tmp`

`sudo unzip /tmp/l2jcli-*.zip -d /opt/l2j/cli`

`sudo chmod 755 l2jcli.sh`

`sudo ./l2jcli.sh`

### Instalación de BBDD

`db install -sql /opt/l2j/server/login/sql -u l2j -p l2jserver2019 -m FULL -t LOGIN -c -mods`

`db install -sql /opt/l2j/server/game/sql -u l2j -p l2jserver2019 -m FULL -t GAME -c -mods`

### Creación de usuario ADMIN
`account create -u zurdok -p -a 8`

`quit`

### Habilitar regla en firewall
También, debemos crear la regla del firewall con  Uncomplicated Firewall (UFW) para permitir el trafico HTTP.

Verificamos el estado de ufw:

`sudo ufw status`

Listamos los perfiles de aplicaciones que tenemos disponibles:

`sudo ufw app list`

Habilitamos el puerto SSH:

`sudo ufw allow in "OpenSSH"`

Para habilitar UFW ejecutamos el siguiente Comando:

`sudo ufw enable`

`sudo ufw allow 2106/tcp && sudo ufw allow 7777/tcp && sudo ufw allow 3306/tcp && sudo ufw allow 3306/tcp`

`sudo ufw status`


## Permisos y LOG ejecutables servidor ⚡

`cd /opt/l2j/server/login`

`sudo mkdir -p log`

`sudo chmod 755 LoginServer_loop.sh`

`sudo chmod 755 startLoginServer.sh`

`cd /opt/l2j/server/game`

`sudo mkdir -p log`

`sudo chmod 755 startGameServer.sh`

### modificar /opt/l2j/server/game/config/server.properties
`cd /opt/l2j/server/game/config`

`sudo vim server.properties`

`URL=jdbc:mysql://localhost/l2jgs`

`usuario: l2j`

`Contraseña: l2jserver2019`



## Iniciar el servidor ⚡
### Iniciar LoginServer
`cd /opt/l2j/server/login`

`sudo ./startLoginServer.sh`

`tail -f -n 300 log/stdout.log`

### Iniciar GameServer
`cd /opt/l2j/server/game`

`sudo ./startGameServer.sh`

`tail -f -n 300 log/stdout.log`

## Asignar permisos de Admin ⚡

### Iniciamos nuestro administrador de BD (HeidiSQL)
`usuario: l2j`

`Contraseña: l2jserver2019`

`Accesslevel=127`