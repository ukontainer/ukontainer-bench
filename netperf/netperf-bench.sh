#!/bin/bash

SCRIPT_DIR="$(cd $(dirname "${BASH_SOURCE[0]}"); pwd)"
source "$SCRIPT_DIR/../netperf-common.sh"

# macos has different syntax
OUTPUT=$SCRIPT_DIR/$(date "+%Y-%m-%d")

PREFIX=netperf-bench
TESTNAMES="TCP_STREAM TCP_MAERTS"
DEST_ADDR="10.0.39.2"
SELF_ADDR="10.0.39.1"
OIF=br0
RR_DURATION=20
#TRIALS=1

FRANKENLIBC_DIR=/home/tazaki/work/frankenlibc
NETPERF_DIR=/home/tazaki/work/rumprun-packages/netperf/build
#TMP variable
export PATH=${FRANKENLIBC_DIR}/rump/bin:${PATH}
export PATH=${FRANKENLIBC_DIR}/liunx/tools/lkl/bin:${PATH}

main() {
  initialize

  # for netperf tests
  for size in $PSIZES; do
    for num in $(seq 1 "$TRIALS"); do
      for test in $TESTNAMES; do
        netperf::run $test $num $size "-m $size,$size"
      done

#      netperf::run UDP_STREAM $num $size "LOCAL_SEND_SIZE,THROUGHPUT,THROUGHPUT_UNITS,REMOTE_RECV_CALLS,ELAPSED_TIME -m $size -R 1"
    done
  done

  # TCP_RR only runs with 1-byte
  netperf::run TCP_RR 1 1 " LSS_SIZE_END,LSR_SIZE_END,RSR_SIZE_END,RSS_SIZE_END,REQUEST_SIZE,RESPONSE_SIZE,ELAPSED_TIME,THROUGHPUT,THROUGHPUT_UNITS,MEAN_LATENCY,STDDEV_LATENCY,LOCAL_SEND_CALLS,LOCAL_RECV_CALLS -r 1,1"

  bash "$SCRIPT_DIR/netperf-plot.sh" "$OUTPUT" tx
  bash "$SCRIPT_DIR/netperf-plot.sh" "$OUTPUT" rx
}

initialize() {
  export LKL_HIJACK_SYSCTL="net.ipv4.tcp_wmem=4096 87380 100000000"
  export LKL_HIJACK_BOOT_CMDLINE="mem=1G"

  export LKL_SYSCTL="net.ipv4.tcp_wmem=4096 87380 100000000"
  export LKL_BOOT_CMDLINE="mem=1G"

  export LKL_HIJACK_OFFLOAD=0xc803

  mkdir -p "$OUTPUT"
  rm -f "$OUTPUT/$PREFIX"-*.dat
  exec > >(tee "$OUTPUT/$(basename $0).log") 2>&1
}

netperf::run() {
  ssh $DEST_ADDR killall -9 netserver
  ssh $DEST_ADDR /home/tazaki/work/netperf2/native/src/netserver -D -f &
  sleep 2
  netperf::lkl    "$@"
  netperf::native "$@"
  netperf::docker "$@" "runc"
  netperf::docker "$@" "kata-runtime"
  netperf::docker "$@" "runsc-ptrace-user"
  #netperf::docker "$@" "runsc-kvm-user"
  netperf::docker-nc "$@" "runnc" "thehajime/nabla-netperf:0.1"
  netperf::docker-graphene "$@" "graphene" "graphene-u1804"
}

netperf::lkl() {
(
  local test="$1"
  local num="$2"
  local psize="$3"
  local ex_arg="$4"
  local duration=10
  if [[ "$test" == "TCP_RR" ]] ; then
	  duration=$RR_DURATION
  fi
  local netperf_args="-H $DEST_ADDR -t $test -l $duration -- -o $ex_arg"

  setup_lkl
  cd $NETPERF_DIR

  # XXX: musl-libc w/ UDP_STREAM is not working over 2sec length so, use hijack
  if [[ "$test" == "NIU_UDP_STREAM" ]] ; then
    echo "$(tput bold)== lkl-hijack tap ($test-$num $*)  ==$(tput sgr0)"

    export LKL_HIJACK_NET_IFTYPE=tap
    export LKL_HIJACK_NET_IFPARAMS=tap0
    export LKL_HIJACK_NET_IP="$SELF_ADDR"
    sudo -u moroo $TASKSET lkl-hijack.sh netperf $netperf_args \
     |& tee -a "$OUTPUT/$PREFIX-$test-lkl-ps$psize-$num.dat"
  else
    echo "$(tput bold)== lkl ($test-$num $*)  ==$(tput sgr0)"
    docker run --rm -i --runtime=runu-dev --net=none  \
	    -e LKL_BOOT_CMDLINE="mem=1G" \
	    -e LKL_NET=tap0 \
	    -e LKL_CONFIG=$SCRIPT_DIR/../lkl.json -e LKL_OFFLOAD=1 \
	    thehajime/runu-base:0.1 netperf $netperf_args \
     2>&1 | tee "$OUTPUT/$PREFIX-$test-lkl-ps$psize-$num.dat"
#	    tgraf/netperf /usr/bin/netperf $netperf_args \
    wait
  fi

  cd $SCRIPT_DIR
)
}

netperf::native() {
(
  local test="$1"
  local num="$2"
  local psize="$3"
  local ex_arg="$4"
  local duration=10
  if [[ "$test" == "TCP_RR" ]] ; then
	  duration=$RR_DURATION
  fi
  local netperf_args="-H $DEST_ADDR -t $test -l $duration -- -o $ex_arg"

  echo "$(tput bold)== native ($test-$num $*)  ==$(tput sgr0)"
  netperf $netperf_args 2>&1 | tee "$OUTPUT/$PREFIX-$test-native-ps$psize-$num.dat"
)
}

netperf::docker() {
( 
  local test=$1
  local num=$2
  local psize="$3"
  local ex_arg="$4"
  local runtime="$5"
  local duration=10
  if [[ "$test" == "TCP_RR" ]] ; then
	  duration=$RR_DURATION
  fi
  local netperf_args="-H $DEST_ADDR -t $test -l $duration -- -o $ex_arg"
  
  echo "$(tput bold)== docker ($runtime) ($test-$num-p${ex_arg})  ==$(tput sgr0)"
  docker run --runtime=$runtime --rm \
   tgraf/netperf /usr/bin/netperf $netperf_args 2>&1 \
  | tee "$OUTPUT/$PREFIX-$test-$runtime-ps$psize-$num.dat"
)
}

netperf::docker-nc() {
( 
  local test=$1
  local num=$2
  local psize="$3"
  local ex_arg="$4"
  local runtime="$5"
  local img="$6"
  local duration=10
  if [[ "$test" == "TCP_RR" ]] ; then
	  duration=$RR_DURATION
  fi
  local netperf_args="-H $DEST_ADDR -t $test -l $duration -- -o $ex_arg"
  
  echo "$(tput bold)== docker ($runtime) ($test-$num-p${ex_arg})  ==$(tput sgr0)"
  docker run --runtime=$runtime --rm $img \
   netperf.nabla $netperf_args 2>&1 \
  | tee "$OUTPUT/$PREFIX-$test-$runtime-ps$psize-$num.dat"
)
}

netperf::docker-graphene() {
(
  local test=$1
  local num=$2
  local psize="$3"
  local ex_arg="$4"
  local runtime="$5"
  local img="$6"
  local duration=10
  if [[ "$test" == "TCP_RR" ]] ; then
	  duration=$RR_DURATION
  fi
  local netperf_args="-H $DEST_ADDR -t $test -l $duration -- -o $ex_arg"

  echo "$(tput bold)== docker ($runtime) ($test-$num-p${ex_arg})  ==$(tput sgr0)"
  TMP_WD=`pwd`
  cd /home/tazaki/work/graphene/Examples/curl
  ./pal_loader ./netperf $netperf_args 2>&1 \
    | tee "$OUTPUT/$PREFIX-$test-$runtime-ps$psize-$num.dat"
  cd $TMP_WD
)
}

main
