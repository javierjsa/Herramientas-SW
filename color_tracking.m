function color_tracking(filtro,directory)
%color_tracking([hmin,hmax,smin,smax,vmin,vmax],"./frames")
%filtro video rotulador verde [0.32,0.45,0.2,1,0.17,0.65];
%filtros video alumno
% - amarillo [0.000,0.150,0.10,1.000,0.100,1.000]
% - verde [0.320,0.450,0.100,1.000,0.100,1.000]
% - azul  [0.500,0.900,0.100,1.000,0.150,1.000]
     

  fflush(stdin);
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
      fprintf("area %f\n",area);
      coord=getfield(props(index),"BoundingBox"); 
      [w,h]=size(img_gray);
      %se descarta la region si su area 
      %es menor que el 0.1% de la imagen
      if area>((w*h)*0.001)
        figure(1);
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