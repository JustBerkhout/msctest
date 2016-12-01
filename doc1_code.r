#for geospatial tools
library(rgdal)
library(maptools)
library(rgeos)
library(ggplot2)

#for some data reduction
library(plyr)
#library(dplyr)

#retrieve and prepar the relevant Surveydata from rls data repository
SUR_DF <- read.csv(url("http://geoserver-rls.imas.utas.edu.au/geoserver/RLS/wfs?request=GetFeature&typeName=RLS:SurveyList&outputFormat=csv"))
SUR_DF <- SUR_DF[,c("SiteLatitude","SiteLongitude","SurveyDate")]
SUR_DF$SurveyDate <- as.Date(substring(SUR_DF$SurveyDate, 0, 10))

#get the eoregions from local repository
MEO <- readOGR("./MEOW", "meow_ecos")


map_plot <- NULL
mytheme <- theme(
  axis.line=element_blank(),
  axis.text.x=element_blank(),
  axis.text.y=element_blank(),
  axis.ticks=element_blank(),
  axis.title.x=NULL, #element_blank(),
  axis.title.y=NULL, #element_blank(),
  legend.position="none",
  panel.background = element_rect(fill = 'gray20'),
  panel.grid.major = element_blank(),
  panel.grid.minor = element_blank(),
  panel.spacing =   element_blank(),
  plot.margin=grid::unit(c(0,0,-0.5,-0.5), "line")
)

worldborders <- borders("world", regions=".", colour="black", fill="black")

MEO@data$id = rownames(MEO@data)
MEO.points = fortify(MEO, ECOREGION="id")
MEO.df = join(MEO.points, MEO@data, by="id")

meow <- geom_polygon(data=MEO.df, aes(x=long, y=lat,group=group), size=0.1, color = "gray20", fill="#2CA25F", alpha=0.2)

startDate <- as.Date("2014-01-01")
endDate <- as.Date("2014-01-31")

frameDate <- startDate
flashDays <- 7

HorizRes <- 1024
VertRes <- HorizRes/2

while (frameDate <= endDate) {

  current_surveys_data <- SUR_DF[(
    SUR_DF$SurveyDate <= frameDate &
      SUR_DF$SurveyDate > frameDate - flashDays
  ),c("SurveyDate","SiteLongitude","SiteLatitude")]
  
  current_surveys_data$sf <- abs(as.integer(current_surveys_data$SurveyDate - frameDate))
  
current_surveys_layer <- geom_point(
  data = current_surveys_data, 
  aes (x = SiteLongitude, y = SiteLatitude), 
  color = "#FFFFFF", 
  size = current_surveys_data$sf,
  alpha = 0.25)

past_surveys_layer <- geom_point(
  data=SUR_DF[SUR_DF$SurveyDate < frameDate - flashDays,], 
  aes(x=SiteLongitude, y=SiteLatitude), 
  color = "#2DB9B5", 
  size=0.9, 
  alpha=0.4)

#info <- grid::roundrectGrob()

map_plot <- ggplot() +
  mytheme +
  meow +
  worldborders + 
  past_surveys_layer +
  current_surveys_layer + 
  #coord_map(xlim = c(-180, 180),ylim = c(-90,90))+ 
  #annotation_custom(grob = info,xmin = 70, xmax = 170,  ymin = -90, ymax = -60,    color = "red"  ) +  
  labs(x=NULL, y=NULL)

  #plot map to plots window
  map_plot
  
  #save plot to frame repository
  filename <- paste("/pvol/2", frameDate, ".tiff", sep="")
  ggsave(filename, plot=map_plot, height=VertRes/96, width=HorizRes/96, units='in', dpi=96)
  
  
  frameDate <- frameDate + 1
}
