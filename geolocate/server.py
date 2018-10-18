import SocketServer
import json
import os
import subprocess
import commands

class MyTCPServerHandler(SocketServer.BaseRequestHandler):
        
    json_file = '/usr/src/app/data.json'     

    def handle(self):
        # Get the JSON data...return the ESSIDS (their respective MAC addresses and the signal strength)
        #self.data = json.loads(self.request.recv(1024).strip())
        #self.data = self.request.recv(1024).strip()
        #self.request.sendall(json.dumps({'location': {'lat': self.latitude, 'lng': self.longtitude}, 'accuracy': self.accuracy}))
        #print json.dumps({'location': {'lat': self.latitude, 'lng': self.longtitude}, 'accuracy': self.accuracy})
        
        self.data = self.request.recv(1024).strip()
        print self.data
        json_data=open(self.json_file)
        print json_data
        data = json.load(json_data)
        print data
        self.request.sendall(json.dumps(data))
        print 'ok'
        

if __name__ == '__main__':
    # Just bind it.
    server = SocketServer.TCPServer(("", 1979), MyTCPHandler) # 1950 TORCIDA HAJDUK

    print '=== WE ARE LIVE_ ==='

    # Forever yours, of course until you bash ^C
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        exit('^C received, exiting...')
   
            
