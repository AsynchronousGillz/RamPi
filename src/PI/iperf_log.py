#!/usr/bin/env python3

import argparse
import json
import os
import sys
import socket

hostName = str(socket.gethostname()).rsplit('.')[0]

def get_filepaths(directory):
    file_paths = []
    for root, directories, files in os.walk(directory):
        for filename in files:
            filepath = os.path.join(root, filename)
            file_paths.append(filepath)
    return file_paths

parser = argparse.ArgumentParser()
parser.add_argument("directory", type=str, help="The directory where the json output of an iperf3 test.")
args = parser.parse_args()

if not os.path.isdir(args.directory):
    print("  error: directory not found.")
    os.exit()

fileList = get_filepaths(args.directory)

output_start = "{{\n\"{}\": {{".format(hostName)
output = output_start

for fileName in fileList:
    with open(fileName) as data_file:
        if output != output_start:
            output += ", "
        data = json.load(data_file)
        if '_' not in fileName:
            print("  error: invalid filename found. {}".format(fileName))
            os.exit()
        device_value = int(fileName.rsplit('_')[1].rsplit('.')[0]) 
        if device_value < 10:
            device_value = "0" + str(device_value)
        short_fileName = "\"" + str(device_value) + "\": "
        if 'end' not in data and 'sum' not in data and 'lost_percent' not in data:
            output += short_fileName + '-1'
        else:
            output += short_fileName + str(data['end']['sum']['lost_percent'])
output += "}\n}"

print(output)

