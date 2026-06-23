%% Sleep-memory clusters
%  Loading Data
data=readtable('Sleep_Variables_090225.xlsx','Sheet','PCA');
% data=readtable('Sleep_PCA_Means_with_PC_Scores');

% Define the list of subject names to extract
subject_names = ["Sub_005","Sub_006", "Sub_007","Sub_009","Sub_010", ...
                 "Sub_011","Sub_012", "Sub_013", "Sub_015", ...
                 "Sub_017", "Sub_019", "Sub_020", "Sub_022", "Sub_023", ...
                 "Sub_027", "Sub_028", ...
                 "Sub_032", "Sub_033","Sub_034", "Sub_035","Sub_037","Sub_039",...
                 "Sub_040","Sub_041","Sub_042","Sub_043","Sub_044","Sub_045","Sub_046","Sub_048", ...
                 "Sub_050","Sub_052","Sub_053","Sub_054","Sub_055",...
                 "Sub_201","Sub_202", ...
                 "Sub_203", "Sub_204", "Sub_205", "Sub_207","Sub_209",...
                 "Sub_210", "Sub_212", "Sub_213", "Sub_214","Sub_215","Sub_216", "Sub_217", "Sub_219", ...
                 "Sub_223","Sub_225","Sub_226","Sub_227","Sub_228","Sub_229","Sub_230","Sub_231","Sub_232","Sub_233",...
                 "Sub_234","Sub_235","Sub_237","Sub_238","Sub_239","Sub_240",...
                 "Sub_242","Sub_243","Sub_245","Sub_246"];

% Replace 'Sub_Sleep_' with 'Sub_' in the 'Row Labels' column to match the format
 % data.subid = strrep(data.subid, 'sub_sleep_', 'Sub_');
  data.RowLabels = strrep(data.RowLabels, 'Sub_Sleep_', 'Sub_');
% Filter the table based on the subject names
filtered_data = data(ismember(data.RowLabels, subject_names), :);
Age = ['Young','Young','Young','Young','Young','Young','Young','Young','Young','Young','Young','Young','Young','Young','Young','Young','Young','Young','Young',"Young","Young","Young","Young","Young","Young","Young","Young","Young","Young","Young","Young","Young","Young","Young","Young",'Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old','Old'];

Age=Age';
% Display the filtered table
%disp(filtered_data);

RSA_Hit=zeros(70,4,26,26);
RSA_Miss=zeros(70,4,26,26);
Hit_Miss=zeros(70,4,22,22);

for S=1:height(filtered_data)
RSA_Hit_data=load('/Users/mseraji1/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/Documents - PSYC-Research-Duarte_Lab/Sleep Study/ERP Project/Analysis & Preprocessed Data/Preproccessed EEG (Masoud)/Retrieval Day 2/updated/Ret2_power/RSA_Hit_with_bit_2/' + subject_names(S)+'RSA_Hit.mat');
RSA_Miss_data=load('/Users/mseraji1/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/Documents - PSYC-Research-Duarte_Lab/Sleep Study/ERP Project/Analysis & Preprocessed Data/Preproccessed EEG (Masoud)/Retrieval Day 2/updated/Ret2_power/RSA_Miss_with_bit_2/' + subject_names(S) +'RSA_Miss.mat');
RSA_CR_data=load('/Users/mseraji1/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/Documents - PSYC-Research-Duarte_Lab/Sleep Study/ERP Project/Analysis & Preprocessed Data/Preproccessed EEG (Masoud)/Retrieval Day 2/updated/Ret2_power/RSA_CR_with_bit_2/' + subject_names(S)+'RSA_CR.mat');
RSA_FA_data=load('/Users/mseraji1/Library/CloudStorage/OneDrive-TheUniversityofTexasatAustin/Documents - PSYC-Research-Duarte_Lab/Sleep Study/ERP Project/Analysis & Preprocessed Data/Preproccessed EEG (Masoud)/Retrieval Day 2/updated/Ret2_power/RSA_FA_with_bit_2/' + subject_names(S) +'RSA_FA.mat');

RSA_Hit(S,:,:,:)=double(RSA_Hit_data.With_Bet);
RSA_Miss(S,:,:,:)=double(RSA_Miss_data.With_Bet);
Hit_Miss(S,:,:,:)=RSA_Hit(S,:,5:26,5:26)-RSA_Miss(S,:,5:26,5:26);
RSA_CR(S,:,:,:)=double(RSA_CR_data.With_Bet);
RSA_FA(S,:,:,:)=double(RSA_FA_data.With_Bet);
CR_FA(S,:,:,:)=RSA_CR(S,:,5:26,5:26)-RSA_FA(S,:,5:26,5:26);

end

p_values = zeros(4, 22, 22);
t_values = zeros(4, 22, 22);
t_age_model1= zeros(4, 22, 22);
t_sleep_model1= zeros(4, 22, 22);
t_interaction= zeros(4, 22, 22);
p_age_model1=zeros(4, 22, 22);
p_sleep_model1=zeros(4, 22, 22);
p_interaction=zeros(4, 22, 22);
% Running Regression
for i = 1:4
    for j = 1:22
        for k = 1:22
sleep=filtered_data.pc1_ret;
sub=filtered_data.RowLabels;
HitMiss=Hit_Miss(:,i,j,k);
data1= table(sub, Age,HitMiss,sleep);

             model1 = fitlm(data1, 'HitMiss ~  Age + sleep ');
           

             model2 = fitlm(data1, 'HitMiss ~ Age + sleep + Age*sleep');

             disp(model2.Coefficients)

% Extract p-value for interaction
             p_age_model1(i, j, k)  = model2.Coefficients.pValue(2);
             t_age_model1(i, j, k)  = model2.Coefficients.tStat(2);
             p_sleep_model1(i, j, k) = model2.Coefficients.pValue(3);
             t_sleep_model1(i, j, k) = model2.Coefficients.tStat(3);

            p_interaction(i, j, k) = model2.Coefficients.pValue(4);
            t_interaction(i, j, k) = model2.Coefficients.tStat(4);
           
        end
    end
end


%% Correction of P-values
for i=1:4
[corrected_pvalues(i,:,:)] = mult_comp_correction(squeeze(    p_interaction(i,:,:)), 10000);
end

%% Plot
t_values = t_interaction;

% Define the time range with a window size of 300 ms and a step of 100 ms
start_time = 0;
end_time = 2400;
step_size = 100;   
num_windows = 22;  

% Adjust the time range
time_range = start_time:step_size:(start_time + step_size*(num_windows-1));

% Shift the time_range by 50 ms to center the data
shifted_time_range = time_range + step_size / 2;

% Create a figure to hold the subplots
figure;

% Loop through each region
for i = 1:4
    % Extract the p-values and t-values for the current region
    region_p_values = squeeze(corrected_pvalues(i, :, :));
    region_t_values = squeeze(t_values(i, :, :));
    
    threshold = 0.05;

    % Custom colors
    blue_color = [0, 0.37, 0.74];
    red_color  = [0.64, 0, 0.2];

    % Custom colormap: blue for negative, white for neutral, red for positive
    custom_colormap = [blue_color; 1 1 1; red_color];

    % Create a binary mask where p-values < threshold
    significant_mask = region_p_values < threshold;
    
    % Create an empty mask for the expanded clusters based on t-value polarity
    colored_mask = zeros(size(significant_mask));

    % Loop through each significant bin and expand based on polarity
    for row = 1:size(significant_mask, 1)
        for col = 1:size(significant_mask, 2)
            if significant_mask(row, col) == 1
                cluster_t = region_t_values(row, col);
                
                if cluster_t > 0
                    colored_mask(max(row-1,1):min(row+1,num_windows), ...
                                 max(col-1,1):min(col+1,num_windows)) = 1;
                elseif cluster_t < 0
                    colored_mask(max(row-1,1):min(row+1,num_windows), ...
                                 max(col-1,1):min(col+1,num_windows)) = -1;
                end
            end
        end
    end

    % Plot significant clusters
    subplot(2, 2, i);
    imagesc(shifted_time_range, shifted_time_range, colored_mask);
    colormap(gca, custom_colormap);
    caxis([-1 1]);
    xlabel('Retrieval (ms)','FontSize',16,'FontWeight','bold');
    ylabel('Encoding (ms)','FontSize',16,'FontWeight','bold');
    set(gca, 'YDir', 'normal');
    axis equal tight;
    set(gca, 'FontSize', 14);

    %% -------- Find connected significant clusters --------
    CC = bwconncomp(significant_mask, 8);   % 8-connected clusters

    fprintf('=============================\n');
    fprintf('Region %d Significant Clusters:\n', i);

    if CC.NumObjects == 0
        fprintf('No significant clusters found.\n\n');
        continue;
    end

    for c = 1:CC.NumObjects
        % Get row/col indices of current cluster
        [rows, cols] = ind2sub(size(significant_mask), CC.PixelIdxList{c});

        % Convert cluster indices to time values
        enc_times = shifted_time_range(rows);
        ret_times = shifted_time_range(cols);

        % Cluster interval
        enc_start = min(enc_times);
        enc_end   = max(enc_times);
        ret_start = min(ret_times);
        ret_end   = max(ret_times);

        % Extract t and p values for all bins in this cluster
        cluster_tvals = region_t_values(CC.PixelIdxList{c});
        cluster_pvals = region_p_values(CC.PixelIdxList{c});

        % Representative statistics:
        % peak absolute t and minimum p
        [~, idx_peak] = max(abs(cluster_tvals));
        peak_t = cluster_tvals(idx_peak);
        min_p  = min(cluster_pvals);

        % Also report cluster size
        cluster_size = numel(CC.PixelIdxList{c});

        fprintf('Cluster %d:\n', c);
        fprintf('  Size                = %d bins\n', cluster_size);
        fprintf('  Encoding interval   = %.0f-%.0f ms\n', enc_start, enc_end);
        fprintf('  Retrieval interval  = %.0f-%.0f ms\n', ret_start, ret_end);
        fprintf('  Peak t-statistic    = %.3f\n', peak_t);

        if min_p < 0.001
            fprintf('  Minimum p-value     = < 0.001\n');
        else
            fprintf('  Minimum p-value     = %.3f\n', min_p);
        end

        fprintf('\n');
    end
end
%% ============================================================
% Separate Young and Old sleep-ERS relationships
% within each significant Age x Sleep interaction cluster
%% ============================================================

threshold = 0.05;
step_size = 100;
t_axis = (0:step_size:(step_size*21)) + step_size/2;   % 50:100:2150

% predictor
sleep_all = filtered_data.pc1_ret(:);

% group indices
young_idx = 1:35;
old_idx   = 36:70;

% optional: store results
group_cluster_results = struct();

for region_to_use = 1:4
    
    fprintf('\n========================================\n');
    fprintf('REGION %d\n', region_to_use);
    fprintf('========================================\n');
    
    % interaction-significant mask for this region
    mask = squeeze(corrected_pvalues(region_to_use,:,:)) < threshold;
    
    % subject data for this region
    dataMat = squeeze(Hit_Miss(:,region_to_use,:,:));   % 70 x 22 x 22
    
    % find connected clusters
    CC = bwconncomp(mask, 8);
    num_clusters = CC.NumObjects;
    
    if num_clusters == 0
        fprintf('No significant interaction clusters found in Region %d.\n', region_to_use);
        group_cluster_results(region_to_use).clusters = [];
        continue;
    end
    
    % sort clusters by size (largest first)
    cluster_sizes = cellfun(@numel, CC.PixelIdxList);
    [~, sortOrder] = sort(cluster_sizes, 'descend');
    
    L_sorted = zeros(size(mask));
    for newID = 1:num_clusters
        oldID = sortOrder(newID);
        L_sorted(CC.PixelIdxList{oldID}) = newID;
    end
    
    % average ERS within each cluster for each subject
    avg_cluster = nan(70, num_clusters);
    
    for c = 1:num_clusters
        cluster_idx = (L_sorted == c);   % 22x22 logical
        
        for s = 1:70
            tmp = squeeze(dataMat(s,:,:));   % 22x22
            avg_cluster(s,c) = mean(tmp(cluster_idx), 'omitnan');
        end
    end
    
    % per-cluster analysis
    region_results = struct([]);
    
    for c = 1:num_clusters
        y = avg_cluster(:,c);
        
        % cluster timing
        [rr, cc] = find(L_sorted == c);
        enc_ms = t_axis(rr);
        ret_ms = t_axis(cc);
        
        % young data
        xY = sleep_all(young_idx);
        yY = y(young_idx);
        validY = ~isnan(xY) & ~isnan(yY);
        xY = xY(validY);
        yY = yY(validY);
        
        % old data
        xO = sleep_all(old_idx);
        yO = y(old_idx);
        validO = ~isnan(xO) & ~isnan(yO);
        xO = xO(validO);
        yO = yO(validO);
        
        % ---- Young regression ----
        mdlY = fitlm(xY, yY);
        slopeY = mdlY.Coefficients.Estimate(2);
        tY     = mdlY.Coefficients.tStat(2);
        pY     = mdlY.Coefficients.pValue(2);
        rY     = corr(xY, yY, 'Rows','complete');
        
        % ---- Old regression ----
        mdlO = fitlm(xO, yO);
        slopeO = mdlO.Coefficients.Estimate(2);
        tO     = mdlO.Coefficients.tStat(2);
        pO     = mdlO.Coefficients.pValue(2);
        rO     = corr(xO, yO, 'Rows','complete');
        
        % print
        fprintf('\nCluster %d\n', c);
        fprintf('  Size = %d bins\n', sum(L_sorted(:)==c));
        fprintf('  Encoding interval  = %.0f-%.0f ms\n', min(enc_ms), max(enc_ms));
        fprintf('  Retrieval interval = %.0f-%.0f ms\n', min(ret_ms), max(ret_ms));
        
        fprintf('  Young: r = %.3f, slope = %.4f, t = %.3f, p = %.4f\n', ...
            rY, slopeY, tY, pY);
        fprintf('  Old:   r = %.3f, slope = %.4f, t = %.3f, p = %.4f\n', ...
            rO, slopeO, tO, pO);
        
        % store
        region_results(c).cluster_id = c;
        region_results(c).size = sum(L_sorted(:)==c);
        region_results(c).enc_interval = [min(enc_ms) max(enc_ms)];
        region_results(c).ret_interval = [min(ret_ms) max(ret_ms)];
        
        region_results(c).young_r = rY;
        region_results(c).young_slope = slopeY;
        region_results(c).young_t = tY;
        region_results(c).young_p = pY;
        
        region_results(c).old_r = rO;
        region_results(c).old_slope = slopeO;
        region_results(c).old_t = tO;
        region_results(c).old_p = pO;
    end
    
    group_cluster_results(region_to_use).clusters = region_results;
end
%% ============================================================
% Save cluster-wise Young/Old sleep-ERS results to Excel
%% ============================================================

outFile = 'InteractionCluster_YoungOld_SleepRelations_Hit_Miss.xlsx';

% create one row per cluster
allRows = {};

for region_to_use = 1:numel(group_cluster_results)
    
    if ~isfield(group_cluster_results(region_to_use), 'clusters') || isempty(group_cluster_results(region_to_use).clusters)
        continue;
    end
    
    clusters = group_cluster_results(region_to_use).clusters;
    
    for c = 1:numel(clusters)
        allRows(end+1,:) = { ...
            region_to_use, ...
            clusters(c).cluster_id, ...
            clusters(c).size, ...
            clusters(c).enc_interval(1), ...
            clusters(c).enc_interval(2), ...
            clusters(c).ret_interval(1), ...
            clusters(c).ret_interval(2), ...
            clusters(c).young_r, ...
            clusters(c).young_slope, ...
            clusters(c).young_t, ...
            clusters(c).young_p, ...
            clusters(c).old_r, ...
            clusters(c).old_slope, ...
            clusters(c).old_t, ...
            clusters(c).old_p ...
            };
    end
end

% convert to table
ResultsTable = cell2table(allRows, ...
    'VariableNames', { ...
    'Region', ...
    'ClusterID', ...
    'ClusterSize_bins', ...
    'EncodingStart_ms', ...
    'EncodingEnd_ms', ...
    'RetrievalStart_ms', ...
    'RetrievalEnd_ms', ...
    'Young_r', ...
    'Young_Slope', ...
    'Young_t', ...
    'Young_p', ...
    'Old_r', ...
    'Old_Slope', ...
    'Old_t', ...
    'Old_p'});

% optional: add region labels
regionNames = ["Left frontal","Right frontal","Left posterior","Right posterior"];
ResultsTable.RegionLabel = regionNames(ResultsTable.Region)';

% move RegionLabel next to Region
ResultsTable = movevars(ResultsTable, 'RegionLabel', 'After', 'Region');

% write to excel
writetable(ResultsTable, outFile, 'Sheet', 'YoungOld_FollowUp');

fprintf('Results saved to %s\n', outFile);
%% Brain + inset t-maps (continuous t-values, masked by p<0.05)

brain_png = 'brain2.png';   % <-- your white brain top-view PNG

% ---- time axis for 22x22 ----
step_size   = 100;
num_windows = 22;
time_range  = 0:step_size:(step_size*(num_windows-1));
t_axis      = time_range + step_size/2;  % 50,150,...,2150

% ---- t-maps ----
tmap_LF = squeeze(t_interaction(1,:,:));
tmap_RF = squeeze(t_interaction(2,:,:));
tmap_LP = squeeze(t_interaction(3,:,:));
tmap_RP = squeeze(t_interaction(4,:,:));

% ---- corrected p-values ----
p_LF = squeeze(corrected_pvalues(1,:,:));
p_RF = squeeze(corrected_pvalues(2,:,:));
p_LP = squeeze(corrected_pvalues(3,:,:));
p_RP = squeeze(corrected_pvalues(4,:,:));

alpha_thr = 0.05;

% ---- mask (keep continuous t but only where significant) ----
radius = 1;  % <-- this is your “extension”: 1 = 3x3 neighborhood (row±1, col±1)

M_LF = extend_sig_tmap(tmap_LF, p_LF, alpha_thr, radius);
M_RF = extend_sig_tmap(tmap_RF, p_RF, alpha_thr, radius);
M_LP = extend_sig_tmap(tmap_LP, p_LP, alpha_thr, radius);
M_RP = extend_sig_tmap(tmap_RP, p_RP, alpha_thr, radius);

% ===== manually remove unwanted cluster =====
 M_RF(6:11, 8:13) = NaN;
 M_LP(13:19, 13:17) = NaN;
% M_LF(1:6, 9:13) = NaN;
% M_LF(10:13, 17:21) = NaN;
% M_RF(18:21, 12:15) = NaN;
% M_LP(14:19, 16:20) = NaN;

%% ===== FIGURE =====
figure('Color','w','Units','pixels','Position',[80 80 700 500]);
set(gcf,'InvertHardcopy','off');

% ===== background brain (fix black from PNG transparency) =====
ax_bg = axes('Position',[0 0 0.9 0.9]);
set(ax_bg,'Color','w'); axis(ax_bg,'off'); hold(ax_bg,'on');

[I,~,alpha] = imread(brain_png);
if ~isempty(alpha)
    white = uint8(255*ones(size(I),'like',I));
    alpha3 = repmat(alpha,1,1,3);
    I = uint8(double(I).*double(alpha3)/255 + double(white).*double(255-alpha3)/255);
end
imshow(I,'Parent',ax_bg);
axis(ax_bg,'off');

%% ===== automatic colormap based on sign of t-values =====
n = 256;

% collect all non-NaN t-values
allvals = [M_LF(:); M_RF(:); M_LP(:); M_RP(:)];
allvals = allvals(~isnan(allvals));

if isempty(allvals)
    clim = 1;
    use_positive_only = true;
else
    has_negative = any(allvals < 0);
    has_positive = any(allvals > 0);

    if has_positive && ~has_negative
        % ===== positive-only: white to red =====
        r = [0.64 0.00 0.20];

        cmap = [linspace(1,r(1),n)' ...
            linspace(1,r(2),n)' ...
            linspace(1,r(3),n)'];

        clim = max(allvals);
        use_positive_only = true;

    elseif has_negative && ~has_positive
        % ===== negative-only: blue to white =====
        b = [0.00 0.37 0.74];

        cmap = [linspace(b(1),1,n)' ...
            linspace(b(2),1,n)' ...
            linspace(b(3),1,n)'];

        clim = abs(min(allvals));
        use_positive_only = false;   % negative-only case

    else
        % ===== both positive and negative: blue-white-red =====
        b = [0.00 0.37 0.74];
        r = [0.64 0.00 0.20];

        cmap = [linspace(b(1),1,n/2)' linspace(b(2),1,n/2)' linspace(b(3),1,n/2)'; ...
            linspace(1,r(1),n/2)' linspace(1,r(2),n/2)' linspace(1,r(3),n/2)'];

        clim = max(abs(allvals));
        use_positive_only = false;
    end

    if clim == 0
        clim = 1;
    end
end

%% ===== inset positions (tune) =====
pos_LF = [0.08 0.65 0.28 0.28];
pos_RF = [0.60 0.65 0.28 0.28];
pos_LP = [0.08 0.18 0.28 0.28];
pos_RP = [0.60 0.18 0.28 0.28];

% ===== draw insets =====
% ax1 = local_plot_inset(pos_LF, t_axis, M_LF, 'Left frontal',  cmap, clim);
% ax2 = local_plot_inset(pos_RF, t_axis, M_RF, 'Right frontal', cmap, clim);
% ax3 = local_plot_inset(pos_LP, t_axis, M_LP, 'Left posterior',cmap, clim);
% ax4 = local_plot_inset(pos_RP, t_axis, M_RP, 'Right posterior',cmap, clim);
ax1 = local_plot_inset(pos_LF, t_axis, M_LF, 'Left frontal',  cmap, clim, use_positive_only);
ax2 = local_plot_inset(pos_RF, t_axis, M_RF, 'Right frontal', cmap, clim, use_positive_only);
ax3 = local_plot_inset(pos_LP, t_axis, M_LP, 'Left posterior',cmap, clim, use_positive_only);
ax4 = local_plot_inset(pos_RP, t_axis, M_RP, 'Right posterior',cmap, clim, use_positive_only);

%% ===== single colorbar =====
ax_cb = axes('Position',[0.295 0.00 0.30 0.10],'Visible','off');
colormap(ax_cb, cmap);
% caxis(ax_cb, [0 clim]);
cb = colorbar(ax_cb,'southoutside');
cb.Label.String = '';  % remove default bottom label
% cb.Ticks = -floor(clim):1:floor(clim);
if use_positive_only
    caxis(ax_cb, [0 clim]);
    cb.Ticks = 0:1:ceil(clim);
else
    caxis(ax_cb, [-clim clim]);
    cb.Ticks = -floor(clim):1:floor(clim);
end
title(cb, 't-value ', ...
      'FontSize', 14, ...
      'FontWeight', 'bold');
cb.FontSize = 12;

% Export
exportgraphics(gcf,'brain_insets_tmaps.png','Resolution',300,'BackgroundColor','white');

%% ===== Local functions =====
function M_ext = extend_sig_tmap(tmap, pmap, alpha_thr, radius)
%EXTEND_SIG_TMAP  Expand each significant bin into a (2*radius+1)^2 neighborhood.
% Keeps continuous t-values. Overlaps keep the larger |t|.
%
% Inputs:
%   tmap      (22x22) t-stat map
%   pmap      (22x22) corrected p-values
%   alpha_thr scalar, e.g., 0.05
%   radius    integer, e.g., 1 (for 3x3 expansion)
%
% Output:
%   M_ext     (22x22) extended t-map, non-sig = NaN (transparent)

    sig = pmap < alpha_thr;
    [nR,nC] = size(sig);
    M_ext = NaN(nR,nC);

    [rows, cols] = find(sig);

    for idx = 1:numel(rows)
        r = rows(idx); 
        c = cols(idx);
        val = tmap(r,c);

        rr = max(r-radius,1):min(r+radius,nR);
        cc = max(c-radius,1):min(c+radius,nC);

        patch = M_ext(rr,cc);

        % If NaN there, write val. If already filled, keep larger |t|
        writeMask = isnan(patch) | abs(val) > abs(patch);
        patch(writeMask) = val;

        M_ext(rr,cc) = patch;
    end
end


function ax = local_plot_inset(pos, t_axis, M, ttl, cmap, clim, use_positive_only)

ax = axes('Position',pos);

h = imagesc(t_axis, t_axis, M);
set(ax,'YDir','normal');
axis(ax,'square');

colormap(ax, cmap);

% automatic color scaling
if use_positive_only
    caxis(ax, [0 clim]);
else
    caxis(ax, [-clim clim]);
end

% transparent non-sig
set(h,'AlphaData', ~isnan(M));

% styling
set(ax, ...
    'FontSize',14, ...
    'FontWeight','bold', ...
    'LineWidth',1.2, ...
    'Box','on', ...
    'Color','w', ...
    'TickDir','out');

xlabel(ax,'Retrieval (ms)','FontWeight','bold');
ylabel(ax,'Encoding (ms)','FontWeight','bold');
title(ax, ttl,'FontSize',16,'FontWeight','bold');

xticks(ax,[0 500 1000 1500 2000]);
yticks(ax,[0 500 1000 1500 2000]);

ax.XAxis.FontWeight = 'normal';
ax.YAxis.FontWeight = 'normal';

% outline cluster boundaries
hold(ax,'on');
bw = ~isnan(M);

if any(bw(:))
    B = bwboundaries(bw);
    for bb = 1:numel(B)
        boundary = B{bb};
        x = t_axis(boundary(:,2));
        y = t_axis(boundary(:,1));
        plot(ax, x, y, 'k', 'LineWidth', 1.0);
    end
end

hold(ax,'off');
end
%% Masking P-value
% Assuming p_values is a 4x26x26 matrix containing the p-values
% Load or generate p_values
% load('p_values.mat');

% Threshold for significance
threshold = 0.05;

% Create a figure to hold the subplots
figure;

for i = 1:4
    % Extract the p-values for the current region
    region_p_values = squeeze(corrected_pvalues(i, :, :));
    
    % Create a binary mask where p-values < 0.05
    significant_mask = region_p_values < threshold;
    region_mask(i,:,:)=significant_mask;
    
    % Plot the significant p-values
    subplot(2, 2, i);
    imagesc(significant_mask);
    colormap(gray); % Use a grayscale colormap
    colorbar;
    title(['Region ' num2str(i) ' Significant P-values (p < 0.05)']);
    xlabel('X-axis');
    ylabel('Y-axis');
    axis equal tight;
end
%% ============================================================
%  FINAL: (1) extract clusters from mask (stable ordering)
%         (2) compute subject-averaged RSA within each cluster
%         (3) plot interaction (Sleep discontinuity x Age) nicely
%
%  Assumes you already have:
%    region_mask      : (4 x 22 x 22) or similar
%    Hit_Miss         : (70 x 4 x 22 x 22)   (or replace with CR_FA etc.)
%    filtered_data    : table with sleep variable (pc1_ret) in SAME subject order
%
%  If you are NOT 100% sure subject order matches, stop and align by IDs first.
%% ============================================================

%% --------------------------
% 0) Choose region + data
% --------------------------
region_to_use = 4;                     % 1..4
mask = squeeze(region_mask(region_to_use,:,:)) ~= 0;     % 22x22 logical

dataMat = squeeze(Hit_Miss(:,region_to_use,:,:));        % 70x22x22
num_subjects = size(dataMat,1);

% Predictor (sleep) in subject order
x = filtered_data.pc1_ret;             % 70x1 numeric (sleep discontinuity)
x = x(:);

% Age indices (your current assumption)
young_idx = 1:35;
old_idx   = 36:70;

%% --------------------------
% 1) Find clusters + enforce a stable numbering
%    Here: Cluster 1 = largest cluster, Cluster 2 = next largest, etc.
% --------------------------
CC = bwconncomp(mask, 8);              % 8-connected clusters
num_clusters = CC.NumObjects;

if num_clusters == 0
    error('No clusters found in mask. Check region_mask and thresholding.');
end

cluster_sizes = cellfun(@numel, CC.PixelIdxList);
[~, sortOrder] = sort(cluster_sizes, 'descend');

L_sorted = zeros(size(mask));          % 22x22 labels
for newID = 1:num_clusters
    oldID = sortOrder(newID);
    L_sorted(CC.PixelIdxList{oldID}) = newID;
end

% Optional sanity check: visualize cluster labels
figure('Color','w'); imagesc(L_sorted); axis image; colorbar;
title(sprintf('Region %d cluster labels (1=largest)', region_to_use));
set(gca,'YDir','normal');

%% --------------------------
% 2) Average data within each cluster for each subject
% --------------------------
avg_cluster = nan(num_subjects, num_clusters);

for c = 1:num_clusters
    cluster_idx = (L_sorted == c);     % 22x22 logical
    for s = 1:num_subjects
        tmp = squeeze(dataMat(s,:,:)); % 22x22
        avg_cluster(s,c) = mean(tmp(cluster_idx), 'omitnan');
    end
end

%% --------------------------
% 3) Choose which cluster to plot
% --------------------------
cluster_to_plot = 1;                    % change to 2,3,... as needed
y = avg_cluster(:, cluster_to_plot);

% Print cluster time extents so you KNOW which one you plotted
step_size = 100;
t_axis = (0:step_size:(step_size*21)) + step_size/2; % 50..2150
[rr, cc] = find(L_sorted == cluster_to_plot);
enc_ms = t_axis(rr);
ret_ms = t_axis(cc);
fprintf('Plotting Cluster %d (size=%d): Encoding %.0f–%.0f ms | Retrieval %.0f–%.0f ms\n', ...
    cluster_to_plot, sum(L_sorted(:)==cluster_to_plot), min(enc_ms), max(enc_ms), min(ret_ms), max(ret_ms));

%% --------------------------
% 4) Pretty interaction plot (Young vs Old) WITHOUT sorting
% --------------------------
% Colors (colorblind-safe-ish, not red/blue)
cYoung = [0.00 0.55 0.55];   % teal
cOld   = [0.55 0.35 0.75];   % soft purple
edgeC  = [0.20 0.20 0.20];

% Fit group-wise lines
mdl_young = fitlm(x(young_idx), y(young_idx));
mdl_old   = fitlm(x(old_idx),   y(old_idx));

x_range = linspace(min(x), max(x), 200)';

[yfit_y, ci_y] = predict(mdl_young, x_range);
[yfit_o, ci_o] = predict(mdl_old,   x_range);

figure('Color','w','Position',[100 100 420 360]); hold on;

% CI bands first (behind)
fill([x_range; flipud(x_range)], [ci_y(:,1); flipud(ci_y(:,2))], ...
     cYoung, 'FaceAlpha',0.18, 'EdgeColor','none');

fill([x_range; flipud(x_range)], [ci_o(:,1); flipud(ci_o(:,2))], ...
     cOld, 'FaceAlpha',0.18, 'EdgeColor','none');

% Fit lines
plot(x_range, yfit_y, '-', 'Color',cYoung, 'LineWidth',3);
plot(x_range, yfit_o, '-', 'Color',cOld,   'LineWidth',3);

% Scatter points
s1 = scatter(x(young_idx), y(young_idx), 44, ...
    'MarkerFaceColor',cYoung, 'MarkerEdgeColor',edgeC, ...
    'MarkerFaceAlpha',0.75, 'LineWidth',0.7);

s2 = scatter(x(old_idx), y(old_idx), 44, ...
    'MarkerFaceColor',cOld, 'MarkerEdgeColor',edgeC, ...
    'MarkerFaceAlpha',0.75, 'LineWidth',0.7);

% Labels (edit text to match your paper)
xlabel('Sleep Discontinuity', 'FontSize', 22, 'FontWeight', 'bold');
ylabel('Right Posterior Hit - Miss', 'FontSize', 22, 'FontWeight', 'bold');
% title(sprintf('Cluster %d Interaction', cluster_to_plot), 'FontSize',15,'FontWeight','bold');

% Axes style
ax = gca;
ax.FontSize = 22;
ax.LineWidth = 1.2;
ax.Box = 'off';
ax.TickDir = 'out';
ax.GridAlpha = 0.10;
%grid on;

leg = legend([s1 s2], {'Younger','Older'}, 'Location','best','FontWeight', 'bold', 'FontSize',20);
leg.Box = 'off';

axis tight;
hold off;










%% ===================== Sleep Discontinuity =====================
nexttile; hold on;

yY = T1.sleep_discontinuity(T1.Age=="Young");
yO = T1.sleep_discontinuity(T1.Age=="Old");

% Boxplots (separate = no bug)
boxchart(ones(size(yY)), yY, ...
    'BoxFaceColor', blue_col, 'BoxFaceAlpha',0.7, ...
    'LineWidth',1.8, 'MarkerStyle','none');

boxchart(2*ones(size(yO)), yO, ...
    'BoxFaceColor', orange_col, 'BoxFaceAlpha',0.7, ...
    'LineWidth',1.8, 'MarkerStyle','none');

% Filled dots
jitY = 1 + (rand(size(yY))-0.5)*0.15;
jitO = 2 + (rand(size(yO))-0.5)*0.15;

scatter(jitY, yY, 70, blue_col, 'filled', 'MarkerFaceAlpha',0.7);
scatter(jitO, yO, 70, orange_col, 'filled', 'MarkerFaceAlpha',0.7);

% Axis
xlim([0.5 2.5]);
xticks([1 2]);
xticklabels({'Young','Old'});
ylabel('PC score');
title('Sleep discontinuity');
set(gca,'FontSize',13,'FontWeight','bold','LineWidth',1.4,'TickDir','out','Box','off');

% Stars (more visible)
yl = ylim; 
yr = yl(2)-yl(1);
ySig = max([yY; yO]) + 0.12*yr;   % a bit higher

if p_disc < 0.05
    
    % significance level
    if p_disc < 0.001
        stars = '***';
    elseif p_disc < 0.01
        stars = '**';
    else
        stars = '*';
    end

    % bracket (optional but recommended for visibility)
    plot([1 1 2 2], [ySig-0.02*yr ySig ySig ySig-0.02*yr], ...
        'k', 'LineWidth',2);

    % STAR TEXT (key improvement)
    text(1.5, ySig + 0.03*yr, stars, ...
        'HorizontalAlignment','center', ...
        'FontSize',20, ...            % bigger
        'FontWeight','bold', ...
        'Color','k', ...
        'BackgroundColor','w', ...    % makes it pop
        'Margin',3);                  % padding

    ylim([yl(1), ySig + 0.15*yr]);
end
%% ===================== Sleep Discontinuity =====================
nexttile; hold on;

yY = T1.sleep_discontinuity(T1.Age=="Young");
yO = T1.sleep_discontinuity(T1.Age=="Old");

% Mean and SEM
mY  = mean(yY,'omitnan');
mO  = mean(yO,'omitnan');
seY = std(yY,'omitnan') / sqrt(sum(~isnan(yY)));
seO = std(yO,'omitnan') / sqrt(sum(~isnan(yO)));

% Bars
bar(1, mY, 0.55, 'FaceColor', blue_col, ...
    'FaceAlpha', 0.65, 'EdgeColor', 'k', 'LineWidth', 1.8);

bar(2, mO, 0.55, 'FaceColor', orange_col, ...
    'FaceAlpha', 0.65, 'EdgeColor', 'k', 'LineWidth', 1.8);

% Error bars
errorbar([1 2], [mY mO], [seY seO], 'k', ...
    'LineStyle', 'none', 'LineWidth', 1.8, 'CapSize', 10);

% Filled dots
jitY = 1 + (rand(size(yY))-0.5)*0.16;
jitO = 2 + (rand(size(yO))-0.5)*0.16;

scatter(jitY, yY, 70, blue_col, ...
    'filled', 'MarkerFaceAlpha', 0.7, ...
    'MarkerEdgeColor', [0.2 0.2 0.2], 'LineWidth', 0.5);

scatter(jitO, yO, 70, orange_col, ...
    'filled', 'MarkerFaceAlpha', 0.7, ...
    'MarkerEdgeColor', [0.2 0.2 0.2], 'LineWidth', 0.5);

% Axis
xlim([0.5 2.5]);
xticks([1 2]);
xticklabels({'Younger','Older'});
ax = gca;
ax.XAxis.FontWeight = 'bold';
ylabel('PCA score','FontWeight','bold');
title('Sleep discontinuity','FontWeight','bold');
set(gca,'FontSize',13,'LineWidth',1.4,'TickDir','out','Box','off');

% Stars
yl = ylim;
yr = yl(2)-yl(1);
ySig = max([yY; yO]) + 0.12*yr;

if p_disc < 0.05
    if p_disc < 0.001
        stars = '*';
    elseif p_disc < 0.01
        stars = '*';
    else
        stars = '*';
    end

    plot([1 1 2 2], [ySig-0.02*yr ySig ySig ySig-0.02*yr], ...
        'k', 'LineWidth', 2);

    text(1.5, ySig + 0.03*yr, stars, ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 20, ...
        'FontWeight', 'bold', ...
        'Color', 'k', ...
        'BackgroundColor', 'w', ...
        'Margin', 3);

    ylim([yl(1), ySig + 0.15*yr]);
end

%% ===================== Sleep Time =====================
nexttile; hold on;

yY = T2.sleep_time(T2.Age=="Young");
yO = T2.sleep_time(T2.Age=="Old");

boxchart(ones(size(yY)), yY, ...
    'BoxFaceColor', blue_col, 'BoxFaceAlpha',0.7, ...
    'LineWidth',1.8, 'MarkerStyle','none');

boxchart(2*ones(size(yO)), yO, ...
    'BoxFaceColor', orange_col, 'BoxFaceAlpha',0.7, ...
    'LineWidth',1.8, 'MarkerStyle','none');

jitY = 1 + (rand(size(yY))-0.5)*0.15;
jitO = 2 + (rand(size(yO))-0.5)*0.15;

scatter(jitY, yY, 70, blue_col, 'filled', 'MarkerFaceAlpha',0.7);
scatter(jitO, yO, 70, orange_col, 'filled', 'MarkerFaceAlpha',0.7);

xlim([0.5 2.5]);
xticks([1 2]);
xticklabels({'Young','Old'});
ylabel('PC score');
title('Sleep time');
set(gca,'FontSize',13,'FontWeight','bold','LineWidth',1.4,'TickDir','out','Box','off');

% Stars
% Stars (more visible)
yl = ylim; 
yr = yl(2)-yl(1);
ySig = max([yY; yO]) + 0.12*yr;   % a bit higher

if p_time < 0.05
    
    % significance level
    if p_time < 0.001
        stars = '***';
    elseif p_time < 0.01
        stars = '**';
    else
        stars = '*';
    end

    % bracket (optional but recommended for visibility)
    plot([1 1 2 2], [ySig-0.02*yr ySig ySig ySig-0.02*yr], ...
        'k', 'LineWidth',2);

    % STAR TEXT (key improvement)
    text(1.5, ySig + 0.03*yr, stars, ...
        'HorizontalAlignment','center', ...
        'FontSize',20, ...            % bigger
        'FontWeight','bold', ...
        'Color','k', ...
        'BackgroundColor','w', ...    % makes it pop
        'Margin',3);                  % padding

    ylim([yl(1), ySig + 0.15*yr]);
end
%% ===================== Sleep Time =====================
nexttile; hold on;

yY = T2.sleep_time(T2.Age=="Young");
yO = T2.sleep_time(T2.Age=="Old");

% Mean and SEM
mY  = mean(yY,'omitnan');
mO  = mean(yO,'omitnan');
seY = std(yY,'omitnan') / sqrt(sum(~isnan(yY)));
seO = std(yO,'omitnan') / sqrt(sum(~isnan(yO)));

% Bars
bar(1, mY, 0.55, 'FaceColor', blue_col, ...
    'FaceAlpha', 0.65, 'EdgeColor', 'k', 'LineWidth', 1.8);

bar(2, mO, 0.55, 'FaceColor', orange_col, ...
    'FaceAlpha', 0.65, 'EdgeColor', 'k', 'LineWidth', 1.8);

% Error bars
errorbar([1 2], [mY mO], [seY seO], 'k', ...
    'LineStyle', 'none', 'LineWidth', 1.8, 'CapSize', 10);

% Filled dots
jitY = 1 + (rand(size(yY))-0.5)*0.16;
jitO = 2 + (rand(size(yO))-0.5)*0.16;

scatter(jitY, yY, 70, blue_col, ...
    'filled', 'MarkerFaceAlpha', 0.7, ...
    'MarkerEdgeColor', [0.2 0.2 0.2], 'LineWidth', 0.5);

scatter(jitO, yO, 70, orange_col, ...
    'filled', 'MarkerFaceAlpha', 0.7, ...
    'MarkerEdgeColor', [0.2 0.2 0.2], 'LineWidth', 0.5);

% Axis
xlim([0.5 2.5]);
xticks([1 2]);
xticklabels({'Younger','Older'});
ax = gca;
ax.XAxis.FontWeight = 'bold';
ylabel('PCA score','FontWeight','bold');
title('Sleep time','FontWeight','bold');
set(gca,'FontSize',13,'LineWidth',1.4,'TickDir','out','Box','off');

% Stars
yl = ylim;
yr = yl(2)-yl(1);
ySig = max([yY; yO]) + 0.12*yr;

if p_time < 0.05
    if p_time < 0.001
        stars = '***';
    elseif p_time < 0.01
        stars = '**';
    else
        stars = '*';
    end

    plot([1 1 2 2], [ySig-0.02*yr ySig ySig ySig-0.02*yr], ...
        'k', 'LineWidth', 2);

    text(1.5, ySig + 0.03*yr, stars, ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 20, ...
        'FontWeight', 'bold', ...
        'Color', 'k', ...
        'BackgroundColor', 'w', ...
        'Margin', 3);

    ylim([yl(1), ySig + 0.15*yr]);
end


%% Correction Function
function corrected_p_values = mult_comp_correction(input, perm)
    % This function receives a matrix of p-values and returns the corrected
    % p-values for significant clusters using permutation testing.

    % Size of the input matrix
    [rows, cols] = size(input);
    
    % Vectorize the input matrix
    vec = input(:);

    % Preallocate permutation statistics
    perm_stats1 = zeros(perm, 1);

    % Perform permutations
    for z = 1:perm
        % Permute the vectorized matrix
        ind = randperm(length(vec));
        new_vec = vec(ind);
        
        % Reshape back to the original size
        new_input = reshape(new_vec, [rows, cols]);

        % Perform connected component labeling on permuted matrix
        [L, n] = bwlabel(new_input < 0.05, 4);  % Considering p-value threshold of 0.05
        
        % Find the largest cluster size in the permuted matrix
        max_n = 0;
        for i = 1:n
            r = sum(L(:) == i);
            if r > max_n
                max_n = r;
            end
        end
        perm_stats1(z) = max_n;
    end

    % Sort permutation statistics
    perm_stats1 = sort(perm_stats1, 'descend');
    
    % Determine the cluster size threshold for significance
    min_sig_size = perm_stats1(floor(0.05 * perm));
    if min_sig_size == 1
        min_sig_size = 2;
    end

    % Analyze the original input matrix
    [L, n] = bwlabel(input < 0.05, 4);
    cluster_sizes = zeros(n, 1);
    for i = 1:n
        cluster_sizes(i) = sum(L(:) == i);
    end

    % Preallocate corrected p-values matrix
    corrected_p_values = ones(rows, cols);

    % Find significant clusters
    significant_cluster_numbers = find(cluster_sizes >= min_sig_size);
    
    if ~isempty(significant_cluster_numbers)
        for j = 1:length(significant_cluster_numbers)
            cluster_num = significant_cluster_numbers(j);
            cluster_indices = find(L == cluster_num);
            cluster_size = length(cluster_indices);
            
            % Calculate the corrected p-value for this cluster
            corrected_p_value = sum(perm_stats1 >= cluster_size) / perm;
            
            % Assign the corrected p-value to the corresponding positions in the matrix
            corrected_p_values(cluster_indices) = corrected_p_value;
        end
    end
end
