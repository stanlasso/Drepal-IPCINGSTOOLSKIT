#!/bin/sh

cp APP/data/variants.bcftools/Filterring/all.vcf APP/data/intercep/
bgzip -c APP/data/intercep/all.vcf > APP/data/intercep/all.vcf.gz
tabix -p vcf APP/data/intercep/all.vcf.gz
bedtools intersect -a APP/data/intercep/all.vcf.gz -b APP/data/intercep/listposition.bed >> APP/data/intercep/allIntersect.vcf
rm -rf APP/data/intercep/all.vcf && rm -rf APP/data/intercep/all.vcf.gz && rm -rf APP/data/intercep/all.vcf.gz.tbi
rm -rf APP/data/intercep/listposition.bed