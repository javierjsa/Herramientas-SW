function rangecolorselector(directory)
%selects HSV values for colot-based tracking
%rangecolorselector('./images')
%jpg images only

% h - select hue
% s - select saturation
% v - select values
% p - increase
% o - decrease
% n - next frame
% q - quit


frames=dir ('*.jpg');
current=1;

%hmin,hmax,smin,smax,vmin,vmax,downs,up
values=[0,0,0,0,0,0,0.1,0.2];


key ='_';
new='h';
old='_';
values(8)=values(2);
values(7)=values(1);

img=imread(frames(current).name);
original=imread(frames(current).name);
imshow(original);
waitforbuttonpress();
close ();
while (new!='q')

  switch (new)
    case {'h','s','v'}              
      values=update(values,new,old);    
      old=new;
      new=key;
      fprintf("------\nNEW: %s, OLD: %s\n------\n",new,old);
      fflush(stdout);      
      imshow(original);
      waitforbuttonpress();
      close ();    
    case 'p'     
      values(8)=values(8)+10;
      values=update(values,new,old);
      output(values);      
      hsv_img= createMask(values,original);
      showImage(hsv_img);     
    case 'o'      
      values(8)=values(8)-10;
      output(values);      
      values=update(values,new,old);
      hsv_img= createMask(values,original);
      showImage(hsv_img);
    case 'l'     
      values(7)=values(7)+10;
      values=update(values,new,old);
      output(values);      
      hsv_img= createMask(values,original);
      showImage(hsv_img);     
    case 'k'      
      values(7)=values(7)-10;
      output(values);      
      values=update(values,new,old);
      hsv_img= createMask(values,original);
      showImage(hsv_img);     
    case 'n'
      current=current+1;
      original=imread(frames(current).name);
      showImage(original);
    otherwise
      new=old;
      
  endswitch
    

new = kbhit();


endwhile
close all;
endfunction

%devuelve la imagen con la mascara aplicada
function hsv_img = createMask(values,original)

  hsv_img=rgb2hsv(original);

  h=hsv_img(:,:,1);
  v=hsv_img(:,:,2);
  s=hsv_img(:,:,3);

  hmask=h>values(1) & h<values(2);
  smask=s>values(3) & s<values(4);
  vmask=v>values(5) & v<values(6);

  mask= hmask & smask & vmask;
  
  hsv_img(:,:,1)= hsv_img(:,:,1) .* mask;
  hsv_img(:,:,2)= hsv_img(:,:,2) .* mask;
  hsv_img(:,:,3)= hsv_img(:,:,3) .* mask;
  
endfunction  

%refresca la imagen cuando cambian los datos
%y la cierra para seguir leyendo del teclado
function showImage(image)
  img=hsv2rgb(image);
  imshow(img);
  waitforbuttonpress();
  close();
endfunction  

%muestra los valores actuales por pantalla
function output(values)
  fprintf("--------------------------\n");
  fprintf("Hmax: %f - Hmin %f\n",values(2),values(1));
  fprintf("Smax: %f - Smin %f\n",values(4),values(3));
  fprintf("Vmax: %f - Vmin %f\n",values(6),values(5));
  fprintf("--------------------------\n");
  fflush(stdout);
  fflush(stderr);
endfunction

%actualiza los valores cuando se cambia entre HSV
function values = update(values,new,old)

  switch old

    case 'h'
      values(2)=values(8);
      values(1)=values(7);
    case 's'
      values(4)=values(8);
      values(3)=values(7);
    case 'v'
      values(6)=values(8);
      values(5)=values(7);    
  endswitch   
  
   switch new

    case 'h'
      values(8)=values(2);
      values(7)=values(1);
    case 's'
      values(8)=values(4);
      values(7)=values(3);
    case 'v'
      values(8)=values(6);      
      values(7)=values(5);
   endswitch  
   
endfunction   