#!/usr/bin/python
# -*- coding: utf-8 -*-

https://gist.github.com/bernardomaciel/380af5e1cc235eb0103634f7e018a035"""delete_seen_shows.py: Delete shows marked as seen at least 15 days ago in Kodi."""

import json
import httplib
import os
import argparse
import logging


def main():
    logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s',
                        filename='/home/osmc/.raspberry-osmc-automated/logs/delete_seen_shows.log', level=logging.INFO)
    args = getParsedArguments()
    seen_episodes = getSeenEpisodesFromRPC(args.host)

    for episode in seen_episodes:
        if args.delete and args.host == 'localhost':
            if deleteFileAndSubtitle(episode['file'].encode('utf-8'), args.dryrun):
                logging.info("Deleted episode " +
                             episode['title'].encode('utf-8'))
        else:
            printEpisode(episode)

    show_count = len(seen_episodes)
    logging.info("TOTAL: " + str(show_count))

    # After deleting all files the DB needs to refresh the changes.
    if args.delete and not args.dryrun:
        cleanLibraryDatabase(args.host)


def getParsedArguments():
    """
    Returns the parsed arguments given in the command line
    """

    parser = argparse.ArgumentParser(
        description='Lists all TV Shows marked as seen and allows to delete them')

    # Optional arguments
    parser.add_argument('-d', '--delete',
                        action='store_true',  # Allows this argument to behave like a flag
                        help='Delete files and subtitles of seen TV shows. Ignored when using the flag --host'
                        )
    parser.add_argument('-H', '--host',
                        help="""Hostname or IP of a remote machine running the Kodi JSON-RPC service.
                      Remote deletion of files through the RPC service is not suported. Ignores
                      flag --delete if present.""",
                        default="localhost"
                        )
    parser.add_argument('-r', '--dryrun',
                        action='store_true',  # Allows this argument to behave like a flag
                        help='Do not delete anything, just print what would be deleted.',
                        default=False
                        )
    args = parser.parse_args()
    return args


def printEpisode(episode):
    logging.info("--")
    logging.info(episode['label'].encode('utf-8'))
    logging.info(episode['file'].encode('utf-8'))
    logging.info("Last played: " + episode['lastplayed'])
    logging.info("Play count: " + str(episode['playcount']))


def deleteFileAndSubtitle(file, dryrun=False):
    try:
        logging.info(file)
        if not dryrun:
            os.remove(file)
            isDeleted = True
        else:
            isDeleted = True

    except OSError as e:
        logging.error(e)
        isDeleted = False

    try:
        # Delete subtitle if present:
        basename = os.path.splitext(file)[0]
        subtitle = basename + ".srt"
        if os.path.isfile(subtitle) and not dryrun:
            os.remove(subtitle)

    except OSError as e:
        logging.error(e)

    return isDeleted


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
    }), {
        "Content-Type": "application/json"
    })

    response = connection.getresponse()
    if 200 == response.status:
        responseObject = json.loads(response.read())

        if 'episodes' in responseObject['result']:
            return responseObject['result']['episodes']
        else:
            logging.error('No shows match the minimum criteria')
    else:
        logging.error('Impossible to retrieve episodes from %r' % rpc_host)

    return []


def cleanLibraryDatabase(rpc_host='localhost'):
    connection = httplib.HTTPConnection(rpc_host, 80)
    connection.connect()
    connection.request('POST', '/jsonrpc', json.dumps({
        "jsonrpc": "2.0",
        "method": "VideoLibrary.Clean",
        "id": "libTvShows"
    }), {
        "Content-Type": "application/json"
    })

    response = connection.getresponse()
    if 200 != response.status:
        logging.error('Could not clean database on %r' % rpc_host)


if __name__ == "__main__":
    main()
