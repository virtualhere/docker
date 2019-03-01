FROM alpine:latest

RUN apk add --no-cache --update abuild bc binutils build-base cmake gcc ncurses-dev sed ca-certificates wget libarchive-tools \
    && KERNELVER=$(uname -r  | cut -d '-' -f 1) \
    && wget -nv -P /srv https://www.kernel.org/pub/linux/kernel/v4.x/linux-$KERNELVER.tar.gz \
    && bsdtar -C /srv -zxf /srv/linux-$KERNELVER.tar.gz \
    && rm -f /srv/linux-$KERNELVER.tar.gz \
    && cd /srv/linux-$KERNELVER \
    && make defconfig \
    && ([ ! -f /proc/1/root/proc/config.gz ] || zcat /proc/1/root/proc/config.gz > .config) \
    && echo 'CONFIG_USBIP_CORE=m' >> .config \
    && echo 'CONFIG_USBIP_VHCI_HCD=m' >> .config \
    && echo 'CONFIG_USBIP_VHCI_HC_PORTS=8' >> .config \
    && echo 'CONFIG_USBIP_VHCI_NR_HCS=1' >> .config \
    && make oldconfig \
    && make modules_prepare \
    && make M=drivers/usb/usbip \
    && cd / \
    && wget https://www.virtualhere.com/sites/default/files/usbclient/vhclientx86_64 \
    && chmod +x ./vhclientx86_64 \
    && cp /srv/linux-$KERNELVER/drivers/usb/usbip/usbip-core.ko / \
    && cp /srv/linux-$KERNELVER/drivers/usb/usbip/vhci-hcd.ko / \
    && rm -rf /srv/linux-$KERNELVER \
    && apk del abuild bc binutils build-base cmake gcc ncurses-dev sed ca-certificates wget libarchive-tools

WORKDIR /