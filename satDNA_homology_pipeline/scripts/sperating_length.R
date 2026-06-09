library(seqinr)
library(kmer)
library(NbClust)
library(ape)
library(DECIPHER)
args = commandArgs(trailingOnly=TRUE)
   
input_1=args[1]
input_2=args[2]


the_folder=args[3]

theoutput_name=args[4]
#species_samples<-read.table(input_3,header = FALSE,stringsAsFactors = FALSE)
#colnames(species_samples)<-c("ref","species","sample")

groups_list<-read.table(paste(input_1,sep=""))
colnames(groups_list)<-c("ref","species","sample","group")

thespecies_and_samples<-groups_list[,c(1,2,3)]

satdna_lengh_info<-read.table(input_2,stringsAsFactors = FALSE) #.fai file

lengths_seqs<-satdna_lengh_info[,c(1,2)]
colnames(lengths_seqs)<-c("ref","length")

groups_list<-merge(groups_list,lengths_seqs)

ref_and_species<-groups_list[,c(1,2)]


new_groups=data.frame(ref=character(),group=numeric(),stringsAsFactors = FALSE)
new_group_index=0

number_of_groups<-NROW(unique(groups_list$group))


groups_list<-groups_list[,c(1,2,4,5)]


groups<- unique(groups_list[,3])

f <- function(x) min(x)/max(x)


for (i in 1:number_of_groups){
  
  print(i)
  
  cur_group_index<-groups[i]
  
  groups_names<-groups_list[groups_list$group==cur_group_index,]
  
  
  # sd_of_lengths<-sd(groups_names$length)
  stat<-min(groups_names$length)/max(groups_names$length)
  num_of_seqs<-NROW(groups_names)
  
  
  if(stat<0.80){
    
    alignment_name<-paste(the_folder,"/","sharedgroup","_",cur_group_index,".align.fasta",sep="")
    
    alignment<-read.alignment(alignment_name,"fasta")
    
    alignment_dna_bin_object<-as.DNAbin(alignment)
    
    
    cluster_new<-otu(alignment_dna_bin_object,threshold = 0.90)
    
    
    
    
    cluster_new<-as.data.frame(cluster_new)
    cluster_new$ref<-rownames(cluster_new)
    cluster_new$ref<-sub("*","",cluster_new$ref,fixed = TRUE)
    cluster_new$group<-cluster_new$cluster_new
    
    cluster_new$cluster_new<-NULL
    
    
    rownames(cluster_new)<-NULL
    
    cluster_new<-merge(cluster_new,lengths_seqs)
    
    
    new_cluster_filtered<-cluster_new[cluster_new$group %in% unique(cluster_new$group[duplicated(cluster_new$group)]),]
    
    
    
    
    
    
    
    if(NROW(new_cluster_filtered)>0){
      # stat<-min(new_cluster_filtered$length)/max(new_cluster_filtered$length)
      stat=tapply(new_cluster_filtered$length, new_cluster_filtered$group, summary)
      
      stat<-sapply(stat, f)
      
      
      
      
      if(any(stat<0.80)){
        
        if(NROW(new_cluster_filtered)>2){
          
          distance_alignment<-dist.dna(alignment_dna_bin_object,model="indel")
          cluster_new <-NbClust(data=NULL,diss=distance_alignment,distance=NULL,method = "average",index="silhouette",max.nc = NROW(new_cluster_filtered)-1)
          cluster_new <-cluster_new$Best.partition
          #cluster_new<-otu(alignment_dna_bin_object,threshold = 0.95)
          
          
          cluster_new<-as.data.frame(cluster_new)
          cluster_new$ref<-rownames(cluster_new)
          cluster_new$ref<-sub("*","",cluster_new$ref,fixed = TRUE)
          
          cluster_new$group<-cluster_new$cluster_new
          
          cluster_new$cluster_new<-NULL
          
          rownames(cluster_new)<-NULL
          
          new_cluster_filtered<-cluster_new[cluster_new$group %in% unique(cluster_new$group[duplicated(cluster_new$group)]),]
          
          
          new_cluster_filtered<-merge(new_cluster_filtered,lengths_seqs)
          #new_cluster_filtered<-new_cluster_filtered[new_cluster_filtered$length/max(new_cluster_filtered$length)>0.9,]
          new_cluster_filtered<-new_cluster_filtered[new_cluster_filtered$group %in% unique(new_cluster_filtered$group[duplicated(new_cluster_filtered$group)]),]
          
          new_cluster_filtered$length<-NULL
          rownames(new_cluster_filtered)<-NULL
          
        }else{
          
          new_cluster_filtered<-NULL
        }
        
        
        
      }
      
      if(NROW(new_cluster_filtered)>0){
        
        
        
        new_cluster_filtered$group<-new_cluster_filtered$group-min(new_cluster_filtered$group)+1
        
        new_cluster_filtered$group<-(new_cluster_filtered$group)+new_group_index
        
        
        new_cluster_filtered$length<-NULL
        
        
        new_group_index<-max(new_cluster_filtered$group)
        
        new_groups<-rbind(new_groups,new_cluster_filtered)
      }
    }
    
    
    
  }
  
  
  
  else {
    
    to_add<-groups_names[,c(1,3)]
    to_add$group<-new_group_index+1
    new_groups<-rbind(new_groups,to_add)
    new_group_index=new_group_index+1
    
  }
  
  
  
}




remove_old_groups<-function(x){
  
  return(gsub("_con_[0-9]*","",x))
  
}




new_groups<-merge(new_groups,thespecies_and_samples)

new_groups<-new_groups[,c(1,3,4,2)]


#just double checked

acceptabl_groups<-table(new_groups$group)[table(new_groups$group)>1]
groups_shared<-row.names(acceptabl_groups)
new_groups<-new_groups[new_groups$group %in% groups_shared,]

new_groups$group<- as.numeric(as.factor(new_groups$group))


new_groups<- new_groups[order(new_groups$group),]

#






write.table(new_groups,theoutput_name,col.names = FALSE,row.names = FALSE,quote = FALSE,sep="\t")







