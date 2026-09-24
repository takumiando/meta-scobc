FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Select the QSPI memory population by board revision and grade.
#   Rev.A Space/Developer -> scobc-v1-reva/qspi.dtsi
#   Rev.B Space           -> scobc-v1-revb/qspi.dtsi
#   Rev.B Developer       -> scobc-v1-revb/qspi-devgrade.dtsi
SCOBC_V1_QSPI_DTSI:scobc-v1-reva = "qspi.dtsi"
SCOBC_V1_QSPI_DTSI:scobc-v1-revb = "qspi.dtsi"
SCOBC_V1_QSPI_DTSI:scobc-v1-revb:scobc-v1-devgrade = "qspi-devgrade.dtsi"

# Apply the QSPI description to the PLM device tree.
EXTRA_DT_INCLUDE_FILES:append:microblaze-pmc:scobc-v1-generic = " ${SCOBC_V1_QSPI_DTSI}"

# Apply the SC-OBC Module V1 peripheral descriptions to Linux.
EXTRA_DT_INCLUDE_FILES:append:linux:scobc-v1-generic = " \
    bootargs.dtsi \
    usb.dtsi \
    ethernet.dtsi \
    ${SCOBC_V1_QSPI_DTSI} \
    reset.dtsi \
    rpu-peripherals.dtsi \
"

# Control the eMMC power supply through PMC_MIO51 on Rev.B boards.
# U-Boot also consumes this Linux-domain device tree through EXT_DTB.
EXTRA_DT_INCLUDE_FILES:append:linux:scobc-v1-revb = " emmc.dtsi"

# Add the OpenAMP description only when OpenAMP is enabled.
EXTRA_DT_INCLUDE_FILES:append:linux:scobc-v1-generic = " \
    ${@' openamp.dtsi' if bb.utils.to_boolean(d.getVar('ENABLE_OPENAMP'), False) else ''} \
"

DT_INCLUDE:append:linux = "${@ \
    ' ${RECIPE_SYSROOT}${datadir}/sdt/${MACHINE}/include' \
    if bb.utils.to_boolean(d.getVar('ENABLE_OPENAMP'), False) else '' \
}"

# The SDT flow keeps PL nodes in a generated Linux DT overlay instead of the
# Linux domain DTS.  SC-OBC Module V1 loads its fixed PL image during boot, so
# merge that hardware description into the base DT rather than requiring the
# overlay to be applied at runtime.
SCOBC_V1_PL_OVERLAY_DTSI = "pl-overlay-full/pl.dtsi"
SRC_URI:append:linux = " file://${SCOBC_V1_PL_OVERLAY_DTSI}"

do_configure:append:linux() {
    if [ ! -f "${WORKDIR}/${SCOBC_V1_PL_OVERLAY_DTSI}" ]; then
        bbfatal "Unable to find generated PL overlay: ${SCOBC_V1_PL_OVERLAY_DTSI}"
    fi

    # Keep the generated overlay fragments but drop the top-level directives
    # so the file can be included in the base DTS.
    sed -e '/^\/dts-v1\/;$/d' -e '/^\/plugin\/;$/d' \
        "${WORKDIR}/${SCOBC_V1_PL_OVERLAY_DTSI}" \
        > "${DT_FILES_PATH}/scobc-pl.dtsi"
    echo '#include "scobc-pl.dtsi"' >> "${DT_FILES_PATH}/${BASE_DTS}.dts"
}
