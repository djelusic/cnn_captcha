path = fullfile(fileparts(mfilename('fullpath')), '\c74k\raw\English\fnt');
load(fullfile(path, 'lists_var_size.mat'));

p = randperm(62992);
traininds = transpose(p(1:10000));
trainlabs = list.ALLlabels(traininds);
trainnames = list.ALLnames(traininds,:);

testinds = transpose(p(10001:11000));
testlabs = list.ALLlabels(testinds);
testnames= list.ALLnames(testinds,:);

for i = 1:size(traininds,1)
	A = imread(fullfile(path, [trainnames(i,:), '.png']));
	A = imresize(A, [50 50]);
	if size(A, 3)==3
		A = rgb2gray(A);
	end
	A = double(A);
	trainimgs(:,:,i) = A(:,:);
end

images = trainimgs/255;
labels = double(trainlabs);

for i = 1:size(testinds,1)
	A = imread(fullfile(path, [testnames(i,:), '.png']));
	A = imresize(A, [50 50]);
	if size(A, 3)==3
		A = rgb2gray(A);
	end
	A = double(A);
	testimgs(:,:,i) = A(:,:);
end

testImages = testimgs/255;
testLabels = double(testlabs);

images = normalize_data(images, 10000, 50);
testImages = normalize_data(testImages, 1000, 50);