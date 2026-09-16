#starting up wsl
wsl

#creating environment
mamba create -n project_one
conda activate project_one 

#download multiple packages
 conda install -y -c bioconda shovill minimap2 trimmomatic fastqc quast

#finding what environments are in conda
conda env list

#comes out with fasta files not fastq 
fasterq-dump --fasta --split-files <accession_number>

fasterq-dump --fasta --split-files SRR15197825

#comes out with fastq files 
fasterq-dump --split-files SRR15197825

#shovill assembing fastq's 
shovill --outdir salmonella_assembly --R1 SRR15197825_1.fastq --R2 SRR15197825_2.fastq --cpus 4 --ram 7

#map onto minimap2
minimap2 -ax asm5 AE005174.2_1.fasta salmonella_assembly/contigs.fasta > asssembly_vs_reference.sam

    #use asm5 if less than 5% sequence divergence (same bacterial species) since mapping to reference genome it'll be less than 5 
    #use asm10 if more than 10% divergence 

#convert sam file to bam file 
samtools view -b -o <output_file_name>.bam <sam_file_name>.sam
 samtools view -b -o assembly_vs_reference.bam asssembly_vs_reference.sam
    # -b convert to bam file
    # -o output

#code to run if ncurses error comes up
conda install -c conda-forge ncurses samtools

#sort bam file
samtools sort -o final_assembly.bam assembly_vs_reference.bam

#make a .bai file for IGV
samtools index final_assembly.bam
    #will have both a .bam and .bai file, do not delete either or rename

#check how many mapped to reference genome 
samtools flagstat final_assembly.bam

#check to see if you have data in the file 
ls -lh contigs.fa

#find snps 
snippy [options] --outdir <dir> --ref <ref> --R1 <R1.fq.gz> --R1 <R2.fq.gz>
snippy --outdir assembly_snps --ref AE005174.2_1.fasta --R1 SRR15197825_1.fastq --R2 SRR15197825_2.fastq

#check if snps are there
samtools flagstat snps.bam

#find snps because its showing up as 0 
bcftools mpileup -f AE005174.2_1.fasta final_assembly.bam -o raw_variants.bcf
bcftools call -mv -Ob -o snp_variants.bcf raw_variants.bcf
bcftools view snp_variants.bcf > real_snps.csv

#have to go into assembly from shovill folder 
abricate --db ncbi contigs.fasta > resistance_results.txt
abricate --db vfdb contigs.fasta > virulence_results.txt
    #ncbi for resistance genes and vfdb for virulence factors

#Questionable 
#grabbing data from page (accession number)
esearch -db bioproject -query "accession_number" | elink -target nuccore | efetch -format fasta > "filename"

    #searching the bioproject section for that accession number given
    # | is a pipe
    # > filename that you want to output 

 esearch -db bioproject -query "PRJNA1525218" | elink -target nuccore | efetch -format fasta > "illumina_assembly.fasta"

#Example of a loop
while read line <&3; do
esearch -db nucleotide -query "$line" | efetch -db nucleotide -format fasta
done 3<16S_list

# Open file descriptor 3 for reading from 16S_list
while read line <&3; do
# Search the NCBI nucleotide database for the current line (query)
    esearch -db nucleotide -query "$line" | efetch -db nucleotide -format fasta
done 3<16S_list

