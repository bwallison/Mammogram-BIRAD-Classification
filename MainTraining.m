% Flag to display output
output_figure = true;

% Reads in the train set information
train_set = table2cell(readtable('.\mammograms_training\mammogram_training.xlsx'));

% Flags to determine the orientation
is_mlo = false;
is_left = false;
 
% Loop through train set
for train_number = 1: size(train_set, 1)
    % Get the file path of the current image
    file_path = strcat('.\mammograms_training\', cellstr(train_set(train_number, 5)));
    
    % Determine whether it is left or right breast 
    if ismember(train_set{train_number, 3}, 'LEFT')
        is_left = true;
    else
        is_left = false;
    end     
    
    % Determine whether it is cc or mlo breast    
    if ismember(train_set{train_number, 4}, 'MLO')
        is_mlo = true;
    else
        is_mlo = false;
    end  
  
    % read in and convert current breast image
    breast_mlo = im2double(dicomread(file_path{1}));

    % Segment image
    if is_left
        [breast_mlo_double] = Segmentation(breast_mlo, output_figure, 'LEFT');
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
    name(1:height(breast_stats), 1) = train_set(train_number,1);
    classification(1:height(breast_stats), 1) = train_set(train_number,2);
    lr(1:height(breast_stats), 1) = train_set(train_number,3);
    ccmlo(1:height(breast_stats), 1) = train_set(train_number,4);
    breast_stats = [table(name, classification, lr, ccmlo) breast_stats];
    
    % Clear useless data from memory
    delete_variables = {'name','classification', 'lr', 'ccmlo' 'delete_variables'};
    clear(delete_variables{:})
    
    % If test number 1 create the file, if not append to global stored stats table   
    if train_number == 1
        all_breast_stats = breast_stats;
        writetable(all_breast_stats, 'breast_training_stats.csv');
    else
        all_breast_stats = vertcat(all_breast_stats, breast_stats);
        writetable(all_breast_stats,'breast_training_stats.csv');
    end
end


%https://ac.els-cdn.com/S1877050915001817/1-s2.0-S1877050915001817-main.pdf?_tid=531c1f8e-d3bc-11e7-83aa-00000aab0f02&acdnat=1511819326_2c674886583c0ba06dde9f493eb51719