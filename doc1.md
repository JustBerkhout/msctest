#Document 1

Lorem ipsum etc etc 

```r
MY_SUR <- read.csv(url("http://geoserver-rls.imas.utas.edu.au/geoserver/RLS/wfs?request=GetFeature&typeName=RLS:SurveyList&outputFormat=csv"))

MY_M1_OBS <- read.csv(url("http://geoserver-rls.imas.utas.edu.au/geoserver/RLS/wfs?request=GetFeature&typeName=RLS:M1_DATA&outputFormat=csv"))
head (MY_M1_OBS)
```

[link to code file](doc1_code.r)
