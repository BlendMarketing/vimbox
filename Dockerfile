FROM ubuntu:16.04
MAINTAINER Marc Tanis <marc@blendimc.com>

# Install Needed Software
RUN apt-get update  && \
apt-get install -y software-properties-common && \
add-apt-repository -yu ppa:pi-rho/dev && \
add-apt-repository ppa:neovim-ppa/stable && \
add-apt-repository ppa:mc3man/xerus-media && \
add-apt-repository ppa:longsleep/golang-backports && \
apt-get update && \
apt-get install -y sudo curl nodejs unzip whois software-properties-common git dialog python3-pip tmux-next neovim golang-go openssh-server awscli jq && \
rm -rf /var/lib/apt/lists/*

# Docker Compose
# Install Docker Client
RUN set -x && \
VER="17.06.0-ce" && \
curl -L -o /tmp/docker-$VER.tgz https://get.docker.com/builds/Linux/x86_64/docker-$VER.tgz && \
tar -xz -C /tmp -f /tmp/docker-$VER.tgz && \
mv /tmp/docker/* /usr/bin && \
curl -L https://github.com/docker/compose/releases/download/1.15.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
sudo chmod +x /usr/local/bin/docker-compose


# SSH
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
sed -i 's|[#]*PasswordAuthentication yes|PasswordAuthentication no|g' /etc/ssh/sshd_config && \
sed -i 's|UsePAM yes|UsePAM no|g' /etc/ssh/sshd_config
EXPOSE 22

# Setup Entrypoin
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Setup User
RUN groupadd -r user -g 1000 && \
groupadd -r docker -g 1001 && \
useradd -u 1000 -r -g user -m -d /home/user -s /sbin/nologin -c "Dev User" user && \
usermod -a -G docker user && \
mkdir /home/user/go && \ 
chmod -R 755 /home/user && \
chown -R user:user /home/user  && \
chsh -s /bin/bash user && \
echo "user ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user && \
chmod 0440 /etc/sudoers.d/user

USER user
WORKDIR /home/user

# Setup Neovim after switching user
ADD https://github.com/marcato15/dotfiles/archive/neovim.zip /home/user
RUN sudo pip3 install neovim && \
sudo unzip -j neovim.zip -d ~/dotfiles && \
cd dotfiles && \
./make.sh && \ 
nvim +GoInstallBinaries +qall || true && \
nvim +UpdateRemotePlugins +qall || true

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]

