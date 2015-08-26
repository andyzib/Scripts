#!/bin/bash
# Deletes all printers if they start with mcx
MYPRINTERS=`lpstat -p | cut -d' ' -f2`
DELETED_PRINTERS=""
for MYPRINTER in $MYPRINTERS; do
    PREFIX=`echo $MYPRINTER | cut -c1-3`
    if [ $PREFIX == "mcx" ]; then
        lpadmin -x $MYPRINTER
        DELETED_PRINTERS="$DELETED_PRINTERS $MYPRINTER "
    elif [ $PREFIX == "PRT" ]; then
        lpadmin -x $MYPRINTER
        DELETED_PRINTERS="$DELETED_PRINTERS $MYPRINTER "
    fi
done
echo "<result>$DELETED_PRINTERS</result>"
exit 0
