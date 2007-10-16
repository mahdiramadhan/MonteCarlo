close all
clear all

% [usage]
% 
%    set BeamType  and spacing parameters and then type:
% 
%            multi_run for matlab command prompt
% 
% 
% 
% 
% set global variables
global BEAM_LOC   DIFF_LEN   DELTA_R   DELTA_Z 

DIFF_LEN = 1;    % length of diffusing tip [cm]
DELTA_R = .01;   %  DELTA_R  = spacing along the r-axis [cm]
DELTA_Z = .01;   %  DELTA_Z  = spacing along the z-axis [cm]
dim1 = 500; % grid dimensions
dim2 = 501; % grid dimensions

% beam radius
R_0 = .38 ;  % [cm]

% set function pointer representing type of beam
%                    diff_init : interstitial beam
%                    flat_init : Flat beam of radium R_0
%                    gauss_init: Gaussian beam with 1/exp(2) radius R_0
%                    point_init: Point source at the origin
BeamType = 4;
if(BeamType == 1)
   functer = @gauss_init ;
   namebase = 'Gauss_g%d_mua%d_mus%d';
   BEAM_LOC = 0.0;  % location in z-axis of center of diffusing tip [cm]
elseif(BeamType == 2)
   functer = @flat_init  ;
   namebase = 'Flat_g%d_mua%d_mus%d';
   BEAM_LOC = 0.0;  % location in z-axis of center of diffusing tip [cm]
elseif(BeamType == 3)
   functer = @point_init ;
   namebase = 'Point_g%d_mua%d_mus%d';
   BEAM_LOC = 0.0;  % location in z-axis of center of diffusing tip [cm]
elseif(BeamType == 4)
   functer = @diff_init  ;
   namebase = 'Diff_g%d_mua%d_mus%d';
   BEAM_LOC = 2.5;  % location in z-axis of center of diffusing tip [cm]
end


% create power grid
P = ones(dim1,dim2);
c = floor(BEAM_LOC/DELTA_Z)+1; %grid location of the center of the diff tip
l = floor(.5*DIFF_LEN/DELTA_Z); %number of grid points from center of diff tip to end
w = floor(.4/DELTA_R);   %number of grid points out from laser for cooling
P(c-l:c+l,1:1+w) = 0;
P = ones(dim1,dim2); % comment/uncomment for uniform power


% setup for parameter study 
mu_a = [.44,.704,1.008,1.312,1.616,1.92,2.224,2.528,2.832,3.136,3.44,3.744,4.048,4.352,4.656,4.96,5.0];
mu_s = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25];
g = [0,.1,.2,.3,.4,.5,.6,.7,.8,.9,.99];

% set number of times to run
nrun = 1 

% Create baseline grid
heating4 = zeros(dim1,dim2-1);

%for ig = 1:size(g,1)
%  for ia = 1:size(mu_a,1)
%    for is = 1:size(mu_s,1)
for ig = 8:8
  for ia = 1:1
    for is = 15:15
      for i = 1:nrun
        i
        [R,A,T,grid,fluence,HEATING] = ...
         scatter_simulation(10000,R_0,g(ig),mu_a(ia),mu_s(is),P,functer);
        heating4 = heating4 + HEATING;
      end
      heating4 = heating4./nrun;  
      % calculate isotropic source term for comparison
      [R,Z] = meshgrid(.01*[DELTA_R/2:DELTA_R:(dim1+0.5)*DELTA_R],...
                       .01*[DELTA_Z/2:DELTA_Z:(dim2-1.5)*DELTA_Z]);  % meters
      dist = sqrt(R.^2 + (BEAM_LOC*.01 - Z).^2);  % meters
      mu_tr  = (mu_a(ia) *100)+ (mu_s(is)*100) * (1-g(ig)); % 1/meters
      mu_eff = sqrt(3*(mu_a(ia)*100)*mu_tr); % 1/meters
      %isotropic should be units of  [W/m^3]
      isotropic = 3/4*(mu_a(ia)*100)*mu_tr*pi*(P.*exp(-mu_eff*dist)).* dist.^-1;
      name = sprintf(namebase,ig,ia,is);
      ascii_write(heating4,isotropic,name,DELTA_R,DELTA_Z)
    end
  end
end


