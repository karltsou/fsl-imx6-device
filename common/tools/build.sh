
#!/bin/sh

# Use CCACHE
export CCACHE_DIR=/home/work/freescale/ccache
export USE_CCACHE=1

# create system.img
mk_sysimage()
{
  echo -e "del old system.img"
  rm out/target/product/evk_6sl/system.img

  echo -e "make new system.img"
  make_ext4fs -S out/target/product/evk_6sl/root/file_contexts -l 377487360 -a system out/target/product/evk_6sl/obj/PACKAGING/systemimage_intermediates/system.img out/target/product/evk_6sl/system

  acp -fp out/target/product/evk_6sl/obj/PACKAGING/systemimage_intermediates/system.img out/target/product/evk_6sl/system.img
}

# create ramdisk.img
mk_ramdisk()
{
  echo -e "del old ramdisk.img"
  rm out/target/product/evk_6sl/ramdisk.img

  echo -e "make new ramdisk.img"
  mkbootfs out/target/product/evk_6sl/root | out/host/linux-x86/bin/minigzip > out/target/product/evk_6sl/ramdisk.img
}

# create boot.img
mk_boot()
{
  echo -e "del old boot.img"
  rm out/target/product/evk_6sl/boot.img

  echo -e "make new boot.img"
  install -D kernel_imx/arch/arm/boot/zImage  out/target/product/evk_6sl/kernel

  mkbootimg --kernel out/target/product/evk_6sl/kernel --ramdisk out/target/product/evk_6sl/ramdisk.img --cmdline "console=ttymxc0,115200 init=/init androidboot.console=ttymxc0 video=mxcepdcfb:E060SCM,bpp=16 androidboot.hardware=freescale" --base 0x80800000  --output out/target/product/evk_6sl/boot.img
}

lunch evk_6sl_eink-userdebug
