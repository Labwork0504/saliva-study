# Co-occurrence network
# setwd("~/")

# install.packages("igraph")
# install.packages("psych")

library(igraph)
library(psych)

otu = read.table("otu_table.txt",head=T,row.names=1)

occor = corr.test(otu,use="pairwise",method="spearman",adjust="fdr",alpha=.05)
occor.r = occor$r 
occor.p = occor$p

occor.r[occor.p>0.05|abs(occor.r)<0.6] = 0 

igraph = graph_from_adjacency_matrix(occor.r,mode="undirected",weighted=TRUE,diag=FALSE)
graph_from_adjacency_matrix(occor.r,mode="undirected",weighted=NULL,diag=FALSE)

# remove isolated nodes
bad.vs = V(igraph)[degree(igraph) == 0]
igraph = delete.vertices(igraph, bad.vs)
igraph

igraph.weight = E(igraph)$weight

E(igraph)$weight = NA

set.seed(123)
plot(igraph,main="Co-occurrence network",vertex.frame.color=NA,vertex.label=NA,edge.width=1,
     vertex.size=5,edge.lty=1,edge.curved=TRUE,margin=c(0,0,0,0))

sum(igraph.weight>0)# number of postive correlation
sum(igraph.weight<0)# number of negative correlation

# set edge color，postive correlation 
E.color = igraph.weight
E.color = ifelse(E.color>0, "red",ifelse(E.color<0, "blue","grey"))
E(igraph)$color = as.character(E.color)

otu_pro = read.table("otu_pro.txt",head=T,row.names=1)
# set vertices size
igraph.size = otu_pro[V(igraph)$name,] 
igraph.size1 = log((igraph.size$abundance)*100) 
V(igraph)$size = igraph.size1

# set vertices color
igraph.col = otu_pro[V(igraph)$name,]
levels(igraph.col$phylum)
levels(igraph.col$phylum) = c("green","deeppink","deepskyblue","yellow","brown","pink","gray","cyan","peachpuff")
V(igraph)$color = as.character(igraph.col$phylum)

set.seed(123)
plot(igraph,main="Co-occurrence network",layout=layout.fruchterman.reingold,vertex.frame.color=NA,vertex.label=NA,
     edge.lty=1,edge.curved=TRUE,margin=c(0,0,0,0))

modularity
fc = cluster_fast_greedy(igraph,weights =NULL)# cluster_walktrap cluster_edge_betweenness, cluster_fast_greedy, cluster_spinglass
modularity = modularity(igraph,membership(fc))
comps = membership(fc)
colbar = rainbow(max(comps))
V(igraph)$color = colbar[comps] 


