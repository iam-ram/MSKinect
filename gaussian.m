function B = JBF(Depthmap,Colorimage,sigma_d,sigma_r)
R=2;
dim=size(Depthmap);
[X,Y] = meshgrid(-R:R,-R:R);
Gauss_distance = exp(-(X.^2+Y.^2)/(2*sigma_d^2));
% For each pixel, calculate the filter, then the new value
B = zeros(dim);
for i = 1:dim(1)
    for j = 1:dim(2)

    % window
        iMin = max(i-R,1);
        iMax = min(i+R,dim(1));
        jMin = max(j-R,1);
        jMax = min(j+R,dim(2));
        Window = Depthmap(iMin:iMax,jMin:jMax);
        I = Colorimage(iMin:iMax,jMin:jMax);
        Iweights = exp(-(I-Colorimage(i,j)).^2/(2*sigma_r^2));
        % JB Filter is
        F = Iweights.*Gauss_distance((iMin:iMax)-i+R+1,(jMin:jMax)-j+R+1);
        % assign new averaged value to the pixel
        B(i,j) = sum(F(:).*Window(:))/sum(F(:));
    end
end