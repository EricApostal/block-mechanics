from flask import Flask
from flask import request
import os
import time
import requests

app = Flask(__name__)

def _getChunk(x,y):
    filename = f"c{x},{y}.txt"

    f = open(f"requests/{filename}", "w")
    f.write("")
    f.close()
    
    print("Waiting for chunk gen")
    while not os.path.isfile(f"responses/{filename}"):
        time.sleep(0.1)

    print("Chunk gen happened!")
    fileContent = ''
    while fileContent == '':
        fileContent = open(f'responses/{filename}').read()

    # os.remove(f"responses/{filename}")
    return fileContent

@app.route('/chunk')
def getChunk():
    x = request.args.get('x')
    y = request.args.get('y')
    if x == None or y == None:
        return "Invalid URL params"

    return _getChunk(x,y)

@app.route('/chunkgroup')
def getChunkGroup():
    chunksIn = request.args.getlist("chunk")
    chunksOut = {}
    for chunk in chunksIn:
        x,y = chunk.split(",")
        chunksOut[chunk] = _getChunk(x,y)
        
    return chunksOut

if __name__ == '__main__':
    app.run(port=8080,host="0.0.0.0")
