FROM registry.fedoraproject.org/fedora:rawhide
RUN echo "fastestmirror=1" >> /etc/dnf/dnf.conf
RUN mkdir -vp /etc/selinux && touch /etc/selinux/config
RUN dnf -y upgrade && \
    dnf -y install composer-cli jq osbuild-composer && \
    dnf clean all
RUN systemctl enable osbuild-composer.socket
CMD ["/sbin/init"]
