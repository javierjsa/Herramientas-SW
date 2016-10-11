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



graphics_toolkit("gnuplot");

frames=dir ('*.jpg');
current=1;

%hmin,hmax,smin,smax,vmin,vmax,down,up
values=[0,1,0,1,0,1,0,1];

step=0.05;
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
fprintf("---------------------------------------------\n\n");  
fprintf("Pulse una tecla sobre la imagen para continuar\n");
fflush(stdout);
imshow(original);
waitforbuttonpress();
close ();
while (new!='q')

  switch (new)
    case {'h','s','v'}
      close ()    
      fprintf("h-HUE, s-SATURATION, v-VALUE\n");   
      output(values);   
      values=update(values,new,old);    
      old=new;
      new=key;
      fprintf("Seleccionado: %s\n---------------\n",old);
      fflush(stdout);      
    case 'p'
     if(values(8)<1)     
      values(8)=values(8)+step;
      values=update(values,new,old);
      output(values);      
      hsv_img= createMask(values,original);
      showImage(hsv_img);
     else
      fprintf("Limite superior alcanzado\n"); 
      fflush(stdout);         
     endif     
    case 'o'      
      if (values(8)>0)
        values(8)=values(8)-step;
        output(values);           
        values=update(values,new,old);
        hsv_img= createMask(values,original);
        showImage(hsv_img);
      else  
        fprintf("Limite inferior alcanzado\n");
        fflush(stdout);
      endif  
    case 'l'
      if (values(7)<1)    
        values(7)=values(7)+step;
        values=update(values,new,old);
        output(values);             
        hsv_img= createMask(values,original);
        showImage(hsv_img);     
      else  
        fprinf("Limite inferior alcanzado\n");
        fflush(stdout);
      endif  
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
    case 'n'
      if(current<length(frames))
        current=current+1;
        original=imread(frames(current).name);
        showImage(original);
        waitforbuttonpress();
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
output(values);  

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