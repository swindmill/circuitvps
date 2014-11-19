#!/usr/bin/python
import sys
import os
import subprocess
import rrdtool

class vzHost:
	def __init__(self):
		self.hostName = os.uname()[1]
		self.vpsList = []
		self.getVpsList()
	def getVpsList(self):
		
		#clear screen
		#sys.stdout.write("\x1b[H\x1b[2J")
	
		#print "stats for hostnode " + self.hostName + ":\n"
		
		vzCmd = "/usr/sbin/vzlist -Ha -o ctid,ip,hostname,name"

		vzRun = subprocess.Popen(vzCmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                stdout_value, stderr_value = vzRun.communicate()

		for VPS in stdout_value.splitlines():
			buildVPS = VPS.split()
			newVzVps = vzVps(buildVPS[0], buildVPS[1], buildVPS[2], buildVPS[3])
			self.vpsList.append(newVzVps)
			newVzVps.getBytes()
			newVzVps.createRRD()
		
		self.clearIptables()

		
	def clearIptables(self):
		iptCmd = "/sbin/iptables -Z"
		iptRun = subprocess.Popen(iptCmd, shell=True)


class vzVps:
	def __init__(self, vzID, ipAddr, vzHostName, vzName):
		self.vzID = vzID
		self.ipAddr = ipAddr
		self.vzHostName = vzHostName
		self.vzName = vzName
		self.srcBytes = 0 
		self.dstBytes = 0 
	
	def createRRD(self):
		
		rrdName = "/root/stuff/python/" + self.vzID + "vzbw.rrd"

		if not os.path.isfile(rrdName):
			rrdtool.create(rrdName, "--step", "300", "DS:srcbw:ABSOLUTE:600:U:U", "DS:dstbw:ABSOLUTE:600:U:U", "RRA:AVERAGE:0.5:1:120960") 
		
		rrdtool.update(rrdName, "N:" + self.srcBytes + ":" + self.dstBytes )
		#rrdtool.update(rrdName, "--template", "dstbw", "N:" + self.dstBytes )		
			
		rrdtool.graph(rrdName + ".png",
              		'--imgformat', 'PNG',
              		'--width', '540',
              		'--height', '100',
              		'--title', 'Data Throughput',
              		'--lower-limit', '0',
              		'DEF:incoming=' + rrdName + ':dstbw:AVERAGE',
			'DEF:outgoing=' + rrdName + ':srcbw:AVERAGE',
			'CDEF:kbin=incoming,1024,/',
    			'CDEF:kbout=outgoing,1024,/',
    			'VDEF:inpct=incoming,95,PERCENT',
			'VDEF:outpct=outgoing,95,PERCENT',
			'AREA:incoming#00FF00:Bandwidth In', 
			'LINE1:outgoing#0000FF:Bandwidth Out\j',
    			'GPRINT:kbin:LAST:Last Bandwidth In\:    %3.2lf KBps', 
			'GPRINT:kbout:LAST:Last Bandwidth Out\:   %3.2lf KBps\j',
    			'GPRINT:kbin:AVERAGE:Average Bandwidth In\: %3.2lf KBps', 
			'GPRINT:kbout:AVERAGE:Average Bandwidth Out\:%3.2lf KBps\j')
			
		scpCmd = "/usr/bin/scp /root/stuff/python/*.png node1:/root/stuff/python/"

                scpRun = subprocess.Popen(scpCmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

	
	def getBytes(self):
		iptCmd = "/sbin/iptables -L -nvx | grep ACCOUNT | grep " + self.ipAddr

       		iptRun = subprocess.Popen(iptCmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
       		stdout_value, stderr_value = iptRun.communicate()

       		iptRules = stdout_value.splitlines()
		
		#print "stats for CTID " + self.vzID + ":"
		
       		for iptRule in iptRules:
               		if iptRule.split()[7] == self.ipAddr:
                       		#print "src bytes: " + iptRule.split()[1]
               			self.srcBytes = iptRule.split()[1]
			elif iptRule.split()[8] == self.ipAddr:
                       		#print "dst bytes: " + iptRule.split()[1]
				self.dstBytes = iptRule.split()[1]
		#print ""	
			
def main():

	this_vzHost = vzHost()
		
	
	
main()
