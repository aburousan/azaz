+++
title = "virtools: A tool for radiometric calibration of DAWN VIR data"
hascode = true
rss = "In this blog, we will understand how to use the package for radiometric calibration."
rss_pubdate = Date(2025, 8, 4)

tags = ["physics", "spectroscopy", "Numerical Methods", "Radiometry", "NASA", "Planetary Science"]
+++

\toc

\newcommand{\col}[2]{~~~<span style="color:~~~#1~~~">~~~!#2~~~</span>~~~}

# virtools: A tool for Radiometric Calibration of DAWN VIR data
The  **\col{purple}{DAWN VIR}** Calibration Package is essential for transforming raw data collected by the Visible and Infrared Spectrometer (VIR) onboard NASA's DAWN spacecraft into scientifically meaningful and physically accurate measurements.

The VIR instrument, which observed planetary bodies like Vesta and Ceres, records radiance data in **\col{red}{digital numbers (DN)}** that are affected by various instrumental and environmental artifacts. These include detector noise, dark current, stray light, bad pixels, spectral misalignments, and radiometric inconsistencies.

Without calibration, the raw data from VIR are not directly usable for scientific analysis, as they do not accurately represent the **\col{blue}{surface reflectance of the observed bodies}**.

The calibration package provides a suite of algorithms and correction procedures—often derived from both pre-flight laboratory characterizations and in-flight observations—that convert these raw measurements into radiometrically calibrated, artifact-corrected data products. These are suitable for applications such as mineralogical mapping, thermal modeling, surface composition studies, and planetary geophysics.

In short, **the calibration package is a critical preprocessing step that ensures data fidelity, enabling reliable interpretation of planetary surfaces and supporting high-quality scientific research.**

--With calibrated sight and spectral flame,
We cut through the lies that corrupt the light.
Stand tall, like a Hashira of knowledge—
Power up… and let this cosmic battle begin!

\poem{
**Through Vesta’s glow and Ceres’ shade,\\
The VIR spectrometer softly played.\\
But raw the light, not clean nor bright,\\
Masked by noise that veils the sight.\\
\\
Dark current flowed beneath each scan,\\
Artifacts danced where truth began.\\
Odd-even shifts broke spectral grace,\\
And radiance lost its rightful place.\\
\\
Yet code arose, both sharp and wise,\\
To lift the veil from distant skies.\\
Corrected spectra, clear and grand,\\
Revealed the story in rock and sand.\\
\\
Now calibrated, pure and wide,\\
The data sings of time and tide.\\
In every cube, a tale made right—\\
A world reborn in measured light.\\
\\
But the path ahead extends afar,\\
Each fix a step, not final star.\\
No end to truth, no perfect scheme—\\
Just clearer maps of a deeper dream.\\
\\
So start with code both clear and small,\\
Though simple, it may yet reveal all.\\
For in this sea without a shore,\\
Each better answer calls for more.**

--K.A.Rousan
}


\note{
    virtools is a python-package developed by myself. To use download it from [github](https://github.com/aburousan/virtools) or follow this blog.
}
## Introduction to the Data and it's format
To use the package, we first have to know what is the data we are working with. **\col{red}{VIR}** actually uses the pushbroom method to capture images of the ceres surface in different wavelengths.
~~~
<div class="row">
  <div class="container">
    <div style="display: flex; flex-wrap: wrap; justify-content: space-between;">
      <img class="plot" src="/assets/Physics/blogs/virtools_blog/push_broom.png" style="max-width: 48%; height: auto;">
      <img class="plot" src="/assets/Physics/blogs/virtools_blog/hyper_spec.png" style="max-width: 48%; height: auto;">
    </div>
    <div style="clear: both;"></div>      
  </div>
</div>
~~~
The left image is a diagram to show pushbroom method. There, we can see a detector array. This array actually take a image along it's length and then it is moved in a direction perpendicular to it's length giving us the image of the surface. The detector has many small detectors(pixels). Those are called **\col{purple}{samples}**. This value is obviously fixed ($s=256$). As the detector moves, it takes images. Each of these are called **\col{purple}{lines}** (in the diagram the rectangular patches on ground). This number is not constant, it can vary data file to data file.

The data is stored for $b=432$ different wavelengths, i.e., the image is taken for $432$ different wavelengths. We can think the data as different images (sample & line) for different wavelengths stacked together. So, the image is sort of like **\col{red}{cube}** as shown in the previous image. One axis is **\col{blue}{band axis}**, one is **\col{blue}{sample axis}** and other is **\col{blue}{sample axis}**. So, if I store the cube file data as an numpy array `C`, then `C[b,s,l]` represent the value of data for band no. $b$, sample no. $s$ and line no. $l$.

| Type | Called|
|----- |-------|
| For fixed band `C[b,:,:]`    |  Image |
| For fixed sample `C[:,s,:]`  |  Slice |
| For fixed line `C[:,:,l]`    |  Frame |

When the device takes the data, It generates $4$ files:
1. .LBL file : This contains info about device name, target name, wavelengths, band index, SPICE file details, distance from sun and all other things. An example of the file is here.
```txt
PDS_VERSION_ID = PDS3                                                         
LABEL_REVISION_NOTE = "MTC_11-10-2011"                                        
                                                                              
/* Dataset and Product Information */                                         
DATA_SET_NAME = "DAWN VIR RAW (EDR) CERES INFRARED SPECTRA V1.0"              
DATA_SET_ID = "DAWN-A-VIR-2-EDR-IR-CERES-SPECTRA-V1.0"                        
PRODUCT_ID = "VIR_IR_1A_1_493156585"                                          
PRODUCT_TYPE = EDR                                                            
PRODUCER_FULL_NAME = "M. C. DE SANCTIS"                                       
PRODUCER_INSTITUTION_NAME = "ISTITUTO NAZIONALE DI ASTROFISICA"               
PRODUCT_CREATION_TIME = 2016-10-13T19:33:39.186                               
PRODUCT_VERSION_ID = "01"                                                     
                                                                              
/* File Information */                                                        
RECORD_TYPE = FIXED_LENGTH                                                    
RECORD_BYTES = 512                                                            
FILE_RECORDS = 15120                                                          
LABEL_RECORDS = 46                                                            
                                                                              
/* Time Information */                                                        
START_TIME = 2015-08-18T07:55:19.569                                          
STOP_TIME = 2015-08-18T08:07:59.799                                           
IMAGE_MID_TIME = 2015-08-18T08:01:39.684                                      
SPACECRAFT_CLOCK_START_COUNT = "1/493156585.1098"                             
SPACECRAFT_CLOCK_STOP_COUNT = "1/493157346.7980"                              
                                                                              
/* Mission description parameters */                                          
INSTRUMENT_HOST_NAME = "DAWN"                                                 
INSTRUMENT_HOST_ID = "DAWN"                                                   
MISSION_PHASE_NAME = "CERES SCIENCE HAMO (CSH)"                               
                                                                              
/* Instrument description parameters */                                       
INSTRUMENT_NAME = "VISIBLE AND INFRARED SPECTROMETER"                         
INSTRUMENT_ID = "VIR"                                                         
INSTRUMENT_TYPE = "IMAGING SPECTROMETER"                                      
                                                                              
/* Celestial Geometry                                       */                
RIGHT_ASCENSION                  =  279.965 <degrees>                         
DECLINATION                      =  -62.231 <degrees>                         
TWIST_ANGLE                      =  227.917 <degrees>                         
CELESTIAL_NORTH_CLOCK_ANGLE      =  312.083 <degrees>                         
QUATERNION                       = (  0.11612,                                
                                     -0.31567,                                
                                     -0.91802,                                
                                      0.21000 )                               
QUATERNION_DESC                  = "                                          
     Above parameters are calculated at the center time of the observation    
     which is 2015-08-18T08:01:39.684.  The quaternion has the form:          
     w, x, y, z (i.e. SPICE format)."                                         
                                                                              
/* Solar geometry                                          */                 
SPACECRAFT_SOLAR_DISTANCE        =   441765162.5 <km>                         
SC_SUN_POSITION_VECTOR           = ( -259675440.2 <km>,                       
                                      299958230.3 <km>,                       
                                      194294067.4 <km> )                      
                                                                              
SC_SUN_VELOCITY_VECTOR           = ( -13.502 <km/s>,                          
                                      -9.829 <km/s>,                          
                                      -1.718 <km/s> )                         
                                                                              
/* SPICE Kernels                                            */                
SPICE_FILE_NAME                  = "DAWN_CSH_R01.TM"                          
                                                                              
TARGET_NAME                      = "CAL LAMP"                                 
TARGET_TYPE                      = "CALIBRATION"                              
                                                                              
/* COORDINATE SYSTEM                                        */                
COORDINATE_SYSTEM_NAME           = "N/A"                                      
COORDINATE_SYSTEM_CENTER_NAME    = "N/A"                                      
                                                                              
/* Geometry in "IAU_VESTA" coordinates from SPICE         */                  
SUB_SPACECRAFT_LATITUDE          = "N/A"                                      
SUB_SPACECRAFT_LONGITUDE         = "N/A"                                      
SUB_SPACECRAFT_AZIMUTH           = "N/A"                                      
SPACECRAFT_ALTITUDE              = "N/A"                                      
TARGET_CENTER_DISTANCE           = "N/A"                                      
SC_TARGET_POSITION_VECTOR        = ( "N/A",                                   
                                     "N/A",                                   
                                     "N/A" )                                  
                                                                              
SC_TARGET_VELOCITY_VECTOR        = ( "N/A",                                   
                                     "N/A",                                   
                                     "N/A" )                                  
                                                                              
LOCAL_HOUR_ANGLE                 = "N/A"                                      
SUB_SOLAR_LATITUDE               = "N/A"                                      
SUB_SOLAR_LONGITUDE              = "N/A"                                      
SUB_SOLAR_AZIMUTH                = "N/A"                                      
                                                                              
/* Illumination                                             */                
INCIDENCE_ANGLE                  = "N/A"                                      
EMISSION_ANGLE                   = "N/A"                                      
PHASE_ANGLE                      = "N/A"                                      
                                                                              
/* Image parameters                                         */                
SLANT_DISTANCE                   = "N/A"                                      
MINIMUM_LATITUDE                 = "N/A"                                      
CENTER_LATITUDE                  = "N/A"                                      
MAXIMUM_LATITUDE                 = "N/A"                                      
WESTERNMOST_LONGITUDE            = "N/A"                                      
CENTER_LONGITUDE                 = "N/A"                                      
EASTERNMOST_LONGITUDE            = "N/A"                                      
HORIZONTAL_PIXEL_SCALE           = "N/A"                                      
VERTICAL_PIXEL_SCALE             = "N/A"                                      
NORTH_AZIMUTH                    = "N/A"                                      
ORBIT_NUMBER                     = "N/A"                                      
                                                                              
/* Data description parameters */                                             
PROCESSING_LEVEL_ID = "2"                                                     
DATA_QUALITY_ID = "1"                                                         
DATA_QUALITY_DESC = "0:INCOMPLETE; 1:COMPLETE"                                
TELEMETRY_SOURCE_ID = "EGSE"                                                  
CHANNEL_ID = "IR"                                                             
SOFTWARE_VERSION_ID = "EGSE V1.14,AMDLSpace"                                  
                                                                              
/* Instrument status */                                                       
INSTRUMENT_MODE_ID = "C_H_SPE_H_SPA_F"                                        
INSTRUMENT_MODE_DESC =                                                        
 "S_H_SPE_H_SPA_F: Science, high spectral high spatial, Full slit             
  S_H_SPE_L_SPA_F: Science, high spectral low spatial, Full slit              
  S_H_SPE_L_SPA_F_SUM: Science, high spectral low spatial, Summing            
  S_L_SPE_H_SPA_F: Science, Low spectral high spatial, Full slit              
  S_L_SPE_L_SPA_F: Science, Low spectral low spatial, Full slit               
  S_L_SPE_L_SPA_F_SUM: Science, Low spectral low spatial, Summing             
  S_H_SPE_H_SPA_Q: Science, high spectral high spatial, Quarter slit          
  S_L_SPE_H_SPA_Q: Science, low spectral high spatial, Quarter slit           
  S_H_SPE_L_SPA_F_MEA: Science, high spectral low spatial, Meaning            
  S_L_SPE_L_SPA_F_MEA: Science, low spectral low spatial, Meaning             
  C_H_SPE_H_SPA_F: Calibration, high spectral high spatial, Full slit         
  C_H_SPE_L_SPA_F: Calibration, high spectral low spatial, Full slit          
  SPARE: CALIBRATION Spare                                                    
  C_L_SPE_H_SPA_F: Calibration, low spectral high spatial, Full slit          
  C_L_SPE_L_SPA_F: Calibration, low spectral low spatial, Full slit           
  C_H_SPE_H_SPA_Q: Calibration, high spectral high spatial, Quarter slit      
  C_L_SPE_H_SPA_Q: Calibration, low spectral high spatial, Quarter slit"      
ENCODING_TYPE = "N/A"                                                         
SCAN_MODE_ID = "5"                                                            
DAWN:SCAN_PARAMETER = (0.1, 0.1, 0.26, 25)                                    
SCAN_PARAMETER_DESC = ("SCAN_START_ANGLE", "SCAN_STOP_ANGLE",                 
 "SCAN_STEP_ANGLE","SCAN_STEP_NUMBER")                                        
DAWN:SCAN_PARAMETER_UNIT = ("DEGREES", "DEGREES", "DEGREES", "DIMENSIONLESS") 
FRAME_PARAMETER = (0.0, 1, 20, 0)                                             
FRAME_PARAMETER_DESC = ("EXPOSURE_DURATION", "FRAME_SUMMING",                 
"EXTERNAL_REPETITION_TIME", "DARK_ACQUISITION_RATE")                          
DAWN:FRAME_PARAMETER_UNIT = ("S", "DIMENSIONLESS", "S", "DIMENSIONLESS")      
DAWN:VIR_IR_START_X_POSITION=0                                                
DAWN:VIR_IR_START_Y_POSITION=0                                                
MAXIMUM_INSTRUMENT_TEMPERATURE = (84.5, 135.6, 136.6, 79.0)                   
INSTRUMENT_TEMPERATURE_POINT = ("FOCAL_PLANE", "TELESCOPE", "SPECTROMETER",   
"CRYOCOOLER")                                                                 
DAWN:INSTRUMENT_TEMPERATURE_UNIT = ("K", "K", "K", "K")                       
PHOTOMETRIC_CORRECTION_TYPE = "NONE"                                          
                                                                              
/* Pointers to first record of objects in file */                             
^HISTORY = 48                                                                 
OBJECT = HISTORY                                                              
END_OBJECT = HISTORY                                                          
^QUBE = "VIR_IR_1A_1_493156585_1.QUB"                                         
                                                                              
/* Description of the object contained in the file */                         
OBJECT = QUBE                                                                 
                                                                              
/*    Standard cube Keywords */                                               
 AXES = 3                                                                     
 AXIS_NAME = (BAND, SAMPLE, LINE)                                             
 CORE_ITEMS = ( 432, 256, 35 )                                                
 CORE_ITEM_BYTES = 2                                                          
 CORE_ITEM_TYPE = MSB_INTEGER                                                 
 CORE_BASE = 0.0                                                              
 CORE_MULTIPLIER = 1.0                                                        
 CORE_VALID_MINIMUM = 0                                                       
 CORE_NULL = -32768                                                           
 CORE_LOW_REPR_SATURATION = -32767                                            
 CORE_LOW_INSTR_SATURATION = -32767                                           
 CORE_HIGH_REPR_SATURATION = -32767                                           
 CORE_HIGH_INSTR_SATURATION = -32767                                          
 CORE_NAME = "RAW DATA NUMBER"                                                
 CORE_UNIT = DIMENSIONLESS                                                    
                                                                              
/*  Suffix definition */                                                      
 SUFFIX_BYTES = 4                                                             
 SUFFIX_ITEMS = (    0,   0,    0)                                            
                                                                              
/* Spectral axis description */                                               
                                                                              
    GROUP = BAND_BIN                                                          
                                                                              
    BAND_BIN_CENTER =                                                         
(1.021,1.030,1.040,1.049,1.059,....)
 BAND_BIN_WIDTH  =                                                       
(0.0140,0.0140,0.0140,0.0140,......)
BAND_BIN_UNIT = MICROMETER                                                   
                                                                              
    BAND_BIN_ORIGINAL_BAND =                                                  
(1,2,3,4,5,6,7,8,9,10,11,12,.......)
END_GROUP = BAND_BIN                                                          
                                                                              
END_OBJECT                     = QUBE                                         
END                                                                           
                                                                              
OBJECT = HISTORY                                                              

END_OBJECT = HISTORY                                                          
```
2. .QUB file: This contains the actual data. This stores the image as **\col{red}{Digital Number}** as normally happens for CCD type devices. This is the data we have to convert in radinace or reflectance. We can't directly open this data (so can't show you here).
3. HK_.LBL file: This contains the column names for the other data file of detail information of the device like temperature of detector, temp of spectroscope, shutter status, exposure time for each lines.

```txt

```
To use this package, we have to first install it. For installing here is a bash script (if you want you can just directly download and use from git),
```bash
#!/bin/bash
ENV_DIR="./virtools-venv"
REPO_URL="https://github.com/aburousan/virtools.git"
CLONE_DIR="./virtools"

echo "Creating virtual environment in $ENV_DIR"
python3 -m venv "$ENV_DIR"
source "$ENV_DIR/bin/activate"

pip install --upgrade pip setuptools wheel build

echo "Cloning repo..."
rm -rf "$CLONE_DIR"
git clone "$REPO_URL" "$CLONE_DIR"
cd "$CLONE_DIR" || exit 1
pip install numpy scipy matplotlib scikit-image pvl PyWavelets
python3 -m build
pip install dist/*.whl

echo "virtools installed in virtualenv at $ENV_DIR"
echo "To activate: source $ENV_DIR/bin/activate"
```
This will create a environment in python and install the package there. For installing in conda, use:
```bash
#!/bin/bash

ENV_NAME="virtools-env"
PYTHON_VERSION="3.10"
REPO_URL="https://github.com/aburousan/virtools.git"
CLONE_DIR="./virtools"

echo "Creating conda environment: $ENV_NAME"
conda create -y -n "$ENV_NAME" python=$PYTHON_VERSION

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "$ENV_NAME"

echo "Cloning repo..."
rm -rf "$CLONE_DIR"
git clone "$REPO_URL" "$CLONE_DIR"
cd "$CLONE_DIR" || exit 1

echo "Installing dependencies..."
conda install -y numpy scipy matplotlib scikit-image pip
pip install pvl PyWavelets build

python3 -m build
pip install dist/*.whl

echo "virtools installed in conda env: $ENV_NAME"
```
<!-- I will be assuming that readers have some basic knowledge on **metric**. But still to be sure, let's start by discussing a bit on it.
\defn{
    Metric is an object that turns coordinat distance into physical distance. It is normally represented by $g$.
    
    In a more rigorous sense, Metric is a tensor, which maps $2$ vectors onto a real number. That real number tells us what is the distance between those two vectors.
}
Let's see this using an example:
\exam{
    In 3-D Euclidean Space, the **physical distance** between two points separated by the infinitesimal coordinate distance $dx$, $dy$ and $dz$ is,
    $$
    ds^2 = dx^2 + dy^2 + dz^2 = \sum_{i,j}^3\delta_{ij} dx^i dx^j = \sum_{i,j}g_{ij} dx^i dx^j
    $$
    where $x_1 = x$, $x_2=y$ and $x_3=z$. As, we can clearly see $g_{ij}=\delta_{ij}$, i.e.,
    $$
    g_{euc} =
        \begin{pmatrix}
        1 & 0 & 0 \\
        0 & 1 & 0 \\
        0 & 0 & 1
        \end{pmatrix}
    $$
}
Let's see one more example.
\exam{
    Let's say we have two points. They have a coordinate values $(r,\theta, \phi)$ and $(r+dr, \theta+d\theta, \phi+d\phi)$. The distance between this two points are,
    $$
    ds^2 = dr^2+r^2 d\theta^2+r^2 \sin^2(\theta) d\phi^2 = \sum_{i,j}^3g_{ij}dx^i dx^j
    $$
    where $x_1 = r$, $x_2=\theta$ and $x_3=\phi$. Here the metric is,
    $$
    g =
        \begin{pmatrix}
        1 & 0 & 0 \\
        0 & r^2 & 0 \\
        0 & 0 & r^2 \sin^2(\theta)
        \end{pmatrix}
    $$
}
It should be noted that people using different coordinate systems won't necessarily agree on the **coordinate distance** between two points, but they will always agree on the **physical distance**, $ds$, i.e., $ds$ is an **\col{red}{invariant}**.

I hope those two examples makes it clear that **\col{purple}{metric helps us to measure physical distance}** and in general it should depend upon the position itself, i.e., $g=g(t,\vec{x})$.

Normally, we actally use **\col{blue}{Einstein's equation}** to find the metric for a given matter and energy distribution. But here we will assume a **Spatial Homogeneity and Isotropy of the Universe** which implies that universe can be represented by a time-ordered sequence of $3-D$ spatial slices. The $4-D$ line element can be written as,
$$
ds^2 = -c^2 dt^2 + a^2(t)\Big(\frac{dr^2}{1- k r^2/R_0^2}+r^2 d\Omega^2\Big)\label{metricgen}
$$
where $d\Omega^2=d\theta^2+\sin^2(\theta)d\phi^2$ and $R_0$ is the curvature of the universe. $k$ defines the type of the universe. If $k=0$ it means flat universe. For $k=1$ and $k=-1$, we have closed and open universe respectively. The function $a(t)$ is called **\col{purple}{scale factor}**, which represent the fact that our universe expands as time goes on.

\note{
1. AstronomR can actually do the calculation for all of those.
2. In the metric(eqn-\eqref{metricgen}), we have a rescaling symmetry, i.e., If we simultaneously rescale $a$, $r$ and $R_0$ by a constant $\lambda$ the geometry of the spacetime remains same. We will use this **freedom to set the scale factor today, at $t=t_0$, to be unity, $a(t_0)=1$**. The scale $R_0$ is then the physical curvature scale today.

It should be remembered throughout this blog using the subscript $0$ to denote quantities evaluated today, at $t=t_0$,
}
## What Hubble Parameter and Constant?
To understand the idea of we have to remember there are two coordinates in the picture.
1. Comoving Coordinate,$r$ (This is the coordinate of the grid. The numbers stick on the grid).
2. Physical Coordinate, $r_{phy}=a(t)r$(THis is the actual physical distance we measure).
~~~
<div class="row">
  <div class="container">
    <img class="left" src="/assets/Physics/blogs/Finding_age_astroR1/scale_fact.jpg" >
    <div style="clear: both"></div>      
  </div>
</div>
~~~
In this image the lattice points are the numbers on the grid and they represent **Comoving Coordinates**.

Now, let's consider a galaxy with a trajectory $\vec{r}(t)$ in comoving coordinates and $\vec{r}_{phy}=a(t)\vec{r}$ in physical coordinates. The physical velocity of the galaxy is,
$$
\vec{v}_{phy} = \frac{d}{dt}\vec{r}_{phy} = \frac{da}{dt}\vec{r}+a(t)\frac{d\vec{r}}{dt} = \frac{\dot{a}}{a} \vec{r}_{phy}+ \vec{v}_{pec}
$$
The first term represent the **velocity of the galaxy resulting from the expansion of the space between the origin and $\vec{r}_{phy}(t)$**. We can define the **coefficient of $\vec{r}_{phy}$** as **\col{purple}{Hubble Parameter}**, i.e.,
$$
H = \frac{\dot{a}(t)}{a(t)}
$$
\note{
    We can use something known as **Redshift**($z$) rather than **Scale Factor**($a$). Recall that the wavelength of light is inversely proportional to the photon energy $\lambda = h/E$, where $h$ is Planck's constant. We can show, 
    $$
\frac{1}{E}\frac{dE}{dt} = -\frac{\dot{a}}{a}
    $$
    which implies $E\propto a^{-1}$, the wavelength therefore scales as $\lambda \propto a(t)$. Light emitted at a time $t_i$ with wavelength $\lambda_i$ will therefore be observed at a later time $t_f$ with a larger wavelength,
    $$\lambda_f = \frac{a(t_f)}{a(t_i)}\lambda_i$$
    This increase of the observed wavelength is called redshift, as red light has a longer wavelength than blue.
    
    We can easily see,
    $$
    z+1 = \frac{a(t_0)}{a(t_i)} =  \frac{1}{a(t_i)}
    $$
    where $a(t_0)=1$ where $t_0$ is today's time.
}
At time $t=t_0$, i.e., today, $H(t_0) = H_0$. This is called **\col{purple}{Hubble Constant}**. This is written as $H_0 = 100 h \ km\cdot s^{-1} \cdot Mpc^{-1}$, where $h$ is a parameter with value of $0.674\pm 0.005$. This is found from CMB anisotropy spectrum.
## Setting up Friedmann Equation
Upto this point we have assumed $a(t)$ as some unknown function of time. Now, let's invest a bit more and find some equation which tells us about $a(t)$.

Let's start with **Einstein Equation**,
$$
G_{\mu \nu}=\frac{8 \pi G}{c^4}T_{\mu \nu}\label{einseq}
$$
We will take $T_{\mu \nu}$ of the perfect fluid,
$$
T_{\mu \nu} = \Big( \rho+\frac{P}{c^2} \Big)U_\mu U_\nu + P g_{\mu \nu}
$$
where $\rho c^2$ & $P$ are the energy density and the pressure in the rest frame of the fluid and $U^\mu$ is its four-velocity relative to a comoving observer.

Now, using the definition of Einstein Tensor,
$$
G_{\mu \nu} = R_{\mu \nu} - \frac{R}{2}g_{\mu \nu}
$$
where $R_{\mu \nu}$ is the **Ricci Tensor** and $R = R^{\mu}_{\mu}=g^{\mu \nu}R_{\mu \nu}$ is the **Ricci scalar**.

Now, using the formula of ricci tensor, we get,
\begin{align}
R_{00} =& -\frac{3}{c^2}\frac{\ddot{a}}{a}\\
R_{ij} =& \frac{1}{c^2}\Bigg[ \frac{\ddot{a}}{a} + 2\Big( \frac{\dot{a}}{a} \Big)^2 + \frac{2 k c^2}{a^2 R_0^2} \Bigg]g_{ij}\\
R =& \frac{6}{c^2}\Bigg[ \frac{\ddot{a}}{a} + \Big( \frac{\dot{a}}{a} \Big)^2 + \frac{k c^2}{a^2 R_0^2} \Bigg]
\end{align}
Using these along with $G^{\mu}_{\nu} = g^{\mu \alpha}G_{\alpha \nu}$, we have,

\begin{align}
G^0_0 =& -\frac{3}{c^2}\Bigg[ \Big( \frac{\dot{a}}{a} \Big)^2 + \frac{kc^2}{a^2 R_0^2}\Bigg]\\
G^i_j =& -\frac{1}{c^2}\Bigg[ 2\frac{\ddot{a}}{a}+ \Big( \frac{\dot{a}}{a} \Big)^2 + \frac{k c^2}{a^2 R_0^2} \Bigg]\delta^i_j
\end{align}
Putting these in eqn-\eqref{einseq}, we have,
$$
\Big(\frac{\dot{a}}{a}\Big)^2=H^2 = \frac{8\pi G}{3}\rho - \frac{k c^2}{a^2 R_0^2}
$$
This is called **\col{purple}{Friedmann Equation}**. $\rho$ should be understood as the sum of all contribution to the energy density of the universe. Here $\rho = \rho_r + \rho_m + \rho_\Lambda + \rho_k$ where $\rho_r$, $\rho_m$, $\rho_\Lambda$ and $\rho_k$ corresponds to the density of radiation, matter, vacuum and curvature respectively.

In a flat universe($k=0$), we have,
$$
\rho_0 = \rho_{crit,0}= \frac{3H_0^2}{8\pi G} = 1.9\times 10^{-29} h^2 gm/cm^3
$$
This is called **Critical Density**. Using this we can write Friedmann Equation as,

$$
\Big(\frac{H}{H_0}\Big)^2=\Omega_r a^{-4}+\Omega_m a^{-3}+\Omega_k a^{-2}+\Omega_\Lambda
$$
where $\Omega_i = \Omega_{i,0}=\rho_{i,0}/\rho_{crit,0}$ and $i=r,m,\Lambda, \cdots$ & $\Omega_k = -kc^2/(R_0 H_0)^2$.

Using this equation we can find the **\col{purple}{age of the universe}** for different cosmological model. For that, we use another form of the equation,
$$
H_0 t = \int_0^a \frac{da}{\sqrt{\Omega_r a^{-2}+\Omega_m a^{-1}+\Omega_\Lambda a^{2}+\Omega_k}}
$$
Now, let's see what we get!
## Determining the age of the universe using AstronomR
In **AstronomR** to start doing cosmological calculations, we need to first define a cosmological model using $h,\Omega_i's$. Let's first see how:
\rcode{r1}{
library(astronomR)
cosmo <- astronomR:::cosmology_model(hubble_constant_fact=0.6774, curvature_crit = 0, dark_matter_crit = 0.6911, matter_crit = 0.3089, radiation_crit = 0)
print(cosmo)
}
As we can see as the curvature is taken to be $0$, it is giving us a model with flat universe.

To find the age we can use the function `age_of_universe` which takes two parameter. The first one is some cosmological model and the second one is unit. Unit can take $2$ values. The default is **year** and another one is **GY** or **Giga-Year**.
### For single component universe
Let's first consider a **flat matter dominated universe**, i.e., only $\Omega_m$ exist other omega's are $0$. 

In this case, we will have the model as,
```R
cosmo <- astronomR:::cosmology_model(hubble_constant_fact=0.6774, curvature_crit = 0, dark_matter_crit = 0, matter_crit = 1, radiation_crit = 0)
print(cosmo)
```
```
$hubble_constant_fact
[1] 0.6774

$dark_matter_crit
[1] 0

$matter_crit
[1] 1

$radiation_crit
[1] 0

$type
[1] "FlatLCDM"

$h_per_s
[1] 2.194948e-20
```
The last value is $h$'s value but in seconds.

Now run,
```R
astronomR:::age_of_universe(cosmo)
```
```
[1] 9631145240
```
This is the age of the universe(9.63 billion years).
\note{
    We can actually find it analytically. It is,
    $$
    t_0 = \frac{2}{3H_0} \approx 9\times 10^9 \ Yr
    $$
}
This is the famous **age problem**. The age of a pure matter universe is shorter than that of the oldest stars. So, we can't have only matter dominated universe.
<!-- \codeoutput{r1} -->
<!-- ### Two-Component Universe
Now, let's consider a matter and radiation dominated universe.
```R
c1 <- astronomR:::cosmology_model(hubble_constant_fact=0.6774, curvature_crit = 0, dark_matter_crit = 0, matter_crit = 0.4, radiation_crit = 0.6)
print(c1)
```
```
$hubble_constant_fact
[1] 0.6774

$dark_matter_crit
[1] 0

$matter_crit
[1] 0.4

$radiation_crit
[1] 0.6

$type
[1] "FlatLCDM"

$h_per_s
[1] 2.194948e-20
```
Now, run,
```R
astronomR:::age_of_universe(c1,unit="GY")
```
```
[1] 7.796172
```
The age is almost $7.796$ GY (again the age problem).
Now, let's consider matter and dark matter dominated universe.
```R
c1 <- astronomR:::cosmology_model(hubble_constant_fact=0.6774, curvature_crit = 0, dark_matter_crit = 0.68, matter_crit = 0.32, radiation_crit = 0)
print(c1)
```
```
$hubble_constant_fact
[1] 0.6774

$dark_matter_crit
[1] 0.68

$matter_crit
[1] 0.32

$radiation_crit
[1] 0

$type
[1] "FlatLCDM"

$h_per_s
[1] 2.194948e-20
```
Now, run,
```R
astronomR:::age_of_universe(c1,unit="GY")
```
```
[1] 13.67772
```
This gives us $13.6$GY or $13.6$ billion years. I guess it's sort of correct($13.8$GY actual value).
### Our Universe
In our universe, we have $\Omega_r = 8.99\times 10^{-5}$ which can be calculated using thermal properties (can also be calculated using AstronomR after the next update). Also, $|\Omega_k|<0.01$, so we will take this as $0$ for now(although I encourage you to put some value and see what you get).

Using this, we have,
```R
c1 <- astronomR:::cosmology_model(hubble_constant_fact=0.6774, curvature_crit = 0, dark_matter_crit = 0.6911, matter_crit = 0.3089, radiation_crit = 8.99e-5)
print(c1)
```
```
$hubble_constant_fact
[1] 0.6774

$dark_matter_crit
[1] 0.6911

$matter_crit
[1] 0.3089

$radiation_crit
[1] 8.99e-05

$type
[1] "FlatLCDM"

$h_per_s
[1] 2.194948e-20
```
Now, run,
```R
astronomR:::age_of_universe(c1,unit="GY")
```
```
[1] 13.8086
```
Good! As you can see the value is very close to real value.


Stay tuned for more cosmological blogs and application of our packages.


--- --> -->

Hope this helps you in some way. If you like it then share with others if possible.

If you have some queries, do let me know in the comments or contact me using my using the informations that are given on the page [About Me](/Pages/about_me/).

~~~
<button onclick="window.history.back()">Go Back</button>
~~~


~~~
<div id="disqus_thread"></div>
<script>
    /**
    *  RECOMMENDED CONFIGURATION VARIABLES: EDIT AND UNCOMMENT THE SECTION BELOW TO INSERT DYNAMIC VALUES FROM YOUR PLATFORM OR CMS.
    *  LEARN WHY DEFINING THESE VARIABLES IS IMPORTANT: https://disqus.com/admin/universalcode/#configuration-variables    */
    /*
    var disqus_config = function () {
    this.page.url = https://rousan.netlify.app/pages/physics/blogs/astronomr_package1/;  // Replace PAGE_URL with your page's canonical URL variable
    this.page.identifier = PAGE_IDENTIFIER; // Replace PAGE_IDENTIFIER with your page's unique identifier variable
    };
    */
    (function() { // DON'T EDIT BELOW THIS LINE
    var d = document, s = d.createElement('script');
    s.src = 'https://https-rousan-netlify-app.disqus.com/embed.js';
    s.setAttribute('data-timestamp', +new Date());
    (d.head || d.body).appendChild(s);
    })();
</script>
<noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
~~~