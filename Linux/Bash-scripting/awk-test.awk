BEGIN {
	print "Starting processing of file:"
} 
/root/ {
	print $0
} 
END {
	print "Done processing file"
}

