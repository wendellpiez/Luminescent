#!/bin/bash
#
# Checks LMNL wellformedness of frontmost document in BBEdit (MacOS)
#
# To configure:
#
# 1) $CALABASH must point to jar file, so include the following wherever you configure
# environment variables (e.g., ~/.profile), pointing to wherever your Calabash jar file 
# is located:
#
# 	export CALABASH="/Applications/xmlcalabash-1.1.16-97/xmlcalabash-1.1.16-97.jar"
#
# 2) Change the path to LMNL-wf-check.xpl in the command below to match the location on 
# your system
#
# 3) Save this file in ~/Library/Application Support/BBEdit/Scripts as lmnl-wf.sh
#
# To bind to keyboard shortcut (optional):
#
# 1) Open System preferences, then Keyboard, then Shortcuts.
#
# 2) Select App Shortcuts.
#
# 3) Hit the plus sign and select BBEdit.app from the list of applications.
#
# 4) Enter the menu command (e.g., lmnl-wf, as it appears in the Scripts drop-down menu) 
# and a hotkey combination.
# 
# To use:
#
# 1) Create or open a LMNL file in BBEdit. The well-formedness check will be applied to
# the "frontmost" document, so click somewhere inside your LMNL document immediately
# before checking it.
#
# 2) Click on the Scripts menu item (looks like a scroll) and double-click on the 
# lmnl-wf item. The results of well-formedness checking will open in a new window.
#
# 3) Alternatively, if you've created a keyboard shortcut, you can run the check with the
# keyboard shortcut instead of from the Scripts menu.
#
# TODO:
#   Fall back on full path if $CALABASH is not set
#   Support optional $XPL path environment variable for XPL files

java -Xmx1024m -jar ${CALABASH} "-dtext/plain@${BB_DOC_PATH}" /Users/djb/Luminescent/LMNL-wf-check.xpl