#!/bin/bash
#SBATCH ---mail-type=ALL
#SBATCH -n 48
#SBATCH -p longrun
R CMD BATCH /scratch/scratch0/srr11006/Code/NetworkCalc.R
