import socket
import json

data = {'location': {'lat': '51.271904', 'lng': '30.226622'}, 'accuracy': '19.50'}
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('172.24.0.2', 1979))
s.send(json.dumps(data))
result = json.loads(s.recv(1024))
print data
s.close()
