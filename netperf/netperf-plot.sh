#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/../netperf-common.sh"
source "$SCRIPT_DIR/../common.sh"

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
grep -E -h bits ${OUTPUT}/${PREFIX}*-lkl-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-lkl.dat
grep -E -h bits ${OUTPUT}/${PREFIX}*-native-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-native.dat
grep -E -h bits ${OUTPUT}/${PREFIX}*-runc-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-runc.dat
grep -E -h bits ${OUTPUT}/${PREFIX}*-kata-runtime-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-kata-runtime.dat
grep -E -h bits ${OUTPUT}/${PREFIX}*-runsc-ptrace-user-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-runsc-ptrace-user.dat
#grep -E -h bits ${OUTPUT}/${PREFIX}*-runsc-kvm-user-* \
#| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
#| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
#> ${OUTPUT}/${DIR}/tcp-stream-runsc-kvm-user.dat
grep -E -h bits ${OUTPUT}/${PREFIX}*-runnc-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-runnc.dat
grep -E -h bits ${OUTPUT}/${PREFIX}*-graphene-* \
| dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 psize d3 thpt d4 \
| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
> ${OUTPUT}/${DIR}/tcp-stream-graphene.dat

# TCP_RR
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-lkl-* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
 | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-lkl.dat
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-native-* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
 | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-native.dat
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-runc-* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
 | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-runc.dat
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-kata-runtime-* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
 | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-kata-runtime.dat
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-runsc-ptrace-user-* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
 | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-runsc-ptrace-user.dat
#grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-runsc-kvm-user-* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
# | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/tcp-rr-runsc-kvm-user.dat
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-runnc-* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
 | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-runnc.dat
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-graphene-* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
 | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-graphene.dat

# TCP_RR (latency)
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-lkl-*-1* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 d9 d8 lat-mean lat-stddev lat-count d10 \
 | dbsort -n psize | dbcol lat-mean lat-stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-lkl-latency.dat
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-native-*-1* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 d9 d8 lat-mean lat-stddev lat-count d10  \
 | dbsort -n psize | dbcol lat-mean lat-stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-native-latency.dat
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-runc-*-1* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 d9 d8 lat-mean lat-stddev lat-count d10  \
 | dbsort -n psize | dbcol lat-mean lat-stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-runc-latency.dat
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-kata-runtime-*-1* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 d9 d8 lat-mean lat-stddev lat-count d10  \
 | dbsort -n psize | dbcol lat-mean lat-stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-kata-runtime-latency.dat
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-runsc-ptrace-user-*-1* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 d9 d8 lat-mean lat-stddev lat-count d10  \
 | dbsort -n psize | dbcol lat-mean lat-stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-runsc-ptrace-user-latency.dat
#grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-runsc-kvm-user-* \
# | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 thpt d8 \
# | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
# > ${OUTPUT}/${DIR}/tcp-rr-runsc-kvm-user.dat
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-runnc-*-1* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 d9 d8 lat-mean lat-stddev lat-count d10  \
 | dbsort -n psize | dbcol lat-mean lat-stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-runnc-latency.dat
grep -E -h Trans ${OUTPUT}/${PREFIX_RR}*-graphene-*-1* \
 | dbcoldefine dum | csv_to_db | dbcoldefine  d1 d2 d3 d4 d5 psize d7 d9 d8 lat-mean lat-stddev lat-count d10  \
 | dbsort -n psize | dbcol lat-mean lat-stddev \
 > ${OUTPUT}/${DIR}/tcp-rr-graphene-latency.dat

# UDP_STREAM
#### grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-lkl-* \
#### | dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
#### | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
#### > ${OUTPUT}/${DIR}/udp-stream-lkl.dat
#### grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-native-* \
#### | dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
#### | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
#### > ${OUTPUT}/${DIR}/udp-stream-native.dat
#### grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-runc-* \
#### | dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
#### | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
#### > ${OUTPUT}/${DIR}/udp-stream-runc.dat
#### grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-kata-runtime-* \
#### | dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
#### | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
#### > ${OUTPUT}/${DIR}/udp-stream-kata-runtime.dat
#### grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-runsc-ptrace-user-* \
#### | dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
#### | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
#### > ${OUTPUT}/${DIR}/udp-stream-runsc-ptrace-user.dat
#### #grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-runsc-kvm-user-* \
#### #| dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
#### #| dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
#### #> ${OUTPUT}/${DIR}/udp-stream-runsc-kvm-user.dat
#### grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-runnc-* \
#### | dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
#### | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
#### > ${OUTPUT}/${DIR}/udp-stream-runnc.dat
#### grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-graphene-* \
#### | dbcoldefine dum | csv_to_db | dbcoldefine  psize thpt d1 d2 d3 \
#### | dbmultistats -k psize thpt | dbsort -n psize | dbcol mean stddev \
#### > ${OUTPUT}/${DIR}/udp-stream-graphene.dat
#### 
#### # UDP_STREAM PPS
#### grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-lkl-* \
#### | dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
#### | dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
#### > ${OUTPUT}/${DIR}/udp-stream-pps-lkl.dat
#### grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-native-* \
#### | dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
#### | dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
#### > ${OUTPUT}/${DIR}/udp-stream-pps-native.dat
#### grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-runc-* \
#### | dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
#### | dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
#### > ${OUTPUT}/${DIR}/udp-stream-pps-runc.dat
#### grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-kata-runtime-* \
#### | dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
#### | dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
#### > ${OUTPUT}/${DIR}/udp-stream-pps-kata-runtime.dat
#### grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-runsc-ptrace-user-* \
#### | dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
#### | dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
#### > ${OUTPUT}/${DIR}/udp-stream-pps-runsc-ptrace-user.dat
#### #grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-runsc-kvm-user-* \
#### #| dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
#### #| dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
#### #> ${OUTPUT}/${DIR}/udp-stream-pps-runsc-kvm-user.dat
#### grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-runnc-* \
#### | dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
#### | dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
#### > ${OUTPUT}/${DIR}/udp-stream-pps-runnc.dat
#### grep -E -h bits ${OUTPUT}/${PREFIX_UDP}*-graphene-* \
#### | dbcoldefine dum | csv_to_db|dbcoldefine  psize d1 d5 npkt d2 | dbroweval   '_npkt=_npkt/10'\
#### | dbmultistats -f "%d" -k psize npkt |  dbsort -n psize  | dbcol mean stddev \
#### > ${OUTPUT}/${DIR}/udp-stream-pps-graphene.dat

done # end of ${DIR}


PSIZE_XTICS="('64' 0, '128' 2, '256' 4, '512' 6, '1024' 8, '1500' 10, '65507' 12)"

gnuplot  << EndGNUPLOT
set terminal postscript color eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/tcp-stream.eps"
#set xtics font "Helvetica,14"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.25
set style fill pattern

set size 1.0,0.9
set key font ",18"
set key top left Left reverse
#set key above vertical maxrows 2

set xrange [-1:13]
set xtics ${PSIZE_XTICS}
set xlabel "Payload size (bytes)"
set yrange [-10:10]
set ytics ('10' -10, '5' -5, '0' 0, '5' 5, '10' 10)
set ylabel "Goodput (Gbps)" offset +0.8
set label 1 right at first -2.0,10 "(tx)"
set label 2 right at first -2.0,-10 "(rx)"



plot \
   '${OUTPUT}/tx/tcp-stream-runc.dat' usin (\$0*2-0.75):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_RUNC title "runc" ,\
   '${OUTPUT}/tx/tcp-stream-kata-runtime.dat' usin (\$0*2-0.5):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_KATA title "kata" ,\
   '${OUTPUT}/tx/tcp-stream-runsc-ptrace-user.dat' usin (\$0*2-0.25):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_GVISOR_P title "gvisor" ,\
   '${OUTPUT}/tx/tcp-stream-graphene.dat' usin (\$0*2+0.0):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_GRAPH title "graphene" ,\
   '${OUTPUT}/tx/tcp-stream-runnc.dat' usin (\$0*2+0.25):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_RUNNC title "nabla" ,\
   '${OUTPUT}/tx/tcp-stream-lkl.dat' usin (\$0*2+0.5):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_RUNU title "ukontainer" ,\
   '${OUTPUT}/tx/tcp-stream-native.dat' usin (\$0*2+0.75):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_NATIVE title "native" ,\
   '${OUTPUT}/rx/tcp-stream-runc.dat' usin (\$0*2-0.75):(\$1*-1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_RUNC notitle ,\
   '${OUTPUT}/rx/tcp-stream-kata-runtime.dat' usin (\$0*2-0.5):(\$1*-1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_KATA notitle ,\
   '${OUTPUT}/rx/tcp-stream-runsc-ptrace-user.dat' usin (\$0*2-0.25):(\$1*-1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_GVISOR_P notitle ,\
   '${OUTPUT}/rx/tcp-stream-graphene.dat' usin (\$0*2-0.0):(\$1*-1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_GRAPH notitle ,\
   '${OUTPUT}/rx/tcp-stream-runnc.dat' usin (\$0*2+0.25):(\$1*-1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_RUNNC notitle ,\
   '${OUTPUT}/rx/tcp-stream-lkl.dat' usin (\$0*2+0.5):(\$1*-1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_RUNU notitle ,\
   '${OUTPUT}/rx/tcp-stream-native.dat' usin (\$0*2+0.75):(\$1*-1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_NATIVE notitle


set terminal png lw 3 14 crop
set key font ",14"
set ylabel "Goodput (Gbps)" offset +0.5
set output "${OUTPUT}/out/tcp-stream.png"
replot


#### # UDP
#### set terminal postscript eps lw 3 "Helvetica" 24
#### set output "${OUTPUT}/out/udp-stream.eps"
#### set ylabel "Goodput (Gbps)"
#### set yrange [0:10]
#### set key font ",18"
#### set key top left
#### 
#### plot \
####    '${OUTPUT}/tx/udp-stream-runc.dat' usin (\$0-0.45):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_RUNC title "runc" ,\
####    '${OUTPUT}/tx/udp-stream-kata-runtime.dat' usin (\$0-0.30):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_KATA title "kata" ,\
####    '${OUTPUT}/tx/udp-stream-runsc-ptrace-user.dat' usin (\$0-0.15):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_GVISOR_P title "gvisor" ,\
####    '${OUTPUT}/tx/udp-stream-graphene.dat' usin (\$0+0.0):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_GRAPH title "graphene" ,\
####    '${OUTPUT}/tx/udp-stream-lkl.dat' usin (\$0+0.15):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_RUNU title "ukontainer" ,\
####    '${OUTPUT}/tx/udp-stream-native.dat' usin (\$0+0.3):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_NATIVE title "native"
#### 
#### 
#### set terminal png lw 3 14 crop
#### set key font ",14"
#### set output "${OUTPUT}/out/udp-stream.png"
#### replot
#### 
#### set terminal postscript eps lw 3 "Helvetica" 24
#### set output "${OUTPUT}/out/udp-stream-pps.eps"
#### set ylabel "Goodput (Mpps)"
#### set key font ",18"
#### set key top right
#### set yrange [0:1]
#### 
#### plot \
####    '${OUTPUT}/tx/udp-stream-pps-runc.dat' usin (\$0-0.45):(\$1/1000000):(\$2/1000000) w boxerrorbar $BOX_PAT_RUNC title "runc" ,\
####    '${OUTPUT}/tx/udp-stream-pps-kata-runtime.dat' usin (\$0-0.30):(\$1/1000000):(\$2/1000000) w boxerrorbar $BOX_PAT_KATA title "kata" ,\
####    '${OUTPUT}/tx/udp-stream-pps-runsc-ptrace-user.dat' usin (\$0-0.15):(\$1/1000000):(\$2/1000000) w boxerrorbar $BOX_PAT_GVISOR_P title "gvisor" ,\
####    '${OUTPUT}/tx/udp-stream-pps-graphene.dat' usin (\$0+0.0):(\$1/1000000):(\$2/1000000) w boxerrorbar $BOX_PAT_GRAPH title "graphene" ,\
####    '${OUTPUT}/tx/udp-stream-pps-lkl.dat' usin (\$0+0.15):(\$1/1000000):(\$2/1000000) w boxerrorbar $BOX_PAT_RUNU title "ukontainer" ,\
####    '${OUTPUT}/tx/udp-stream-pps-native.dat' usin (\$0+0.3):(\$1/1000000):(\$2/1000000) w boxerrorbar $BOX_PAT_NATIVE title "native"
#### 
#### set terminal png lw 3 14 crop
#### set key font ",14"
#### set output "${OUTPUT}/out/udp-stream-pps.png"
#### replot


# TCP_RR
unset xlabel
set xrange [-0.5:6.5]
set xtics ('runc' 0, 'kata' 1, 'gvisor' 2, 'graphene' 3, 'nabla' 4, 'ukontainer' 5, 'native' 6) rotate by 315
set terminal postscript color eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/tcp-rr.eps"
set ylabel "Goodput (KTrans/sec)"
set yrange [0:20]
set ytics auto
set key font ",18"
set key top right
unset label 1
unset label 2

plot \
   '${OUTPUT}/tx/tcp-rr-runc.dat' usin (\$0-0.45):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_RUNC title "runc" ,\
   '${OUTPUT}/tx/tcp-rr-kata-runtime.dat' usin (\$0-0.30):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_KATA title "kata" ,\
   '${OUTPUT}/tx/tcp-rr-runsc-ptrace-user.dat' usin (\$0-0.15):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_GVISOR_P title "gvisor" ,\
   '${OUTPUT}/tx/tcp-rr-graphene.dat' usin (\$0+0.0):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_GRAPH title "graphene" ,\
   '${OUTPUT}/tx/tcp-rr-runnc.dat' usin (\$0+0.0):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_RUNNC title "nabla" ,\
   '${OUTPUT}/tx/tcp-rr-lkl.dat' usin (\$0+0.15):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_RUNU title "ukontainer" ,\
   '${OUTPUT}/tx/tcp-rr-native.dat' usin (\$0+0.3):(\$1/1000):(\$2/1000) w boxerrorbar $BOX_PAT_NATIVE title "native"

set terminal png lw 3 14 crop
set key font ",14"
set output "${OUTPUT}/out/tcp-rr.png"
replot

set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/tcp-rr-latency.eps"
set ylabel "Latency (usec)" offset +2.0
set yrange [0:300]

set boxwidth 0.3
set style fill pattern
unset key
set size 1.0,0.7

plot \
   '${OUTPUT}/tx/tcp-rr-runc-latency.dat' usin (0):(\$1):(\$2) w boxerrorbar $BOX_PAT_RUNC title "runc" ,\
   '' usi (0):(\$1):(\$1) w labels notitle offset 0,2, \
   '${OUTPUT}/tx/tcp-rr-kata-runtime-latency.dat' usin (1):(\$1):(\$2) w boxerrorbar $BOX_PAT_KATA title "kata" ,\
   '' usi (1):(\$1):(\$1) w labels notitle offset 0,2, \
   '${OUTPUT}/tx/tcp-rr-runsc-ptrace-user-latency.dat' usin (2):(\$1):(\$2) w boxerrorbar $BOX_PAT_GVISOR_P title "gvisor" ,\
   '' usi (2):(\$1):(\$1) w labels notitle offset 0,2, \
   '${OUTPUT}/tx/tcp-rr-graphene-latency.dat' usin (3):(\$1):(\$2) w boxerrorbar $BOX_PAT_GRAPH title "graphene" ,\
   '' usi (3):(\$1):(\$1) w labels notitle offset 0,2, \
   '${OUTPUT}/tx/tcp-rr-runnc-latency.dat' usin (4):(\$1):(\$2) w boxerrorbar $BOX_PAT_RUNNC title "nabla" ,\
   '' usi (4):(\$1):(\$1) w labels notitle offset 0,2, \
   '${OUTPUT}/tx/tcp-rr-lkl-latency.dat' usin (5):(\$1):(\$2) w boxerrorbar $BOX_PAT_RUNU title "ukontainer" ,\
   '' usi (5):(\$1):(\$1) w labels notitle offset 0,2, \
   '${OUTPUT}/tx/tcp-rr-native-latency.dat' usin (6):(\$1):(\$2) w boxerrorbar $BOX_PAT_NATIVE title "native" ,\
   '' usi (6):(\$1):(\$1) w labels notitle offset 0,2

set terminal png lw 3 14 crop
set output "${OUTPUT}/out/tcp-rr-latency.png"
replot

set terminal dumb
unset key
unset output
replot

quit
EndGNUPLOT

