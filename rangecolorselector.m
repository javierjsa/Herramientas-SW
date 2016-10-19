function rangecolorselector(directory)
%selects HSV values for colot-based tracking
%requires gnuplot to work
%rangecolorselector('./images')
%jpg images only

% h - select hue
% s - select saturation
% v - select values
% p - increase
% o - decrease
% n - next frame
% q - quit

fflush(stdin);
actual=pwd;
graphics_toolkit("gnuplot");
cd(directory);
frames=dir ('*.jpg');
current=1;

%hmin,hmax,smin,smax,vmin,vmax,down,up
values=[0,1,0,1,0,1,0,1];

step=0.01;
%key ='_';
new='_';
old='_';
values(8)=values(2);
values(7)=values(1);



original=imread(frames(current).name);
hsv_img=rgb2hsv(original);
fprintf("---------------------------------------------\n");  
fprintf("h-HUE, s-SATURATION, v-VALUE\n");  
fprintf("o/p - decrementar/incrementar limite superior\n");
fprintf("k/l - decrementar/incrementar limite inferior\n");
fprintf("n - siguiente imagen.  q- salir\n");
fprintf("---------------------------------------------\n\n");  
fprintf("Pulse una tecla sobre la imagen para continuar\n");
fflush(stdout);
imshow(original);
waitforbuttonpress();
close ();
while (new!='q')
  fprintf("%s\n",new);
  fflush(stdout);
  switch (new)
    case {'h','s','v'}
      close ()    
      fprintf("h-HUE, s-SATURATION, v-VALUE\n");   
      output(values);   
      values=update(values,new,old);    
      old=new;      
      fprintf("Seleccionado: %s\n---------------\n",old);
      fflush(stdout);   
      
    case 'p'
     if(values(8)<1)     
      values(8)=values(8)+step;      
     else
      fprintf("Limite superior alcanzado\n"); 
      fflush(stdout);         
     endif     
     values=update(values,new,old);
     output(values);      
     hsv_img= createMask(values,original);
     showImage(hsv_img);
     
    case 'o'      
      if (values(8)>0)
        values(8)=values(8)-step;            
      else  
        fprintf("Limite inferior alcanzado\n");
        fflush(stdout);
      endif  
      output(values);
      values=update(values,new,old);
      hsv_img= createMask(values,original);
      showImage(hsv_img);
      
    case 'l'
      if (values(7)<1)    
        values(7)=values(7)+step;             
      else  
        fprinf("Limite inferior alcanzado\n");
        fflush(stdout);
      endif
      values=update(values,new,old);
      output(values);             
      hsv_img= createMask(values,original);
      showImage(hsv_img);  
      
    case 'k'     
      if(values(7)>0) 
        values(7)=values(7)-step;
        output(values);      
        fflush(stdout);
        values=update(values,new,old);
        hsv_img= createMask(values,original);
        showImage(hsv_img);
      else
        fprintf("Limite inferior alcanzado\n");
        fflush(stdout);
      endif     
      output(values);
      values=update(values,new,old);
      hsv_img= createMask(values,original);
      showImage(hsv_img);
      
    case 'n'
      if(current<length(frames))        
        current=current+1;
        fprintf("Nueva imagen:%s\n",frames(current).name);
        output(values);
        fflush(stdout);
        original=imread(frames(current).name);
        hsv_img= createMask(values,original);
        showImage(hsv_img);
      else  
        fprintf("No hay mas imagenes\n");
        fflush(stdout);
        showImage(hsv_img);
      endif    
        
    otherwise
      new=old; 
 
  endswitch
        
new=kbhit();

endwhile
close all;
filtro=values(1:6);
output(filtro);  
cd(actual);
color_tracking(values,directory);
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

%refresca la imagen cuando cambian los datos
%y la cierra para seguir leyendo del teclado
function showImage(image)
  fprintf("Pulse una tecla sobre la imagen para continuar\n");
  fflush(stdout);
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


function color_tracking(filtro,directory)
%Hmax: 0.450000 - Hmin 0.100000
%Smax: 1.000000 - Smin 0.100000
%Vmax: 0.650000 - Vmin 0.250000
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