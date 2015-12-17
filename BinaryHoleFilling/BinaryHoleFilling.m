%%BINARY HOLE FILLING

clear
clc
load depthframe_1.mat
%load hf1.mat

[H W] = size(orig);

thrHole = 120;
test = orig > thrHole;

% We have here the binary original image. What we have to do is, by user,
% select the holes in the picture and using the algorithm fill all the
% holes using se1.

figure(1)
imshow(orig,[])
title('Original image. Select the holes with the mouse')

% Obtain the holes location manually
[xh yh] = ginput;
xh = round(xh);             % Convert coordinates into integers
yh = round(yh);

current = zeros(H,W);
for c=1:length(xh)
    
    if yh(c)<1 || yh(c)>H
        continue
    end
    if xh(c)<1 || xh(c)>W
        continue
    end
    
    current(yh(c),xh(c)) = 1;
end

% Initialize Xn image for algorithm
previous = current;
while 1
   for x=1:W
       for y=1:H
           
           % Apply algorithm
           if previous(y,x) == 1
               if y>1
                   current(y-1,x) = 1-test(y-1,x);
               end
               if y<H
                   current(y+1,x) = 1-test(y+1,x);
               end
               if x>1
                   current(y,x-1) = 1-test(y,x-1);
               end
               if x<W
                   current(y,x+1) = 1-test(y,x+1);
               end
           end
  
       end
   end
   
   if isequal(previous,current)
       break
   else
       previous = current;
   end
end

final = orig + 255*uint8(current);

figure(2)
imshow(final,[0 255]);
title('Image with holes filled')


