#!/bin/bash

OUTPUT=$1
SCRIPT_DIR=$(cd "$(dirname ${BASH_SOURCE:-$0})" ; pwd )

if [ -z $OUTPUT ] ; then
	echo "missing output dir"
	exit
fi

PROG="hello nginx python"


# plot
gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/imgsize.eps"
set pointsize 2
set xzeroaxis
set grid

set boxwidth 0.3
set style fill pattern
set key top left
set size 1.0,0.7
set bmargin 6

set ylabel "Image size (Mbyte)"
#set yrange [0:80]
#set logscale y
#set xtics font ", 18"
set xtics ("nginx\n(ukontainer)" 0, "python\n(ukontainer)" 1, "nginx\n(official)" 2, "python\n(official)" 3)
#set xrange [-0.5:4.5]
set xtics nomirror

set datafile separator ','

plot '${OUTPUT}/imgsize.dat'  usi (\$0-0.15):(\$2/1000000) w boxes title "amd64", \
     '' usin (\$0+0.15):(\$3/1000000) w boxes title "arm64" 

set terminal png lw 3 14 crop
#set xtics nomirror rotate by -45
set output "${OUTPUT}/imgsize.png"
replot


set terminal dumb
unset output
replot

quit
EndGNUPLOT


# report
cat $OUTPUT/imgsize.dat

grep nginx $OUTPUT/imgsize.dat | cut -d, -f2 | tr "\n" " " | awk  '{printf "nginx (ukon/docker:amd64) = %f%%\n", 100*$1/$2}'
grep python $OUTPUT/imgsize.dat | cut -d, -f2 | tr "\n" " " | awk  '{printf "python (ukon/docker:amd64) = %f%%\n", 100*$1/$2}'

grep nginx $OUTPUT/imgsize.dat | cut -d, -f3 | tr "\n" " " | awk  '{printf "nginx (ukon/docker:arm64) = %f%%\n", 100*$1/$2}'
grep python $OUTPUT/imgsize.dat | cut -d, -f3 | tr "\n" " " | awk  '{printf "python (ukon/docker:arm64) = %f%%\n", 100*$1/$2}'
