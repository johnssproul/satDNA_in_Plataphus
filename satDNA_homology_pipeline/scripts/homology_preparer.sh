awk -v fasta_name="$2" '{print  "bash scripts/cross_homology_ref.sh " $1 " " fasta_name}' $1  > $3 
