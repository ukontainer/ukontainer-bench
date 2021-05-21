
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
source "$SCRIPT_DIR/../common.sh"

OUTPUT=$1
mkdir -p ${OUTPUT}/out

PKG_SIZES="1024 4096 16384 65536 262144"

# parse outputs

# thpt (req/sec)
for tls in http https https-ktls https-ktls-sendfile; do
grep -E -h Req/Sec  ${OUTPUT}/nginx*-$tls-lkl-[0-9].*  \
    | awk '{print $2 " " $3}' | sed "s/k/K/g" | numfmt --from=si --field=1,2 | \
    awk '{print $1 " " $2}' \
 > ${OUTPUT}/nginx-$tls-lkl-thpt.dat
grep -E -h Req/Sec  ${OUTPUT}/nginx*-$tls-lkl-hijack-[0-9].*  \
    | awk '{print $2 " " $3}' | sed "s/k/K/g" | numfmt --from=si --field=1,2 | \
    awk '{print $1 " " $2}' \
 > ${OUTPUT}/nginx-$tls-lkl-hijack-thpt.dat
grep -E -h Requests/sec  ${OUTPUT}/nginx*-$tls-lkl-hijack-[0-9].*  \
    | awk '{print $2}'  \
 > ${OUTPUT}/nginx-$tls-lkl-hijack-thpt.dat
grep -E -h Req/Sec  ${OUTPUT}/nginx*-$tls-native-[0-9].*  \
    | awk '{print $2 " " $3}' | sed "s/k/K/g" | numfmt --from=si --field=1,2 | \
    awk '{print $1 " " $2}' \
 > ${OUTPUT}/nginx-$tls-native-thpt.dat
grep -E -h Requests/sec  ${OUTPUT}/nginx*-$tls-native-[0-9].*  \
    | awk '{print $2}'  \
 > ${OUTPUT}/nginx-$tls-native-thpt.dat
grep -E -h Req/Sec  ${OUTPUT}/nginx*-$tls-docker-[0-9].*  \
    | awk '{print $2 " " $3}' | sed "s/k/K/g" | numfmt --from=si --field=1,2 | \
    awk '{print $1 " " $2}' \
 > ${OUTPUT}/nginx-$tls-docker-thpt.dat
# latency
grep -E -h "Latency.*%" ${OUTPUT}/nginx*-$tls-lkl-[0-9].*  \
 | awk '{print $2 " " $3}' | sed "s/ms/ 1000/g" | sed "s/us/ 1/g" | awk '{print $1*$2 " " $3*$4}'  > ${OUTPUT}/nginx-$tls-lkl.dat
grep -E -h "Latency.*%" ${OUTPUT}/nginx*-$tls-lkl-hijack-[0-9].*  \
 | awk '{print $2 " " $3}' | sed "s/ms/ 1000/g" | sed "s/us/ 1/g" | awk '{print $1*$2 " " $3*$4}'  > ${OUTPUT}/nginx-$tls-lkl-hijack.dat
grep -E -h "Latency.*%" ${OUTPUT}/nginx*-$tls-native-[0-9]* \
 | awk '{print $2 " " $3}' | sed "s/ms/ 1000/g" | sed "s/us/ 1/g" | awk '{print $1*$2 " " $3*$4}'  > ${OUTPUT}/nginx-$tls-native.dat
grep -E -h "Latency.*%" ${OUTPUT}/nginx*-$tls-docker-[0-9]* \
 | awk '{print $2 " " $3}' | sed "s/ms/ 1000/g" | sed "s/us/ 1/g" | awk '{print $1*$2 " " $3*$4}'  > ${OUTPUT}/nginx-$tls-docker.dat

done

PLOT_STRING_THPT="plot \\"

###if [ ! -s ${OUTPUT}/nginx-docker-thpt.dat ] ; then
###   PLOT_STRING_THPT=$PLOT_STRING_THPT' \'${OUTPUT}/nginx-docker-thpt.dat\' usi (\$0-0.3):(\$1/1000):(\$2/1000) w boxerr lt 1 lc rgb green fill pattern 2 title "docker(mac)" , '
###fi
###if [ ! -s ${OUTPUT}/nginx-lkl-thpt.dat ] ; then
###   PLOT_STRING_THPT=$PLOT_STRING_THPT' \'${OUTPUT}/nginx-lkl-thpt.dat\' usi (\$0-0):(\$1/1000):(\$2/1000) w boxerr lt 1 lc rgb cyan fill pattern 4 title "lkl", \'
###fi
###if [ ! -s ${OUTPUT}/nginx-lkl-hijack-thpt.dat ] ; then
###   PLOT_STRING_THPT=$PLOT_STRING_THPT' \'${OUTPUT}/nginx-lkl-hijack-thpt.dat\' usi (\$0-0):(\$1/1000):(\$2/1000) w boxerr lt 1 lc rgb blue fill pattern 6 title "lkl-hijack", \'
###fi
###if [ ! -s ${OUTPUT}/nginx-native-thpt.dat ] ; then
###   PLOT_STRING_THPT=$PLOT_STRING_THPT' \'${OUTPUT}/nginx-native-thpt.dat\' usi (\$0+0.3):(\$1/1000):(\$2/1000) w boxerr fill pattern 0 lt 1 lc rgb red title "native(mac)"'
###fi



gnuplot  << EndGNUPLOT
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/nginx-wrk.eps"
set pointsize 2
set xzeroaxis
set grid ytics

set boxwidth 0.1
set style fill pattern
set key top righ
set size 1.0,0.7

# trans/sec
set ylabel "Throughput (KReq/sec)"
set yrange [0:200]
set ytics 50
set xtics ("1k" 0, "4k" 1, "16k" 2, "64k" 3, "256k" 4)
set xlabel "File size (bytes)"
set xrange [-1:5]
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/nginx-wrk-thpt.eps"

plot \
   '${OUTPUT}/nginx-http-lkl-hijack-thpt.dat' usi (\$0-0.35):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_RUNU title "lkl", \
   '${OUTPUT}/nginx-https-lkl-hijack-thpt.dat' usi (\$0-0.25):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_RUNU fill patter 1 title "lkl(https)", \
   '${OUTPUT}/nginx-https-ktls-lkl-hijack-thpt.dat' usi (\$0-0.15):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_RUNU fill patter 1 title "lkl(https-ktls)", \
   '${OUTPUT}/nginx-https-ktls-sendfile-lkl-hijack-thpt.dat' usi (\$0-0.05):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_RUNU fill patter 1 title "lkl(https-ktls-sendfile)", \
   '${OUTPUT}/nginx-http-native-thpt.dat' usi (\$0+0.05):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_NATIVE title "native", \
   '${OUTPUT}/nginx-https-native-thpt.dat' usi (\$0+0.15):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_NATIVE fill patter 1 title "native(https)", \
   '${OUTPUT}/nginx-https-ktls-native-thpt.dat' usi (\$0+0.25):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_NATIVE fill patter 1 title "native(https-ktls)", \
   '${OUTPUT}/nginx-https-ktls-sendfile-native-thpt.dat' usi (\$0+0.35):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_NATIVE fill patter 1 title "native(https-ktls-sendfile)"

set terminal png lw 3 14 crop
set output "${OUTPUT}/out/nginx-wrk-thpt.png"
replot

# latency
set ylabel "Latency (msec)"
set ytics 50
set yrange [0:100]
set xtics ("1k" 0, "4k" 1, "16k" 2, "64k" 3, "256k" 4)
set xlabel "File size (bytes)"
set xrange [-1:5]
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/nginx-wrk-latency.eps"

plot \
   '${OUTPUT}/nginx-http-lkl-hijack.dat' usin (\$0-0.35):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_RUNU title "lkl-hijack", \
   '${OUTPUT}/nginx-https-lkl-hijack.dat' usin (\$0-0.25):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_RUNU fill patter 1 title "lkl-hijack(https)", \
   '${OUTPUT}/nginx-https-ktls-lkl-hijack.dat' usin (\$0-0.15):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_RUNU fill patter 1 title "lkl-hijack(https-ktls)", \
   '${OUTPUT}/nginx-https-ktls-sendfile-lkl-hijack.dat' usin (\$0-0.05):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_RUNU fill patter 1 title "lkl-hijack(https-ktls-sendfile)", \
   '${OUTPUT}/nginx-http-native.dat' usin (\$0+0.05):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_NATIVE title "native" ,\
   '${OUTPUT}/nginx-https-native.dat' usin (\$0+0.15):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_NATIVE fill patter 1 title "native(https)", \
   '${OUTPUT}/nginx-https-ktls-native.dat' usin (\$0+0.25):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_NATIVE fill patter 1 title "native(https-ktls)", \
   '${OUTPUT}/nginx-https-ktls-sendfile-native.dat' usin (\$0+0.35):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_NATIVE fill patter 1 title "native(https-ktls-sendfile)"

set terminal png lw 3 14 crop
set output "${OUTPUT}/out/nginx-wrk-latency.png"
replot

# combined
set ylabel "Throughput (KReq/sec)"
set ytics 10
set yrange [0:100]
set y2label "Latency (msec)"
set y2tics 10
set y2range [0:]
set xtics ("1k" 0, "4k" 1, "16k" 2, "64k" 3, "256k" 4)
set xlabel "File size (bytes)"
set xrange [-1:5]
set terminal postscript eps lw 3 "Helvetica" 24
set output "${OUTPUT}/out/nginx-wrk-combined.eps"

plot \
   '${OUTPUT}/nginx-http-lkl-hijack-thpt.dat' usi (\$0-0):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_RUNU title "lkl", \
   '${OUTPUT}/nginx-http-native-thpt.dat' usi (\$0+0.3):(\$1/1000):(\$2/1000) w boxerr $BOX_PAT_NATIVE title "native" ,\
   '${OUTPUT}/nginx-http-lkl-hijack.dat' usin (\$0-0):(\$1/1000):(\$2/1000) w yerror ps 1 lc rgb "cyan" ax x1y2 notitle, \
   '${OUTPUT}/nginx-http-native.dat' usin (\$0+0.3):(\$1/1000):(\$2/1000) w yerror ps 1 lc rgb "red" ax x1y2 notitle

set terminal png lw 3 14 crop
set xtics nomirror font ",14"
set output "${OUTPUT}/out/nginx-wrk-combined.png"
replot


set terminal dumb
unset output
replot

quit
EndGNUPLOT

