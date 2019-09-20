function [dist] = bmCompareWeightedRecon(mMembership1, mMembership2, mAdj1, mAdj2, sMeasure)
%
% Compares the blockmodels represented by cPosition1 and cPosition2, using the
% weighted reconstruction error.
%
% INPUT:
% mMembership1 - matrix of memberships of each vertex
% mMembership2 - matrix of memberships of each vertex
% mImageMat1    - 2D cell, where each element is the edge weight distribution of the corresponding element in the image matrix
% mImageMat2    - 2D cell, where each element is the edge weight distribution of the corresponding element in the image matrix
% vWeightDistValues     - vector, of the actual weight values used in the
%                           histograms of the mImageMat*.
%
% OUTPUT:
% dist          - reconstruction (block) distance between the two blockmodels
%
% @author: Jeffrey Chan, 2013
%


    switch sMeasure
        case 'emd'
            fBlockDiv = @emdDist;
        case 'kl'
            fBlockDiv = @klDivergence;
        case 'symkl'
            fBlockDiv = @symKlDivergence;
        case 'js'
            fBlockDiv = @jsDivergence;
        case 'klEmd'
            fBlockDiv = @klEmdDivergence;
        otherwise
            error(sprinf('%s is an unknown measure.\n', sMeasure));
    end


    dist = computeBlockDist(mMembership1, mMembership2, mAdj1, mAdj2, fBlockDiv);

    
    
end % end of function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function dist = computeBlockDist(mMembership1, mMembership2, mAdj1, mAdj2, fBlockDiv)
%
% Compute the EMD between blocks.
%
    % find the values in both matrices
    vUniqVals = intersect(unique(mAdj1), unique(mAdj2));
    % compute the weight distribution for each block
    [m3Image1] = computePmf(mAdj1, mMembership1, vUniqVals);
    [m3Image2] = computePmf(mAdj2, mMembership2, vUniqVals);
        
    

    % find the positions that have some overlap - we use that as the basis for
    % determining which blocks we need to compare their densities over
    mPosOverlap = mMembership1' * mMembership2;
    mPosOverlap = mPosOverlap / size(mMembership1, 1);
    

    dist = 0;
    % Loop through the blocks and compute their distance
    for c1 = 1 : size(m3Image1,2)
        for c2 = 1 : size(m3Image2, 2)
            for r1 = 1 : size(m3Image1,1)
                for r2 = 1 : size(m3Image2,1)
                    imageDiff = fBlockDiv(squeeze(m3Image1(r1,c1,:)), squeeze(m3Image2(r2,c2,:)), vUniqVals);
                    dist = dist + mPosOverlap(r1,r2) * mPosOverlap(c1,c2) * imageDiff; 
                end
            end
        end
    end

end



function m3Image = computePmf(mAdj, mMembership, vUniqVals)
%
% Compute the pmfs for the image matrix.
%
    posNum = size(mMembership,2);
    cvPos = cell(1, posNum);
    for p = 1 : posNum
        vR = find(mMembership(:,p));
        cvPos{p} = vR;
    end
    
    m3Image = zeros(posNum, posNum, length(vUniqVals));
    
    for c = 1 : posNum
        for r = 1 : posNum
            mSub = mAdj(cvPos{r}, cvPos{c});
            vFreq = histc(mSub(:), vUniqVals);
            % normalise to pmf
            vProb = vFreq / (length(cvPos{r}) * length(cvPos{c}));
            m3Image(r, c, :) = vProb;
        end
    end
    

end







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% function [dist] = computeKL(mMembership1, mMembership2, mAdj1, mAdj2)
% %
% % Computes the EMD distance between the two weight distributions.
% %
%     % find the values in both matrices
%     vUniqVals = intersect(unique(mAdj1), unique(mAdj2));
%     % compute the weight distribution for each block
%     [m3Image1] = computePmf(mAdj1, mMembership1, vUniqVals);
%     [m3Image2] = computePmf(mAdj2, mMembership2, vUniqVals);
% 
%     
%        
%     % find the positions that have some overlap - we use that as the basis for
%     % determining which blocks we need to compare their densities over
%     mPosOverlap = mMembership1' * mMembership2;
%     mPosOverlap = mPosOverlap / size(mMembership1, 1);
%     
% 
%     dist = 0;
%     % Loop through the blocks and compute their distance
%     for c1 = 1 : size(m3Image1,2)
%         for c2 = 1 : size(m3Image2, 2)
%             for r1 = 1 : size(m3Image1,1)
%                 for r2 = 1 : size(m3Image2,1)
% %                     squeeze(m3Image1(r1,c1,:))
% %                     squeeze(m3Image2(r2,c2,:))
%                     imageDiff = klDivergence(squeeze(m3Image1(r1,c1,:)), squeeze(m3Image2(r2,c2,:)));
%                     dist = dist + mPosOverlap(r1,r2) * mPosOverlap(c1,c2) * imageDiff; 
%                 end
%             end
%         end
%     end    
%     
% 
% end % end of function



% function m3Image = computeHist(mAdj, mMembership, vUniqVals)
% %
% % Compute the pmfs for the image matrix.
% %
%     posNum = size(mMembership,2);
%     cvPos = cell(1, posNum);
%     for p = 1 : posNum
%         vR = find(mMembership(:,p));
%         cvPos{p} = vR;
%     end
%     
%     m3Image = zeros(posNum, posNum, length(vUniqVals));
%     
%     for c = 1 : posNum
%         for r = 1 : posNum
%             mSub = mAdj(cvPos{r}, cvPos{c});
%             vFreq = histc(mSub(:), vUniqVals);
%             m3Image(r, c, :) = vFreq;
%         end
%     end
%     
% 
% end % end of function


