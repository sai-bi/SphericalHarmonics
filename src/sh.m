%% Compute the Spherical Harmonics(SH) coefficients and representation os given
%% environment map.
%% For details of SH, please refer to: 
%%  - https://en.wikipedia.org/wiki/Spherical_harmonics
%%  - https://en.wikipedia.org/wiki/Spherical_harmonic_lighting
function [sh_coeff, sh_img] = sh(img, l)
%% Input:
%% img: [h * w * 3] input environment light probe
%% l  : [scalar] degree of sh

img = double(img);
[h, w, ~] = size(img);
theta = ((0:h-1)  + 0.5) * pi / h;
phi = ((0:w-1)  + 0.5) *2 * pi/ w;

[x, y] = meshgrid(phi, theta);
dirs = [x(:) y(:)];

num = (l+1)^2;
coeff = getSH(l, dirs, 'real');

theta = [0 theta];
val = cos(theta);
w_theta = val(1:end-1) - val(2:end);

val = [0 phi];
w_phi = val(2:end) - val(1:end-1);
[x,y] = meshgrid(w_phi, w_theta);
div = x(:) .* y(:);

r = img(:,:,1); r = r(:) .* div; r_coeff = repmat(r, 1, num) .* coeff; r_coeff = sum(r_coeff,1) ;
g = img(:,:,2); g = g(:) .* div; g_coeff = repmat(g, 1, num) .* coeff; g_coeff = sum(g_coeff,1) ;
b = img(:,:,3); b = b(:) .* div; b_coeff = repmat(b, 1, num) .* coeff; b_coeff = sum(b_coeff,1) ;

out_r = coeff .* repmat(r_coeff, h*w,1); out_r = sum(out_r, 2);
out_g = coeff .* repmat(g_coeff, h*w,1); out_g = sum(out_g, 2);
out_b = coeff .* repmat(b_coeff, h*w,1); out_b = sum(out_b, 2);

output = zeros(h,w,3);
output(:,:,1) = reshape(out_r, h, w);
output(:,:,2) = reshape(out_g, h, w);
output(:,:,3) = reshape(out_b, h, w);

imwrite(uint8(output), [num2str(l+1) '.png']);
