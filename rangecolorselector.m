function rangecolorselector(directory)
%Javier Saez Alonso
%Crea un filtro HSV para color-tracking
%Requiere gnuplot para funcionar correctamente
%Uso: rangecolorselector('./images')
%Solo imagenes jpg con nombre frameX.jpg (frame1.jpg, ...frame211.jpg)
%Teclas:
% h - selecciona hue
% s - selecciona saturation
% v - selecciona value
% p - incrementar limite superior
% o - decrementar limite superior
% l - incrementar limite inferior
% k - decrementar limite inferior
% n - siguiente frame
% q - salir

clc;
fflush(stdin);
actual=pwd;
graphics_toolkit("gnuplot");
cd(directory);
frames=dir ('*.jpg');
current=1;
current_frame="";
fig=figure;

%hmin,hmax,smin,smax,vmin,vmax,down,up
values=[0,1,0,1,0,1,0,1];

%Inicializacion de valores
step=0.04;
new='_';
old='_';
values(8)=values(2);
values(7)=values(1);

%Carga primera imagen
current_frame=nextFrame(current);
original=imread(current_frame);
hsv_img=rgb2hsv(original);
figure(fig,'name',current_frame);
imshow(original);

%Estado inicial
leyenda();
output(values);
fprintf("Pulse una tecla sobre la imagen para continuar\n");
fflush(stdout);
waitforbuttonpress();
close ();
clc;

while (new!='q')

  if (old=='_')
    fprintf("Seleccione primero h-HUE, s-SATURATION, v-VALUE\n");    
  endif 
  
  switch (new)
    case {'h','s','v'}
      clc;
      close ()          
      values=update(values,new,old);    
      old=new;      
      fprintf("---------------------------------------------\n");
      fprintf("Canal seleccionado: %s\n",old);
      fprintf("---------------------------------------------\n");
      fflush(stdout);   
    case 'p'
     if(values(8)<1)     
      values(8)=values(8)+step;
      canal(old);  
     else
      fprintf("---------------------------------------------\n");
      fprintf("Limite superior alcanzado\n"); 
      fprintf("---------------------------------------------\n");
      fflush(stdout);         
     endif     
     values=update(values,new,old);          
     hsv_img= createMask(values,original);
     showImage(hsv_img,values,fig,current_frame);
     
    case 'o'      
      if ((values(8)>0) && (values(8)>values(7)))
        values(8)=values(8)-step; 
        canal(old);        
      else  
        fprintf("---------------------------------------------\n");
        fprintf("Limite inferior alcanzado\n");
        fprintf("---------------------------------------------\n");
        fflush(stdout);
      endif        
      values=update(values,new,old);
      hsv_img= createMask(values,original);
      showImage(hsv_img,values,fig,current_frame);
      
    case 'l'
      if ((values(7)<1) && (values(7)<values(8)))    
        values(7)=values(7)+step;  
        canal(old);      
      else  
        fprintf("---------------------------------------------\n");
        fprintf("Limite inferior alcanzado\n");
        fprintf("---------------------------------------------\n");
        fflush(stdout);
      endif
      values=update(values,new,old);              
      hsv_img= createMask(values,original);
      showImage(hsv_img,values,fig,current_frame);
      
    case 'k'     
      if(values(7)>0) 
        values(7)=values(7)-step;          
        canal(old); 
        values=update(values,new,old);
        hsv_img= createMask(values,original);
        showImage(hsv_img,values,fig,current_frame);
      else
        fprintf("---------------------------------------------\n");
        fprintf("Limite inferior alcanzado\n");
        fprintf("---------------------------------------------\n");
        fflush(stdout);
      endif           
      values=update(values,new,old);
      hsv_img= createMask(values,original);
      showImage(hsv_img,values,fig,current_frame);
      
    case 'n'
      if(current<=length(frames))           
        current=current+1;
        current_frame=nextFrame(current);
      endif    
      if(exist(current_frame))  
        fprintf("---------------------------------------------\n");
        fprintf("Nueva imagen:%s\n",current_frame);
        fprintf("---------------------------------------------\n");       
        fflush(stdout);        
        original=imread(current_frame);
        hsv_img= createMask(values,original);
        showImage(hsv_img,values,fig,current_frame);
      else  
        fprintf("---------------------------------------------\n");
        fprintf("No hay mas imagenes\n");
        fprintf("---------------------------------------------\n");
        fflush(stdout);
        showImage(hsv_img,values,fig,current_frame);
      endif    
        
    otherwise
      new=old; 
 
  endswitch
leyenda(); 
output(values);  
fflush(stdout);      
new=kbhit();
clc;
endwhile

%Cierra e imprime los valores del filtro 
%en el formato que acepta color_tracking
close all;
filtro=values(1:6);
output(filtro);  
cd(actual);
clc;
fprintf("Valores del filtro [hmin,hmax,smin,smax,vmin,vmax]:\n");
fprintf("[%.3f,%.3f,%.3f,%.3f,%.3f,%.3f]\n",filtro(1),filtro(2),filtro(3),filtro(4),filtro(5),filtro(6));
fflush(stdout);
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
function showImage(image,values,fig,current_frame)  
  fprintf("Pulse una tecla sobre la imagen para continuar\n");
  fflush(stdout);
  img=hsv2rgb(image);
  figure(fig,'name',current_frame);
  imshow(img);
  waitforbuttonpress();
  clc;
  
  close();
endfunction  

%actualiza los valores cuando se cambia entre H,S,V
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

%muestra instrucciones por pantalla
function leyenda()
  fprintf("---------------------------------------------\n");  
  fprintf("h-HUE, s-SATURATION, v-VALUE\n");  
  fprintf("o/p - decrementar/incrementar limite superior\n");
  fprintf("k/l - decrementar/incrementar limite inferior\n");
  fprintf("n - siguiente imagen.  q - salir\n");
  fprintf("---------------------------------------------\n"); 
endfunction

%muestra los valores actuales por pantalla
function output(values)
  fprintf("---------------------------------------------\n");
  fprintf("Hmax: %f - Hmin %f\n",values(2),values(1));
  fprintf("Smax: %f - Smin %f\n",values(4),values(3));
  fprintf("Vmax: %f - Vmin %f\n",values(6),values(5));
  fprintf("---------------------------------------------\n");
  fflush(stdout);  
endfunction

%genera el nombre del siguiente frame
function next=nextFrame(current)  
  number=int2str(current);   
  next=strcat("frame",number);
  next=strcat(next,".jpg");
  
endfunction  

%indica el canal que se modifica
function canal(old)
  if (old!='_')  
    fprintf("---------------------------------------------\n");
    fprintf("Canal modificado: %s\n",old);
    fprintf("---------------------------------------------\n");     
  endif  
  fflush(stdout);
  
endfunction