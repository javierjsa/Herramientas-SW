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

prop=regionprops(im,'Area','BoundingBox','Orientation','Extrema');

aux=prop(1);
for i=2:length(prop)
    a=prop(i);
    if a.Area>aux.Area
        aux=a;      
    end    
end    
disp(i);
%https://es.mathworks.com/matlabcentral/answers/97460-why-does-the-regionprops-command-not-return-the-correct-orientation-for-a-square-region
sides = a.Extrema(4,:) - a.Extrema(6,:);
angle = atan(-sides(2)/sides(1));

if (abs(angle-1.5708)<0.174533 || abs(angle-0)<0.174533)
    angle=0;
end

cont=aux.BoundingBox;

x=cont(1);
y=cont(2);
w=cont(3);
h=cont(4);


a=[x y]; %esquina inf. izda
b=[x y+h]; %esquina sup izda
c=[(x+w) (y+h)];%esquina sup dcha
d=[(x+w) y]; %esquina inf dcha;

centro = [ (c(1)+b(1))/2  (d(2)+c(2))/2  ];

R = [cos(angle) -sin(angle); sin(angle) cos(angle)];

ca=a-centro;
cb=b-centro;
cc=c-centro;
cd=d-centro;

ra=ca*R;
rb=cb*R;
rc=cc*R;
rd=cd*R;

fa=ra+centro;
fb=rb+centro;
fc=rc+centro;
fd=rd+centro;

x=round([fa(1) fb(1) fc(1) fd(1) fa(1)]);
y=round([fa(2) fb(2) fc(2) fd(2) fa(2)]);

figure(2);
imshow(imr);
hold on;
plot(x,y,'.-','Color',[1,0,0]);



