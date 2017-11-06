# EQ ORFEUS

This package is a wrap up tool to collect broadband data from ORFEUS.
It first use [ORFEUS webservices](https://www.orfeus-eu.org/data/eida/webservices/) to download both waveform data and station metadata (xml format). Then the station xml metadata is converted to dataless seed file using a java tool maintained by [IRIS](https://seiscode.iris.washington.edu/projects/stationxml-converter/files). After this, the waveform data and dataless seed data is combined with rdseed to produce sac format data for all three components, corresponding to thress sac file.

# Usage
Parameters are specified in `./INFILE`

To execute the code:
```shell
csh c00.mother.sh
```

The collected data is stored under `./DATADIR/${YEAR}/${event_name}`


# Notes:

### Event List 
Events to collect is specified under `./support/big_list.EQ.1994_20171025`, the default file contains all events from 1994 to Oct. 25th 2017 with magnitude > 6.
### Data Detail
Currently for each event, we are collecting 2 hour time series for all three component

If not all three components are found, the station gets rejected
### Output file format
The output file is in sac format, each station has three corresponding sac file. The corresponding metadata of each station is stored in the same directory as the sac file in `eventStation.${event_name}`
Each column of the eventStation file is explained below:
1. Station Name
2. Network Name
3. Distance
4. "DEGREE"
5. Azimuth
6. "deg"
7. Back Azimuth
8. "deg"
9. Station Latitude
10. Station Longitude
11. Event Latitude
12. Event Longitude
13. Event Depth
14. "km"
15. "mww"
16. Event Magnitude
17. "VEBSN"
18. "EIDA"
19. Event Name

