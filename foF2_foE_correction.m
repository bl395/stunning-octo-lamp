% This script generates the corrected foF2 based on the vipir observation
load('VIPIR_2019_02');
latitude=-90:-68;
long=0:4:356;
year_iri=2018*ones(1,675);
month_iri=3*ones(1,675);
day_iri=2*ones(1,675);
UTselect=NaN(5,675);
UTselect(1,:)=year_iri;
UTselect(2,:)=month_iri;
UTselect(3,:)=day_iri;
UTselect(4,:)=double(hour');
UTselect(5,:)=double(min');
UTselect(6,:)=double(second'); % UTselect includes the time information: year,month,date,hour,minute,second
NmF2iri=NaN(length(long),length(latitude),675);
NmEiri=NaN(length(long),length(latitude),675);
h5create('IRI_correction.h5','/NmF2IRI',size(NmF2iri));
h5create('IRI_correction.h5','/NmEIRI',size(NmEiri));
h5create('IRI_correction.h5','/foF2IRI',size(NmEiri));
h5create('IRI_correction.h5','/foEIRI',size(NmEiri));
h5create('IRI_correction.h5','/foEIRI_correct',size(NmEiri));
h5create('IRI_correction.h5','/foF2IRI_correct',size(NmEiri));
h5create('IRI_correction.h5','/UTselect',size(UTselect));

lat=-90:1:-68;
longitude=0:4:356;
lon=NaN(size(longitude));
lat_length=length(lat);
longitude_length=length(longitude);

%%
%generate the foF2 and foE from iri2016
parfor timecount=1:675
    R12=-1;
    tic
    for latcount=1:lat_length
        for loncount=1:longitude_length
            month=3;
            date=2;
            minute=double(min(timecount));
            hor=double(hour(timecount));
            UT = [2018,month,date,hor,minute];
            [ionoiri, iono_extrairi] = iri2020(lat(latcount), longitude(loncount), R12, UT);
            NmF2iri(loncount,latcount,timecount)=iono_extrairi(1);%lon*lat*time
            NmEiri(loncount,latcount,timecount)=iono_extrairi(5);
        end
    end
    toc
end
h5write('IRI_correction.h5','/NmF2IRI',NmF2iri);
h5write('IRI_correction.h5','/NmEIRI',NmEiri);
foF2_iri=sqrt(NmF2iri)*9*1e-6;
foE_iri=sqrt(NmEiri)*9*1e-6;
h5write('IRI_correction.h5','/foF2IRI',foF2_iri);
h5write('IRI_correction.h5','/foEIRI',foE_iri);
h5write('IRI_correction.h5','/UTselect',UTselect);
foF2_iri=h5read('IRI_correction.h5','/foF2IRI');
foE_iri=h5read('IRI_correction.h5','/foEIRI');
%%
% Generate the foF2 and foE at VIPIR location from iri2020 and find the difference
% between iri2020 and VIPIR observation.
% Use the difference to correct the foF2 and foE found in previous section
load('VIPIR_2019_02.mat');
parfor t=1:675
    R12=-1;
    month=3;
    date=2;
    minute=double(min(t));
    hor=double(hour(t));
    UT = [2018,month,date,hor,minute];
    [iono_jang, iono_extra_jang] = iri2020(-74.624,164.229 , R12, UT);
    Nmf2_jang(t)=iono_extra_jang(1);
    NmE_jang(t)=iono_extra_jang(5);
end
foF2_jang=sqrt(Nmf2_jang)*9*1e-6;
foE_jang=sqrt(NmE_jang)*9*1e-6;
correction_foF2=foF2-foF2_jang;
correction_foE=foE-foE_jang;
foF2_iri_correct=NaN(size(foF2_iri));
foE_iri_correct=NaN(size(foE_iri));
for timecount=1:675
    foF2_iri_correct(:,:,timecount)=foF2_iri(:,:,timecount)+correction_foF2(timecount);
    foE_iri_correct(:,:,timecount)=foE_iri(:,:,timecount)+correction_foE(timecount);
end
foF2_iri_correct(foF2_iri_correct<=0.1)=0.1;
foE_iri_correct(foE_iri_correct<=0.1)=0.1;
% "foE_iri_correct" and "foF2_iri_correct" are two matrixes for the whole
% ionospheric grid thoughout the time series. They are used as iri_options
% for generating the ionosphere.
h5write('IRI_correction.h5','/foEIRI_correct',foE_iri_correct);
h5write('IRI_correction.h5','/foF2IRI_correct',foF2_iri_correct);

