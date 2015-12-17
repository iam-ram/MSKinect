%% GAUSSIAN HOLE FILLING

clear
clc

% USER PARAMETERS (works with hf2-7.mat)
%load hf2.mat
load depthframe_1.mat

BW = 7;                     % Gaussian blur width in pixels (odd number)
thrHole = 100;              % Threshold for possible hole detecting
T = 3;                      % Times to be reduced

% Determine dimensions of original image
[H W] = size(orig);

% Create Gaussian Kernel
GK = zeros(BW);
l = round(BW/2-1);
for i=-l:l
    for j=-l:l
        GK(j+l+1,i+l+1) = exp(-(i^2 + j^2)/2);
    end
end
GK = GK/sum(sum(GK));

% Detect holes: 
test = orig.*uint8(orig > thrHole);          % Apply threshold

% Start reduction
Hi = H;
Wi = W;
bef = test;
n = 0;

while n<T
    
    % Initialize reducted image
    Wi = round(Wi/2 + 0.1);
    Hi = round(Hi/2 + 0.1);
    red = zeros(Hi,Wi);
    
    % Reduce image applying Gaussian filter
    for x=1:Wi
        for y=1:Hi
            
            a = zeros(BW);
            for i=-l:l
                for j=-l:l
                    xp = 2*x-1+i;
                    yp = 2*y-1+j;
                    
                    if xp<1 || xp>length(bef(1,:)) || yp<1 || yp>length(bef(:,1))
                        continue;
                    end
                    
                    a(j+l+1,i+l+1) = bef(yp,xp);
                end
            end
            
            nz = sum(sum(a~=0));        % Number of non-zeros in a
            
            if nz == 0
                red(y,x) = 0;
            elseif nz == 15
                red(y,x) = sum(sum(GK.*a));
            else
                red(y,x) = sum(sum(a))/nz;
            end
        end
    end
    
    n = n+1;
    bef = red;
end
        

n = 0;
while n<T
    
    amp = zeros(2*Hi,2*Wi);
    
    for x=1:Wi
        for y=1:Hi
            amp(2*y-1,2*x-1) = bef(y,x);
        end
    end

    % Perform interpolation on each axis
    for x=1:Wi
        for y=1:Hi

            % Interpolate in X-axis direction
            if (x == Wi)
                amp(2*y-1,2*x) = amp(2*y-1,2*x-1)/2;
            else
                amp(2*y-1,2*x) = (amp(2*y-1,2*x-1) + amp(2*y-1,2*x+1))/2;
            end

            % Interpolate in Y-axis direction
            if (y == Hi)
                amp(2*y,2*x-1) = amp(2*y-1,2*x-1)/2;
            else
                amp(2*y,2*x-1) = (amp(2*y-1,2*x-1) + amp(2*y+1,2*x-1))/2;
            end   
        end
    end

    % Interpolate the pixels left
    for x=1:Wi
        for y=1:Hi

            if(x == Wi)
                amp(2*y,2*x) = amp(2*y,2*x-1)/2;
            else
                amp(2*y,2*x) = (amp(2*y,2*x-1) + amp(2*y,2*x+1))/2;
            end
        end
    end
    
    Wi = 2*Wi;
    Hi = 2*Hi;
    bef = amp;    
    n = n+1;

end

final = test;
for x=1:Wi
    for y=1:Hi
        
        if x>W || y>H
            continue;
        end
        
        if final(y,x) == 0
            final(y,x) = amp(y,x);
        end
    end
end

figure(1)
imshow(orig,[0 255])
figure(2)
imshow(amp,[0 255])
figure(3)
imshow(final,[0 255])