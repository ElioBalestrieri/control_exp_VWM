 P = local_assign_colors(P)
% assign random colors to the squares based on preallocation

ntrl = length(P.which_cond);
[P.which_cols1, P.which_cols2] = nan(ntrl, 3, 4);


for Itrl = 1:ntrl

    swap_color = P.colormap(randsample(1:6,5,'false'),:)';
    P.which_cols1(Itrl, :, :) = swap_color(:,1:4);

    % determine color arrays
    if P.which_cond(iTrl,1)==1
        P.which_cols2(Itrl, :, :) = P.which_cols1(Itrl, :, :);
    else
        which_square = randi(4);
        P.which_cols2(Itrl, :, :) = P.which_cols1(Itrl, :, :);
        P.which_cols2(Itrl, :, which_square) = swap_color(:,end);
    end

end

