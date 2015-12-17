clear all;
clc;
close all;
colorimage=imread('colortest.png');
depthmap=imread('depthtest.png');
[s1,s2]=size(depthmap);
%joint bilateral filter
YCBCR = rgb2ycbcr(colorimage);
[a,~]=size(diag(depthmap));
sigm=[0.03*a,0.008];
better_depth=depthmap;
for i=1:10
    better_depth=gaussian(double(better_depth)/255, double(YCBCR(:,:,1))/255, sigm(1), sigm(2));
    if i==1
        atest=better_depth;
    end
end

figure;
subplot(2,2,1)
imshow(colorimage,[]), title('color image')
subplot(2,2,2)
imshow(depthmap,[]), title('depth map')
subplot(2,2,3)
imshow(atest,[]), title('first iterated depth map')
subplot(2,2,4)
imshow(better_depth,[]), title('enhanced depth map iteration')

