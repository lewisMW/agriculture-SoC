#!/bin/ksh


# generated at: Sun Mar 30 00:29:27 2025
# 
unset CDS_W3264_LIBPATH
unset CDS_MPS_SESSION
unset W3264_USER_PATH
unset W3264_USER_LIBPATH
unset OS_ID
unset REL_VERSION

LOGDIR="/home/hee/cadence/SoC/logs_hee/logs0/"
OUTPUTLOG="/home/hee/cadence/SoC/logs_hee/logs0/distributedPlot.fnxSession0.log"
export CDSHOME="/opt/cadence/installs/IC231"

env >$LOGDIR/distributedPlot.fnxSession0.env.log 2>/dev/null
BLDVER="`$CDSHOME/bin/srrversion -build 2>/dev/null `"

#
if [ -z "$DISPLAY" ]; then
    export DISPLAY=127.0.1.1:0.0
fi

#

if [ "$BLDVER" =  "" ]; then
    echo "[`date`] Error: target machine (`hostname`) cannot run ViVA. Probably wrong system.">$LOGDIR/distributedPlot.fnxSession0.err
    sync $LOGDIR/distributedPlot.fnxSession0.err
    exit 1
fi
#
$CDSHOME/bin/srrversion -sysinfo >>$LOGDIR/distributedPlot.fnxSession0.env.log 2>/dev/null
$CDSHOME/bin/srrversion -envinfo >>$LOGDIR/distributedPlot.fnxSession0.env.log 2>/dev/null
#
# Check for X11 connectivity....
ERR="`srrversion -x11`"
if [ "$ERR" != "OK" ]; then
    echo "[`date`] Error: $ERR.">$LOGDIR/distributedPlot.fnxSession0.err
    exit 1
fi
# 
# 
export CDN_VIVA_SERVICE_LINGER_TIME=60
export CDN_VIVA_SERVICE_SEND_JSON_GRPC=1
# 
CMD="$CDSHOME/bin/viva  -brokerAddress MrDonothing:46693 -tag 436969f74340ece84686a0a6a15d572e -axlsession fnxSession0 -libCellView SoC_probe:tb_probe:maestro -adeService distributedPlot -noautostart  -distributedPlot 1 -log /home/hee/cadence/SoC/logs_hee/logs0/distributedPlot.0.log -no-ciw -nocdsinit -viva-service 000143E78B008E70EF2803E3E662FC18BC4D03E3E77AFC06BC4D4CE3B605886ED22230D4D45FCE288D7A7AEA931CD2378E7548D3B52FFC06BC4D01047AA809B1DBAA00001E03"


WORK_DIR=/home/hee/cadence/SoC
if [ -d $WORK_DIR ]; then
    cd $WORK_DIR
    $CMD &
    PID=$!
    wait $PID
fi


