


satname=$1
fastafile=$2


#awk '/^>/ {printf("\n%s\n",$0);next; } { printf("%s",$0);}  END {printf("\n");}' < $fastafile > out_onelined.fa




grep -A1 $satname $fastafile > ${satname}.fa






grep -v -f ${satname}.fa $fastafile > ${satname}_database.fa



makeblastdb -in ${satname}_database.fa -dbtype nucl





blastn -db ${satname}_database.fa -query ${satname}.fa -outfmt 6 > ${satname}.blast.hits






rm -f ${satname}.fa
rm -f ${satname}_database*