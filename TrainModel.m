% Read in train, test and name data
raw_data = readtable('./Data/ground_truth.csv');
train_data_extended = readtable('./Data/ground_truth_extended.csv');
raw_data = vertcat(raw_data, train_data_extended);

% Split the train set randomly 80:20
n = size(raw_data,1);
data_rand = raw_data(randperm(n),:);
m = ceil(n*0.8);
k = 1:m:n-m;

% Extract a train and test set
test_set = [data_rand(1:k-1,:); data_rand(k+m:end,:)];
train_set = data_rand(k:k+m-1,:);

% Extract the label of train and test sets
train_set_labels = train_set(:,21:21);
test_set_labels = table2array(test_set(:,21:21));

% Extract the ddata of train and test sets
train_set = train_set(:,1:20);
test_set = test_set(:,1:20);

% Performance PCA on the train set
[coeff, scores, eigenvalues] = pca(table2array(train_set));

% Extract first 5 Principal Components
reducedDimension = coeff(:,1:5);

% Reduce Dimensions of the train set and convert back to array
reduced_training_data = table2array(train_set) * reducedDimension;
reduced_training_data = array2table(reduced_training_data);

% Reduce test set to same dimensions
reduced_test_set = table2array(test_set) * reducedDimension;

trained_model_knn = fitcknn(train_set, train_set_labels);
trained_model_knn_reduced = fitcknn(reduced_training_data, train_set_labels);

% Train SVM from training data
trained_model_svm = fitcsvm(train_set, train_set_labels);
trained_model_svm_reduced = fitcsvm(reduced_training_data, train_set_labels);

% Train Decision from training data
trained_model_decision = fitctree(train_set, train_set_labels);
trained_model_decision_reduced = fitctree(reduced_training_data, train_set_labels);

% Show Scree plot
figure('Name','EIGENVALUES')
plot(eigenvalues, 'Marker', 'o','LineWidth', 1)
title('SCREE PLOT - EIGENVALUES ACROSS PRINCIPAL COMPONENTS')
xlabel('COMPONENT NUMBER')
ylabel('EIGENVALUE')

% Plot Eigenvalues for first two principal components
figure('Name','ORTHONORMAL PRINCIPAL COMPONENT COEFFICIENTS 1, 2 FOR EACH VARIABLE')
biplot(coeff(:,1:2),'scores',scores(:,1:2),'varlabels',{'autoc','contr','corrm','cprom','cshad','dissi','energy','entro','homom','maxpr','sosvh','savgh','svarh','senth','dvarh','denth','inf1h','inf2h','indnc','idmnc'});
title('ORTHONORMAL PRINCIPAL COMPONENT COEFFICIENTS FOR EACH VARIABLE')
legend('autoc','contr','corrm','cprom','cshad','dissi','energy','entro','homom','maxpr','sosvh','savgh','svarh','senth','dvarh','denth','inf1h','inf2h','indnc','idmnc')

% Plot Eigenvalues for first three principal components
figure('Name','ORTHONORMAL PRINCIPAL COMPONENT COEFFICIENTS 1, 2, 3 FOR EACH VARIABLE')
biplot(coeff(:,1:3),'scores',scores(:,1:3),'varlabels',{'autoc','contr','corrm','cprom','cshad','dissi','energy','entro','homom','maxpr','sosvh','savgh','svarh','senth','dvarh','denth','inf1h','inf2h','indnc','idmnc'});
title('ORTHONORMAL PRINCIPAL COMPONENT COEFFICIENTS FOR EACH VARIABLE')
legend('autoc','contr','corrm','cprom','cshad','dissi','energy','entro','homom','maxpr','sosvh','savgh','svarh','senth','dvarh','denth','inf1h','inf2h','indnc','idmnc')

% Predict test labels from test data
[label_knn, score_knn] = predict(trained_model_knn, test_set);
[label_svm, score_svm] = predict(trained_model_svm, test_set);
[label_decision, score_decision] = predict(trained_model_decision, test_set);

% Predict test labels from test data which has been reduced
[label_knn_reduced, score_knn_reduced] = predict(trained_model_knn_reduced, reduced_test_set);
[label_svm_reduced, score_svm_reduced] = predict(trained_model_svm_reduced, reduced_test_set);
[label_decision_reduced, score_decision_reduced] = predict(trained_model_decision_reduced, reduced_test_set);

% Calculate class performance for both
class_performance_knn = classperf(test_set_labels, label_knn);
class_performance_knn_reduced = classperf(test_set_labels, label_knn_reduced);

class_performance_svm = classperf(test_set_labels, label_svm);
class_performance_svm_reduced = classperf(test_set_labels, label_svm_reduced);

class_performance_decision = classperf(test_set_labels, label_decision);
class_performance_decision_reduced = classperf(test_set_labels, label_decision_reduced);



