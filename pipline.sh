mkdir -p hackathon && cd hackathon 



# 2. Adım: Ham veriyi SRA veritabanından indirme (SRR..)

prefetch SRR17855325

# (Not: fastq-dump veya fasterq-dump komutu ile SRA formatındaki ham veri FASTQ'ya dönüştürülür)

fasterq-dump SRR17855325 --split-files



# 3. Adım: Ham veriler için Kalite Kontrol (FastQC)

# (Okumaların ham kalitesini, adapter varlığını ve GC oranını raporlar)



fastqc  SRR17855325.fastq 


# 4. Adım: Kalite Kontrol ve Temizleme (fastp)

# (Düşük kaliteli bazları ve hatalı okumaları temizler, ileri analiz için filtreler)

fastp -i SRR17855325.fastq -o temiz_1.fastq --html fastp_rapor.html --json fastp_rapor.json



# 5. Adım: Bacillus subtilis referans genomunu NCBI'dan indir ve aç


# sequence.fasta adında fasta data indirildi ve ilgili klasöre taşındı
mv sequence.fasta referans.fasta

# 6. Adım: Referans genomu indexle (BWA ve Samtools için)

bwa index referans.fasta

samtools faidx referans.fasta



# 7. Adım: BWA MEM ile Referansa Hizalama (Temizlenmiş fastq dosyaları kullanılır)

bwa mem referans.fasta temiz_1.fastq > hizalama.sam



# 8. Adım: SAM formatını BAM formatına çevir, koordinata göre sırala ve indexle

samtools view -bS hizalama.sam | samtools sort -o hizalama_sirali.bam

samtools index hizalama_sirali.bam



# 9. Adım: Bcftools ile Varyant Çağırma (Variant Calling)

bcftools mpileup -f referans.fasta hizalama_sirali.bam | bcftools call -mv -Ob -o varyantlar.bcf



# 10. Adım: Tablolaştırma (BCF dosyasını CSV formatına dönüştürme)

bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%QUAL\n' varyantlar.bcf | tr '\t' ',' > varyantlar.csv



echo "Tebrikler! Uçtan uca tüm pipeline başarıyla tamamlandı ve varyantlar.csv klasöründe hazır!"






