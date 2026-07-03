FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

EXTRA_DT_INCLUDE_FILES:append:linux:scobc-v1 = " \
    bootargs.dtsi \
    usb.dtsi \
    ethernet.dtsi \
    norflash.dtsi \
    reset.dtsi \
"

EXTRA_DT_INCLUDE_FILES:append:linux:vck190 = " \
    mram.dtsi \
"

EXTRA_DT_INCLUDE_FILES:append = "${@ \
    ' qspi-single.dtsi' \
    if d.getVar('BB_CURRENT_MC') == \
       'versal-vck190-sdt-seg-microblaze-pmc' \
    else '' \
}"
