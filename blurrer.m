function blurrer (directory);
% Loads all images of file type in directory
% and applies gaussian kernels of various sizes
% jpg images only
% usage: blurrer('./images')

 actual=pwd; 
 file_type='jpg';
 size =[5,15,21];
 cd(directory); 
 exp=strcat('./*.',file_type);
 disp(exp)
 dir_struct = dir(exp);
 
 for i=1:length(dir_struct)
  nombre_img=dir_struct(i).name;
  disp('Archivo cargado:'),disp(nombre_img);
  img=imread(nombre_img); 
  nombre_trunc=strtrunc(nombre_img,length(nombre_img)-4);
  disp('Archivos generados');
  for j=1:length(size)     
    blur=imsmooth(img,'Gaussian',size(j));
    nombre_blur=strcat(nombre_trunc,'-',num2str(j),'.jpg');
    disp(nombre_blur);
    imwrite(blur,nombre_blur);
  endfor  
 endfor  
 cd(actual); 
endfunction  
