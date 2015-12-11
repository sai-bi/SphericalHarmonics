img = imread('../img/grace.jpg');
l = 3;
[sh_coeff, sh_img] = sh(img, l);
figure;
imshow(uint8(sh_img));