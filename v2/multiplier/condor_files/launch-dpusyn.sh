#echo -e "make directories"
#cd lisas-dse
for dir in multiplier; do
	mkdir $dir
	cp -r /proj/arcade/home/tkp2108/research/rsa/synthesis/$dir/rtl $dir/.
	cp -r /proj/arcade/home/tkp2108/research/rsa/synthesis/synth.sh $dir/.
	cp -r /proj/arcade/home/tkp2108/research/rsa/synthesis/synth.submit $dir/.

#	mod=`echo $dir | sed 's/[0-9]*$//g'`
#	echo "$dir $mod"

#	cat /proj/arcade/home/tkp2108/research/DPU/verilog/synthesis/synth_tools/dsyn.tcl.template | sed "s/%TOPMODULE%/$mod/g" > $dir/dsyn.tcl
#	cat /proj/arcade/home/tkp2108/research/DPU/verilog/synthesis/synth_tools/psyn.tcl.template | sed "s/%TOPMODULE%/$mod/g" > $dir/psyn.tcl

done 

for dir in multiplier; do
	echo -e "job id\tdirectory"
	echo -e "------\t---------"
    pushd $dir > /dev/null
    condor_submit synth.submit > condor_job.txt
    job=`cat condor_job.txt | grep cluster | sed 's/.*cluster \(.*\)\.$/\1/g'`
    echo -e "$job\t$dir"
    popd > /dev/null
done

echo -e "-----------------"
echo "NOTE: 'condor_q' shows job queue state"
echo "NOTE: 'condor_rm <username>' kills all users job"
echo "NOTE: 'condor_rm <job id>' kills a particular job"
