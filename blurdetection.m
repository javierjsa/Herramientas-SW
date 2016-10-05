function blurdetection(directory);
%function blurry(directory,file_type);
% determines if pictures in floder are blurry
% jpg only
% usage: blurdetection('./images')

  file_type='jpg';
  actual=pwd;
  cd(directory);
  exp=strcat('./*.',file_type);
  disp(exp);
  dir_struct=dir(exp);  
  filter=fspecial('laplacian');
  for i=1:length(dir_struct)
    nom=dir_struct(i).name;
    img=imread(nom);    
    img_gray=rgb2gray(img);
    img_filter=imfilter(img_gray,filter);
    [fil,col]= size(img_filter);
    img_vector=reshape(img_filter,1,fil*col);
    img_var=var(img_vector);
    imshow(img);
    if img_var<90
      enf='Desenfocada';
    else
      enf='Enfocada';
    endif  
    texto=cstrcat(enf,', var=',num2str(img_var));
    text(5,30,texto,'fontsize',20,'fontweight','bold','color','cyan');
    waitforbuttonpress;
  endfor
  cd(actual);
endfunction   
