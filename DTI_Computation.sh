DTI_Computation#!/bin/sh

#  DTI_Computation.sh
#  
#
#  Created by Julian on 8/12/16.
#

#To make this excecutable:
#Put me in your /home/bin/, and make me executable with chmod a+rwx DTI_Computation.

#Preprocessing: b0 extraction, brain extraction, eddy-correction
#Processing: DTI estimation

subjs="sub-ON02747"
#Put your subject folders in here

#Write your main directory here
main_dir="/fast/hv_bids"
cd ${main_dir}

#Extract b0
for zzVARroi in ${subjs} ; do
echo "Extracting b0 image for ${zzVARroi}"
dwi_dir=${main_dir}/${zzVARroi}/ses-01/dwi/
echo ${dwi_dir}
if [ -f ${dwi_dri}/${zzVARroi}_nodif.nii.gz ]; then rm  ${dwi_dir}/${zzVARroi}_nodif.nii.gz ; fi
fslroi ${dwi_dir}/${zzVARroi}*run-01*dwi.nii.gz ${dwi_dir}/nodif.nii.gz 0 6
done

#Extract brain
for zzVARbet in ${subjs} ; do
echo "Betting nodif image for ${zzVARbet}"
dwi_dir=${main_dir}/${zzVARbet}/ses-01/dwi/
echo ${dwi_dir}
cd ${dwi_dir} #${main_dir}/${zzVARbet}/
#echo $(pwd)
#echo $(ls)
bet nodif.nii.gz nodif_brain.nii.gz -m -f 0.1
done

cd ${main_dir}

#### If pre eddy correction visualisation for vector examination is necessary

for zzVARdti in ${subjs} ; do
echo "Running Pre eddy dtifit for ${zzVARdti}"
dwi_dir=${main_dir}/${zzVARdti}/ses-01/dwi/
cd ${dwi_dir} #${main_dir}/${zzVARdti}

if [ ! -d Pre_ec ]; then
# Control will enter here if $DIRECTORY doesn't exist.
mkdir Pre_ec
fi

echo $(pwd)
echo $(ls)
echo dtifit -k ${zzVARdti}*run-01_dwi.nii.gz -m nodif_brain_mask.nii.gz -r ${zzVARdti}.bvecs -b ${zzVARdti}.bvals -o Pre_ec/dti_pre_ec


dtifit -k ${zzVARdti}_ses-01_run-01_dwi.nii.gz -m nodif_brain_mask.nii.gz -r ${zzVARdti}_ses-01_run-01_dwi.bvec -b ${zzVARdti}_ses-01_run-01_dwi.bval -o Pre_ec/dti_pre_ec
echo "Close fslview aafter examination"
#fslview_deprecated dti_pre_ec_FA.nii.gz
done

for zzVARec in ${subjs} ; do
echo "${zzVARec} eddy correcting"
dwi_dir=${main_dir}/${zzVARec}/ses-01/dwi/
echo $dwi_dir
eddy_correct ${dwi_dir}/${zzVARec}*run-01_dwi.nii.gz ${dwi_dir}/${zzVARec}"ec".nii.gz 0
done

# Specify bvals/bvecs versus bval/bvec
for zzVARdti in ${subjs} ; do
echo "Running dtifit for ${zzVARdti}"
dwi_dir=${main_dir}/${zzVARdti}/ses-01/dwi/
cd ${dwi_dir}
dtifit -k ${zzVARdti}"ec".nii.gz -m nodif_brain_mask.nii.gz -r ${zzVARdti}*run-01_dwi.bvec -b ${zzVARdti}*run-01_dwi.bval -o dti
cd ${main_dir}
done


echo "End"


cd ${main_dir}
