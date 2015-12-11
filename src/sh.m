%% Compute the Spherical Harmonics(SH) coefficients and representation of given
%% environment map.
%% For details of SH, please refer to: 
%%  - https://en.wikipedia.org/wiki/Spherical_harmonics
%%  - https://en.wikipedia.org/wiki/Spherical_harmonic_lighting
function [sh_coeff, sh_img] = sh(img, l)
%% Input:
%% - img        [h * w * 3]         input environment light probe
%% - l          [scalar]            degree of sh
%% Output:
%% - sh_coeff   [3 * (l+1)^2]       SH coefficients of environment map
%% - sh_img     [h * w * 3 uint8]   image approximated by SH

%% get direction of each pixel
img = double(img);
[h, w, ~] = size(img);
theta = ((0:h-1) + 0.5) * pi / h;
phi = ((0:w-1) + 0.5) * 2 * pi/ w;

[x, y] = meshgrid(phi, theta);
dirs = [x(:) y(:)];

%% compute SH basis value of different directions
num = (l+1)^2;
coeff = getSH(l, dirs, 'real');

%% compute d(\omega): differential of solid angle
theta = (0:h) * pi / h; val = cos(theta); w_theta = val(1:end-1) - val(2:end);
val = (0:w)*2*pi/w; w_phi = val(2:end) - val(1:end-1); [x,y] = meshgrid(w_phi, w_theta);
d_omega = x(:) .* y(:);

%% compute SH coefficient
r = img(:,:,1); r = r(:) .* d_omega; r_coeff = repmat(r, 1, num) .* coeff; r_coeff = sum(r_coeff,1) ;
g = img(:,:,2); g = g(:) .* d_omega; g_coeff = repmat(g, 1, num) .* coeff; g_coeff = sum(g_coeff,1) ;
b = img(:,:,3); b = b(:) .* d_omega; b_coeff = repmat(b, 1, num) .* coeff; b_coeff = sum(b_coeff,1) ;

sh_coeff = [r_coeff; g_coeff; b_coeff];

%% compute output image approximated by SH
out_r = coeff .* repmat(r_coeff, h*w,1); out_r = sum(out_r, 2);
out_g = coeff .* repmat(g_coeff, h*w,1); out_g = sum(out_g, 2);
out_b = coeff .* repmat(b_coeff, h*w,1); out_b = sum(out_b, 2);

sh_img = zeros(h,w,3);
sh_img(:,:,1) = reshape(out_r, h, w);
sh_img(:,:,2) = reshape(out_g, h, w);
sh_img(:,:,3) = reshape(out_b, h, w);
sh_img = uint8(sh_img);