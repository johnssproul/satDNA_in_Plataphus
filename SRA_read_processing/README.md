# SRA Read Processing

This pipeline is to be run within a conda environment on a campus cluster computer through a SLURM script. Paired-end raw reads (FASTQ files) downloaded from the NCBI database are trimmed, randomly down sampled, converted to FASTA files, and merged to create files prepped for further analysis. Outputs are tied to inputs using their file name, which contains each organism's unique accession code.

## Input

Paired-end FASTQ reads pulled from the NCBI database. Here is an example of what might display after a single set of paired-end reads is uploaded:

> SRR089081_1.fq

> SRR089081_2.fq

The shared accession code (e.g., `SRR089081`) is used to associate input files with all generated outputs.

## Output

Note: Each step of the pipeline builds on the previous step. For example, sampled reads found within `seqSample/` are both trimmed and down sampled, and files contained in `seqMerged/` are trimmed, down sampled, converted to FASTA files (quality scores removed), and finally merged (paired-end reads combined).

#### `trimmed/`

* Paired-end FASTQ reads with low-quality read ends trimmed and adapter contamination removed

#### `seqSample/`

* Randomly subsampled paired-end FASTQ reads calculated to be less than 1× coverage

#### `seqFasta/`

* Paired-end reads with associated Phred base quality scores removed

#### `seqMerged/`

* Paired-end reads matched together using overlapping sequences

#### `run_info.yaml`

* Contains the run metadata

## Slurm Script

### User Instructions

`snakemake_slurm.sh` is an example SLURM script. Modify as needed to the specifications of your cluster computer. Your SLURM script should accomplish the following:

1. Activate the correct environment

* To create an environment with the correct dependencies and packages, run the following command:

    `conda env create -f env.yml`

    > To use this command, ensure you are in the directory containing `env.yml`

2. Implement the following tags for a successful and efficient Snakefile run.

* Specifies which Snakefile (`.smk`) Snakemake should run.

    `-s`

* Sets the maximum number of jobs Snakemake can run at the same time.

    `--jobs`

* Specifies how Snakemake submits and manages jobs (local machine, SLURM cluster, etc.).

    `--executor`

* Defines the command Snakemake uses to submit jobs to the cluster scheduler.

    `--cluster-generic-submit-cmd`

## Config File

For each run, specify the `insect_order` and the `read_count`.

## Snakemake Script

### Set Up Instructions

Assign the path to the config file. Assign `RUNS_BASE` to your desired output directory. Set `assembly_dir` to the raw paired-end FASTQ sequence data. After these modifications, the Snakefile should be ready to run.

### Implementation Details

Each run generates its own directory stored in the `RUNS_BASE` directory with `insect_order`, `read_count`, and `date` as part of its folder name. A single run folder might look like:

`runs/mylabris_sibrica_212500_20260324`

`insect_order` = mylabris_sibrica

`read_count` = 212500

`date` = 20260324

#### Rules

The following list explains the functions of each of the Snakemake rules in the pipeline.

1. `all`

* Final target rule that ensures all merged FASTA files and the run information YAML file are successfully generated.

2. `trim`

* Uses TrimGalore to trim paired-end FASTQ reads and remove low-quality or adapter-contaminated sequences.

3. `seqtkSample`

* Randomly subsamples a specified number of reads from each trimmed FASTQ file using seqtk.

4. `seqtkFastqtoFasta`

* Converts the sampled FASTQ files into FASTA format using seqtk.

5. `seqtkMerge`

* Merges paired-end FASTA reads into a single merged FASTA output file using seqtk `mergepe`.

6. `write_run_info`

* Generates a YAML file containing run configuration and metadata information for the pipeline execution.

## Runtime

Runtime will vary depending on input file size, cluster hardware, and resource allocation. As a benchmark, processing 30 paired-end datasets (60 FASTQ files total) required approximately **1 hour and 20 minutes** on the following SLURM configuration:

* 1 node
* 24 CPU cores (`--ntasks=24`)
* 3 GB RAM per core (`--mem-per-cpu=3000M`)
* Total memory: 72 GB

Larger datasets or lower resource allocations may increase runtime.