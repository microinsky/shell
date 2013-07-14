
#!/bin/sh
yesterday=`date -d last-day +'%Y-%m-%d %H:%M:%S'`
echo $yesterday

ysdate=`date -d last-day +'%Y%m%d'`
echo $ysdate

purewalktotal=0

for filename in `find . -name *${ysdate}*.log.gz`
#for filename in `find . -name 'test.log.gz'`
do
    echo $filename
    gzip -dc $filename > tmp.log
    
    purewalk=`awk -v count=0 '$0~/<request/{count+=1}END{print count}' tmp.log`
    echo $purewalk
    let purewalktotal=$purewalktotal+$purewalk

    buscall=`awk -v c2=0 '$0~/reqsrc="routeservice"/{c2+=1}END{print c2}' tmp.log`
    echo $buscall
    let buscalltotal=$buscalltotal+$buscall
    
    buswalk=`awk -v c3=0 '$0~/routeservice/{for(i=0;i<=NF;i++){if($i~/<route/){c3+=1}}}END{print c3}' tmp.log`
    echo $buswalk
    let buswalktotal=$buswalktotal+$buswalk

done
echo $purewalktotal
echo $buscalltotal
echo $buswalktotal

mysql -h ***** -u root -p***** navigation --default-character-set=utf8 -e "insert into nv_basic_info (fre_request,fre_success,max_elapse,min_elapse,avg_elapse,sum_len,service,platform,day_time) values (${purewalktotal},${purewalktotal},0,0,0,0,\"purewalk\",\"unknown\",\"$yesterday\");"

mysql -h ***** -u root -p***** navigation --default-character-set=utf8 -e "insert into nv_basic_info (fre_request,fre_success,max_elapse,min_elapse,avg_elapse,sum_len,service,platform,day_time) values ($buscalltotal,$buscalltotal,0,0,0,0,\"buscall\",\"unknown\",\"$yesterday\");"

mysql -h ***** -u root -p***** navigation --default-character-set=utf8 -e "insert into nv_basic_info (fre_request,fre_success,max_elapse,min_elapse,avg_elapse,sum_len,service,platform,day_time) values ($buswalktotal,$buswalktotal,0,0,0,0,\"buswalk\",\"unknown\",\"$yesterday\");"
