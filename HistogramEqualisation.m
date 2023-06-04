function [breast_image_double_output] = HistogramEqualisation(breast_image_double_raw, outputFigures, name)
    
    %HISTOGRAM EQUALISATION%
    breast_image_double = adapthisteq(breast_image_double_raw);
    % Copy of image to manipulate just for plot
    breast_image_double_output = breast_image_double;
    
    % If Outputting figures
    if outputFigures == true
        
        % Set the black pixels to NaN to display histogram better (high number of black compared to actual relevant pixels)
        breast_image_double_raw(breast_image_double_raw == 0) = NaN;               
        breast_image_double(round(breast_image_double,2) < 0.05) = NaN;
        
        %PLOT HISTOGRAMS%
        figure('Name','Equalisation')

        %PLOT%
        subplot(2,2,1)
        histogram(breast_image_double_raw, 256)
        title(strcat(name,' BREAST PRE-EQUALISATION'))

        subplot(2,2,2)
        histogram(breast_image_double)
        title(strcat(name,' BREAST POST-EQUALISATION'))

        subplot(2,2,3)
        imshow(breast_image_double_raw);
        title(strcat(name,' BREAST PRE-EQUALISATION'))

        subplot(2,2,4)
        imshow(breast_image_double);
        title(strcat(name,' BREAST POST-EQUALISATION'))
    end
end