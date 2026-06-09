
# coding: utf-8

# In[3]:

from Bio.Align.Applications import MafftCommandline
from Bio.Align.Applications import ClustalOmegaCommandline
from Bio import AlignIO
from io import StringIO
from Bio import pairwise2
from Bio import SeqIO
from cogent3 import load_unaligned_seqs
import sys
from Bio import Align
import re
from Bio.Align import AlignInfo
from Bio.Seq import Seq

print("done importing")


# In[7]:
def clustal_directory(repeatdictionary):

    repeat_file_name="tempy.fasta"
    ofile = open(repeat_file_name, "w")
    for key in repeatdictionary.keys():
        ofile.write(">" + key + "\n" +str(repeatdictionary[key]) + "\n")

    ofile.close()
    
    mafft_cline  = MafftCommandline("scripts/mafft.bat",input=repeat_file_name,genafpair =True) #clustal has it infile
    stdout, stderr = mafft_cline ()
    align = AlignIO.read(StringIO(stdout), "fasta")
    summary_align = AlignInfo.SummaryInfo(align)
    return(align)


filename=sys.argv[1]
seqs=load_unaligned_seqs(filename)


output_folder=sys.argv[2]


groupname=filename.replace(".fasta","")


# In[8]:


seqs_dict=seqs.to_dict()






# In[9]:


keys_seqs=list(seqs_dict.keys())

if(len(keys_seqs)<2):
    
    ofile = open(groupname+"_special_con.fasta", "w")
    ofile.write(">" + groupname+ "\n" +seqs_dict[keys_seqs[0]] + "\n")
    ofile.close()
    sys.exit()


# In[4]:

max=""
key_max=""
for key in seqs_dict.keys():
    if(len(seqs_dict[key])>len(max)):
        max=seqs_dict[key]
        key_max=key
        
ref=max+max

length_seq=len(max)
aligner = Align.PairwiseAligner()

cutparts={}
#print(key_max)
for i in range(len(seqs_dict)):
    alignments1 = pairwise2.align.localxx(ref.upper(), str(seqs_dict[keys_seqs[i]]).upper())

    score1=alignments1[0][2]

    seq = Seq(seqs_dict[keys_seqs[i]])
    


    alignments2 = pairwise2.align.localxx(ref.upper(),str(seq.reverse_complement()).upper())
    
    

    
    score2=alignments2[0][2]
    if(score1>score2):
        alignments=alignments1
        repeatdict={}
        repeatdict["ref"]=ref
        repeatdict["query"]=seqs_dict[keys_seqs[i]]

    else:
        alignments=alignments2
        repeatdict={}
        repeatdict["ref"]=ref
        repeatdict["query"]=seq.reverse_complement()

    
    alignmentobj=clustal_directory(repeatdict)
    ref=str(alignmentobj[0].seq)
    query=str(alignmentobj[1].seq)
    
    sequence_1=1
    index=0
    letter_count=0
    while (letter_count<length_seq):

        theletter=ref[index]
        if(re.match('A|T|G|C|a|t|g|c',theletter)):
            letter_count=letter_count+1
        index+=1
    secondalign=query
    
    
    firstpart=secondalign[0:index].replace('-',"")
    secondpart=secondalign[index:len(secondalign)].replace('-',"")
   
    cutparts[keys_seqs[i]]=secondpart+firstpart


    #if len(firstpart)<5 or len(secondpart)<5:
       # cutparts["seq"+"_"+str(i)]=seqs_dict[keys_seqs[i]]
    #else:
     #   cutparts["first_"+str(sequence_1)+"_"+str(i)]=firstpart
      #  cutparts["second_"+str(sequence_1)+"_"+str(i)]=secondpart

        


        


# In[127]:



repeat_file_name=output_folder+"/"+groupname+"_splitted.fasta"
ofile = open(repeat_file_name, "w")
for key in cutparts.keys():
    ofile.write(">" + key + "\n" +cutparts[key] + "\n")

ofile.close()
   
   #new stuff


print("thetest",repeat_file_name)
mafft_cline  = MafftCommandline("scripts/mafft.bat",input=repeat_file_name,genafpair =True) #clustal has it infile
##print(clustalomega_cline)
stdout, stderr = mafft_cline()
align = AlignIO.read(StringIO(stdout), "fasta")
summary_align = AlignInfo.SummaryInfo(align)

consensus=str(summary_align.dumb_consensus())

ofile = open(output_folder+"/"+groupname+".align.fasta", "w")
ofile.write(">" + str(align[0].name) + "\n" +str(align[0].seq) + "\n")
ofile.close()
ofile = open(output_folder+"/"+groupname+".align.fasta", "a")
for aligned_i in range(1,len(align)):
    ofile.write(">" + str(align[aligned_i].name) + "\n" +str(align[aligned_i].seq) + "\n")
ofile.close()


longest_len=-1

for key in cutparts.keys():
	cur_len=len(cutparts[key])
	if(cur_len>longest_len):
		longest_index=key
		longest_len=cur_len





ofile = open(output_folder+"/"+groupname+"_representive.fasta", "w")
ofile.write(">" +groupname+"_"+str(longest_index)+ "\n" +cutparts[longest_index]+ "\n")
    
ofile.close()







