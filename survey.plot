set title "LoC Analysis"
set xdata time
set ylabel "Lines of Code" font "Arial,12"
set xlabel "Time"
set timefmt "%Y-%m-%d"
set xrange ['2009-01-01':'2020-01-01']
set xtics rotate
set term png
set term png size 1024, 768
set autoscale
set output "./survey.png"
set key left top
plot "<(grep -i ovs analysis.csv)" using 2:4 title "OVS" with linespoints, \
     '' using 2:4:3 notitle with labels font " ,6" offset 0,char 1, \
     "<(grep -i dpdk analysis.csv)" using 2:4 title "DPDK" with linespoints, \
     '' using 2:4:3 notitle with labels font " ,6" offset 0,char 1, \
     "<(grep -i contrail analysis.csv)" using 2:4 title "Contrail" with linespoints, \
     '' using 2:4:3 notitle with labels font " ,6" offset 0,char 1, \
     "<(grep -i Seastar analysis.csv)" using 2:4 title "Seastar" with linespoints, \
     '' using 2:4:3 notitle with labels font " ,6" offset 0,char 1, \
     "<(grep -i mTCP analysis.csv)" using 2:4 title "mTCP" with linespoints, \
     '' using 2:4:3 notitle with labels font " ,6" offset 0,char 1, \
     "<(grep -i vpp analysis.csv)" using 2:4 title "VPP" with linespoints, \
     '' using 2:4:3 notitle with labels font " ,6" offset 0,char 1
