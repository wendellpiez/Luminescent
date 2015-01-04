#!/bin/sh

FILE=$1
CALABASH=/home/wendell/xmlcalabash-1.0.23-96/calabash.jar
PIPE=file:///home/wendell/Documents/Luminescent/LMNL-wf-check.xpl

echo LMNL syntax checking ... $FILE ...
java -Xmx1024m -jar $CALABASH -dtext/plain@$FILE $PIPE
