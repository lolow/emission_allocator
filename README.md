# Space-Time Emission Allocation of annual sectoral emissions for Austal2000

## Requirements:

*   Red
*   Ruby environment (works with ruby 1.8.7, ruby 1.9.2, jruby 1.5.6)
*   Austal2000 input files to be completed
*   austal2000.txt source containing at list the following parameters
    *    gh : filename of the DEM (austal calculation domain)
    *    pollutants (nox, voc, o3)
*   series.dmna source
    *   the header must contain (hghb : number of time interval)
    *   the body must contain the list of time steps
*   Emission sources map in grid-ascii format : all cells but NODATA's
*   Sectoral distribution maps : factors from ton to gramme/cell [cells sum should be equal to 10^6]
*   Sectoral time profile (yml format) : monthly,daily,hourly shares
*   Sectoral annual emission (yml formal) : ton/year

## Usage:

<code>
Usage: emissions.rb conf.yml [options]

Specific options:
    -v, --[no-]verbose               Run verbosely
    -m, --[no-]maps                  generate emission maps
    -e, --emission TYPE              (annual [default],episode)
    -f, --[no-]details               compute sectoral emission of the episode
    -a, --austal-src FILE            Default: austal2000.txt.src
    -d, --dmna-src FILE              Default: series.dmna.src
        --austal-out FILE            Default: austal2000.txt
    -y, --dmna-out FILE              Default: series.dmna
    -w, --write-emi FILE             Default: 
    -i, --input DIR                  Default: conf.yml path
    -o, --output DIR                 Default: current dir
    -x, --extra-src FILE             where each row contains space-separated values with header:
                                     xq yq aq bq [nox voc no no2 so2 co pm-1 pm-2 o3]
    -s, --sector x,y,z               Specify a list of sectors
                                       example: tra,prd,ind

Common options:
        --version                    Show version
    -h, --help                       Show this message
</code>

## Authors

Laurent Drouet: ldrouet at gmail.com
Lara Aleluia Reis: lara.aleluia at tudor.lu

## Copyright

The code is licensed to the MIT License (MIT). See the LICENSE file for the full license. 
Copyright (c) 2011 Public Research Center Henri Tudor
