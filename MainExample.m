% Flag to display output
output_figure = false;

% Read case test input
left_mlo = im2double(dicomread('.\mammograms\Calc-Test_P_00038_LEFT_MLO\1.3.6.1.4.1.9590.100.1.2.384159464510350889125645400702639717613\1.3.6.1.4.1.9590.100.1.2.174390361112646747718661211471328897934\000000.dcm'));
right_mlo = im2double(dicomread('.\mammograms\Calc-Test_P_00038_RIGHT_MLO\1.3.6.1.4.1.9590.100.1.2.328421320411501709324953698601549885215\1.3.6.1.4.1.9590.100.1.2.44262460211112930513355519060642708846\000000.dcm'));

% Segment images

right_mlo = right_mlo(:,end:-1:1,:);
[left_breast_double] = Segmentation(left_mlo, output_figure, 'LEFT');
[right_breast_double] = Segmentation(right_mlo, output_figure, 'RIGHT');

deleted_variables = {'left_mlo', 'right_mlo', 'deleted_variables'};
clear (deleted_variables{:})

% Histogram Equalisation
[left_breast_double] = HistogramEqualisation(left_breast_double, output_figure, 'LEFT');
[right_breast_double] = HistogramEqualisation(right_breast_double, output_figure, 'RIGHT');

% SLIC segmentation

[left_regions, left_region_number, left_region_props] = SLIC(left_breast_double, output_figure, 'LEFT'); 
[right_regions, right_region_number, right_region_props] = SLIC(right_breast_double, output_figure, 'RIGHT'); 

% Subimage Extraction
% Example Extraction
if output_figure == true
    bounding_box = left_region_props(101).BoundingBox;
    sub_image = imcrop(left_breast_double, bounding_box);
    sub_image_pixels = left_regions == 101;
    sub_image_mask = imcrop(sub_image_pixels, bounding_box);
    sub_image = sub_image_mask.*sub_image;

    figure('Name','IMAGE SEGMENT 101 OF LEFT BREAST')
    imshow(sub_image);
    title('IMAGE SEGMENT 101 OF LEFT BREAST')
end

% Example stats calculation for all regions
left_stats = CalculateStats(left_regions, left_breast_double, left_region_props , left_region_number);
right_stats = CalculateStats(right_regions, right_breast_double, right_region_props , right_region_number);

