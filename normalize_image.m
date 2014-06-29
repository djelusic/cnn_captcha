function nd = normalize_image(image,dim)
    std_k = 1./ std(reshape(image, dim*dim, 1));
    nd = (image - mean(reshape(image, dim*dim, 1))).*std_k;