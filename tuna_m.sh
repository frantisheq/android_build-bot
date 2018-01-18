#!/bin/bash

SAUCE=~/android2/kernelcompile
PVRSAUCE=~/android2/official/omap4/stable/pvr-source/eurasiacon
KERNELSOURCE=~/android2/official/kernel/android_kernel_ti_omap4
TOOLCHAIN="gcc4.7"
DEFCONFIGNAME=tuna_defconfig
WORKINGDIR=$SAUCE/out/$DEFCONFIGNAME
WORKINGOUTDIR=$SAUCE/$DEFCONFIGNAME-bin
. `dirname $0`/compile-tuna.sh