# This file was generated, do not modify it. # hide
#hideall
using RCall
R"""
library(astronomR)
cosmo <- astronomR:::cosmology_model(hubble_constant_fact=0.6774, curvature_crit = 0, dark_matter_crit = 0.6911, matter_crit = 0.3089, radiation_crit = 0)
print(cosmo)
"""