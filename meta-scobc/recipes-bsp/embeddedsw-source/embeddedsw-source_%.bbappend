FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://0003-xilpm-Keep-SPI1-powered-in-the-default-subsystem.patch \
"
