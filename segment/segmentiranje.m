function si = segmentiranje(B)
B=medfilt3(B);
B=im2double(B);
C = uint8(255 * ((B >= 0.4 & B <= 0.5) | ((B >= 0.9 & B <= 1))));
B=im2bw(C);
B = medfilt2(B, [2 2]);
B = imcomplement(B);
SE = strel('square', 2);
B = imdilate(B,SE);
B = medfilt2(B, [3 3]);
%figure(4), imshow(B)
stats = regionprops(B);
for index=1:length(stats)
%if stats(index).Area > 200 && stats(index).BoundingBox(3)*stats(index).BoundingBox(4) < 30000
x = ceil(stats(index).BoundingBox(1));
y= ceil(stats(index).BoundingBox(2));
widthX = floor(stats(index).BoundingBox(3)-1);
widthY = floor(stats(index).BoundingBox(4)-1);
subimage(index) = {B(y:y+widthY,x:x+widthX,:)};
subimage{index} = imresize(subimage{index}, [28 28]);
subimage{index} = imcomplement(subimage{index}); %ova linija se može maknuti u ovisnosti što želiš
%figure, imshow(subimage{index})
%end
end

for i=1:length(subimage)
si(:,:,i) = subimage{i};
end