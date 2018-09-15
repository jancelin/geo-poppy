import SocketServer
import json
import os
import subprocess
import commands

class MyTCPServerHandler(SocketServer.BaseRequestHandler):
        
        def handle(self):
               
            try:
                data = json.loads(self.request.recv(1024).strip())
                print data
                self.request.sendall(json.dumps(data))
            except Exception, e:
                print "Exception wile receiving message: ", e

server = SocketServer.TCPServer(("", 1950), MyTCPServerHandler)
print '=== WE ARE LIVE ==='
server.serve_forever()
