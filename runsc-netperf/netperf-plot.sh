#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/../netperf-common.sh"

OUTPUT="$1"
DIRS="tx rx"
PREFIX=netperf-bench-TCP_STREAM
PREFIX_RR=netperf-bench-TCP_RR
PREFIX_UDP=netperf-bench-UDP_STREAM

for DIR in $DIRS; do

if [[ "$DIR" == "rx" ]] ; then
  PREFIX=netperf-bench-TCP_MAERTS
elif [[ "$DIR" == "tx" ]] ; then
  PREFIX=netperf-bench-TCP_STREAM
else
  echo "Invalid direction: $0 \${OUTPUT} [tx/rx]"
  exit
fi


rm -rf "$OUTPUT/$DIR"
mkdir -p "$OUTPUT/$DIR"
mkdir -p "$OUTPUT/out/"


# parse outputs

# TCP_STREAM
grep -E -h bits ${OUTPUT}/${PREFIX}*-runsc-ptrace-user-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-runsc-ptrace-user.dat
grep -E -h bits ${OUTPUT}/${PREFIX}*-runsc-ptrace-host-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-runsc-ptrace-host.dat
grep -E -h bits ${OUTPUT}/${PREFIX}*-runsc-kvm-user-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-runsc-kvm-user.dat
grep -E -h bits ${OUTPUT}/${PREFIX}*-runsc-kvm-host-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-runsc-kvm-host.dat

# TCP_RR
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-runsc-ptrace-user-* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
 | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-runsc-ptrace-user.dat
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-runsc-ptrace-host-* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
 | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-runsc-ptrace-host.dat
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-runsc-kvm-user-* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
 | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-runsc-kvm-user.dat
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-runsc-kvm-host-* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
 | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-runsc-kvm-host.dat

# UDP_STREAM
grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-runsc-ptrace-user-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-runsc-ptrace-user.dat
grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-runsc-ptrace-host-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-runsc-ptrace-host.dat
grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-runsc-kvm-user-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-runsc-kvm-user.dat
grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-runsc-kvm-host-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-runsc-kvm-host.dat

# UDP_STREAM PPS
grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-runsc-ptrace-user-* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-runsc-ptrace-user.dat
grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-runsc-ptrace-host-* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-runsc-ptrace-host.dat
grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-runsc-kvm-user-* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-runsc-kvm-user.dat
grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-runsc-kvm-host-* \
| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
> ${OUTPUT}/${DIR}/udp-stream-pps-runsc-kvm-host.dat

done # end of ${DIR}


gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/tcp-stream.eps"
#set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.2
set style fill pattern

set size 1.0,0.8
set key top left

set xrange [-0.5:6.5]
set xtics ${PSIZE_XTICS}
set xlabel "Payload size (bytes)"
set yrange [-10:10]
set ytics ('(rx) 10' -10, '5' -5, '0' 0, '5' 5, '(tx) 10' 10)
set ylabel "Goodput (Gbps)"


plot \
   '${OUTPUT}/tx/tcp-stream-runsc-ptrace-user.dat' usin (\$0-0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 2 lc rgb "green" title "ptrace+user" ,\
   '${OUTPUT}/tx/tcp-stream-runsc-ptrace-host.dat' usin (\$0-0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 1 lc rgb "gray" title "ptrace+host" ,\
   '${OUTPUT}/tx/tcp-stream-runsc-kvm-user.dat' usin (\$0+0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 3 lc rgb "blue" title "kvm+user" ,\
   '${OUTPUT}/tx/tcp-stream-runsc-kvm-host.dat' usin (\$0+0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 lc rgb "red" title "kvm+host" ,\
   '${OUTPUT}/rx/tcp-stream-runsc-ptrace-user.dat' usin (\$0-0.3):(\$1*-1/1000):(\$2/1000) w boxerrorbar fill patter 2 lc rgb "green" notitle ,\
   '${OUTPUT}/rx/tcp-stream-runsc-ptrace-host.dat' usin (\$0-0.1):(\$1*-1/1000):(\$2/1000) w boxerrorbar fill patter 1 lc rgb "gray" notitle ,\
   '${OUTPUT}/rx/tcp-stream-runsc-kvm-user.dat' usin (\$0+0.1):(\$1*-1/1000):(\$2/1000) w boxerrorbar fill patter 3 lc rgb "blue" notitle ,\
   '${OUTPUT}/rx/tcp-stream-runsc-kvm-host.dat' usin (\$0+0.3):(\$1*-1/1000):(\$2/1000) w boxerrorbar fill patter 0 lc rgb "red" notitle


set terminal png lw 3 14 crop
set output "${OUTPUT}/out/tcp-stream.png"
replot


set xlabel "Payload size (bytes)"
set xrange [-0.5:6.5]
set xtics ${PSIZE_XTICS}
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/tcp-rr.eps"
set ylabel "Goodput (KTrans/sec)"
set yrange [0:12]
set ytics auto
set key top right

plot \
   '${OUTPUT}/tx/tcp-rr-runsc-ptrace-user.dat' usin (\$0-0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 2 lc rgb "green" title "ptrace+user" ,\
   '${OUTPUT}/tx/tcp-rr-runsc-ptrace-host.dat' usin (\$0-0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 1 lc rgb "gray" title "ptrace+host" ,\
   '${OUTPUT}/tx/tcp-rr-runsc-kvm-user.dat' usin (\$0+0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 3 lc rgb "blue" title "kvm+user" ,\
   '${OUTPUT}/tx/tcp-rr-runsc-kvm-host.dat' usin (\$0+0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 lc rgb "red" title "kvm+host"

set terminal png lw 3 14 crop
set output "${OUTPUT}/out/tcp-rr.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/udp-stream.eps"
set ylabel "Goodput (Gbps)"
set yrange [0:7]
set key top left

plot \
   '${OUTPUT}/tx/udp-stream-runsc-ptrace-user.dat' usin (\$0-0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 2 lc rgb "green" title "ptrace+user" ,\
   '${OUTPUT}/tx/udp-stream-runsc-ptrace-host.dat' usin (\$0-0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 1 lc rgb "gray" title "ptrace+host" ,\
   '${OUTPUT}/tx/udp-stream-runsc-kvm-user.dat' usin (\$0+0.1):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 3 lc rgb "blue" title "kvm+user" ,\
   '${OUTPUT}/tx/udp-stream-runsc-kvm-host.dat' usin (\$0+0.3):(\$1/1000):(\$2/1000) w boxerrorbar fill patter 0 lc rgb "red" title "kvm+host"


set terminal png lw 3 14 crop
set output "${OUTPUT}/out/udp-stream.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/udp-stream-pps.eps"
set ylabel "Goodput (Mpps)"
set key top right
set yrange [0:0.08]

plot \
   '${OUTPUT}/tx/udp-stream-pps-runsc-ptrace-user.dat' usin (\$0-0.3):(\$1/1000000):(\$2/1000000) w boxerrorbar fill patter 2 lc rgb "green" title "ptrace+user" ,\
   '${OUTPUT}/tx/udp-stream-pps-runsc-ptrace-host.dat' usin (\$0-0.1):(\$1/1000000):(\$2/1000000) w boxerrorbar fill patter 1 lc rgb "gray" title "ptrace+host" ,\
   '${OUTPUT}/tx/udp-stream-pps-runsc-kvm-user.dat' usin (\$0+0.1):(\$1/1000000):(\$2/1000000) w boxerrorbar fill patter 3 lc rgb "blue" title "kvm+user" ,\
   '${OUTPUT}/tx/udp-stream-pps-runsc-kvm-host.dat' usin (\$0+0.3):(\$1/1000000):(\$2/1000000) w boxerrorbar fill patter 0 lc rgb "red" title "kvm+host"

set terminal png lw 3 14 crop
set output "${OUTPUT}/out/udp-stream-pps.png"
replot

set terminal dumb
unset output
replot

quit
EndGNUPLOT

