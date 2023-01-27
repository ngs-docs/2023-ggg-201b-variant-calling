rule download_data:
    output: "SRR2584857_1.fastq.gz"
    shell: """
        curl -JLO https://osf.io/4rdza/download
    """

rule download_genome:
    output: "ecoli-rel606.fa.gz"
    shell:
        "curl -JLO https://osf.io/8sm92/download"

rule map_reads:
    input:
        reads="SRR2584857_1.fastq.gz",
        ref="ecoli-rel606.fa.gz",
    shell: """
        minimap2 -ax sr ecoli-rel606.fa.gz SRR2584857_1.fastq.gz > SRR2584857_1.x.ecoli-rel606.sam
    """

rule sam_to_bam:
    shell: """
        samtools view -b -F 4 SRR2584857_1.x.ecoli-rel606.sam > SRR2584857_1.x.ecoli-rel606.bam
     """

rule sort_bam:
    shell: """
        samtools sort SRR2584857_1.x.ecoli-rel606.bam > SRR2584857_1.x.ecoli-rel606.bam.sorted
    """

rule call_variants:
    shell: """
        gunzip -k ecoli-rel606.fa.gz
        bcftools mpileup -Ou -f ecoli-rel606.fa SRR2584857_1.x.ecoli-rel606.bam.sorted > SRR2584857_1.x.ecoli-rel606.pileup
        bcftools call -mv -Ob SRR2584857_1.x.ecoli-rel606.pileup -o SRR2584857_1.x.ecoli-rel606.bcf
        bcftools view SRR2584857_1.x.ecoli-rel606.bcf > SRR2584857_1.x.ecoli-rel606.vcf
    """
