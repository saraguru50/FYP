function segment = entropy_segmentation(I)
    maxm = int16(-1);
    s = size(I);
    r = s(1,1);
    c = s(1,2);
    for i=1:r
        for j=1:c
            if(I(i,j) > maxm)
                maxm = I(i,j);
            end
        end
    end

    move = [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1];
    entropy_matrix = zeros(r,c);
    ent = zeros(r,c);
    max_entropy = double(0);
    entropy_threshold = 0;

    for i=1:r
        for j=1:c
            entropy = double(0);
            window_size = int16(81);
            stdeviation = zeros(1,81);
            count = zeros(1,maxm+1);
            idx = 1;
            boundary_row = [i-1,i+1,i-2,i+2,i-3,i+3,i-4,i+4];
            boundary_col = [j-1,j+1,j-2,j+2,j-3,j+3,j-4,j+4];
            for iw=i-4:i+4
                for jw=j-4:j+4
                    row = iw;
                    col = jw;
                    if(iw < 1 || iw > r)
                        for l=1:8
                            if(iw == boundary_row(1,l))
                                if(mod(l,2) == 0)
                                    row = boundary_row(1,l-1);
                                else
                                    row = boundary_row(1,l+1);
                                end
                            end
                        end
                    end
                    if(jw < 1 || jw > c)
                        for l=1:8
                            if(jw == boundary_col(1,l))
                                if(mod(l,2) == 0)
                                    col = boundary_col(1,l-1);
                                else
                                    col = boundary_col(1,l+1);
                                end
                            end
                        end
                    end
                    stdeviation(1,idx) = I(row,col);
                    idx = idx + 1;
                    count(1,I(row,col)+1) = count(1,I(row,col)+1) + 1;
                end
            end
            for k=1:maxm+1
                cnt = count(1,k);
                if(cnt > 0)
                    prob = double(double(cnt) / double(window_size));
                    entropy = double(double(entropy) + (double(prob) * double(log2(double(prob)))));
                end
            end
            entropy = -entropy;
            ent(i,j) = entropy * double(std(stdeviation,0,2));
            if(ent(i,j) > max_entropy)
                max_entropy = ent(i,j);
            end
        end
    end

    if(max_entropy > 300)
        entropy_threshold = 150;
    else
        entropy_threshold = 55;
    end
    for i=1:r
        for j=1:c
            if(ent(i,j) > entropy_threshold)
                entropy_matrix(i,j) = 1;
            else
                entropy_matrix(i,j) = 0;
            end
        end
    end

    entropy_matrix = mat2gray(entropy_matrix);
    binaryImage = bwareaopen(entropy_matrix, 500);
    global skeletonImage;
    skeletonImage = bwmorph(binaryImage, 'thin', inf);
    segment = skeletonImage;