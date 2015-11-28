#!/usr/bin/python
# -*- coding: utf-8 -*-

import json
import httplib
import os
import argparse
import logging

def main():
  args = getParsedArguments()
  seen_episodes = getSeenEpisodesFromRPC(args.host)

  for episode in  seen_episodes:
    if args.delete and args.host == 'localhost':
      if deleteFileAndSubtitle( episode['file'].encode('utf-8') ):
        print "[OK] Deleted episode " + episode['title'].encode('utf-8')
    else:
      printEpisode( episode )

  show_count = len(seen_episodes)
  print "TOTAL: "  + str(show_count)

def getParsedArguments():
  """
  Returns the parsed arguments given in the command line
  """

  parser = argparse.ArgumentParser(
    description='Lists all TV Shows marked as seen and allows to delete them')

  # Optional arguments
  parser.add_argument('-d', '--delete',
                      action='store_true', # Allows this argument to behave like a flag
                      help='Delete files and subtitles of seen TV shows. Ignored when using the flag --host'
                      )
  parser.add_argument('-H', '--host',
                      help="""Hostname or IP of a remote machine running the Kodi JSON-RPC service.
                      Remote deletion of files through the RPC service is not suported. Ignores
                      flag --delete if present.""",
                      default="localhost"
                      )
  args = parser.parse_args()
  return args


def printEpisode(episode):
    print "--"
    print episode['label'].encode('utf-8')
    print episode['file'].encode('utf-8')
    print "Last played: " + episode['lastplayed']
    print "Play count: " + str( episode['playcount'])

def deleteFileAndSubtitle(file):
  try:
    print(file)
    isDeleted = os.remove(file)

    # Delete subtitle if present:
    basename = os.path.splitext(file)[0]
    subtitle = basename + ".srt"
    if os.path.isfile(subtitle):
      os.remove(subtitle)

    return isDeleted
  except OSError as e:
    logging.error(e)
    return False


def getSeenEpisodesFromRPC(rpc_host='localhost'):
  """
  Retrieves from Kodi JSON-RPC service the list of episodes
  marked as seen and not played in the last month (avoids
  immediate deletion)
  """

  connection = httplib.HTTPConnection(rpc_host, 80)
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
            "value": "15 days"
          },
          {
            "field": "playcount",
            "operator": "greaterthan",
            "value": "0"
          }
        ]
      },
      "properties": [
        "title",
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

    if ('episodes' in responseObject['result'] ):
      return responseObject['result']['episodes']
    else:
      logging.error('No shows match the minum criteria')
  else:
    logging.error('Impossible to retrieve episodes from %r' % rpc_host  )

  return []


if __name__ == "__main__":
    main()
