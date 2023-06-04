% Read in train, test and name data
train_data = readtable('./Data/ground_truth.csv');
test_data = readtable('./Data/breast_test_stats.csv');
dataset = readtable('./Data/mammogram_test.xlsx');
%train_data_extended = readtable('./Data/ground_truth_extended.csv');

%train_data = vertcat(train_data, train_data_extended);
ground_truth = test_data(:,2);

% Split the train set randomly 80:20
n = size(train_data,2:2);
data_rand = train_data(randperm(n),:);
m = ceil(n*0.8);
k = 1:m:n-m;

% Extract data and labels into seperate variables
train_set = train_data(:,1:20);
train_set_labels = train_data(:,21);

% Extract area values of these regions and test data
area = test_data(:,26);
test_set = test_data(:,6:25);

% Perform PCA
[coeff, scores, eigenvalues] = pca(table2array(train_set));

% Extract first 5 Principal Components
reducedDimension = coeff(:,1:5);

% Reduce Dimensions of the train set and convert back to array
reduced_training_data = table2array(train_set) * reducedDimension;
train_set = array2table(reduced_training_data);

% Reduce test set to same dimensions
reduced_test_set = table2array(test_set) * reducedDimension;

% Train KNN from training data
trained_model = fitcknn(train_set, train_set_labels);

% Train SVM from training data
% trained_model = fitcsvm(train_set, train_set_labels);

% Train Decision from training data
% trained_model = fitctree(train_set, train_set_labels);

% Predict region classification
[label, score] = predict(trained_model, reduced_test_set);

% Initialise arrays to store totals
total_fat_area = zeros(50, 1);
total_fibroglandular_area = zeros(50, 1);
total_area = zeros(50, 1);
breast_ground_truth = zeros(50, 1);

% Loop through test data 
for n = 1:50
    % Extract what elements corresponding to this region
    breast_elements = find(table2array(test_data(:,1)) == n);
    % Extract the labels
    breast_label = label(breast_elements(1,1): breast_elements(size(breast_elements, 1),1),:);
    % Extract the areas
    breast_areas = table2array(area(breast_elements(1,1): breast_elements(size(breast_elements, 1),1),:));
    % Extract the ground truth of this segments classification
    breast_ground_truth(n) =  table2array(ground_truth(breast_elements(1,1),1));
    
    % Loop through each segment
    for m = 1:size(breast_elements)
        % Count fibroglandular area, fat area and total area
        if breast_label(m) == 1
            total_fibroglandular_area(n) = total_fibroglandular_area(n) + breast_areas(m);
        else
            total_fat_area(n) = total_fat_area(n) + breast_areas(m);
        end    
        total_area(n) = total_area(n) + breast_areas(m);
    end    
end

% Calculate percentage density
percentage_fibroglandular_area = rdivide(total_fibroglandular_area, total_area);

% Create array to store the BIRAD classification
classification = zeros(50, 1);

% Loop through the test regions
for n = 1:50
    % Assign BIRAD categories based on percentage density
    if percentage_fibroglandular_area(n) < 0.25
        classification(n) = 1;
    end
    if percentage_fibroglandular_area(n) >= 0.25 && percentage_fibroglandular_area(n) < 0.50 
        classification(n) = 2;
    end
    if percentage_fibroglandular_area(n) >= 0.50 && percentage_fibroglandular_area(n) < 0.75 
        classification(n) = 3;
    end
    if percentage_fibroglandular_area(n) >= 0.75  
        classification(n) = 4;
    end
end

% Compare the performance of the classification with the ground truths of each breast 
CP_reduced = classperf(breast_ground_truth , classification);



