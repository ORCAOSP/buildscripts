ORCA BIGFOOT
===============

Getting started
---------------
First you must initialize a repository with Bigfoot sources:

    repo init -u git://github.com/ORCAOSP/platform_manifest.git -b bigfoot

then

    repo sync -j1

*This might take a few hours depending on your internet connection.

Building Orca Bigfoot
------------------------

To build Bigfoot you must cd to the working directory.

Now you can run the build script:

    $ . build_bigfoot.sh -device- -sync- -thread- -clean-


* device: Choose between the following supported devices: i9100, i9100g, i9300, d2att, d2tmo, mako and grouper.
* sync: Will sync latest Bigfoot sources before building
* threads: Allows to choose a number of threads for syncing and building operation.
* clean: Will remove the entire out folder and start a clean build. (Use this at your discretion)


ex: $ . build_bigfoot.sh mako sync 12 clean (This will sync latest sources, clean out folder, build Bigfot for Mako with -j12 threads)



You might want to consider using CCACHE to speed up build time after the first build.

This will make a signed flashable zip file located in out/target/product/-device-/

