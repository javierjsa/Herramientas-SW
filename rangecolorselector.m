function rangecolorselector(directory)
%selects HSV values for colot-based tracking
%rangecolorselector('./images')
%jpg images only
% h - selects hue
% s - selects saturation
% v - selects value
% q/a - increase/decrease value
% n - next frame
% t - exit
frames=dir ('*.jpg');
current=1;
hmin=0.1;
hmax=0.6;
smin= 0.1;
smax= 0.6;
vmin= 0.1;
vmax= 0.6;

img=imread(frames(current).name);
hsv_img=rgb2hsv(img);
disp(hsv_img);
imshow(img);

waitforbuttonpress();
h=hsv_img(:,:,1);
v=hsv_img(:,:,2);
s=hsv_img(:,:,3);

hmask=h>hmin & h<hmax;
smask=s>smin & s<hmax;
vmask=v>vmin & v<hmax;

hsv_img(:,:,1)=hsv_img(:,:,1) .* hmask .* smask .* vmask;
hsv_img(:,:,2)=hsv_img(:,:,2) .* hmask .* smask .* vmask;
hsv_img(:,:,3)=hsv_img(:,:,3) .* hmask .* smask .* vmask;
img=hsv2rgb(hsv_img);
imshow(img);
disp(img);
waitforbuttonpress();
endfunction