function color_tracking(filtro,directory)
%hmin,hmax,smin,smax,vmin,vmax
%color_tracking([0.250,0.400,0.450,1.000,0.15,1],"./frames")
fflush(stdin);
%filtro=[0.1,0.45,0.1,1,0.25,0.65];
elem=strel ("square", 3);
actual=pwd;
cd(directory)
frames=dir ('*.jpg');

current=1;

while(current<=length(frames))

  current_frame=nextFrame(current);
  original=imread(current_frame);
  figure(1);
  imshow(original);
  fprintf("%s\n",current_frame);
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
  if length(props)>0
    index=selectArea(props);
    fprintf("index %d\n",index);
    coord=computeRect(props(index));
    disp(coord);
    figure(1);
    rectangle("Position",coord,"LineWidth",2,"EdgeColor",'green');
  endif    
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
  
endfunction  

function index =selectArea(regions)
  i=1;
  j = length(regions);
  area = 0;
  index=1;
  while (i<j)
    elem = regions(i);
    field=getfield(elem,"Area");
    if (field>area)
      index=i;
    endif  
    i=i+1;
  endwhile
  
endfunction

function coord = computeRect(elem)
  coord=getfield(elem,"BoundingBox");
  coord(2)=coord(1)-coord(3);  

endfunction