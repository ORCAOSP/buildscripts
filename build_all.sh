#!/bin/bash

ydate=$(date -d '1 day ago' +"%m/%d/%Y")
sdate="$2"
cdate=`date +"%m_%d_%Y"`
DATE=`date +"%Y%m%d"`
rdir=`pwd`
RELEASE="$1"
OFFICIAL="$3"

# Remove previous build info
echo "Removing previous build.prop"
rm out/target/product/d2att/system/build.prop;
rm out/target/product/d2tmo/system/build.prop;
rm out/target/product/d2vzw/system/build.prop;
rm out/target/product/grouper/system/build.prop;
rm out/target/product/mako/system/build.prop;
rm out/target/product/i9100/system/build.prop;
rm out/target/product/i9100g/system/build.prop;
rm out/target/product/i9300/system/build.prop;
rm out/target/product/maguro/system/build.prop;
rm out/target/product/toro/system/build.prop;
rm out/target/product/t0lte/system/build.prop;
rm out/target/product/i605/system/build.prop;
rm out/target/product/l900/system/build.prop;

if [ "$RELEASE" == "official" ]
then
    echo "Building Official Release";
    export BF_BUILD="$OFFICIAL"
else
    echo "Building Nightly"
fi

echo "Generating Changelog"

# Generate Changelog

# Check the date start range is set
if [ -z "$sdate" ]; then
    sdate=${ydate}
fi

# Find the directories to log
find $rdir -name .git | sed 's/\/.git//g' | sed 'N;$!P;$!D;$d' | while read line
do
    cd $line
    # Test to see if the repo needs to have a changelog written.
    log=$(git log --pretty="%an - %s" --no-merges --since=$sdate --date-order)
    project=$(git remote -v | head -n1 | awk '{print $2}' | sed 's/.*\///' | sed 's/\.git//')
    if [ -z "$log" ]; then
        echo "Nothing updated on $project, skipping"
    else
        # Prepend group project ownership to each project.
        origin=`grep "$project" $rdir/.repo/manifest.xml | awk {'print $4'} | cut -f2 -d '"'`
        if [ "$origin" = "aokp" ]; then
            proj_credit=AOKP
        elif [ "$origin" = "aosp" ]; then
            proj_credit=AOSP
        elif [ "$origin" = "cm" ]; then
            proj_credit=CyanogenMod
        elif [ "$origin" = "faux" ]; then
            proj_credit=Faux123
        elif [ "$origin" = "drewgaren" ]; then
            proj_credit=Orca
        else
            proj_credit=""
        fi
        # Write the changelog
        echo "$proj_credit Project name: $project" >> "$rdir"/changelog.txt
        echo "$log" | while read line
        do
             echo "  •$line" >> "$rdir"/changelog.txt
        done
        echo "" >> "$rdir"/changelog.txt
    fi
done

# Create Version Changelog
if [ "$RELEASE" == "nightly" ]
then
    echo "Generating and Uploading Changelog for Nightly"
    cp changelog.txt changelog_"$DATE".txt
    scp "$rdir"/changelog_"$DATE".txt drewgaren@upload.goo.im:~/public_html/Nightlies/Changelogs
else
    echo "Generating and Uploading Changelog for Official Release"
    cp changelog.txt changelog_"$BF_BUILD".txt
    scp "$rdir"/changelog_"$BF_BUILD".txt drewgaren@upload.goo.im:~/public_html/Bigfoot_Changelogs
fi

# Build Bigfoot Mako (Nexus 4)
. build/envsetup.sh;
brunch bigfoot_mako-userdebug;

# Get Package Name
sed -i -e 's/bigfoot_//' $OUT/system/build.prop
VERSION1=`sed -n -e'/ro.bigfoot.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEmako=$OUT/$VERSION1.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Bigfoot-JB-mako-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmako" drewgaren@upload.goo.im:~/public_html/mako/Bigfoot/Nightlies
else
    find "$OUT" -name *Bigfoot-JB-mako-*${BF_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmako" drewgaren@upload.goo.im:~/public_html/mako/Bigfoot/Stable
fi


# Build Bigfoot Grouper
brunch bigfoot_grouper-userdebug;

# Get Package Name
sed -i -e 's/bigfoot_//' $OUT/system/build.prop
VERSION2=`sed -n -e'/ro.bigfoot.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEgrouper=$OUT/$VERSION2.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Bigfoot-JB-grouper-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEgrouper" drewgaren@upload.goo.im:~/public_html/grouper/Bigfoot/Nightlies
else
    find "$OUT" -name *Bigfoot-JB-grouper-*${BF_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEgrouper" drewgaren@upload.goo.im:~/public_html/grouper/Bigfoot/Stable
fi

echo "Cleaning build folder";
make clean;

# Build Bigfoot SGH-I747
brunch bigfoot_d2att-userdebug;

# Get Package Name
sed -i -e 's/bigfoot_//' $OUT/system/build.prop
VERSION3=`sed -n -e'/ro.bigfoot.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2att=$OUT/$VERSION3.zip

# Move the changelog into zip  & upload zip to Goo.im

if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Bigfoot-JB-d2att-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2att" drewgaren@upload.goo.im:~/public_html/d2att/Bigfoot/Nightlies
else
    find "$rdir"/out/target/product -name *Bigfoot-JB-d2att-*${BF_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2att" drewgaren@upload.goo.im:~/public_html/d2att/Bigfoot/Stable
fi

# Build Bigfoot SGH-T999
brunch bigfoot_d2tmo-userdebug;

# Get Package Name
sed -i -e 's/bigfoot_//' $OUT/system/build.prop
VERSION4=`sed -n -e'/ro.bigfoot.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2tmo=$OUT/$VERSION4.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Bigfoot-JB-d2tmo-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2tmo" drewgaren@upload.goo.im:~/public_html/d2tmo/Bigfoot/Nightlies
else
    find "$OUT" -name *Bigfoot-JB-d2tmo-*${BF_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2tmo" drewgaren@upload.goo.im:~/public_html/d2tmo/Bigfoot/Stable
fi

echo "Cleaning build folder";
make clean;

# Build Bigfoot SGH-I535
brunch bigfoot_d2vzw-userdebug;

# Get Package Name
sed -i -e 's/bigfoot_//' $OUT/system/build.prop
VERSION5=`sed -n -e'/ro.bigfoot.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEd2vzw=$OUT/$VERSION5.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Bigfoot-JB-d2vzw-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2vzw" drewgaren@upload.goo.im:~/public_html/d2vzw/Bigfoot/Nightlies
else
    find "$OUT" -name *Bigfoot-JB-d2vzw-*${BF_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEd2vzw" drewgaren@upload.goo.im:~/public_html/d2vzw/Bigfoot/Stable
fi

echo "Cleaning build folder";
make clean;

# Build Bigfoot Maguro
brunch bigfoot_maguro-userdebug;

# Get Package Name
sed -i -e 's/bigfoot_//' $OUT/system/build.prop
VERSION9=`sed -n -e'/ro.bigfoot.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEmaguro=$OUT/$VERSION9.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Bigfoot-JB-maguro-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmaguro" drewgaren@upload.goo.im:~/public_html/maguro/Bigfoot/Nightlies
else
    find "$OUT" -name *Bigfoot-JB-maguro-*${BF_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEmaguro" drewgaren@upload.goo.im:~/public_html/maguro/Bigfoot/Stable
fi

echo "Cleaning build folder";
make clean;

# Build Bigfoot Toro
brunch bigfoot_toro-userdebug;

# Get Package Name
sed -i -e 's/bigfoot_//' $OUT/system/build.prop
VERSION10=`sed -n -e'/ro.bigfoot.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEtoro=$OUT/$VERSION10.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Bigfoot-JB-toro-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEtoro" drewgaren@upload.goo.im:~/public_html/toro/Bigfoot/Nightlies
else
    find "$OUT" -name *Bigfoot-JB-toro-*${BF_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEtoro" drewgaren@upload.goo.im:~/toro/Bigfoot/Stable
fi

# Build Bigfoot GT-N7105
brunch bigfoot_t0lte-userdebug;

# Get Package Name
sed -i -e 's/bigfoot_//' $OUT/system/build.prop
VERSION11=`sed -n -e'/ro.bigfoot.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEt0lte=$OUT/$VERSION11.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Bigfoot-JB-t0lte-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEt0lte" drewgaren@upload.goo.im:~/public_html/t0lte/Bigfoot/Nightlies
else
    find "$OUT" -name *Bigfoot-JB-t0lte-*${BF_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEt0lte" drewgaren@upload.goo.im:~/public_html/t0lte/Bigfoot/Stable

# Build Bigfoot SCH-I605
brunch bigfoot_i605-userdebug;

# Get Package Name
sed -i -e 's/bigfoot_//' $OUT/system/build.prop
VERSION12=`sed -n -e'/ro.bigfoot.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi605=$OUT/$VERSION12.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Bigfoot-JB-i605-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi605" drewgaren@upload.goo.im:~/public_html/i605/Bigfoot/Nightlies
else
    find "$OUT" -name *Bigfoot-JB-i605-*${BF_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi605" drewgaren@upload.goo.im:~/public_html/i605/Bigfoot/Stable
fi

echo "Cleaning build folder";
make clean;

# Build Bigfoot SCH-L900
brunch bigfoot_l900-userdebug;

# Get Package Name
sed -i -e 's/bigfoot_//' $OUT/system/build.prop
VERSION13=`sed -n -e'/ro.bigfoot.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEl900=$OUT/$VERSION13.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Bigfoot-JB-l900-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEl900" drewgaren@upload.goo.im:~/public_html/l900/Bigfoot/Nightlies
else
    find "$OUT" -name *Bigfoot-JB-l900-*${BF_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEl900" drewgaren@upload.goo.im:~/public_html/l900/Bigfoot/Stable
fi

echo "Cleaning build folder";
make clean;

# Build Bigfoot GT-I9100
brunch bigfoot_i9100-userdebug;

# Get Package Name
sed -i -e 's/bigfoot_//' $OUT/system/build.prop
VERSION6=`sed -n -e'/ro.bigfoot.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9100=$OUT/$VERSION6.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Bigfoot-JB-i9100-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100" drewgaren@upload.goo.im:~/public_html/i9100/Bigfoot/Nightlies
else
    find "$OUT" -name *Bigfoot-JB-i9100-*${BF_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100" drewgaren@upload.goo.im:~/public_html/i9100/Bigfoot/Stable
fi

# Build Bigfoot GT-I9100G
brunch bigfoot_i9100g-userdebug;

# Get Package Name
sed -i -e 's/bigfoot_//' $OUT/system/build.prop
VERSION7=`sed -n -e'/ro.bigfoot.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9100g=$OUT/$VERSION7.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Bigfoot-JB-i9100g-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100g" drewgaren@upload.goo.im:~/public_html/i9100g/Bigfoot/Nightlies
else
    find "$OUT" -name *Bigfoot-JB-i9100g-*${BF_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9100g" drewgaren@upload.goo.im:~/public_html/i9100g/Bigfoot/Stable
fi

echo "Cleaning build folder";
make clean;

# Build Bigfoot GT-I9300
brunch bigfoot_i9300-userdebug;

# Get Package Name
sed -i -e 's/bigfoot_//' $OUT/system/build.prop
VERSION8=`sed -n -e'/ro.bigfoot.version/s/^.*=//p' $OUT/system/build.prop`
PACKAGEi9300=$OUT/$VERSION8.zip

# Move the changelog into zip  & upload zip to Goo.im
if [ "$RELEASE" == "nightly" ]
then
    find "$OUT" -name *Bigfoot-JB-i9300-Nightly-*${DATE}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9300" drewgaren@upload.goo.im:~/public_html/i9300/Bigfoot/Nightlies
else
    find "$OUT" -name *Bigfoot-JB-i9300-*${BF_BUILD}*.zip -exec zip -j {} "$rdir"/changelog.txt \;
    scp "$PACKAGEi9300" drewgaren@upload.goo.im:~/public_html/i9300/Bigfoot/Stable
fi

# Remove Changelogs
if [ "$RELEASE" == "nightly" ]
then
    rm "$rdir"/changelog.txt
    rm "$rdir"/changelog_"$DATE".txt
else
    rm "$rdir"/changelog.txt
    rm "$rdir"/changelog_"$BF_BUILD".txt
fi

echo "Cleaning build folder";
make clean;

echo "Bigfoot packages built, Changelog generated and everything uploaded to server!"

