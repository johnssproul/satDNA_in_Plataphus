input_file=$1
fasta=$2
output_folder=$3

number=$(cut -f4 $input_file | sort | uniq | wc -l)



module load python3/3.8.1


echo "" > commands_temp

rm -fr ${output_folder}

mkdir ${output_folder}

for i in $(seq 1 $number)
do

bash scripts/conesnus_maker.sh  ${i}  ${input_file} ${fasta} ${output_folder} #" >> commands_temp





done



#cat commands_temp | parallel



module unload python3/3.8.1
