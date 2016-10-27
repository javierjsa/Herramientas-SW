function color_tracking(filtro,directory)
%[0.250,0.400,0.450,1.000,0.200,0.700]
%hmin,hmax,smin,smax,vmin,vmax
fflush(stdin);
filtro=[0.1,0.45,0.1,1,0.25,0.65];
elem=strel ("square", 3);
actual=pwd;
cd(directory)
frames=dir ('*.jpg');

current=1;

while(current<=length(frames))

  original=imread(frames(current).name);
  figure(1);
  imshow(original);
  fprintf("%s\n",frames(current).name);
  fflush(stdout);
  filtrada=imsmooth(original,"Gaussian",3);
  %filtro
  hsv_img= createMask(filtro,filtrada);
  %erosion
  hsv_img=imerode(hsv_img,elem,'same');
  hsv_img=imerode(hsv_img,elem,'same');
  %dilatacion
  hsv_img=imdilate(hsv_img,elem,'same');
  hsv_img=imdilate(hsv_img,elem,'same');
  img=hsv2rgb(hsv_img);
  img_gray=im2bw(img);
  figure(3)
  imshow(img_gray);
  props=regionprops(img_gray);
  disp(props);  
  figure(2);
  imshow(img);
  current=current+1;
  new=kbhit(1);
  if (new=='q')
    
    break;
  endif  
endwhile
close all;
cd(actual);
endfunction
%devuelve la imagen con la mascara aplicada
function hsv_img = createMask(values,original)

  hsv_img=rgb2hsv(original);

  h=hsv_img(:,:,1);
  v=hsv_img(:,:,2);
  s=hsv_img(:,:,3);

  hmask=h>=values(1) & h<=values(2);
  smask=s>=values(3) & s<=values(4);
  vmask=v>=values(5) & v<=values(6);

  mask= hmask & smask & vmask;
  
  hsv_img(:,:,1)= hsv_img(:,:,1) .* mask;
  hsv_img(:,:,2)= hsv_img(:,:,2) .* mask;
  hsv_img(:,:,3)= hsv_img(:,:,3) .* mask;
  
endfunction  

function next=nextFrame(current)  
  number=int2str(current);   
  next=strcat("frame",number);
  next=strcat(next,".jpg");
  i=i+1;
endfunction  