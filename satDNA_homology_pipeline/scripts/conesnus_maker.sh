

i=$1
input_file=$2
fasta_file=$3
output_file=$4

awk -v  group="$i" '{if($4==group){ print $1"\t"$2"\t"$3"\t"$4} }' $input_file >cur_group.txt  


echo $i


cut -f1 cur_group.txt > temp_cur_groups.txt


name_of_species=$(cat cur_group.txt | cut -f2 | head -n1 )
num_of_group=$(cat  cur_group.txt | cut -f4 | head -n1 )

name_of_con="sharedgroup_${num_of_group}"

grep -A1 -f temp_cur_groups.txt $fasta_file --no-group-separator > ${name_of_con}.fasta

numlines=$(wc -l ${name_of_con}.fasta | cut -f1 -d " ")



ls ${name_of_con}.fasta 


ls $output_file




python3 scripts/dimerization.py ${name_of_con}.fasta $output_file


rm -f ${name_of_con}.fasta temp_cur_groups.txt cur_group.txt  




