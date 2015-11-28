#!/usr/bin/python
# -*- coding: utf-8 -*-

import json,httplib,os,sys,argparse

def main():
  args = getArguments()
  print 'List of episodes marked as seen:'
  for path in listSeenShowsPaths(args.host):
    if args.delete:
      print "Deleting " + path
      # delete(path)
    print path
  
def getArguments():
  """
  Returns the list of arguments passed
  """
  
  parser = argparse.ArgumentParser(
    description='Lists all files associated to TV Shows marked as seen not played in the last month')
  
  # Optional arguments
  parser.add_argument('-d', '--delete',
                      action='store_true', # Allows this argument to behave like a flag
                      help='Delete all matching files'
                      )
  parser.add_argument('-H', '--host',
                      help='hostname or IP of the machine running the RPC service',
                      default="localhost"
                      )  
  args = parser.parse_args()
  return args


def delete(file):
  return os.remove(path)

def listSeenShowsPaths(Kodi_host='localhost'):
  files = []
  connection = httplib.HTTPConnection(Kodi_host, 80)
  connection.connect()
  connection.request('POST', '/jsonrpc', json.dumps({
    "jsonrpc": "2.0",
    "method": "VideoLibrary.GetEpisodes",
    "params": {
      "filter": {
        "and": [
          {
            "field": "lastplayed",
            "operator": "notinthelast",
            "value": "month"
          },
          {
            "field": "playcount",
            "operator": "greaterthan",
            "value": "0"
          }
        ]
      },
      "properties": [
        "playcount",
        "lastplayed",
        "file"
      ],
      "sort": {
        "order": "ascending",
        "method": "label"
      }
    },
    "id": "libTvShows"
  }),{
    "Content-Type": "application/json"
  })
  response = connection.getresponse()
  if ( 200 == response.status ):
    responseObject = json.loads(response.read())
    for item in responseObject['result']['episodes']:
      files.append( item['file'] )
  else:
    print 'Impossible to retrieve episodes from %r' % Kodi_host
      

  return files


if __name__ == "__main__":
    main()
