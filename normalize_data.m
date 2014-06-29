function nd = normalize_data(data,n,dim)
for k=1:n
    std_k = 1./ std(reshape(data(:,:,k), dim*dim, 1));
    nd(:,:,k) = (data(:,:,k) - mean(reshape(data(:,:,k), dim*dim, 1))).*std_k;        
end

