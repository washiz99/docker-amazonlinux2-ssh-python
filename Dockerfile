FROM amazonlinux:2.0.20200304.0

# os update
RUN yum update -y && yum upgrade -y

# install sshd
RUN yum install -y git openssh-server tar gcc make bzip2-devel zlib-devel openssl-devel readline-devel sqlite-devel

RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
RUN echo "UseDNS=no" >> /etc/ssh/sshd_config
RUN ssh-keygen -A

COPY ./ssh-key/authorized_keys /root/authorized_keys
RUN mkdir ~/.ssh && \
    mv ~/authorized_keys ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

EXPOSE 22

# install python and pyenv
RUN rm -fR ~/.pyenv
RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
RUN echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
RUN echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
RUN ~/.pyenv/bin/pyenv install 3.6.3
RUN ~/.pyenv/bin/pyenv install 3.7.6
RUN ~/.pyenv/bin/pyenv install 3.8.2
RUN ~/.pyenv/bin/pyenv global 3.8.2

CMD ["/usr/sbin/sshd", "-D"]