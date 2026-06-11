#!/bin/bash --login

#SBATCH --time=12:00:00   # walltime
#SBATCH --ntasks=24   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem-per-cpu=3000M   # memory per CPU core
#SBATCH -J "trim_galore_test "   # job name
#SBATCH --mail-user=pw264@byu.edu   # email address
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
echo "mamba activate"
mamba activate /grphome/grp_sproul_lab/nobackup/archive/miniconda3/envs/TrimGalore1
echo "activated"
#module load sra-tools/3.0.3-qmybldj
echo "sra tools loaded"
echo "snake-making"
snakemake -s ./scripts/SnakeMakeMaster_autodelete_parent_dir_test.smk --jobs 4 --executor cluster-generic --cluster-generic-submit-cmd "sbatch --time='1:00:00' --ntasks=24 --nodes=1 --mem-per-cpu='3000M' --mail-user=pw264@byu.edu --mail-type=END,FAIL"
