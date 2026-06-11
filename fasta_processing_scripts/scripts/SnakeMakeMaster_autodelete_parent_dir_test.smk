import sys

sys.path.append("/grphome/grp_sproul_lab/nobackup/archive/Patrick/Adephaga/Winter2025/scripts")
import datetime as dt
import os
import pwd
import pandas as pd
import yaml
from datetime import datetime
from RenameFromDatabase import renameFromDatabase


# !!!MODIFY ME!!!
configfile: "/grphome/grp_sproul_lab/nobackup/archive/Patrick/Adephaga/Winter2025/configs/config.yaml"

read_count = config["read_count"]
insect_order = config["insect_order"]
raw_directory = f"raw_{insect_order}"
read_label = read_count

# Where you want all run outputs to live (choose one base), !!!MODIFY ME!!!
RUNS_BASE = "/grphome/grp_sproul_lab/nobackup/archive/Patrick/Adephaga/Winter2025/runs"


# Example: Hymenoptera_60_Samples_368000_20260103
today = datetime.now().strftime("%Y%m%d")
run_name = f"{insect_order}_{read_count}_{today}"

# Parent directory for THIS run, all output for this run will go in this directory
parent_dir = os.path.join(RUNS_BASE, run_name)

# For simplicity, my recently downloaded Fasta files are placed in a directory "raw" followed by "insect_order"
raw_directory = f"raw_{insect_order}"

# correct raw directory path (your raw files should already be in this folder)
assembly_dir = os.path.join("/grphome/grp_sproul_lab/nobackup/archive/Patrick/Adephaga/Winter2025", raw_directory)

# ---- All outputs go under parent_dir ----
trimmed_dir   = os.path.join(parent_dir, "trimmed")
seqSample_dir = os.path.join(parent_dir, "seqSample")
seqFasta_dir  = os.path.join(parent_dir, "seqFasta")
seqMerged_dir = os.path.join(parent_dir, "seqMerged") 

script_dir = "/grphome/grp_sproul_lab/nobackup/archive/Patrick/Adephaga/Winter2025/scripts"

# ---- Run metadata ---- 
run_info = {
    "run_name": run_name,
    "date": today,
    "user": pwd.getpwuid(os.getuid()).pw_name,
    "insect_order": insect_order,
    "read_count": read_count,
    "read_label": read_label,
    "rename_files": rename_files,
    "raw_directory": assembly_dir,
    "parent_directory": parent_dir,
}


# Use glob_wildcards to capture all files in the assembly directory

# pull all FASTQ files in a directory into a vector of acc names
RAW_FILES = glob_wildcards(assembly_dir + "/{filename}_1.fastq").filename
print(f"raw_files: {RAW_FILES}")

# Rule all
rule all:
     input:
        parent_dir + "/run_info.yaml",
        expand(seqMerged_dir + "/{filename}_merged.fa", filename = RAW_FILES)
# TrimGalore
rule trim:
    input:
        assembly1 = assembly_dir + "/{filename}_1.fastq",
        assembly2 = assembly_dir + "/{filename}_2.fastq"

    output:
        output1 = trimmed_dir + "/{filename}_1_val_1.fq",
        output2 = trimmed_dir  + "/{filename}_2_val_2.fq"
    params:
        output_dir = trimmed_dir
    resources:
        time="1:00:00",
        ntasks=24,
        nodes=1,
        mem_per_cpu="3000M"

    shell:
        '''
        #call trim galore
        mkdir -p {params.output_dir}
        trim_galore -o {params.output_dir}  --paired -j 2 --illumina {input.assembly1} {input.assembly2}

        '''
rule seqtkSample:
    input:
        trimmed_input1 = trimmed_dir + "/{filename}_1_val_1.fq",
        trimmed_input2 = trimmed_dir + "/{filename}_2_val_2.fq"
    output:
        output1 = seqSample_dir + "/{filename}_1seq.fq",
        output2 = seqSample_dir + "/{filename}_2seq.fq"
    params:
        output_dir = seqSample_dir,
        read_count = read_count
    resources:
        time="8:00:00",
        ntasks=24,
        nodes=1,
        mem_per_cpu="3000M"

    shell:
        '''
        mkdir -p {params.output_dir}
        # Run the seqtk command
        seqtk sample -s100 {input.trimmed_input1} {params.read_count} > {output.output1}
        seqtk sample -s100 {input.trimmed_input2} {params.read_count} > {output.output2}
        '''

rule seqtkFastqtoFasta:
    input:
        input1 = seqSample_dir + "/{filename}_1seq.fq",
        input2 = seqSample_dir + "/{filename}_2seq.fq"
    output:
        output1 = seqFasta_dir + "/{filename}_1.fa",
        output2 = seqFasta_dir + "/{filename}_2.fa"
    params:
        output_dir = seqFasta_dir
    resources:
        time="8:00:00",
        ntasks=24,
        nodes=1,
        mem_per_cpu="3000M"

    shell:
        '''
        mkdir -p {params.output_dir}
        # Run the seqtk command

        seqtk seq -a {input.input1} > {output.output1}
        seqtk seq -a {input.input2} > {output.output2}
        '''

rule seqtkMerge:
    input:
        input1 = seqFasta_dir + "/{filename}_1.fa",
        input2 = seqFasta_dir + "/{filename}_2.fa"
    output:
        output = seqMerged_dir + "/{filename}_merged.fa"
    params:
        output_dir = seqMerged_dir
    resources:
        time="8:00:00",
        ntasks=24,
        nodes=1,
        mem_per_cpu="3000M"

    shell:
        '''
        mkdir -p {params.output_dir}
        # Run the seqtk command
        seqtk mergepe {input.input1} {input.input2} > {output.output}
        '''
rule write_run_info:
    output:
        run_info_yaml = parent_dir + "/run_info.yaml"
    run:
        os.makedirs(parent_dir, exist_ok=True)
        with open(output.run_info_yaml, "w") as f:
            yaml.dump(run_info, f, default_flow_style=False)
