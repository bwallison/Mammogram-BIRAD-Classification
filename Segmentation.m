function [breast_image_double] = Segmentation(breast_mlo, outputFigures, name)
    
    % Get image dimensions
    [height, width] = size(breast_mlo);
    
    % Region growing to get pectoral

    structuring_element = strel('disk', 50);
    structuring_element_2 = strel('disk', 60);

    mlo_pectoral = RegionGrowing(imresize(breast_mlo, 0.2),25,25,0.1);
    mlo_pectoral = imresize(mlo_pectoral, [height, width]);
    mlo_pectoral = imfill(imdilate(mlo_pectoral , structuring_element), 4, 'holes');

    % Region growing to get negative space

    mlo_negative_area = RegionGrowing(imresize(breast_mlo, 0.1), round(height/10)- 25, round(width/10) - 25, 0.01);
    mlo_negative_area = imresize(mlo_negative_area, [height, width]);
    mlo_negative_area = imfill(imdilate(mlo_negative_area, structuring_element_2), 4, 'holes');

    % Remove pectoral and negative space segments

    breast_image = imbinarize(breast_mlo, 0.0001) & ~mlo_pectoral & ~mlo_negative_area;

    % Break wall connections and get largest object (Breast)

    breast_image(:,1:20) = 0;
    breast_image(1:50,:) = 0;
    breast_image(height-50:height,:) = 0;

    breast_image = imfill(breast_image, 'holes');

    breast_image = bwareafilt(breast_image, 1);
    breast_image_double = breast_mlo.*breast_image;
    
    % Output figures
    if outputFigures == true
        
        % Pectoral space output
        
        figure('Name','Segmentation')
        subplot(1,3,1)
        imshow(breast_mlo);
        title(strcat(name,' PECTORAL SPACE OUTPUT'))

        [boundaries, boundary_number] = bwboundaries(mlo_pectoral, 'noholes');

        hold on
        for k = 1:length(boundaries)
            boundary = boundaries{k};
            plot(boundary(:,2), boundary(:,1), 'cyan', 'LineWidth', 1);
        end

        % Negative space output

        subplot(1,3,2)
        imshow(breast_mlo);
        title(strcat(name,' NEGATIVE SPACE OUTPUT'))

        [boundaries, boundary_number] = bwboundaries(mlo_negative_area, 'noholes');

        hold on
        for k = 1:length(boundaries)
            boundary = boundaries{k};
            plot(boundary(:,2), boundary(:,1), 'cyan', 'LineWidth', 1);
        end

        % Final Image

        subplot(1,3,3)
        imshow(breast_image_double);
        title(strcat(name,' FINAL IMAGE'))

        [bwB3, boundary_number] = bwboundaries(breast_image, 'noholes');

        hold on
        for k = 1:length(bwB3)
            boundary = bwB3{k};
            plot(boundary(:,2), boundary(:,1), 'cyan', 'LineWidth', 1);
        end
    end
end