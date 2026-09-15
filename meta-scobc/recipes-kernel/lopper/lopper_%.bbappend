FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://0001-assists-xlnx-overlay-Fix-QDMA-host-register-regions.patch \
"
