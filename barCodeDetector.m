function barCodeDetector(imagen)

imr=imresize(imagen, 0.25);
im=rgb2gray(imr);
[Gx,Gy] = imgradientxy(im,'sobel');

dif=abs(Gx-Gy);
dit_u = dif>200;
im = medfilt2(im, [9 9]);
im = im & dit_u;

ser = strel('rectangle',[21 7]);
ses = strel('square',3);
im =imclose(im,ser);
for i=1:4
    im =imerode(im,ses);
end

for i=1:4
    im =imclose(im,ses);
end

prop=regionprops(im,'Area','BoundingBox','Orientation');

aux=prop(1);
for i=2:length(prop)
    a=prop(i);
    if a.Area>aux.Area
        aux=a;
    end    
end    

cont=a.BoundingBox;
angle=a.Orientation;

rot=[cos(angle) -sin(angle); sin(angle) cos(angle)];


a=[0 cont(4)]; %esquina inf izda
b=[cont(3) cont(4)];%esquina inf dcha
c=[cont(3) 0]; %esquina sup dcha;

a=rot*a';
b=rot*b';
c=rot*c';

x=[cont(1) cont(2)];
a=a'+ x;
b=b'+ x;
c=c'+ x;



vertx=[x(1),a(1),b(1),c(1)];
verty=[x(2),a(1),b(2),c(2)];

imshow(imr);
hold on;
plot(vertx,verty,'.-');
%rectangle('Position',cont,'EdgeColor','g','LineWidth',2);




end

