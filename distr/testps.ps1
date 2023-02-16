$param = $args[0]
$pwd = $args[1]
$cert = $args[2]
$path = $MyInvocation.MyCommand.Path | split-path -parent
$log = "$path\param.txt"
echo "=====================" >> $log 
echo "web service type:" >> $log 
echo $param >> $log 
echo "password:" >> $log 
echo $pwd >> $log 
echo "cert:" >> $log 
echo $cert >> $log 
echo "=====================" >> $log 