% Flag to display output
output_figure = true;

% Reads in the test set information
test_set = table2cell(readtable('.\mammograms_test\mammogram_test.xlsx'));

% Flags to determine the orientation
is_mlo = false;
is_left = false;
    
% Loop through test set
for test_number = 1: size(test_set, 1)
    % Get the file path of the current image
    file_path = strcat('.\mammograms_test\', cellstr(test_set(test_number, 5)));
        
    % Determine whether it is left or right breast
    if ismember(test_set{test_number, 3}, 'LEFT')
        is_left = true;
    else
        is_left = false;
    end      
    
    % Determine whether it is cc or mlo breast
    if ismember(test_set{test_number, 4}, 'MLO')
        is_mlo = true;
    else
        is_mlo = false;
    end  
  
    % read in and convert current breast image
    breast_mlo = im2double(dicomread(file_path{1}));

    % Segment Image
    if is_left
        [breast_mlo_double] = Segmentation(breast_mlo, output_figure, 'Left');
    else
        breast_mlo = breast_mlo(:,end:-1:1,:);
        [breast_mlo_double] = Segmentation(breast_mlo, output_figure, 'RIGHT');
    end

    % Clear useless data from memory
    deleted_variables = {'breast_mlo', 'deleted_variables'};
    clear (deleted_variables{:})

    % Histogram equalisation
    if is_left
        [breast_mlo_double] = HistogramEqualisation(breast_mlo_double, output_figure, 'LEFT');
    else
        [breast_mlo_double] = HistogramEqualisation(breast_mlo_double, output_figure, 'RIGHT');
    end

    % SLIC segmentation
    if is_left
        [breast_regions, breast_region_number, breast_region_props] = SLIC(breast_mlo_double, output_figure, 'LEFT'); 
    else
        [breast_regions, breast_region_number, breast_region_props] = SLIC(breast_mlo_double, output_figure, 'RIGHT'); 
    end

    % Calculate stats of mammogram
    breast_stats = CalculateStats(breast_regions, breast_mlo_double, breast_region_props , breast_region_number);
    
    % Remove useless data
    breast_stats = squeeze((struct2table(breast_stats)));
    breast_stats = rmmissing(breast_stats);
    
    % Create a table of other useful information and append to stats table
    name(1:height(breast_stats), 1) = test_set(test_number,1);
    classification(1:height(breast_stats), 1) = test_set(test_number,2);
    lr(1:height(breast_stats), 1) = test_set(test_number,3);
    ccmlo(1:height(breast_stats), 1) = test_set(test_number,4);
    breast_stats = [table(name, classification, lr, ccmlo) breast_stats];
    
    % Clear useless data from memory
    delete_variables = {'name','classification', 'lr', 'ccmlo' 'delete_variables'};
    clear(delete_variables{:})
    
    % If test number 1 create the file, if not append to global stored stats table
    if test_number == 1
        all_breast_stats = breast_stats;
        writetable(all_breast_stats, 'breast_training_stats.csv');
    else
        all_breast_stats = vertcat(all_breast_stats, breast_stats);
        writetable(all_breast_stats,'breast_training_stats.csv');
    end
end