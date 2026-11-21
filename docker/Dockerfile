# Disposable Ubuntu machine with real systemd, for troubleshooting practice.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    container=docker

# Base system: systemd as init, a web server, cron and the tools an ops engineer reaches for.
RUN apt-get update && apt-get install -y --no-install-recommends \
        systemd systemd-sysv dbus \
        nginx cron logrotate \
        curl ca-certificates openssl \
        iproute2 iputils-ping dnsutils net-tools lsof \
        procps psmisc htop sysstat \
        less vim-tiny nano sudo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Trim systemd units that make no sense in a container.
RUN find /etc/systemd/system /lib/systemd/system \
        -path '*.wants/*' \
        \( -name '*getty*' -o -name '*udev*' -o -name 'systemd-logind*' -o -name '*remount-fs*' \) \
        -exec rm -f {} + \
    && systemctl mask systemd-firstboot.service systemd-resolved.service \
    && systemctl enable nginx cron

# A small "production" site the scenarios can break.
COPY site/ /var/www/opslab/
COPY nginx-opslab.conf /etc/nginx/sites-available/opslab
RUN rm -f /etc/nginx/sites-enabled/default \
    && ln -s /etc/nginx/sites-available/opslab /etc/nginx/sites-enabled/opslab \
    && mkdir -p /var/log/opslab \
    && chown -R www-data:www-data /var/www/opslab /var/log/opslab

# An unprivileged operator account, like on a real server.
RUN useradd -m -s /bin/bash ops \
    && echo 'ops ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ops \
    && chmod 0440 /etc/sudoers.d/ops

STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
