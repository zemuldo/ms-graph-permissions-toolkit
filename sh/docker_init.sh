#!/bin/bash
export HOSTNAME=`hostname`
export ERLANG_COOKIE=b67fbaea7f676343ba7848ef
echo | tee /opt/app/releases/0.1.0/vm.args << EndOfMessage
-name yweri@$HOSTNAME
-setcookie $ERLANG_COOKIE
-smp auto
EndOfMessage

/opt/app/bin/scrapper $1