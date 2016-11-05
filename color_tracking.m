function color_tracking(filtro,directory)
%Javier Saez Alonso
%color_tracking([hmin,hmax,smin,smax,vmin,vmax],"./frames")
%Los archivos deben tener nombre "frameX.jpg"(frame0.jpg,frame1.jpg..)
%Frames alumno:
%https://dl.dropboxusercontent.com/u/64814516/master/HSW/frames-jsa.zip
%Filtro video rotulador verde:
% - [0.320,0.450,0.200,1.000,0.170,0.650];
%Filtros video alumno:  
% - amarillo [0.050,0.200,0.400,1.000,0.40,1.000]
% - verde [0.320,0.400,0.200,1.000,0.180,1.000]
% - azul  [0.500,0.900,0.200,1.000,0.300,1.000]
     

  fflush(stdin);
  elem=strel ("square", 3);
  actual=pwd;
  cd(directory)
  frames=dir ('*.jpg');
  fig=figure;
  current=1;

  while(current<=length(frames))

    current_frame=nextFrame(current);
    original=imread(current_frame);    
    figure(fig,'name',current_frame);
    imshow(original);    
    
    %filtro y mascara
    filtrada=imsmooth(original,"Gaussian",3);    
    hsv_img= createMask(filtro,filtrada);
    %erosion
    hsv_img=imerode(hsv_img,elem,'same');
    hsv_img=imerode(hsv_img,elem,'same');
    %dilatacion
    hsv_img=imdilate(hsv_img,elem,'same');
    hsv_img=imdilate(hsv_img,elem,'same');
  
    %umbralizado
    %se comprueba si graythresh devuelve algo
    img=hsv2rgb(hsv_img);    
    img_th=graythresh(img);    
    if length(img_th)==0
      img_gray=im2bw(img);
    else     
      img_gray=im2bw(img,img_th);
    endif
  
    %imagen con mascara
    %figure(2);
    %imshow(img);  
    %imagen erosionada
    %figure(3)
    %imshow(img_gray); 
  
    props=regionprops(img_gray);
    if length(props)>0
      [index,area]=selectArea(props);      
      coord=getfield(props(index),"BoundingBox"); 
      [w,h]=size(img_gray);
      %se descarta la region si su area 
      %es menor que el 0.05% de la imagen
      if area>((w*h)*0.0005)
        figure(fig);
        rectangle("Position",coord,"LineWidth",2,"EdgeColor",'green');
      endif  
      
    endif    
  
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

%genera el nombre de la siguiente imagen a cargar
function next=nextFrame(current)  
  number=int2str(current);   
  next=strcat("frame",number);
  next=strcat(next,".jpg");
  
endfunction  

%selecciona la region con mayor area
function [index,area] =selectArea(regions)
  i=1;
  j = length(regions);
  area = 0;
  index=1;
  while (i<=j)
    elem = regions(i);
    field=getfield(elem,"Area");   
    if (field>area)
      index=i;
      area=field;
    endif  
    i=i+1;
  endwhile   
endfunction