
#################### This one makes bar plots in Fig. 1, column 2. Swap out the "bg" vs "plat" version of the input file as needed #####################
library (ggplot2)

in_data5<-read.table("bg_three_proportions.txt", header = TRUE)
print(in_data5)

bar_cols<-c("#D3D3D3", "#E5A229", "#9DC8EB", "#F2AAF2", "#9D4C9C", "#CE7A7A", "#79A461", "#4260AC")
#in_data5$Taxon <- factor(in_data5$Taxon, levels = in_data5$Taxon)

in_data5$Taxon <- factor(in_data5$Taxon, levels =unique(in_data5$Taxon))

ggplot(data = in_data5, aes(x = Taxon, y = Percentage, fill = Category)) +
  geom_bar(stat='identity') + theme_bw() + scale_fill_manual(values=bar_cols)
  #theme(legend.position = "top")


#################### This one makes bar plots in Fig. 1, column 1. Swap out the "bg" vs "plat" version of the input file as needed #####################
library (ggplot2)

in_data5<-read.table("plat_total_50_90.txt", header = TRUE)
print(in_data5)

bar_cols<-c("#D3D3D3", "#E5A229", "#9DC8EB", "#F2AAF2", "#9D4C9C", "#CE7A7A", "#79A461", "#4260AC")
#in_data5$Taxon <- factor(in_data5$Taxon, levels = in_data5$Taxon)

in_data5$Taxon <- factor(in_data5$Taxon, levels =unique(in_data5$Taxon))

ggplot(data = in_data5, aes(x = Taxon, y = Count, fill = Category)) +
  geom_bar(stat='identity') + theme_bw() + scale_fill_manual(values=bar_cols)
#theme(legend.position = "top")

#################### This one makes bar plots in Fig. 1, column 3. Swap out the "bg" vs "plat" version of the input file as needed #####################
library (ggplot2)

in_data5<-read.table("bg_sat1_genprop.txt", header = TRUE)
print(in_data5)

bar_cols<-c("#D3D3D3", "#E5A229", "#9DC8EB", "#F2AAF2", "#9D4C9C", "#CE7A7A", "#79A461", "#4260AC")
#in_data5$Taxon <- factor(in_data5$Taxon, levels = in_data5$Taxon)

in_data5$Taxon <- factor(in_data5$Taxon, levels =unique(in_data5$Taxon))

ggplot(data = in_data5, aes(x = Taxon, y = sat1_genprop)) +
  geom_bar(stat='identity') + theme_bw() + scale_fill_manual(values=bar_cols)
#theme(legend.position = "top")


#################### This one makes box plots for Fig. 2a, boxplots of satDNA genomic proportions. Swap out the "bg" vs "plat" version of the input file as needed  #####################
library (ggplot2)

in_data5<-read.table("plat_bg_box_1.txt", header = TRUE)
print(in_data5)

ggplot(data = in_data5, aes(x=Category, y=Data, fill = Category)) + 
  geom_boxplot(notch=FALSE) + theme_bw()

#################### This one makes box plots for Fig. 2b, boxplots of satDNA counts for different genomic fractions of satDNA coverage. Swap out the "bg" vs "plat" version of the input file as needed #####################
library (ggplot2)

in_data5<-read.table("plat_bg_box_2.txt", header = TRUE)
print(in_data5)

ggplot(data = in_data5, aes(x=Category, y=Data, fill = Category)) + 
  geom_boxplot(notch=FALSE) + theme_bw()

#################### This one makes corr satDNA plots, Fig. 2C #####################

## R code for BUSCO Repeat correlation plots
#library("ggpubr")

my_data <- read.delim(file.choose("plat_summary_7.0.txt"))

head(my_data)

library("ggpubr")
ggscatter(my_data, x = "total_satDNAs", y = "genprop_sat", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson")


#################### This one makes corr satDNA plots, Fig. 2D #####################

## R code for BUSCO Repeat correlation plots
#library("ggpubr")

my_data <- read.delim(file.choose("RE_summary7.0.txt"))

head(my_data)

library("ggpubr")
ggscatter(my_data, x = "total_satDNAs", y = "genprop_rep", 
          add = "reg.line", conf.int = TRUE, 
          cor.coef = TRUE, cor.method = "pearson")


#####
#Below here may do nothing for this paper.

#################### This one summarizes TE categories -- Fig2b #####################
library (ggplot2)

in_data5<-read.table("Fig2b_group_summaries3.txt", header = TRUE)
print(in_data5)

bar_cols<-c("#D3D3D3", "#E5A229", "#9DC8EB", "#F2AAF2", "#BEE0BD", "#8A181B", "#CE7A7A", "#9D4C9C", "#79A461", "#4260AC")
#in_data5$Taxon <- factor(in_data5$Taxon, levels = in_data5$Taxon)

in_data5$Taxon <- factor(in_data5$Taxon, levels =unique(in_data5$Taxon))

ggplot(data = in_data5, aes(group_repeat, TotalBases, fill = major_group)) +
  geom_boxplot() + theme_bw() + theme(axis.text.x=element_text(angle=90,hjust=1)) #+ coord_flip() #+ geom_jitter(width = 0.2)  #+ scale_fill_manual(values=bar_cols)

ggplot(data = in_data5, aes(group_repeat, AssemblyPercent, fill = major_group)) +
  geom_boxplot() + theme_bw() + theme(axis.text.x=element_text(angle=90,hjust=1)) #+ coord_flip() #+ geom_jitter(width = 0.2) + theme_bw() #+ scale_fill_manual(values=bar_cols)

