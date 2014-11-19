#!/usr/bin/python

import os
import sys
import subprocess
from socket import gethostname

script_base = "/root/stuff/backup/scripts"
zimbra_ctl = script_base + "/zimbractl.sh"

#print zimbra_ctl

#infile = file(zimbra_ctl, "r")
#content = infile.read()
#print content

#from socket import gethostname 
host_name = gethostname()

vzlist = "/usr/sbin/vzlist"
rsync = "/usr/bin/rsync"

print host_name

os.environ["PYTHONPATH"]="/usr/local/rdiff-backup/lib64/python2.4/site-packages"

rdiff = "/usr/local/rdiff-backup/bin/rdiff-backup"

try:
    p = subprocess.Popen(vzlist + " -aH -o veid", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output = p.communicate()
    p.wait()
    if p.returncode < 0:
        print >>sys.stderr, "Child was terminated by signal", p.returncode
    else:
        print >>sys.stderr, "Child returned", p.returncode
except OSError, e:
    print >>sys.stderr, "Execution failed:", e

if output[1] != "":
	print "error"

containers = output[0].splitlines()

for container in containers:
	print "vzctl backup " + container.strip()
