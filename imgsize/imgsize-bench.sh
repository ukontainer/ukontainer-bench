#!/bin/bash

TRIALS=1

OUTPUT="$(date "+%Y-%m-%d")"
SCRIPT_DIR=$(cd $(dirname $0); pwd)


mkdir -p $OUTPUT
rm -rf $OUTPUT/*

exec > >(tee "$OUTPUT/$(basename $0).log") 2>&1

IMAGES="ukontainer/runu-nginx ukontainer/runu-python ukontainer/runu-node ukontainer/runu-netperf library/nginx library/python library/node"
IMAGES="ukontainer/runu-nginx ukontainer/runu-python library/nginx library/python"
URI=https://registry.hub.docker.com/v2/repositories
ARCH="amd64 arm64"

for img in $IMAGES
do

echo -n "$img," >> $OUTPUT/imgsize.dat

for arch in $ARCH
do

	if [ $img == "library/nginx" ] ; then
		TAG="stable"
	elif [ $img == "library/python" ] ; then
		TAG="3.9.1-slim"
	elif [ $img == "library/node" ] ; then
		TAG="14.15.4-slim"
	else
		TAG="0.5-slim"
	fi

	echo -n "$img:$TAG/linux/$arch: "
	SIZE=$(curl -s $URI/$img/tags?page_size=100 | \
	 jq -r ".results[] | select(.name == \"$TAG\")" | \
	 jq -r ".images[] | select(.architecture==\"$arch\") | select(.os==\"linux\") | .size") #|  gnumfmt --to=iec-i
	echo $SIZE
	echo -n $SIZE"," >> $OUTPUT/imgsize.dat
done

echo "" >> $OUTPUT/imgsize.dat

done


bash ./imgsize-plot.sh $OUTPUT
