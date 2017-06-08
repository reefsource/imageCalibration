import re
import sys

def dms2dd(degrees, minutes, seconds):
    print (degrees, minutes, seconds)
    dd = float(degrees) + float(minutes)/60 + float(seconds)/(60*60)
    return dd

def parse_dms(dms):
    parts = re.split('^(-?\d+) deg (\d+)\' (\d+\.\d+)"$', dms)
    lat = dms2dd(parts[1], parts[2], parts[3])

    return lat

if __name__ == '__main__':

    #26 deg 9' 36.00"
    print parse_dms(sys.argv[1].strip())