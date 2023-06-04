function [region_mask, region_number, region_props] = SLIC(breast_image_double, output_figure, name)
    
    % Call SLIC and store the mask and region numbers
    [region_mask, region_number] = superpixels(breast_image_double, 500, 'compactness', 40);

    % Extract region props to be able to plot the regions
    region_props = regionprops(region_mask,'BoundingBox','centroid','Area','PixelList');

    if output_figure == true
        
        % Extract centroids of segments
        centroids = round(cat(1, region_props.Centroid));

        % Isolate x and y co-ordinates of centroids
        centroids_x = centroids(:,1);
        centroids_y = centroids(:,2);
        
        boundary_mask = boundarymask(region_mask);
        
        % Plot the image, with segmentation regions and number on the
        % centroid of the regions
        figure('Name','SLIC')
        imshow(imoverlay(breast_image_double, boundary_mask,'cyan'),'InitialMagnification',67);
        for k = 1 : region_number         
            text(centroids_x(k) - 40, centroids_y(k), num2str(k),'color','red');
        end      
        title(strcat(name,' BREAST POST-SLIC'))
    end
end