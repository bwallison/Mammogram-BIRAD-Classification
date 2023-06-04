function [out] = GLCMFeaturesVectorised(glcmin, pairs)

% If 'pairs' not entered: set pairs to 0 
if ((nargin > 2) || (nargin == 0))
   error('Too many or too few input arguments. Enter GLCM and pairs.');
elseif ( (nargin == 2) ) 
    if ((size(glcmin,1) <= 1) || (size(glcmin,2) <= 1))
       error('The GLCM should be a 2-D or 3-D matrix.');
    elseif ( size(glcmin,1) ~= size(glcmin,2) )
        error('Each GLCM should be square with NumLevels rows and NumLevels cols');
    end    
elseif (nargin == 1) % only GLCM is entered
    pairs = 0; % default is numbers and input 1 for percentage
    if ((size(glcmin,1) <= 1) || (size(glcmin,2) <= 1))
       error('The GLCM should be a 2-D or 3-D matrix.');
    elseif ( size(glcmin,1) ~= size(glcmin,2) )
       error('Each GLCM should be square with NumLevels rows and NumLevels cols');
    end    
end

% Handling symmetry
format long e
if (pairs == 1)
    newn = 1;
    for nglcm = 1:2:size(glcmin,3)
        glcm(:,:,newn)  = glcmin(:,:,nglcm) + glcmin(:,:,nglcm+1);
        newn = newn + 1;
    end
elseif (pairs == 0)
    glcm = glcmin;
end

% GLCM for multiple dimensions
size_glcm_1 = size(glcm,1);
size_glcm_2 = size(glcm,2);
size_glcm_3 = size(glcm,3);

% Output texture struct
out.region = zeros(1,size_glcm_3); % Region number
out.autoc = zeros(1,size_glcm_3);  % Autocorrelation
out.contr = zeros(1,size_glcm_3);  % Contrast: matlab
out.corrm = zeros(1,size_glcm_3);  % Correlation: matlab
out.cprom = zeros(1,size_glcm_3);  % Cluster Prominence
out.cshad = zeros(1,size_glcm_3);  % Cluster Shade
out.dissi = zeros(1,size_glcm_3);  % Dissimilarity
out.energ = zeros(1,size_glcm_3);  % Energy: matlab
out.entro = zeros(1,size_glcm_3);  % Entropy
out.homom = zeros(1,size_glcm_3);  % Homogeneity: matlab
out.maxpr = zeros(1,size_glcm_3);  % Maximum probability
out.sosvh = zeros(1,size_glcm_3);  % Sum of sqaures: Variance
out.savgh = zeros(1,size_glcm_3);  % Sum average 
out.svarh = zeros(1,size_glcm_3);  % Sum variance
out.senth = zeros(1,size_glcm_3);  % Sum entropy
out.dvarh = zeros(1,size_glcm_3);  % Difference variance
out.denth = zeros(1,size_glcm_3);  % Difference entropy
out.inf1h = zeros(1,size_glcm_3);  % Information measure of correlation1
out.inf2h = zeros(1,size_glcm_3);  % Informaiton measure of correlation2 
out.indnc = zeros(1,size_glcm_3);  % Inverse difference normalized (INN)
out.idmnc = zeros(1,size_glcm_3);  % Inverse difference moment normalized 
out.area = zeros(1,size_glcm_3);   % Segment pixel area

% Store statistics used in other calculations
glcm_sum  = zeros(size_glcm_3,1);
glcm_mean = zeros(size_glcm_3,1);
glcm_var  = zeros(size_glcm_3,1);


u_x = zeros(size_glcm_3,1);
u_y = zeros(size_glcm_3,1);
s_x = zeros(size_glcm_3,1);
s_y = zeros(size_glcm_3,1);

% checked p_x p_y p_xplusy p_xminusy
p_x = zeros(size_glcm_1,size_glcm_3); 
p_y = zeros(size_glcm_2,size_glcm_3); 
p_xplusy = zeros((size_glcm_1*2 - 1),size_glcm_3); 
p_xminusy = zeros((size_glcm_1),size_glcm_3); 

% checked hxy hxy1 hxy2 hx hy
hxy  = zeros(size_glcm_3,1);
hxy1 = zeros(size_glcm_3,1);
hx   = zeros(size_glcm_3,1);
hy   = zeros(size_glcm_3,1);
hxy2 = zeros(size_glcm_3,1);

corm = zeros(size_glcm_3,1);
corp = zeros(size_glcm_3,1);

for k = 1:size_glcm_3
    
    glcm_sum(k) = sum(sum(glcm(:,:,k)));    % Compute sum
    glcm(:,:,k) = glcm(:,:,k)./glcm_sum(k); % Normalize each glcm
    glcm_mean(k) = mean2(glcm(:,:,k));      % Compute mean after norm
    glcm_var(k)  = (std2(glcm(:,:,k)))^2;   % Compute variance
    
    for i = 1:size_glcm_1
        
        for j = 1:size_glcm_2
            p_x(i,k) = p_x(i,k) + glcm(i,j,k); 
            p_y(i,k) = p_y(i,k) + glcm(j,i,k); 
            p_xplusy((i+j)-1,k) = p_xplusy((i+j)-1,k) + glcm(i,j,k);
            p_xminusy((abs(i-j))+1,k) = p_xminusy((abs(i-j))+1,k) +...
                glcm(i,j,k);
        end
    end
    
end

i_matrix  = repmat([1:size_glcm_1]',1,size_glcm_2);
j_matrix  = repmat([1:size_glcm_2],size_glcm_1,1);
i_index   = j_matrix(:);
j_index   = i_matrix(:);
xplusy_index = [1:(2*(size_glcm_1)-1)]';
xminusy_index = [0:(size_glcm_1-1)]';
mul_contr = abs(i_matrix - j_matrix).^2;
mul_dissi = abs(i_matrix - j_matrix);

for k = 1:size_glcm_3 % number glcms
    
    % Calculate contrast
    out.contr(k) = sum(sum(mul_contr.*glcm(:,:,k)));
    % Calculate Dissimilarity
    out.dissi(k) = sum(sum(mul_dissi.*glcm(:,:,k)));
    % Calculate Energy    
    out.energ(k) = sum(sum(glcm(:,:,k).^2));
    % Calculate Entropy
    out.entro(k) = - sum(sum((glcm(:,:,k).*log(glcm(:,:,k) + eps))));
    % Calculate Homogeneity
    out.homom(k) = sum(sum((glcm(:,:,k)./( 1 + mul_dissi))));
    % Calculate  Sum of sqaures: Variance 
    out.sosvh(k) = sum(sum(glcm(:,:,k).*((i_matrix - glcm_mean(k)).^2)));
    % Calculate Inverse difference normalized
    out.indnc(k) = sum(sum(glcm(:,:,k)./( 1 + (mul_dissi./size_glcm_1) )));
    % Calculate Inverse difference moment normalized 
    out.idmnc(k) = sum(sum(glcm(:,:,k)./( 1 + (mul_contr./(size_glcm_1^2)))));
    % Calculate Maximum probability
    out.maxpr(k) = max(max(glcm(:,:,k)));
    
    u_x(k)       = sum(sum(i_matrix.*glcm(:,:,k))); 
    u_y(k)       = sum(sum(j_matrix.*glcm(:,:,k))); 
    
    s_x(k)  = (sum(sum( ((i_matrix - u_x(k)).^2).*glcm(:,:,k) )))^0.5;
    s_y(k)  = (sum(sum( ((j_matrix - u_y(k)).^2).*glcm(:,:,k) )))^0.5;
   

   % Calculate Autocorrelation    
   corp(k) = sum(sum((i_matrix.*j_matrix.*glcm(:,:,k))));
   % Calculate Correlation: matlab   
   corm(k) = sum(sum(((i_matrix - u_x(k)).*(j_matrix - u_y(k)).*glcm(:,:,k)))); 
   
   % Calculate Autocorrelation
   out.autoc(k) = corp(k);
   % Calculate Correlation: matlab
   out.corrm(k) = corm(k) / (s_x(k)*s_y(k)); 
   % Calculate Cluster Prominence
   out.cprom(k) = sum(sum(((i_matrix + j_matrix - u_x(k) - u_y(k)).^4).*...
                glcm(:,:,k))); 
   % Calculate Cluster Shade          
   out.cshad(k) = sum(sum(((i_matrix + j_matrix - u_x(k) - u_y(k)).^3).*...
                glcm(:,:,k)));        
   % Calculate Sum average 
   out.savgh(k) = sum((xplusy_index + 1).*p_xplusy(:,k));
   % Calculate Sum entropy
   out.senth(k) =  - sum(p_xplusy(:,k).*...
            log(p_xplusy(:,k) + eps));
   % Calculate Sum variance
   out.svarh(k) = sum((((xplusy_index + 1) - out.senth(k)).^2).*...
        p_xplusy(:,k));
   % Calculate Difference entropy
    out.denth(k) = - sum((p_xminusy(:,k)).*...
        log(p_xminusy(:,k) + eps));
   % Calculate Difference variance
    out.dvarh(k) = sum((xminusy_index.^2).*p_xminusy(:,k));
    
   % Calculate information measure of correlation (1,2)
    hxy(k) = out.entro(k);
    glcmk  = glcm(:,:,k)';
    glcmkv = glcmk(:);
    
    hxy1(k) =  - sum(glcmkv.*log(p_x(i_index,k).*p_y(j_index,k) + eps));
    hxy2(k) =  - sum(p_x(i_index,k).*p_y(j_index,k).*...
        log(p_x(i_index,k).*p_y(j_index,k) + eps));
     hx(k) = - sum(p_x(:,k).*log(p_x(:,k) + eps));
     hy(k) = - sum(p_y(:,k).*log(p_y(:,k) + eps));   
    
    out.inf1h(k) = ( hxy(k) - hxy1(k) ) / ( max([hx(k),hy(k)]) );
    out.inf2h(k) = ( 1 - exp( -2*( hxy2(k) - hxy(k) ) ) )^0.5;          
end

