#!/bin/sh

# For example, >Luminescent-calabash LMNL-process-example lmnl/frost-quote.lmnl
 
CALABASH=/home/wendell/xmlcalabash-1.1.16-97/xmlcalabash-1.1.16-97.jar
PIPELINE=$1.xpl
FILENAME=$2

echo Luminescent processing ... $FILENAME ...
java -Xmx1024m -jar $CALABASH -dtext/plain@$FILE $PIPELINE
