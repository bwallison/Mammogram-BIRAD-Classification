function [stats] = CalculateStats(breast_image_mask, breast_image_double, breast_region_props, region_number)

    %define struct to hold the data
    stats = struct();    
    stats.region = zeros(1,region_number);
    stats.autoc = zeros(1,region_number); % Autocorrelation: 
    stats.contr = zeros(1,region_number); % Contrast: matlab
    stats.corrm = zeros(1,region_number); % Correlation: matlab
    stats.cprom = zeros(1,region_number); % Cluster Prominence:
    stats.cshad = zeros(1,region_number); % Cluster Shade:
    stats.dissi = zeros(1,region_number); % Dissimilarity:
    stats.energ = zeros(1,region_number); % Energy: matlab
    stats.entro = zeros(1,region_number); % Entropy:
    stats.homom = zeros(1,region_number); % Homogeneity: matlab
    stats.maxpr = zeros(1,region_number); % Maximum probability: 
    stats.sosvh = zeros(1,region_number); % Sum of sqaures: Variance
    stats.savgh = zeros(1,region_number); % Sum average
    stats.svarh = zeros(1,region_number); % Sum variance
    stats.senth = zeros(1,region_number); % Sum entropy
    stats.dvarh = zeros(1,region_number); % Difference variance
    stats.denth = zeros(1,region_number); % Difference entropy
    stats.inf1h = zeros(1,region_number); % Information measure of correlation1
    stats.inf2h = zeros(1,region_number); % Informaiton measure of correlation2
    stats.indnc = zeros(1,region_number); % Inverse difference normalized (INN)
    stats.idmnc = zeros(1,region_number); % Inverse difference moment normalized
    stats.area = zeros(1,region_number); % region area

    %count the number of regions which are not NaN
    breast_areas = region_number;

    % Loop extraction and GLCM calculation %
    for k = 1 : region_number
        % Extract bounding box
        bounding_box = breast_region_props(k).BoundingBox;
        % crop out sub image of box
        sub_image = imcrop(breast_image_double, bounding_box);
        % Get all pixels in this area equal to where the super pixel pixels are located
        subImagePixels = breast_image_mask == k;
        % Extract this mask from this subimage
        subImageMask = imcrop(subImagePixels, bounding_box);
        % Use mask and extract region sub image of segmentation
        sub_image = subImageMask.*sub_image;

        % GLCM %
        % Set non-useful pixels to NaN
        sub_image(sub_image < 0.05) = NaN;
        % Create GLCM matrix
        GLCM = graycomatrix(sub_image,'Offset',[2 0;0 2],'Symmetric',true);
        % Call GLCMFeaturesVectorised to extract textural features and
        % stored in current struct element
        stats(k) = GLCMFeaturesVectorised(GLCM,1);
        if sum(isnan(stats(k).autoc(1)))
            breast_areas = breast_areas - 1;
        end
        % Calculate area of the region
        stats(k).area = sum(sum(sub_image>0.05));
        % Store what region number this is in the struct
        stats(k).region = k;
    end
end