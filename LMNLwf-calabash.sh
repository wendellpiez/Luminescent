#!/bin/sh

FILENAME=$1
CALABASH=/home/wendell/xmlcalabash-1.1.16-97/xmlcalabash-1.1.16-97.jar
PIPELINE=file:///home/wendell/Documents/Luminescent/LMNL-wf-check.xpl

echo LMNL syntax checking ... $FILENAME ...
java -Xmx1024m -jar $CALABASH -dtext/plain@$FILENAME $PIPELINE
