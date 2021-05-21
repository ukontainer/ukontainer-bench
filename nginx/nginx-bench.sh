#!/bin/bash

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
#source "$SCRIPT_DIR/netperf-common.sh"

DEST_ADDR="10.0.39.2"
SELF_ADDR="172.17.0.39"
HOST_ADDR="10.0.39.1"
TRIALS=1
PKG_SIZES="1024 4096 16384 65536 262144"

LKLMUSL_NGINX="$HOME/gitworks/rumprun-packages/"
LKL_HIJACK_ROOT="/home/tazaki/work/lkl-linux"
NGINX_BIN="/home/tazaki/work/nginx-ktls/objs/nginx"
NGINX_NATIVE_ROOT="/home/tazaki/work/nginx-ktls/root"
export PATH=~/bin:~/gitworks/frankenlibc/rump/bin:${PATH}

WRK_NUM_CONN=64
WRK_NUM_THREAD=8
WRK_CMD="~/work/wrk/wrk -t $WRK_NUM_THREAD -c $WRK_NUM_CONN --latency"

OUTPUT="$(date "+%Y-%m-%d")"

main() {
  mkdir -p "$OUTPUT"
  rm -f "$OUTPUT"/nginx-*.dat
  exec > >(tee "$OUTPUT/$(basename $0).log") 2>&1

  # for nginx/wrk tests
  for num in $(seq 1 "$TRIALS"); do
    for size in $PKG_SIZES; do
      nginx::run wrk $num $size
      nginx::run wrk $num $size https
      nginx::run wrk $num $size https-ktls
      nginx::run wrk $num $size https-ktls-sendfile
    done
  done

  bash "$SCRIPT_DIR/nginx-plot.sh" "$OUTPUT"
}

nginx::run() {
  #nginx::lkl "$@"
  nginx::lkl-hijack "$@"
  nginx::native "$@"
  #nginx::docker "$@"
}


nginx::lkl-hijack() {
(
  local test=$1
  local num=$2
  local ex_arg=$3
  local tls=$4
  local conf=/conf/nginx.conf
  if [ "$tls" == "https" ] ; then
      # non kTLS
      local wrk_args="-Z AES128-GCM-SHA256 https://$SELF_ADDR/${ex_arg}b.img"
  elif [ "$tls" == "https-ktls" ] ; then
      # kTLS
      local wrk_args="-Z AES128-GCM-SHA256 https://$SELF_ADDR/${ex_arg}b.img"
      conf=/conf/nginx-ktls.conf
  elif [ "$tls" == "https-ktls-sendfile" ] ; then
      # kTLS
      local wrk_args="-Z AES128-GCM-SHA256 https://$SELF_ADDR/sf/${ex_arg}b.img"
      conf=/conf/nginx-ktls.conf
  else
      local wrk_args="http://$SELF_ADDR/${ex_arg}b.img"
      tls="http"
  fi

  #setup_lkl

  echo "$(tput bold)== lkl-hijack ($test-$num-$tls-p${ex_arg}) ==$(tput sgr0)"
  killall -9 nginx
  MINO_EXCLUDE="$LKL_HIJACK_ROOT/,./,/dev" \
	      LKL_HIJACK_CONFIG_FILE=./lkl-hijack-ktls.json \
	      taskset -c 0 \
	      $LKL_HIJACK_ROOT/tools/lkl/bin/lkl-hijack.sh $NGINX_BIN -p / -c $conf \
     &
  sleep 3

  ssh "$DEST_ADDR" "$WRK_CMD" "$wrk_args" \
    2>&1 | tee -a "$OUTPUT/nginx-$test-$tls-lkl-hijack-$num.dat"

  kill $!
  wait $! 2>/dev/null
)
}

nginx::lkl() {
(
  local test=$1
  local num=$2
  local ex_arg=$3
  local wrk_args="http://$SELF_ADDR/${ex_arg}b.img"

  #setup_lkl

  echo "$(tput bold)== lkl ($test-$num-$tls-p${ex_arg}) ==$(tput sgr0)"
  sudo killall -9 nginx
  sudo rexec "$LKLMUSL_NGINX/nginx/bin/nginx" \
    "$LKLMUSL_NGINX/nginx/images/data.iso" tap:tap0 config:../lkl.json \
    | grep -v fallback &
  sleep 3
  sudo ifconfig tap0 up; sudo ifconfig bridge1 addm tap0

  ssh -t "$DEST_ADDR" sudo arp -d "$FIXED_ADDRESS"
  ssh "$DEST_ADDR" "$WRK_CMD" "$wrk_args" \
    2>&1 | tee -a "$OUTPUT/nginx-$test-lkl-$num.dat"

  sudo kill $!
  sudo wait $! 2>/dev/null
)
}

nginx::native() {
(
  local test=$1
  local num=$2
  local ex_arg=$3
  local tls=$4
  local conf=$NGINX_NATIVE_ROOT/conf/nginx.conf
  if [ "$tls" == "https" ] ; then
      # non kTLS case
      local wrk_args="-Z AES128-GCM-SHA256 https://${HOST_ADDR}:8080/${ex_arg}b.img"
  elif [ "$tls" == "https-ktls" ] ; then
      # kTLS
      local wrk_args="-Z AES128-GCM-SHA256 https://${HOST_ADDR}:8080/${ex_arg}b.img"
      conf=$NGINX_NATIVE_ROOT/conf/nginx-ktls.conf
  elif [ "$tls" == "https-ktls-sendfile" ] ; then
      # kTLS
      local wrk_args="-Z AES128-GCM-SHA256 https://${HOST_ADDR}:8080/sf/${ex_arg}b.img"
      conf=$NGINX_NATIVE_ROOT/conf/nginx-ktls.conf
  else
      local wrk_args="http://${HOST_ADDR}:8081/${ex_arg}b.img"
      tls="http"
  fi


  echo "$(tput bold)== native ($test-$num-$tls-p${ex_arg})  ==$(tput sgr0)"
  killall -9 nginx
  taskset -c 0 $NGINX_BIN -p $NGINX_NATIVE_ROOT -c $conf &
  ssh "$DEST_ADDR" "$WRK_CMD" "$wrk_args" \
    2>&1 | tee -a "$OUTPUT/nginx-$test-$tls-native-$num.dat"
  killall -9 nginx
)
}

nginx::docker() {
(
  local test=$1
  local num=$2
  local ex_arg=$3
  local wrk_args="http://${HOST_ADDR}/${ex_arg}b.img"

  echo "$(tput bold)== docker ($test-$num-p${ex_arg})  ==$(tput sgr0)"
  docker run --rm -p 80:80 \
   -v /Users/tazaki/gitworks/nuse-msmt/apsys/nginx/nginx-docker.conf:/etc/nginx/nginx.conf:ro \
  nginx-test nginx &

  sleep 5
  ssh "$DEST_ADDR" "$WRK_CMD" "$wrk_args" \
    2>&1 | tee -a "$OUTPUT/nginx-$test-docker-$num.dat"

  kill $!
  wait $! 2>/dev/null
)
}


main
