; NCL script
; plot_oft.ncl 
; Mark Stevens, Sept 2001
; Rich Neale, Jan 2008
; plot data from model and ECMWF reanalysis
;*****************************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"  
load "$DIAG_CODE/functions_contrib.ncl"   
load "$DIAG_CODE/functions_surfaces.ncl"
load "$DIAG_CODE/functions_transport.ncl"
;*****************************************************************
begin
version    = getenv("DIAG_VERSION")
compare    = getenv("COMPARE") 
wkdir      = getenv("WKDIR")
plot_type  = getenv("PLOTTYPE") 
color_type = getenv("COLORTYPE") 
time_stamp = getenv("TIMESTAMP")
case_names = getenv("CASENAMES")
ncdf_mode  = getenv("NCDF_MODE")
infile1    = getenv("TEST_INPUT")     ; case1 input filename
outfile1   = getenv("TEST_PLOTVARS")  ; case1 output filename
infile2    = getenv("CNTL_INPUT")     ; case2 input filename
if (compare .ne. "OBS") then
  outfile2 = getenv("CNTL_PLOTVARS")  ; case2 output filename
end if

; ECMWF reanalysis data on T42 grid
; all floats
inptr = addfile("$OBS_DATA/ECMWF_ANN_climo.nc","r")
lat0 = inptr->lat          
nlat0 = dimsizes(lat0)
;jtgw = inptr->gw
if (isfilevar(inptr,"gw")) then
  gw = inptr->gw 
else
  if (isfilevar(inptr,"wgt")) then
    gw = inptr->wgt
  else 
    gwtemp = latRegWgt(lat1,"double",0)  ; no gw in file
    gw = gwtemp
    delete(gwtemp)
    gw!0 = "lat"
    gw&lat = lat1
  end if
end if
oro = inptr->ORO(0,:,:)
ep = inptr->EP(0,:,:)
oft0 = oft_ecmwf (gw,oro,ep)
delete(gw)
delete(oro)

; MODEL 1 
; get the model data
inptr1 = addfile(infile1,"r")
if (ncdf_mode .eq. "write") then
  outptr1 = addfile(outfile1,"w")
else
  outptr1 = addfile(outfile1,"c")
end if
if (case_names .eq. "True") then
  case1 = getenv("CASE1")
else
  case1 = inptr1@case
end if
tmp = inptr1->lat        
if (typeof(tmp).eq."double") then
  lat1 = dble2flt(tmp)
else
  lat1 = tmp
end if
delete(tmp)
nlat1 = dimsizes(lat1)

;jt gw = inptr1->gw
if (isfilevar(inptr1,"gw")) then
  gw = inptr1->gw 
else
  if (isfilevar(inptr1,"wgt")) then
    gw = inptr1->wgt
  else 
    gwtemp = latRegWgt(lat1,"double",0)  ; no gw in file
    gw = gwtemp
    delete(gwtemp)
    gw!0 = "lat"
    gw&lat = lat1
  end if
end if

;if (isfilevar(inptr1,"ORO")) then
;  oro = get_ORO (inptr1,outptr1)
;else
  oro = get_ORO_OCNFRAC (inptr1,outptr1)
;end if
precc = inptr1->PRECC(0,:,:)   ; m/s
precl = inptr1->PRECL(0,:,:)
if (isfilevar(inptr1,"QFLX")) then
  qflx = inptr1->QFLX(0,:,:)
else
  print("QFLX not present in input file")
  exit()
end if
oft1 = oft_model (gw,oro,precc,precl,qflx)
delete(gw)
delete(oro)
delete (precc)
delete (precl)
delete (qflx)

; Model 2 for model-to-model comparisons
if (compare .ne. "OBS") then
  inptr2 = addfile(infile2,"r")
  if (ncdf_mode .eq. "write") then
    outptr2 = addfile(outfile2,"w")
  else
    outptr2 = addfile(outfile2,"c")
  end if
  if (case_names .eq. "True") then
    case2 = getenv("CASE2")
  else
    case2 = inptr2@case
  end if
  tmp = inptr2->lat        
  if (typeof(tmp).eq."double") then
    lat2 = dble2flt(tmp)
  else
    lat2 = tmp
  end if
  delete(tmp)
  nlat2 = dimsizes(lat2)
;jt  gw = inptr2->gw
if (isfilevar(inptr2,"gw")) then
  gw = inptr2->gw 
else
  if (isfilevar(inptr2,"wgt")) then
    gw = inptr2->wgt
  else 
    gwtemp = latRegWgt(lat2,"double",0)  ; no gw in file
    gw = gwtemp
    delete(gwtemp)
    gw!0 = "lat"
    gw&lat = lat2
  end if
end if
;  if (isfilevar(inptr2,"ORO")) then
;    oro = get_ORO (inptr2,outptr2)
;  else
    oro = get_ORO_OCNFRAC (inptr2,outptr2)
;  end if
  precc = inptr2->PRECC(0,:,:)
  precl = inptr2->PRECL(0,:,:)
  if (isfilevar(inptr2,"QFLX")) then
    qflx = inptr2->QFLX(0,:,:)
  else
    print("QFLX not present in input file")
    exit()
  end if
  oft2 = oft_model (gw,oro,precc,precl,qflx)
end if

;*****************************************************************************
; plotting resources
if (compare .eq. "OBS") then
  if (color_type .eq. "COLOR") then
    wks = gsn_open_wks(plot_type,wkdir+"set2_OFT_obsc")   
  else
    wks = gsn_open_wks(plot_type,wkdir+"set2_OFT_obs")   
  end if
else
  if (color_type .eq. "COLOR") then
    wks = gsn_open_wks(plot_type,wkdir+"set2_OFT_c")   
  else
    wks = gsn_open_wks(plot_type,wkdir+"set2_OFT")   
  end if
end if
plotO = new(1,"graphic")  
plotP = new(1,"graphic")  
plotA = new(1,"graphic")  
plotI = new(1,"graphic")  

res                        = True
res@gsnFrame               = False
res@gsnDraw                = False
res@pmLegendSide           = "Right"            
res@pmLegendWidthF         = 0.13              
res@pmLegendDisplayMode    = "Always"
res@lgPerimOn              =  True
res@lgLabelFontHeightF     = 0.015
res@trXReverse             = True
if (compare.eq."OBS") then
  res@pmLegendHeightF        = 0.08             
  res@xyExplicitLegendLabels = (/"ECMWF",case1/)
  res@xyLineThicknesses      = (/2.,2./)
  if (color_type .eq. "COLOR") then
    res@xyLineColors           = (/"black","red"/)
    res@xyDashPatterns         = (/0,0/)
  else
    res@xyMonoLineColor       = True
    res@xyLineColor           = "black" 
    res@xyDashPatterns         = (/0,1/)
  end if
else
  res@pmLegendHeightF        = 0.10             
  res@xyExplicitLegendLabels = (/"ECMWF",case1,case2/)
  res@xyLineThicknesses      = (/2.,2.,2./)
  if (color_type .eq. "COLOR") then
    res@xyLineColors           = (/"black","red","blue"/)
    res@xyDashPatterns         = (/0,0,1/)
  else
    res@xyMonoLineColor       = True
    res@xyLineColor           = "black" 
    res@xyDashPatterns         = (/0,1,2/)
  end if
end if
res@tiYAxisString          = "Freshwater Transport (Sv)"
res@tiXAxisString          = "Latitude"
res@tiXAxisFontHeightF     = 0.017
res@tiYAxisFontHeightF     = 0.017
res@txFontHeightF          = 0.02
res@pmLegendParallelPosF   =  0.91              
res@pmLegendOrthogonalPosF = -1.03             
res@gsnYRefLine            = 0.0
;-----------------------------------------------------------------
; allow for models with grids other than T42
if (compare.eq."OBS") then
  dimXY = (/nlat0,nlat1/) 
  nMax = max(dimXY)
  data = new((/2,nMax/),float)        ; oft to plot 
  plat = new((/2,nMax/),float)        ; latitudes for plotting
  plat(0,0:dimXY(0)-1) = lat0 
  plat(1,0:dimXY(1)-1) = lat1 
else
  dimXY = (/nlat0,nlat1,nlat2/) 
  nMax = max(dimXY)
  data = new((/3,nMax/),float)        ; oft to plot 
  plat = new((/3,nMax/),float)        ; latitudes for plotting
  plat(0,0:dimXY(0)-1) = lat0 
  plat(1,0:dimXY(1)-1) = lat1 
  plat(2,0:dimXY(2)-1) = lat2 
end if
plat!0 = "line"
plat!1 = "lat"
data!0 = "line"

; total ocean
res@gsnLeftString = "Total Ocean"
data(0,0:dimXY(0)-1) = (/oft0(3,:)/)    ; ECMWF 
data(1,0:dimXY(1)-1) = (/oft1(3,:)/)    ; model 1 
if (compare.ne."OBS") then
  data(2,0:dimXY(2)-1) = (/oft2(3,:)/)  ; model 2 
end if
plotO = gsn_csm_xy(wks,plat,data,res)
;MK store in other variable for saving to netcdf file later
data_tot = data

; pacific ocean
res@gsnLeftString = "Pacific Ocean"
delete(res@tiYAxisString)
data(0,0:dimXY(0)-1) = (/oft0(0,:)/)     ; ECMWF 
data(1,0:dimXY(1)-1) = (/oft1(0,:)/)     ; model 1 
if (compare.ne."OBS") then
  data(2,0:dimXY(2)-1) = (/oft2(0,:)/)   ; model 2 
end if
plotP = gsn_csm_xy(wks,plat,data,res)
;MK store in other variable for saving to netcdf file later
data_pac = data

; atlantic ocean
res@gsnLeftString = "Atlantic Ocean"
res@tiYAxisString = "Freshwater Transport (Sv)"
data(0,0:dimXY(0)-1) = (/oft0(1,:)/)      ; ECMWF
data(1,0:dimXY(1)-1) = (/oft1(1,:)/)      ; model 1 
if (compare.ne."OBS") then
  data(2,0:dimXY(2)-1) = (/oft2(1,:)/)    ; model 2 
end if
plotA = gsn_csm_xy(wks,plat,data,res)
;MK store in other variable for saving to netcdf file later
data_atl = data

; indian ocean
res@gsnLeftString = "Indian Ocean"
delete(res@tiYAxisString)
data(0,0:dimXY(0)-1) = (/oft0(2,:)/)      ; ECMWF 
data(1,0:dimXY(1)-1) = (/oft1(2,:)/)      ; model 1
if (compare.ne."OBS") then
  data(2,0:dimXY(2)-1) = (/oft2(2,:)/)    ; model 2 
end if
plotI = gsn_csm_xy(wks,plat,data,res)
;MK store in other variable for saving to netcdf file later
data_ind = data

pan = True
pan@gsnMaximize = True
pan@gsnPaperOrientation = "portrait"
pan@gsnFrame = False
pan@gsnPanelTop = 0.96
if (time_stamp .eq. "True") then
  pan@gsnPanelBottom = 0.05
  gsn_panel(wks,(/plotO,plotP,plotA,plotI/),(/2,2/),pan)
  infoTimeStamp(wks,0.011,"DIAG Version: "+version)
else
  gsn_panel(wks,(/plotO,plotP,plotA,plotI/),(/2,2/),pan)
end if
txres = True
txres@txFontHeightF = 0.016
gsn_text_ndc(wks,"Annual Implied Northward Freshwater Transport",0.5,0.98,txres)
frame (wks)

; MK 
;===================================================================
; write all ocean freshwater transports to netcdf file TEST_PLOTVARS (outfile1) when comparing to observations
; or to CNTL_PLOTVARS (outfile2) when comparing to another model run 
;===================================================================

if (compare.eq."OBS") then
  print(" write all ocean freshwater transports to netcdf file:")
  print(" " + outfile1)
  fout=outptr1
else
  print(" write all ocean freshwater transports to netcdf file:")
  print(" " + outfile2)
  fout=outptr2
end if
print(" functionality added by MK from IMAU")

;===================================================================
; create global attributes of the file (optional)
;===================================================================
fileAtt               = True
fileAtt@creation_date = systemfunc("date")
fileAtt@src           = "plot_and_write_oft.ncl"

fileattdef(fout, fileAtt)  ; copy file attributes

; save total ocean freshwater transport 
oft_tot_ecmwf = data_tot(0,:)
oft_tot_ecmwf!0 = "lats_ecmwf"
oft_tot_ecmwf&lats_ecmwf = plat(0,:)
oft_tot_ecmwf@units = "Sv"
oft_tot_ecmwf@long_name = "total ocean freshwater transport ecmwf"
fout->oft_tot_ecmwf = oft_tot_ecmwf

oft_tot_testcase = data_tot(1,:)
oft_tot_testcase!0 = "lats_testcase"
oft_tot_testcase&lats_testcase = plat(1,:)
oft_tot_testcase@units = "Sv"
oft_tot_testcase@long_name = "total ocean freshwater transport " + case1
fout->oft_tot_testcase = oft_tot_testcase

if (compare .ne. "OBS") then
  ; testcase is compared with control case
  oft_tot_controlcase = data_tot(2,:)
  oft_tot_controlcase!0 = "lats_controlcase"
  oft_tot_controlcase&lats_controlcase = plat(2,:)
  oft_tot_controlcase@units = "Sv"
  oft_tot_controlcase@long_name = "total ocean freshwater transport " + case2
  fout->oft_tot_controlcase = oft_tot_controlcase
end if

; save pacific ocean freshwater transport
oft_pac_ecmwf = data_pac(0,:)
oft_pac_ecmwf!0 = "lats_ecmwf"
oft_pac_ecmwf&lats_ecmwf = plat(0,:)
oft_pac_ecmwf@units = "Sv"
oft_pac_ecmwf@long_name = "pacific ocean freshwater transport ecmwf"
fout->oft_pac_ecmwf = oft_pac_ecmwf

oft_pac_testcase = data_pac(1,:)
oft_pac_testcase!0 = "lats_testcase"
oft_pac_testcase&lats_testcase = plat(1,:)
oft_pac_testcase@units = "Sv"
oft_pac_testcase@long_name = "pacific ocean freshwater transport " + case1
fout->oft_pac_testcase = oft_pac_testcase

if (compare .ne. "OBS") then
  ; testcase is compared with control case
  oft_pac_controlcase = data_pac(2,:)
  oft_pac_controlcase!0 = "lats_controlcase"
  oft_pac_controlcase&lats_controlcase = plat(2,:)
  oft_pac_controlcase@units = "Sv"
  oft_pac_controlcase@long_name = "pacific ocean freshwater transport " + case2
  fout->oft_pac_controlcase = oft_pac_controlcase
end if

; save atlantic ocean freshwater transport
oft_atl_ecmwf = data_atl(0,:)
oft_atl_ecmwf!0 = "lats_ecmwf"
oft_atl_ecmwf&lats_ecmwf = plat(0,:)
oft_atl_ecmwf@units = "Sv"
oft_atl_ecmwf@long_name = "atlantic ocean freshwater transport ecmwf"
fout->oft_atl_ecmwf = oft_atl_ecmwf

oft_atl_testcase = data_atl(1,:)
oft_atl_testcase!0 = "lats_testcase"
oft_atl_testcase&lats_testcase = plat(1,:)
oft_atl_testcase@units = "Sv"
oft_atl_testcase@long_name = "atlantic ocean freshwater transport " + case1
fout->oft_atl_testcase = oft_atl_testcase

if (compare .ne. "OBS") then
  ; testcase is compared with control case
  oft_atl_controlcase = data_atl(2,:)
  oft_atl_controlcase!0 = "lats_controlcase"
  oft_atl_controlcase&lats_controlcase = plat(2,:)
  oft_atl_controlcase@units = "Sv"
  oft_atl_controlcase@long_name = "atlantic ocean freshwater transport " + case2
  fout->oft_atl_controlcase = oft_atl_controlcase
end if

; save indian ocean freshwater transport
oft_ind_ecmwf = data_ind(0,:)
oft_ind_ecmwf!0 = "lats_ecmwf"
oft_ind_ecmwf&lats_ecmwf = plat(0,:)
oft_ind_ecmwf@units = "Sv"
oft_ind_ecmwf@long_name = "indan ocean freshwater transport ecmwf"
fout->oft_ind_ecmwf = oft_ind_ecmwf

oft_ind_testcase = data_ind(1,:)
oft_ind_testcase!0 = "lats_testcase"
oft_ind_testcase&lats_testcase = plat(1,:)
oft_ind_testcase@units = "Sv"
oft_ind_testcase@long_name = "indian ocean freshwater transport " + case1
fout->oft_ind_testcase = oft_ind_testcase

if (compare .ne. "OBS") then
  ; testcase is compared with control case
  oft_ind_controlcase = data_ind(2,:)
  oft_ind_controlcase!0 = "lats_controlcase"
  oft_ind_controlcase&lats_controlcase = plat(2,:)
  oft_ind_controlcase@units = "Sv"
  oft_ind_controlcase@long_name = "indian ocean freshwater transport " + case2
  fout->oft_ind_controlcase = oft_ind_controlcase
end if

;/MK

end
