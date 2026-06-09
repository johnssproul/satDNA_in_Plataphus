

fasta_file=$1
out_file=$2




while read line;
do
if [[ $line == ">"* ]];

then
refname=$(echo $line | sed 's/>//g')
species_name=$(echo $line | cut -f1 -d "_" |  sed 's/>//g')

sample_name="Single_sample"





echo "$refname	$species_name	$sample_name" >> $out_file



fi













done < $fasta_file
