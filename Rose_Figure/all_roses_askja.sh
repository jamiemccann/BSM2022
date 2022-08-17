#!/bin/bash




ps_out=askja_with_roses.ps 
gmtdatadir=../gmt_data 

gmt gmtset PS_MEDIA a4 MAP_FRAME_TYPE plain

# define coastline projction  latlong
#wet areas blue  land great  coast black thin
#resolution - size of features eg dont lot less than 100mk2/only plot islands   2 would be lakes
 #will edit later 
echo "Potting coastline"





gmt pscoast -JM15c -R-17.3/-16/64.75/65.3 \
    -Gc \
    -Dh -A100/0/2  \
    -K  > $ps_out #got rid of Y and changed to a4 to stop the blank white space problem


plot_height=`gmt mapproject -J -R -Wh`
gmt mapproject -J -R -W > tmp
read w h < tmp

gmt grdimage -J -R \
    $gmtdatadir/IcelandDEM_20m.grd \
    -I$gmtdatadir/IcelandDEM_20mI.grd \
    -C$gmtdatadir/grey_poss.cpt \
    -E300 \
    -O -K >> $ps_out


#we need to close pscost with -Q after grid to make sure we don't have any clip errors
gmt pscoast -Q -O -K >> $ps_out




echo "Plotting lakes"
gmt psxy -JM15c -R-17.3/-16/64.75/65.3 \
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

echo "Plot earthquakes"
awk -F',' '{print $4,  $5,  $6}' askja_eqs.csv | gmt psxy -J -R -Sc0.03c -Cdepth.cpt -O -K >> $ps_out
    




echo "Plotting Stations"
#awk -F',' '{print $2  $1}' stations_all_edit.txt | gmt psxy -J -R -St0.25c -Ghotpink -Wthinner black -O -K >> $ps_out
#awk -F' ' '{print $2  $1  $4}' stations_all_edit.txt | gmt pstext -J -R -D0/0.1c -F+f5p+jCB -O -K >> $ps_out


echo "-16.8 65.06 Askja" | gmt pstext -J -R -F+f12p,Helvetica-Bold white =2p black+a0+jCM -O -K >> $ps_out
echo "-16.8 65.06 Askja" | gmt pstext -J -R -F+f12p,Helvetica-Bold white+a0+jCM -O -K >> $ps_out
#echo "-16.8 65.105 Askja" | gmt pstext -R -J  -O -K >> $ps_out




echo "Plotting Legend"
#G is vertical gap  V is vertical line  N sets # of columns  D draws horizontal line 
# H is ps=legend.ps
gmt pslegend -J -R -DjBL+w1.2i -F+gwhite+pblack -O -K << END >> $ps_out
N 2
G 0.15c
S +0.1c t 0.4c hotpink thin,black 0.4c Seismometer
N 0
END

######ROSE PLOTTING######

##ROSE FUNCTION##
function plotrose()
## Function to plot rose diagram at the place it's supposed to be plotted
#  This version uses the command mapproject to find where it's supposed to go
#   instead of using complicated methods to try to backproject it myself.
#psbasemap $RVAL $BVAL $JVAL -X4 -Y1  -K > $POSTSCRIPT_NAME.ps
{
stalat=$1
stalon=$2
stanam=$3
rosename=$4
circlesize=$5



echo "about to do pstext args are " $stalon $stalat $stanam $rosename $circlesize
nm=`cat $rosename | wc -l | awk '{print $1}'`
gmt pstext <<END -JM15c -R-17.3/-16/64.75/65.3 -D0.1/0.25 -F+f3p+jCB -O -K  >> ${ps_out}
$stalon $stalat $stanam $nm
END



echo "just plotted name"
#gmt psxy <<END $RVAL $JVAL -G0/0/0 -St1.5 -O -K -V  >> ${ps_out}
#$stalon $stalat 
#END
gmt mapproject <<END -JM15c -R-17.3/-16/64.75/65.3 >starose.xy
$stalon $stalat
END





xoff=`awk '{print $1}' <starose.xy`
yoff=`awk '{print $2}' <starose.xy`
#echo "calculated xoff  yoff are "  $xoff  $yoff
## set so that it is on the centre of the station-- depends on the size of the
##  circle
yoff=`echo $yoff - $circlesize  | bc -l `
xoff=`echo $xoff - $circlesize | bc -l `
#  prepending "a" before -X returns the plotting coordinates
#   back to what they were after the offset.  
gmt psrose $rosename -R0/5/0/360 -G0/255/0 -S"$circlesize"cn -T -A10 -Xa$xoff -Ya$yoff -V -O -K -W0.25/0/0 >>${ps_out}
#cat $rosename | wc -l
#nm=`cat $rosename | wc -l | awk '{print $1/2}'`
#echo "about to do pstext args are " $stalon $stalat $nm $rosename
#gmt pstext <<END $RVAL $JVAL -D0.25 -F8p+jRB -O -V -K >> ${ps_out}
#$stalon $stalat $nm
#END
}


#PLOT ACTUAL ROSES#




plotrose 65.0519 -16.6481 ASK ../Rose_Data_Combo/ASK_rose.txt 0.25
plotrose 65.07733 -16.93670 DALR ../Rose_Data_Combo/DALR_rose.txt 0.25
#plotrose 65.07739 -16.93341 DDAL ../Rose_Data_Combo/DDAL_rose.txt 0.25
plotrose 65.04944 -16.59703 DREK ../Rose_Data_Combo/DREK_rose.txt 0.25
plotrose 64.92149 -16.72847 DSAN ../Rose_Data_Combo/DSAN_rose.txt 0.25
#plotrose 64.79086 -17.36648 DYN ../Rose_Data_Combo/DYN_rose.txt 0.25
plotrose 64.93490 -16.67546 DYSA ../Rose_Data_Combo/DYSA_rose.txt 0.25
plotrose 65.03358 -16.96212 EFJA ../Rose_Data_Combo/EFJA_rose.txt 0.25
plotrose 65.18279 -16.49796 FLAT ../Rose_Data_Combo/FLAT_rose.txt 0.25
plotrose 65.03704 -16.85982 GODA ../Rose_Data_Combo/GODA_rose.txt 0.25
plotrose 65.04748 -16.52985 HOTT ../Rose_Data_Combo/HOTT_rose.txt 0.25
plotrose 65.15577 -16.67551 HRUR ../Rose_Data_Combo/HRUR_rose.txt 0.25
plotrose 65.07747 -16.80570 JONS ../Rose_Data_Combo/JONS_rose.txt 0.25
plotrose 64.99901 -16.96539 KATT ../Rose_Data_Combo/KATT_rose.txt 0.25
plotrose 65.07529 -16.75322 KLUR ../Rose_Data_Combo/KLUR_rose.txt 0.25
plotrose 65.29024 -16.56726 KOLL ../Rose_Data_Combo/KOLL_rose.txt 0.25
#plotrose 65.29024 -16.56726 KOLLA ../Rose_Data_Combo/KOLLA_rose.txt 0.25
#plotrose 65.29024 -16.56726 KOLLS ../Rose_Data_Combo/KOLLS_rose.txt 0.25
plotrose 65.15699 -16.82042 LOKAA ../Rose_Data_Combo/LOKAA_rose.txt 0.25
plotrose 65.08676 -16.32961 MIDF ../Rose_Data_Combo/MIDF_rose.txt 0.25
plotrose 64.97840 -16.33826 MKO ../Rose_Data_Combo/MKO_rose.txt 0.25
plotrose 64.98440 -16.65119 MOFO ../Rose_Data_Combo/MOFO_rose.txt 0.25
plotrose 65.01350 -16.81258 MVET ../Rose_Data_Combo/MVET_rose.txt 0.25
plotrose 65.15550 -16.36895 MYVO ../Rose_Data_Combo/MYVO_rose.txt 0.25
#plotrose 65.15550 -16.36895 MYVOA ../Rose_Data_Combo/MYVOA_rose.txt 0.25
#plotrose 65.15550 -16.36895 MYVOS ../Rose_Data_Combo/MYVOS_rose.txt 0.25
plotrose 65.02023 -16.57285 NAUG ../Rose_Data_Combo/NAUG_rose.txt 0.25
plotrose 65.02071 -16.57330 NAUT ../Rose_Data_Combo/NAUT_rose.txt 0.25
#plotrose 65.04225 -16.79473 OLAF ../Rose_Data_Combo/OLAF_rose.txt 0.25
plotrose 65.03933 -16.70164 OSKV ../Rose_Data_Combo/OSKV_rose.txt 0.25
plotrose 65.04696 -16.77066 OSVA ../Rose_Data_Combo/OSVA_rose.txt 0.25
plotrose 64.98513 -16.88639 RODG ../Rose_Data_Combo/RODG_rose.txt 0.25
#plotrose 64.98513 -16.88639 RODGA ../Rose_Data_Combo/RODGA_rose.txt 0.25
#plotrose 64.98513 -16.88639 RODGS ../Rose_Data_Combo/RODGS_rose.txt 0.25
plotrose 64.97894 -16.83757 SOFA ../Rose_Data_Combo/SOFA_rose.txt 0.25
plotrose 64.94193 -16.85430 SOSU ../Rose_Data_Combo/SOSU_rose.txt 0.25
plotrose 64.94189 -16.85419 SSUD ../Rose_Data_Combo/SSUD_rose.txt 0.25
plotrose 64.99691 -16.80959 STAM ../Rose_Data_Combo/STAM_rose.txt 0.25
plotrose 65.11746 -16.57498 SVAD ../Rose_Data_Combo/SVAD_rose.txt 0.25
plotrose 64.93372 -16.67558 THO ../Rose_Data_Combo/THO_rose.txt 0.25
plotrose 64.91658 -16.78473 TOHR ../Rose_Data_Combo/TOHR_rose.txt 0.25
plotrose 65.03605 -16.31867 UTYR ../Rose_Data_Combo/UTYR_rose.txt 0.25
#plotrose 65.03605 -16.31867 UTYRA ../Rose_Data_Combo/UTYRA_rose.txt 0.25
#plotrose 65.03605 -16.31867 UTYRS ../Rose_Data_Combo/UTYRS_rose.txt 0.25
plotrose 64.99487 -16.53817 VADA ../Rose_Data_Combo/VADA_rose.txt 0.25
plotrose 65.06619 -16.73256 VIBR ../Rose_Data_Combo/VIBR_rose.txt 0.25
plotrose 65.08446 -16.49346 VIFE ../Rose_Data_Combo/VIFE_rose.txt 0.25
plotrose 65.07474 -16.51347 VIKR ../Rose_Data_Combo/VIKR_rose.txt 0.25









echo "Plotting frame"
gmt psbasemap -JM15c -R-17.3/-16/64.75/65.3\
    -Bxa0.25df0.25d -Bya0.255df0.255d -BSWne  \
    -Ln0.8/0.03+w10k+c64+jBR+l \
    -O >> $ps_out









rm -f tmp


echo "converting to pdf..."
gmt psconvert -Tg -A -P -Z $ps_out
