%% drawFlash_gaussian
%
% this function draws a circular flash with max contrast in a varying
% position around the center of the screen whith a
% magnitude scaled along a radius defined in pixels.
% such scaling is defined along a pseudo gaussian curve, whose value range
% from 1 to 0. Multiplication of the contrast value for the gaussian vector
% leads to a luminance value ranging from the highest luminant point
% to the least luminant. This selection is adjusted in order to create a
% patch that has the same extension for every luminance value: this
% adjustment is achieved by selecting in the gaussian theoretical
% distribution only those value which exceed the minimum luminance
% displayed by the computer screen (1/255), creating the scale along this
% vector.
%##########################################################################
%
% synopsis
% outIm = drawFlash_gaussian(inX,inY,contrast,radius,bslCol, nAngles, noisePos)
%
%
% inX, inY: dimension of the screen, in pixels
% contrast: float value between 0-1 to define contrast
% radius: radius of flash, in pixels
% bslCol: float value between 0-1 to define baseline color of canvas
% nAngles: defines resolution of the stimulus (1000 OK)
% noisePos: to shift the center of flash from the screen's center
%
%##########################################################################
%
% -created ---------------------------------------------------------------- Elio Balestrieri 19-Jul-2017 
% modified to adjust gaussian shape (keeping flash extension stable)------- Elio Balestrieri 23-Mar-2018
% double checked & warning added------------------------------------------- Elio Balestrieri 09-Apr-2018


function [outIm, cntX, cntY]= drawFlash_gaussian(inX,inY,contrast,radius,bslCol, nAngles,noisePos)

    canvasMat=zeros(inY,inX)+bslCol; %-------------------------------------define zeros "canvas" matrix

    %radius=100;
    %contrast=1;
    %nAngles=1000;
    
    max_expected = bslCol+contrast;
    
    pd = makedist('normal');
    theoretical = pdf(pd, linspace(0, 5, 10000));
    rad_theory = contrast*theoretical/theoretical(1);
    
    end_indx = find(rad_theory<1/255,1)-1; % select only those values that can be converted into uint8 (255)
    all_indx = round(linspace(1,end_indx, radius));
    
    % double check
%     x_ax = linspace(0, 5, 10000);
%     x_term = x_ax(end_indx)
%     x_newAx = linspace(0,x_term,radius);
%     x_selected = x_ax(1:end_indx);
%     plot(x_selected,rad_theory(1:end_indx), x_newAx, radShadow)
%     legend('theoretical','effective')

    radShadow = rad_theory(all_indx); %------------------------------------ define vec equal spaced till radius value
    abstCoor=1:radius;                %------------------------------------ abstract linear coordinates of pixels, from O
    cntX = inX/2+randsample(-noisePos(2):noisePos(2),1);
    cntY = inY/2+randsample(-noisePos(1):noisePos(1),1);
    
    for ii=1:nAngles  % start rotation for num of angles of the grad vect

        rowCoor=round(cntX+abstCoor*sin(ii*2*pi/nAngles));
        colCoor=round(cntY+abstCoor*cos(ii*2*pi/nAngles));
        linCoor=(rowCoor-1)*inY+colCoor;

        canvasMat(linCoor)=radShadow+bslCol; %--------------------define contrast along the vector

    end

    canvasMat(cntY,cntX)=contrast+bslCol; %----------------------------------correct central point to 
    
    max_effective = max(max(canvasMat));
    
    if max_effective~=max_expected
        warning('different max value of luminance expected')
    end
    
    outIm = repmat(canvasMat,1,1,3);
    
end

    
    
    
    