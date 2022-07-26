#!/bin/bash



ps_out=askja_with_inset.ps 
gmtdatadir=../gmt_data 

gmt gmtset PS_MEDIA a4 MAP_FRAME_TYPE plain

# define coastline projction, latlong
#wet areas blue, land great, coast black thin
#resolution - size of features eg dont lot less than 100mk2/only plot islands , 2 would be lakes
 #will edit later 
echo "Potting coastline"


#get rid of the -Y and Q further down, these open u 
gmt pscoast -JM15c -R-17.3/-16/64.75/65.3 \
    -Gc \
    -Dh -A100/0/2  \
    -K  > $ps_out 


plot_height=`gmt mapproject -J -R -Wh`

gmt grdimage -J -R \
    $gmtdatadir/IcelandDEM_20m.grd \
    -I$gmtdatadir/IcelandDEM_20mI.grd \
    -C$gmtdatadir/grey_poss.cpt \
    -E300 \
    -O -K >> $ps_out


#we need to close pscost with -Q after grid to make sure we don't have any clip errors
gmt pscoast -Q -O -K >> $ps_out


echo "-16.8 65.055 Askja" | gmt pstext -J -R -F+f12p+jCB -O -K >> $ps_out
#echo "-16.8 65.105 Askja" | gmt pstext -R -J  -O -K >> $ps_out


echo "Plotting lakes"
gmt psxy -J -R \
    $gmtdatadir/askja_lakes.xy\
    -Glightblue \
    -O -K >> $ps_out

echo "Plotting fractures"
gmt psxy -J -R \
    $gmtdatadir/sNVZ_fractures.xy\
    -Wthinnest,black \
    -O -K >> $ps_out

echo "Plotting glaciers"
gmt psxy -J -R \
    $gmtdatadir/glaciers.xy \
    -Gwhite -Wthinner,black \
    -O -K >> $ps_out

echo "Plotting Stations"
awk -F',' '{print $2, $1}' stations_all.txt | gmt psxy -J -R -St0.2c -Ghotpink -Wthinner,black -O -K >> $ps_out
#awk -F',' '{print $2, $1, $4}' stations_all.txt | gmt pstext -J -R -D0/0.1c -F+f8p+jCB -O -K >> $ps_out







echo "Plotting frame"
gmt psbasemap -J -R\
    -Bxa0.5df0.5d -Bya0.25df0.25d -BSWne+t"Study Area"  \
    -Ln0.95/0.05+w10k+c64+jBR+l \
    -O -K >> $ps_out


#Calculate height that we want to shift the Iceland Map
map_height=`gmt mapproject -R -J -Wh`
inset_map_height=`gmt mapproject -R-24/-13/63.5/66.7 -JM5c -Wh`
Y=`echo "$map_height - $inset_map_height" | bc`


#Plot the whole Iceland Map
gmt gmtset MAP_FRAME_TYPE inside
gmt pscoast -R-24/-13/63.5/66.7 -JM5c -Dh -Ggrey -Wthinnest,black -Slightblue -B0 -EES+gbisque -O -K -X10c -Y${Y}c >> $ps_out


#plot NVZ EVZ and WVZ labels
echo "-16 65.1 NVZ" | gmt pstext -R -J -F+f9p -O -K >> $ps_out
echo "-18.2 64.35 EVZ" | gmt pstext -R -J -F+f9p -O -K >> $ps_out
echo "-21 64.35 WVZ" | gmt pstext -R -J -F+f9p -O -K >> $ps_out


#Plot Fissure Swarms on inset
gmt psxy -J -R \
    $gmtdatadir/fisswarms_out.xy \
    -Wthinnest,red \
    -O  >> $ps_out  


rm -f tmp


echo "converting to pdf..."
gmt psconvert -Tg -A -P -Z $ps_out
