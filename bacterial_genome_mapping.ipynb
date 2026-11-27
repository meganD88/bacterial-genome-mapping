Samples = ["SRR41602795"]
Reference Genome = GCF_000005845.2
Organism = Escherichia coli
Bioproject = PRJNA1558265

#Download zipped fasta file from NCBI and unzip it 
curl -L -O "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz"
gunzip GCF_000005845.2_ASM584v2_genomic.fna.gz

#Creating environment
mamba create -n bacterial_genome_mapping
conda activate bacterial_genome_mapping 

#Downloading multiple packages
conda install -y -c bioconda fastqc shovill minimap2 samtools snippy bcftools abricate sra-tools

#Creating fastq files  
fasterq-dump --split-files SRR41602795

# Run QC on raw reads
fastqc SRR41602795_1.fastq SRR41602795_2.fastq

#Assembling genome using shovill  
shovill --outdir ecoli_assembly --R1 SRR41602795_1.fastq --R2 SRR41602795_2.fastq --cpus 4 --ram 7  

#Mapping to reference genome using minimap2
minimap2 -ax asm5 GCF_000005845.2_ASM584v2_genomic.fna ecoli_assembly/contigs.fasta > ecoli_assembly_ref.sam

    #use asm5 if less than 5% sequence divergence (same bacterial species) since mapping to reference genome it'll be less than 5 
    #use asm10 if more than 10% divergence 

#Converting sam file to bam file 
 samtools view -b -o ecoli_assembly_ref.bam ecoli_assembly_ref.sam

#Sorting bam file
samtools sort -o final_ecoli_assembly.bam ecoli_assembly_ref.bam

#Make a .bai file for IGV
samtools index final_ecoli_assembly.bam
    #will have both a .bam and .bai file, do not delete either or rename

#Finding snps 
snippy --outdir ecoli_assembly_snps --ref GCF_000005845.2_ASM584v2_genomic.fna --R1 SRR41602795_1.fastq --R2 SRR41602795_2.fastq

#Annotate contigs using abricate 
abricate --db ncbi ecoli_assembly/contigs.fasta > ecoli_resistance_results.txt
abricate --db vfdb ecoli_assembly/contigs.fasta > ecoli_virulence_results.txt
    #NCBI for resistance genes and VFDB for virulence factors
