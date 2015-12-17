clear all
clc
close all

disp 'Step1: Read the color image file'
colorimage=imread('colorframe_3.jpg');
disp 'Step2: Read the depth map image')
depthmap=imread('depthframe_3.jpg');
[s1,s2]=size(depthmap);

disp 'Step3: Create the mask'
%create the mask
mask=zeros(s1,s2);
for i=1:s1
    for j=1:s2
        if depthmap(i,j)<20 % if there is a hole
            mask(i,j)=255;
        end
    end
end
figure
subplot(2,2,1)
imshow(colorimage,[]), title('original image')
subplot(2,2,2)
imshow(depthmap,[]), title('depth map')
subplot(2,2,3)
imshow(mask,[]), title('mask')

% diffusion
a=0.073235;
b=0.176765;
c=0.125;
K=[a,b,a;b,0,b;a,b,a];
L=[c,c,c;c,0,c;c,c,c];
better_depth=depthmap;
R=6;

disp 'Step4: Perform the diffusion'
for i=R:(s1-R)
    for j=R:(s2-R)
        if mask(i,j)==255
            test=sort(better_depth((i-R+1):(i+R-1),(j-R+1):(j+R-1)));
            if test(R-1,R-1)<=30 
                %if we are on the edge of a hole area, otherwise do nothing
                X=conv2(double(better_depth((i-R+1):(i+R-1),(j-R+1):(j+R-1)))/255,K);
                Y=conv2(double(better_depth((i-R+1):(i+R-1),(j-R+1):(j+R-1)))/255,L);
                [h,w]=size(X);
                h=floor(h/2);
                w=floor(w/2);
                if (i-h>0)&&(j-w>0)&&(i+h-1<s1)&&(j+w-1<s2)
                    better_depth((i-h):(i+h),(j-w):(j+w))=sqrt(X.^2 + Y.^2); %assign new values
                end
            end
        end
    end
end
subplot(2,2,4)
imshow(better_depth,[]), title('enhanced depth map')