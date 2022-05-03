#!/bin/bash

#Iniciar sesión como usuario "root"
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: Please, run as root"
  exit
fi

#Introducir IP como parámetro
IP=$1
if [ $# -eq 0 ]; then
  echo "ERROR: It is necessary to enter a parameter"
  echo "Enter th IP address that is going to be used as Default Gateway and DNS Server as a parameter"
  exit
fi

#Guardar rutas que vamos a usar en variables
NET_FILE="/etc/sysconfig/network"
DNS_FILE="/etc/resolv.conf"

#Guardar en variable IP
OLD_IP=$(grep "GATEWAY" ${NET_FILE} | cut -f 2 -d "=")

#Modificar la IP
sed -i "s/${OLD_IP}/${IP}/g" ${NET_FILE}
#Configurar Servidor DNS

sed "/search localdomain/ a nameserver ${IP}" -i ${DNS_FILE}

#restart network
systemctl restart network

#Cambiar repositorios de paquetes/librerias a vault
sed -i "s/mirrorlist/#mirrorlist/g" /etc/yum.repos.d/CentOS-*
sed -i "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.epel.cloud|g" /etc/yum.repos.d/CentOS-*

#Instalción de Squish en Centos8 TMCS
echo "=================================================================================================================================="

echo "SQUISH INSTALLATION"

#Actualizamos la versión de la librería libXdmcp: libXdmcp-1.1.3-1.el8.x86_64
dnf -y update libXdmcp

#Instalamos su versión de 32 bits
dnf -y install libXdmcp.i686

#Instalamos squish en modo unattended pasandole la licencia y el installation folder (si no, da error)
/tmp/squish-6.7.2-qt48x-linux32.run unattended=1 licensekey=XSF-2J7K2-2SKZF-2JF targetdir=/home/squish

#Instalamos la librería gtk 32 bits y todas las dependencias necesarias 
dnf -y update openssl-libs
dnf -y install gtk3-devel.i686

#/home/squish/squishide (para iniciar la aplicación)

echo "=================================================================================================================================="

#Restaurar la configuración predeterminada
echo "RESTORATION OF DEFAULT CONFIGURATION"

#Restaurar la IP
sed -i "s/${IP}/${OLD_IP}/g" ${NET_FILE}

#Eliminar el servidor DNS
sed -i "s/nameserver ${IP}//g" ${DNS_FILE}

#Restart network
systemctl restart network

rm -f /tmp/squish-6.7.2-qt48x-linux32.run

echo "DONE"

