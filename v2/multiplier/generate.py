

for i in range(0,4096):
	print "12'd%d: begin if(a[i]==1) \n\t \
		intermediate[4095+%d:0+%d] <= intermediate[4095+%d:0+%d] + a; end" % (i,i,i,i,i)


