#! /bin/sh

make modules
make tools
make -j

### Lambda:
awk '$1 ~/S/ {print ">"$2"\n"$3}' test-data/lambda/layout-miniasm.gfa > test-data/lambda/layout-miniasm.fasta
contigs=test-data/lambda/layout-miniasm.fasta
reads=test-data/lambda/reads.fastq
sam=test-data/lambda/alignments.sam
dataset=lambda
consensus=temp/consensus-${dataset}.fasta
reference=test-data/lambda/NC_001416.fa
tools/graphmap/bin/Linux-x64/graphmap -a anchor -z 0 -c 40 -B 0 -r ${contigs} -d ${reads} -o ${sam}
memtime=temp/consensus-${dataset}.memtime
mkdir -p temp
/usr/bin/time --format "Command line: %C\nReal time: %e s\nCPU time: -1.0 s\nUser time: %U s\nSystem time: %S s\nMaximum RSS: %M kB\nExit status: %x" --quiet -o $memtime \
	bin/consise -w 500 --msa mafft --winpath temp/window.fasta ${contigs} ${sam} ${consensus}
mkdir -p temp/dnadiff-${dataset}
dnadiff -p temp/dnadiff-${dataset}/consise-mafft-all ${reference} ${consensus}
grep "AlignedBases" temp/dnadiff-${dataset}/consise-mafft-all.report
grep "AvgIdentity" temp/dnadiff-${dataset}/consise-mafft-all.report
cat $memtime