#echo -e "make directories"
#cd lisas-dse
for dir in multiplier; do
	mkdir $dir
	cp -r /proj/arcade/home/tkp2108/research/DPU/verilog/synthesis/$dir/rtl $dir/.
	cp -r /proj/arcade/home/tkp2108/research/DPU/verilog/synthesis/synth_tools/synth.sh $dir/.
	cp -r /proj/arcade/home/tkp2108/research/DPU/verilog/synthesis/synth_tools/synth.submit $dir/.

	mod=`echo $dir | sed 's/[0-9]*$//g'`
#	echo "$dir $mod"

	cat /proj/arcade/home/tkp2108/research/DPU/verilog/synthesis/synth_tools/dsyn.tcl.template | sed "s/%TOPMODULE%/$mod/g" > $dir/dsyn.tcl
	cat /proj/arcade/home/tkp2108/research/DPU/verilog/synthesis/synth_tools/psyn.tcl.template | sed "s/%TOPMODULE%/$mod/g" > $dir/psyn.tcl

done 

for dir in partitioner0 partitioner1 partitioner2 partitioner3 partitioner4 partitioner5; do
	cp -f /proj/arcade/home/tkp2108/research/DPU/verilog/synthesis/condor_mods/dsyn_part.tcl $dir/dsyn.tcl
done

for dir in sorter0 sorter1 sorter2 sorter3; do 
	cp -f /proj/arcade/home/tkp2108/research/DPU/verilog/synthesis/condor_mods/dsyn_sort.tcl $dir/dsyn.tcl
done

for dir in joiner0 joiner1 joiner2; do
	cp -f /proj/arcade/home/tkp2108/research/DPU/verilog/synthesis/condor_mods/dsyn_join.tcl $dir/dsyn.tcl
done

for dir in alu0 alu1 alu2 aggregator0 aggregator1 aggregator2 sorter0 sorter1 sorter2 sorter3 stitch0 stitch1 stitch2 concatenate0 concatenate1 concatenate2 boolgen0 boolgen1 boolgen2 filter0 filter1 filter2 colselect0 colselect1 colselect2 partitioner0 partitioner1 partitioner2 partitioner3 partitioner4 partitioner5 joiner0 joiner1 joiner2; do
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
