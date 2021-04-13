

# init rhel VSI

# change password
passwd

# change sshd port
sed -i "s:#Port.*:Port 32022:" /etc/ssh/sshd_config

# Disable firewall
systemctl stop firewalld
systemctl disable firewalld

# Disable SELINUX
sed -i "s:SELINUX=.*:SELINUX=disable:" /etc/selinux/config
setenforce 0
systemctl restart sshd

reboot

# Do not forget to add inbound rule for port 32022 in VSI's Security Group



# install Gnome
yum -y update
yum -y groupinstall "Server with GUI"

# install VNC
yum -y install tigervnc-server xorg-x11-fonts-Type1
vncpasswd
vncserver
sed -i "s:# geometry:geometry:" .vnc/config
vncserver -kill :1
vncserver

# open tunnel for VNC
ssh -p 32022 -fL 9901:localhost:5901 root@158.176.179.103 tail -f /dev/null