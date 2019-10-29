param
(
    [string]$vsGenerator="Visual Studio 15 2017 Win64",
    [string]$vsToolset="v141"
)

$env:Path += ";C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin"
echo "Downloading Csound dependencies..."
echo "vsGenerator: $vsGenerator"
echo "vsToolset:   $vsToolset"

$startTime = (Get-Date).TimeOfDay

# Add different protocols to get download working for HDF5 site
# ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls12 | SecurityProtocolType.Ssl3;
[System.Net.ServicePointManager]::SecurityProtocol =  [System.Net.SecurityProtocolType]::Tls12;

$webclient = New-Object System.Net.WebClient
$currentDir = Split-Path $MyInvocation.MyCommand.Path
$cacheDir = $currentDir + "\cache\"
$depsDir = $currentDir + "\deps\"
$stageDir = $currentDir + "\staging\"
$depsBinDir = $depsDir + "bin\"
$depsLibDir = $depsDir + "lib\"
$depsIncDir = $depsDir + "include\"
$csoundDir = $currentDir + "\.."
$vcpkgDir = ""


# Metrics
$vcpkgTiming = 0
$buildTiming = 0
$cmakeTiming = 0

# Add to path to call tools
$env:Path += $depsDir

# Find VCPKG from path if it already exists
# Otherwise use the local Csound version that will be installed
$systemVCPKG = $(Get-Command vcpkg -ErrorAction SilentlyContinue).Source

# Generate VCPKG AlwaysAllowDownloads file if needed
New-Item -type file $vcpkgDir\downloads\AlwaysAllowDownloads -errorAction SilentlyContinue | Out-Null

$systemVCPKG = $(Get-Command vcpkg -ErrorAction SilentlyContinue).Source
echo "System VCPKG"
echo $systemVCPKG

# Download all vcpkg packages available
echo "Downloading VC packages..."
# Target can be arm-uwp, x64-uwp, x64-windows-static, x64-windows, x86-uwp, x86-windows-static, x86-windows
$targetTriplet = "x64-windows"
$targetTripletStatic = "x64-windows-static"
#vcpkg --triplet $targetTriplet install eigen3 fltk zlib 
#vcpkg --triplet $targetTripletStatic install libflac libogg libvorbis libsndfile
vcpkg --triplet $targetTripletStatic install libflac libogg libvorbis libsndfile pthreads[core]:x64-windows
$vcpkgTiming = (Get-Date).TimeOfDay

dir  
cd c:/
Invoke-WebRequest -Uri "https://github.com/rorywalsh/cabbage/releases/download/v2.0.00/csound-windows_x64-6.13.0.zip" -OutFile "C:\csound-windows_x64-6.13.0.zip" 
7z.exe x csound-windows_x64-6.13.0.zip -o"C:/Program Files"
cd "C:/Program Files/Csound6_x64"
dir
cd c:/
Invoke-WebRequest -Uri "https://cycling74.s3.amazonaws.com/download/max-sdk-8.0.3.zip" -OutFile "C:\max-sdk-8.0.3.zip"
7z.exe x C:\max-sdk-8.0.3.zip -o"C:\max-sdk"

cd D:/a/1/s/

mkdir build
cd build
cmake -G "Visual Studio 15 2017 Win64" .. -DMAX_SDK_ROOT=C:/max-sdk/max-sdk-8.0.3 -DVCPKG_PACKAGES_DIR=C:\vcpkg\packages -DBOOST_DIR="C:/Program Files/Boost/1.69.0/include/boost-1_69"
msbuild.exe Project.sln /property:Platform=x64 /property:Configuration=Release
mkdir D:/a/1/a/csound~/externals
mkdir D:/a/1/a/csound~/examples
mkdir D:/a/1/a/csound~/help


Copy-Item "D:/a/1/s/build/Release/csound~.mxe64" -Destination D:/a/1/a/csound~/externals/csound~.mxe64
Copy-Item "D:/a/1/s/examples/*" -Destination D:/a/1/a/csound~/examples
Copy-Item "D:/a/1/s/help/*" -Destination D:/a/1/a/csound~/help
