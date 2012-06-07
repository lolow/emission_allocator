# Space-Time Emission Allocation of annual sectoral emissions for Austal2000

This script is generating time series of emission strength (g/s-1) for austal2000 (http://www.austal2000.de),
an atmospheric dispersion model for simulating the dispersion of air pollutants in the ambient atmosphere.
Annual/episode (several days) emissions are
*   distributed in space according to sectoral distribution maps,
*   distributed in time according to sectoral time profile.

The script collects the sectoral distribution maps and create a source map which covers all of them.
Every grid cell of the source map will be defined as emission source areas in *austal.txt*.
Emissions sources and their strenght are generated in the file *series.dmna*.
Extra sources can be also defined manually, see the section above for details.

From an existing working directory of AUSTAL2000, the files *austal.txt* and *series.dmna* can be used as template,
simply rename them as *austal.txt.src* and *series.dmna.src*. The definition files (time profile, maps, emissions)
should be located in a separate directory.

This script is used by the Luxembourg Energy Air Quality LEAQ model (http://crteweb.tudor.lu/leaq).

## Requirements

*   Ruby environment (ruby 1.9.2 or higher)
*   Austal2000 input files to be completed
*   austal2000.txt source containing at list the following parameters
    *    gh : filename of the DEM (austal calculation domain)
    *    pollutants (nox, voc, no, no2, so2, co, pm-1, pm-2, o3)
*   series.dmna source
    *   the header must contain (hghb : number of time interval)
    *   the body must contain the list of time steps
*   Sectoral distribution maps : spatial density maps
*   Sectoral time profiles (yml format) : monthly,daily,hourly shares
*   Sectoral annual emissions (yml formal) : ton/year

## Usage


    Usage: emissions.rb conf.yml [options]

    Specific options:
        -v, --[no-]verbose               Run verbosely
        -m, --[no-]maps                  Generate emission maps
        -e, --emission TYPE              (annual [default],episode)
        -f, --[no-]details               Compute sectoral emission of the episode
        -a, --austal-src FILE            Default: austal2000.txt.src
        -d, --dmna-src FILE              Default: series.dmna.src
        --austal-out FILE                Default: austal2000.txt
        -y, --dmna-out FILE              Default: series.dmna
        -w, --write-emi FILE             Default:
        -i, --input DIR                  Default: conf.yml path
        -o, --output DIR                 Default: current dir
        -x, --extra-src FILE             Where each row contains space-separated values with header:
                                             xq yq aq bq [nox voc no no2 so2 co pm-1 pm-2 o3]
        -s, --sector x,y,z               Specify a list of sectors
                                             example: tra,prd,ind
    Common options:
        --version                        Show version
        -h, --help                       Show this message


## Emission maps

The sectoral maps are ESRI raster maps as follows:

    ncols 4
    nrows 4
    xllcorner 800000
    yllcorner 9000000
    cellsize 10000
    NODATA_value -9999
    -9999 1     -9999 -9999
    -9999 1     1     1
    -9999 -9999 1     0.5
    -9999 -9999 -9999 0.5

The sum of the grid cell does need to be equal to 1, the script normalizes itself the map.

## Time profiles

The time profiles are yml files of the following form:

    ---·
    :hourly:·
      :annual:·
      - 0.03
      - 0.03
      - 0.029
      - 0.030
      - 0.033
      - 0.038
      - 0.045
      - 0.049
      - 0.050
      - 0.050
      - 0.050
      - 0.048
      - 0.047
      - 0.047
      - 0.047
      - 0.045
      - 0.044
      - 0.043
      - 0.042
      - 0.042
      - 0.042
      - 0.04
      - 0.036
      - 0.032
    :monthly:
    - 0.09
    - 0.09
    - 0.07
    - 0.07
    - 0.07
    - 0.08
    - 0.07
    - 0.06
    - 0.07
    - 0.09
    - 0.10
    - 0.09
    :daily:
      :annual:
      - 0.14
      - 0.15
      - 0.15
      - 0.15
      - 0.15
      - 0.12
      - 0.11

An homogenous distribution can be easily generated in ruby. Type the following in irb to create a file *profile.yml*:

      require 'yaml'
      profile = {hourly:{annual:[1.0/24]*24},monthly:[1.0/12]*12,daily:{annual:[1.0/7]*7}}
      File.new('profile.yml','w').write(profile.to_yaml)

*:hourly* defines the hourly profile. It is a hash {key:array}, where key is *:annual* for a annual profile or
*:winter*, *:summer* and *:midseason* for seasonnal profile. The array(s) contain 24 values for each hour, as
[1sth hour, 2nd hour, 3rd hour, ..., 24th hour]. The sum per array must be equal to 1.

*:monthly* defines the monthly profile. The array contain 12 values for each month, as [January, February, ...,
December]. Its sum must be equal to 1.

*:daily* defines the daily profile. It is a hash {key:array}, where key is *:annual* for a annual profile or
*:winter*, *:summer* and *:midseason* for seasonnal profile.
The array(s) contain 24 values for each weekday, as [Monday, Tuesday, ..., Sunday].
Sum per array must be equal to 1.

## Emission file

The emission file contains the information about sectors, files and emissions. Look at the following example:

    ---
    sectoral_maps:
      snap1: land_cover_snap1.asc
      snap2: land_cover_snap2.asc
    time_allocation:
      snap1: profile_snap1.yml
      snap2: profile_snap1.yml
    sectoral_emissions:
      snap1:
        nox: 1035
        voc: 28
      snap2:
        nox: 16
        voc: 1

The emissions are expressed in ton, and by default, are expressed in ton per year. If the type of emission
is defined as "episode" (with the parameter -e), the emissions are the total emissions over the time serie
defined in the $series.dmna.src$ template


## Extra sources

Extra sources are manually defined by the user. It allows to define emission sources bigger than the size of the source
map grid cells.

In a text file with space-separated values, the header contains the name of the source, the coordinates xq, yq, aq, bq
as defined by AUSTAL2000, then the pollutants. When the pollutant is postfixed with '~' + the sector name, the
value is expressed in tonne per year and will be distributed in time according to the sector time profile.

    name xq    yq     aq    bq   voc~snap1 voc~snap2 nox~snap1 nox~snap2
    S1   12718 13011  12700 2300 32        610       29        415
    S2   22718 55611  34000 8300 59        296       34        775
    S3   12718 40611  12700 1500 124       996       145       1091

Otherwise when the pollutant is just written, the value are expressed in gram per second and will be used at every timestep.

    name xq    yq     aq    bq   voc  nox
    S1   12718 13011  12700 2300 0.01 10
    S2   22718 55611  34000 8300 6    86
    S3   12718 40611  12700 1500 12   6

## Authors

*    Laurent Drouet: ldrouet at gmail.com
*    Lara Aleluia Reis: lara.aleluia at tudor.lu

## Copyright

The code is licensed to the MIT License (MIT). See the LICENSE file for the full license. 
Copyright (c) 2011-2012 Public Research Center Henri Tudor

