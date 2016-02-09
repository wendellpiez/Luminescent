#!/bin/sh

# For example, >Luminescent-calabash LMNL-process-example lmnl/frost-quote.lmnl
 
CALABASH=/home/wendell/xmlcalabash-1.0.23-96/calabash.jar
PIPELINE=$1.xpl
FILENAME=$2

echo LMNL syntax checking ... $FILENAME ...
java -Xmx1024m -jar $CALABASH -dtext/plain@$FILE $PIPELINE
