import json,httplib

def main():
  for path in listSeenShowsPaths():
    print path

def listSeenShowsPaths():
  files = []
  connection = httplib.HTTPConnection('192.168.1.135', 80)
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
      "limits": {
        "start": 0,
        "end": 50
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
      

  return files


if __name__ == "__main__":
    main()
