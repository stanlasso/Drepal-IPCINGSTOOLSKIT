#!/bin/sh

###################################################
#            MATRIX version 1.1                   #
###################################################
# RECUPERE LES FICHIERS ISSUE DU FILTERING PUIS LES 
# LES TRAITES POUR FORMER UNE MATRICE DE n,m ou LES 
# COLONNES SONT LES INDIVIDUS(AlternatifS) ET ASSO-
# CIE AUX POSTIONS , REFERENCES ET CHROMOSONES ...   
###################################################
#initialisation
i=0
### Traitement
declare -a tab
for read in "$@"
do
    let i=i+1
    # mettre tous les fichiers dans un tableau
    tab[$i]="$read"
done

# initialisation
j=0
#Tantque la variable j est inférieur ou égale à la taille du tableau
while [ "$j" -lt "$#" ]
do
    # Incrémente j de deux pas
    let j=j+1
    #if [ $j -le "$#" ]
    #then
    #Extraire le préfixe du gène
    Input=${tab[$j]}
    
    
    chemin=${Input:38} #pour chemin plus long dans script finale
    #echo "$chemin"
    prefix=$(echo $chemin | cut -d'_' -f 1)

    bgzip -c APP/data/variants.bcftools/Filterring/"$prefix"_filtered_snps.vcf  > APP/data/variants.bcftools/Filterring/"$prefix"_filtered_snps.vcf.gz

    tabix -p vcf  APP/data/variants.bcftools/Filterring/"$prefix"_filtered_snps.vcf.gz

    # merge des sorties en une seul des chromosones...positions...references...alternatifs pour chacun des individus: 
    bcftools view APP/data/variants.bcftools/Filterring/"$prefix"_filtered_snps.vcf | bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\n' | sort +1 -n  >> APP/data/variants.bcftools/Filterring/"$prefix"_CPRA.tsv


    cut -f 1 APP/data/variants.bcftools/Filterring/"$prefix"_CPRA.tsv >> APP/data/variants.bcftools/Filterring/"$prefix"_Chromosones.tsv
    cut -f 2 APP/data/variants.bcftools/Filterring/"$prefix"_CPRA.tsv >> APP/data/variants.bcftools/Filterring/"$prefix"_Positions.tsv
    cut -f 3 APP/data/variants.bcftools/Filterring/"$prefix"_CPRA.tsv >> APP/data/variants.bcftools/Filterring/"$prefix"_References.tsv
    cut -f 4 APP/data/variants.bcftools/Filterring/"$prefix"_CPRA.tsv >> APP/data/variants.bcftools/Filterring/"$prefix"_Alternatif.tsv


    sed -i '1iPOSITION' APP/data/variants.bcftools/Filterring/"$prefix"_Positions.tsv 
    sed -i '1iREFERENCE' APP/data/variants.bcftools/Filterring/"$prefix"_References.tsv 
    sed -i '1iCHROMOSOME' APP/data/variants.bcftools/Filterring/"$prefix"_Chromosones.tsv
    sed -i "1i$prefix" APP/data/variants.bcftools/Filterring/"$prefix"_Alternatif.tsv

    paste APP/data/variants.bcftools/Filterring/"$prefix"_Chromosones.tsv APP/data/variants.bcftools/Filterring/"$prefix"_Positions.tsv APP/data/variants.bcftools/Filterring/"$prefix"_References.tsv APP/data/variants.bcftools/Filterring/"$prefix"_Alternatif.tsv >> APP/data/variants.bcftools/Filterring/MATRICE/"$prefix"_data.tsv   


done

bcftools merge --force-samples APP/data/variants.bcftools/Filterring/*filtered_snps.vcf.gz > APP/data/variants.bcftools/Filterring/01.vcf
bcftools view APP/data/variants.bcftools/Filterring/01.vcf | bcftools query -f '%CHROM\t%POS\t%REF\n' >> APP/data/variants.bcftools/Filterring/01snps.tsv
sort +1 -n APP/data/variants.bcftools/Filterring/01snps.tsv | uniq >> APP/data/variants.bcftools/Filterring/01snps_sorted.tsv

cut -f 1 APP/data/variants.bcftools/Filterring/01snps_sorted.tsv >> APP/data/variants.bcftools/Filterring/Chromosones.tsv
cut -f 2 APP/data/variants.bcftools/Filterring/01snps_sorted.tsv >> APP/data/variants.bcftools/Filterring/Positions.tsv
cut -f 3 APP/data/variants.bcftools/Filterring/01snps_sorted.tsv >> APP/data/variants.bcftools/Filterring/References.tsv


sed -i '1iPOSITION' APP/data/variants.bcftools/Filterring/Positions.tsv
sed -i '1iREFERENCE' APP/data/variants.bcftools/Filterring/References.tsv
sed -i '1iCHROMOSOME' APP/data/variants.bcftools/Filterring/Chromosones.tsv

paste APP/data/variants.bcftools/Filterring/Chromosones.tsv APP/data/variants.bcftools/Filterring/Positions.tsv APP/data/variants.bcftools/Filterring/References.tsv >> APP/data/variants.bcftools/Filterring/MATRICE/01snps_data.tsv

