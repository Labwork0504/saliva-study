#PCoA
library(vegan)
library(ggplot2)
library(grid)
library(plyr)
library(ape)
library(RColorBrewer)
library(patchwork)
library(cowplot)

argv =c("bmap", "weighted_unifrac_distance.txt")
map_file=argv[1]
in_file=argv[2]

dist=read.table(in_file)

pcoa <- pcoa(dist, correction="none",rn=rownames(dist))
map=read.table(map_file,header=T)

if(pcoa$correction[2]==1){name_eig="Relative_eig";axis.1=pcoa$vectors[,1];axis.2=pcoa$vectors[, 2];rn=map[rownames(pcoa$vectors),3]};
if(pcoa$correction[2]==2){name_eig="Rel_corr_eig";axis.1=pcoa$vectors.cor[,1];axis.2=pcoa$vectors.cor[, 2];rn=map[rownames(pcoa$vectors.cor),3]};

Group=map$Group
Group=factor(as.character(map$Group),levels=unique(map$Group))
# Treatment=map$Treatment
# Treatment=factor(as.character(map$Treatment),levels=unique(map$Treatment))

col=rep(c("#BC3C29","#0072B5","#FF5A46","#74A8EC"),t=100)[1:length(levels(factor(Group)))] 

# shapes=c(21,24)
# if (length(levels(factor(Treatment)))<6) {
# shape=shapes[1:length(levels(factor(Group)))]
# }else{
# shape=rep(shapes[2],t=length(levels(factor(Group))))
# }

plot.data <- data.frame(Axis.1=axis.1, Axis.2=axis.2,Group=Group)
plot.var_explained <- round(100*pcoa$values[1:2, name_eig]/sum(pcoa$values[, name_eig]), digits=1);
plot.hulls <- ddply(plot.data, "Group", function(df) df[chull(df$Axis.1, df$Axis.2), ]);
plot.centroids <- ddply(plot.data, "Group", function(df) c(mean(df$Axis.1), mean(df$Axis.2)));
plot.df <- merge(plot.data, plot.centroids, by="Group");
plot.hulls$Group=factor(as.character(plot.hulls$Group),levels=unique(map$Group))
plot.df$Group=factor(as.character(plot.df$Group),levels=unique(map$Group))
plot.data$Group=factor(as.character(plot.data$Group),levels=unique(map$Group))

write.table(plot.data,  paste0(gsub("_distance.txt","",strsplit(argv[2],"/")[[1]][2], fixed = TRUE),".xls"),sep="\t",row.names = T,col.names =T,quote=FALSE)

plot.df=plot.df[order(sample(seq(0,nrow(plot.df),by=0.1),nrow(plot.df),replace=FALSE)  ),]


#Make plot
xmin=sort(plot.data$Axis.1 )[1]
xmax=sort(plot.data$Axis.1 )[length(plot.data$Axis.1)]

ymin=sort(plot.data$Axis.2 )[1]
ymax=sort(plot.data$Axis.2 )[length(plot.data$Axis.1)]

q1 <- ggplot(data = plot.df, aes_string(x="Axis.1", y="Axis.2")) +
  geom_point(aes(color = Group,fill = Group),size=2)+
  theme_bw()+
  xlab(paste("Axis 1 [", plot.var_explained[1], "%]", sep="")) +
  ylab(paste("Axis 2 [", plot.var_explained[2], "%]", sep="")) +
  theme(axis.text.x=element_text(color = "black",size = 10),
        axis.text.y=element_text(color = "black", size = 10),
        axis.title.x=element_text(color = "black",size = 12),
        axis.title.y=element_text(color = "black", size = 12),
        axis.ticks.length = unit(.1, "cm"),
        axis.ticks=element_line(color="black"),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        legend.justification = c(0.5,0.5),
        legend.position="right",
        legend.text=element_text(face="plain",size=12),
        legend.title = element_text(face="plain",size=12),
        legend.key.width=unit(0.5,'cm'),legend.key.height=unit(0.5,'cm'),
        plot.margin = unit(c(0.1,0.1,0.1,0.1),"cm"),
        strip.text = element_text(face = "bold")
  )+ 
  scale_x_continuous()+
  scale_y_continuous()+
  scale_color_manual(values=col)+
  scale_fill_manual(values=col)+
  #scale_shape_manual(values=shape)+
  geom_vline(xintercept = 0,linetype=2)+
  geom_hline(yintercept = 0,linetype=2)

pdf("PCoA.common.pdf", ,width =6, height =5,bg="white")
q1
dev.off()

pdf("boxplot1.pdf",width =6, height =5,bg="white")
ggplot(data=plot.df, aes(x=Group,y=Axis.1))+
  xlab("")+ 
  geom_boxplot(size=0.1,aes(x=Group,y=Axis.1,fill=Group),notch = F, outlier.shape=NA)+geom_jitter(aes(x=Group,y=Axis.1),shape=19,size=0.5,width=0.25)+
  scale_color_manual(values = col)+
  theme_bw()+                                                                                      ## 清空主题
  scale_fill_manual(values=col)+                                                  ## 填充颜色
  theme(axis.text.x=element_text(color = "black",size = 10),
        axis.text.y=element_text(color = "black", size = 10),
        axis.title.x=element_text(color = "black",size = 12),
        axis.title.y=element_text(color = "black", size = 12),
        axis.ticks.length = unit(.1, "cm"),
        axis.ticks=element_line(color="black"),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        legend.position="none",
        plot.margin = unit(c(0.01,0.01,0.01,0.01),"cm"),
        strip.text = element_text(face = "bold")
  )  + 
  scale_y_continuous(limits=c(xmin,xmax))+ 
  ylab(paste("Axis 1 [", plot.var_explained[1], "%]", sep="")) +
  coord_flip()
dev.off()

pdf("boxplot2.pdf",width =6, height =5,bg="white")
ggplot(data=plot.df, aes(x=factor(Group,level=c("CTL","AAA")),y=Axis.2))+
  ylab("")+ #geom_jitter(aes(color=Group),shape=19,size=0.4)+
  geom_boxplot(size=0.1,aes(x=factor(Group,level=c("CTL","AAA")),y=Axis.2,fill=Group),notch = F, outlier.shape=NA) + geom_jitter(aes(x=factor(Group,level=c("CTL","AAA")),y=Axis.2),shape=19,size=0.5,width=0.25)+
  scale_color_manual(values = col)+
  theme_bw()+                                                                                      ## 清空主题
  scale_fill_manual(values=col)+                                                  ## 填充颜色
  theme(axis.text.x=element_text(color = "black",size = 10),
        axis.text.y=element_blank(),
        axis.title.x=element_text(color = "black",size = 12),
        axis.title.y=element_blank(),
        axis.ticks.length = unit(.1, "cm"),
        axis.ticks=element_line(color="black"),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        legend.position="none",
        plot.margin = unit(c(0.01,0.01,0.01,0.01),"cm"),
        strip.text = element_text(face = "bold")
  )  + xlab("") +
  scale_y_continuous(limits=c(ymin,ymax))
dev.off()

