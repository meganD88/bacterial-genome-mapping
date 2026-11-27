SAMPLES = ["SRR41602795"]
REF = "GCF_000005845.2_ASM584v2_genomic.fna"
REF_URL = "https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/005/845/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.fna.gz"

rule all:
    input:
        expand("qc/{sample}_1_fastqc.html", sample=SAMPLES),
        expand("qc/{sample}_2_fastqc.html", sample=SAMPLES),
        expand("mapping/{sample}_final.bam.bai", sample=SAMPLES),
        expand("snps/{sample}/snps.vcf", sample=SAMPLES),
        expand("results/{sample}_resistance_results.txt", sample=SAMPLES),
        expand("results/{sample}_virulence_results.txt", sample=SAMPLES)

rule download_reference:
    output:
        REF
    shell:
        """
        curl -L -o {output}.gz "{REF_URL}"
        gunzip -f {output}.gz
        """

rule fetch_fastq:
    output:
        r1="data/{sample}_1.fastq",
        r2="data/{sample}_2.fastq"
    shell:
        """
        mkdir -p data
        fasterq-dump --split-files {wildcards.sample} -O data
        """

rule fastqc:
    input:
        r1="data/{sample}_1.fastq",
        r2="data/{sample}_2.fastq"
    output:
        html1="qc/{sample}_1_fastqc.html",
        html2="qc/{sample}_2_fastqc.html"
    shell:
        """
        mkdir -p qc
        fastqc {input.r1} {input.r2} -o qc
        """

rule assemble_shovill:
    input:
        r1="data/{sample}_1.fastq",
        r2="data/{sample}_2.fastq"
    output:
        contigs="assembly/{sample}/contigs.fasta"
    threads: 4
    shell:
        """
        shovill --outdir assembly/{wildcards.sample} \
            --R1 {input.r1} --R2 {input.r2} \
            --cpus {threads} --ram 7 --force
        """

rule map_minimap2:
    input:
        ref=REF,
        contigs="assembly/{sample}/contigs.fasta"
    output:
        sam=temp("mapping/{sample}_ref.sam")
    shell:
        """
        mkdir -p mapping
        # Use asm5 for <5% sequence divergence (same species); use asm10 if >10%
        minimap2 -ax asm5 {input.ref} {input.contigs} > {output.sam}
        """

rule sam_to_sorted_bam:
    input:
        sam="mapping/{sample}_ref.sam"
    output:
        unsorted=temp("mapping/{sample}_ref.bam"),
        sorted_bam="mapping/{sample}_final.bam",
        bai="mapping/{sample}_final.bam.bai"
    shell:
        """
        samtools view -b -o {output.unsorted} {input.sam}
        samtools sort -o {output.sorted_bam} {output.unsorted}
        samtools index {output.sorted_bam}
        """

rule call_snps:
    input:
        ref=REF,
        r1="data/{sample}_1.fastq",
        r2="data/{sample}_2.fastq"
    output:
        vcf="snps/{sample}/snps.vcf"
    shell:
        """
        snippy --outdir snps/{wildcards.sample} \
            --ref {input.ref} \
            --R1 {input.r1} --R2 {input.r2} --force
        """

rule annotate_abricate:
    input:
        contigs="assembly/{sample}/contigs.fasta"
    output:
        amr="results/{sample}_resistance_results.txt",
        vf="results/{sample}_virulence_results.txt"
    shell:
        """
        mkdir -p results
        abricate --db ncbi {input.contigs} > {output.amr}
        abricate --db vfdb {input.contigs} > {output.vf}
        """




