


args = commandArgs(trailingOnly=TRUE)

args[1]<-"breve_group_satDNAs_combined_reads_within_species_sattallites.all.hits"
args[2]<-"breve_group_satDNAs_combined_reads_within_species_sattallites.fa.fai"
args[3]<-"breve_group_satDNAs_combined_reads_within_species_sattallites.species_sample.txt"



satdnahomology<-read.table(args[1],stringsAsFactors = FALSE) #.all.hits file

colnames(satdnahomology)<-c("qseqid","sseqid","pident","length","mismatch","gapopen","qstart","qend","sstart","send","evalue","bitscore")

satdna_lengh_info<-read.table(args[2],stringsAsFactors = FALSE) #.fai file

lengths<-satdna_lengh_info[,c(1,2)]

sample_speices<-read.table(args[3],stringsAsFactors = FALSE)
colnames(sample_speices)<-c("qseqid","qspecies","qsample")

satdnahomology<-merge(satdnahomology,sample_speices)
colnames(sample_speices)<-c("sseqid","sspecies","ssample")
satdnahomology<-merge(satdnahomology,sample_speices)


colnames(lengths)<-c("sseqid","sseqlen")
satdnahomology<-merge(satdnahomology,lengths)
colnames(lengths)<-c("qseqid","qseqlen")
satdnahomology<-merge(satdnahomology,lengths)



#
####homology within species

all_species_in<-unique(satdnahomology$qspecies)

number_of_repeats<-c()
list_groups<-c()
all_repeats_filtered_allsep<-c()
list_groups_all_within_Species<-c()


  
homology_between_species<-  satdnahomology

homology_between_species<-homology_between_species[homology_between_species$pid>0.80,]

sat_dna_homology_Recoprical<-homology_between_species[0,]#data.frame(qseqid=character(),sseqid=character(),sseqid_species=character(),qseqid_species=character(),qslen=numeric(),sslen=numeric(),pid=numeric(),stringsAsFactors = FALSE)

homology_between_species<-na.omit(homology_between_species)

for(i in 1:NROW(homology_between_species)){
  
  
  
  
  recoprical_Record_qseqid<-homology_between_species[i,2]
  recoprical_Record_sseqid<-homology_between_species[i,1]
  
  
  temp<-homology_between_species[homology_between_species$qseqid==recoprical_Record_qseqid &homology_between_species$sseqid==recoprical_Record_sseqid ,]
  temp<-na.omit(temp)
  
  if(NROW(temp)>0){
    
    
    
    sat_dna_homology_Recoprical[NROW(sat_dna_homology_Recoprical)+1,]<-homology_between_species[i,]
    
    
  }
  
  
  
  
  
}

all_queries<-unique(sat_dna_homology_Recoprical$qseqid)

represtnted_repeats_list<-c()

chosen_repeats<-c()

list_in_species_groups<-list()  
for(i in 1:NROW(all_queries)){
  
  q<-all_queries[i]
  
  all_recep_hits<-sat_dna_homology_Recoprical[sat_dna_homology_Recoprical$qseqid==q,2]
  
  
  
  
  
  
  if(!any(q %in% represtnted_repeats_list)){
    
    if(any(all_recep_hits %in% represtnted_repeats_list )){
      
      elements_shared=intersect(all_recep_hits,represtnted_repeats_list)
      
      
      
      
    } 
    
    
    
    represtnted_repeats_list<-c(represtnted_repeats_list,q,all_recep_hits)
    chosen_repeats<-c(chosen_repeats,q)
    list_in_species_groups[[NROW(list_in_species_groups)+1]]<-c(q,all_recep_hits)
    list_groups[[NROW(list_groups)+1]]<-c(q,all_recep_hits)
    
    
  }
  
}


all_repeats_filtered_allsep<-c(all_repeats_filtered_allsep,chosen_repeats)
number_of_repeats<-c(number_of_repeats,NROW(chosen_repeats))




#species_repeats<-data.frame(species=all_species_in,number_of_repeats=number_of_repeats,stringsAsFactors = FALSE)


counter=1
repeats_groups<-data.frame(ref=character(),group=numeric(),stringsAsFactors = FALSE)

for(i in 1:NROW(list_groups)){
  for(t in 1:NROW(list_groups[[i]])){
    repeats_groups[NROW(repeats_groups)+1,]<-c(list_groups[[i]][t],i)
    
  }  
  
}

colnames(sample_speices)<-c("ref","species","sample")


repeats_groups<-merge(repeats_groups,sample_speices)




#homology_between_species<-homology_between_species[,c(1,3)]
library(igraph)

g <- graph_from_data_frame(repeats_groups[,c(1,2)])

x <- clusters(g)$membership

repeats_groups$new_groups <- x[ repeats_groups$ref ]
repeats_groups<-repeats_groups[,c(1,3,4,5)]



repeats_groups<-repeats_groups[!duplicated(repeats_groups[,c('ref','new_groups')]),]


acceptabl_groups<-table(repeats_groups$new_groups)[table(repeats_groups$new_groups)>1]
groups_shared<-row.names(acceptabl_groups)
repeats_groups<-repeats_groups[repeats_groups$new_groups %in% groups_shared,]

repeats_groups$new_groups<- as.numeric(as.factor(repeats_groups$new_groups))


repeats_groups<- repeats_groups[order(repeats_groups$new_groups),]



write.table(repeats_groups,args[4],quote=FALSE,row.names = FALSE,col.names = FALSE,sep="\t")

