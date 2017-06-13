function [ Iout ] = deDepthImage( Iin )

g = Iin(:,:,2);
b = Iin(:,:,3);

ind = (g < 1) & (b < 1);
ind = ind(:);

g = g(ind);
b = b(ind);

gain = b\g;

Iout = Iin;
Iout(:,:,3) = Iout(:,:,3)*gain;

g1 = Iout(:,:,2);
b1 = Iout(:,:,3);

% figure; plot(g1(:),b1(:),'.');

end

