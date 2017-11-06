# EQ ORFEUS

# Usage
Parameters are specified in `./INFILE`



# Notes:

### Event List 
Events to collect is specified under `./support/big_list.EQ.1994_20171025`, the default file contains all events from 1994 to Oct. 25th 2017 with magnitude > 6.
### Data Detail
Currently for each event, we are collecting 2 hour time series for all three component

If not all three components are found, the station gets rejected
### Output file format
The output file is in sac format, each of the sac file has a corresponding metadata entry stored in the same directory under `eventStation.${event_name}`
Each column of the eventStation file is explained below:
1. Station Name
2. Network Name
3. Distance
4. 
5. Azimuth
6.
7. Back Azimuth
8. 
9. Station Latitude
10. Station Longitude
11. Event Latitude
12. Event Longitude
13. Event Depth
14. 
15. 
16. Event Magnitude
17. 
18. 
19. Event Name

