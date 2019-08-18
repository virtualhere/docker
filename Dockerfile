FROM alpine AS build
WORKDIR /tmp/linux-src
RUN apk add --no-cache --update ca-certificates curl gcc make musl-dev \
    && curl -fsSL https://www.kernel.org/pub/linux/kernel/v4.x/linux-$(uname -r | cut -d '-' -f 1).tar.gz | tar -xzf - --strip-components=1 \
    && make defconfig \
    && ([ ! -f /proc/1/root/proc/config.gz ] || zcat /proc/1/root/proc/config.gz > .config) \
    && printf '%s\n' 'CONFIG_USBIP_CORE=m' 'CONFIG_USBIP_VHCI_HCD=m' 'CONFIG_USBIP_VHCI_HC_PORTS=8' 'CONFIG_USBIP_VHCI_NR_HCS=1' >> .config \
    && make oldconfig modules_prepare \
    && make M=drivers/usb/usbip \
    && mkdir -p /dist \
    && cd drivers/usb/usbip \
    && cp usbip-core.ko vhci-hcd.ko /dist \
    && echo -e '[General]\nAutoFind=0\n' > /dist/.vhui \
    && curl -fsSL https://www.virtualhere.com/sites/default/files/usbclient/vhclientx86_64 -o /dist/vhclientx86_64 \
    && chmod +x /dist/vhclientx86_64

FROM alpine
COPY --from=build /dist/* /vhclient/
ENV HOME=/vhclient
WORKDIR /vhclient
