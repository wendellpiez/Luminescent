@echo off
rem @echo Validating %1 as well-formed LMNL syntax ...
call C:\Users\Wendell\Projects\LMNL\2012-demo\lmnl-validate-xpl lmnl-file=%1 > valid.xml
xsltproc C:\Users\Wendell\Projects\LMNL\2012-demo\bin\support\report-plaintext.xsl valid.xml
rem del valid.xml
