% MAIN
% Version 30-Nov-2019
% Help on http://liecn.github.com
clear;
% clc;
close all;

%% Set Parameters for Loading Data
lineA=["-",":","--",'-.'];
% lineB=[left_color,"b","m","g"];
lineC=["*","s","o","^","+","s"];
lineS=["-.r","--m",":b"];

fig=figure;
set(fig,'DefaultAxesFontSize',18);
set(fig,'DefaultAxesFontWeight','bold');
%tailor the pdf
left_color = [0.929 0.262 0.564];
right_color = [0.439, 0.188, 0.627];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

set(fig,'PaperSize',[7.5 3.8]);

data_root = '/data/test_40/test';

%% differnt noise
data_type=["conversation", "joint","babble","factory2","leopard", "volvo"];
metric = ["WER", "pesq", "SDR", "Confidence"];
error_matrix_total=cell(data_type.size(2),4);
speakers = dir(data_root);
speaker_ids = {speakers(3:end).name};
speaker_ids = {1919, 777};
for speaker_id = speaker_ids
    mkdir(num2str(speaker_id{1,1}));
    for ii=1:data_type.size(2)
        if ii==1
            error_dir = [data_root, speaker_id, data_type(ii),'hide_expect_hidden.xlsx'];
        elseif ii==2
            error_dir = [data_root, speaker_id, data_type(ii), '0dB', 'hide_expect_hidden.xlsx'];
        else
            error_dir = [data_root, speaker_id, 'noise', data_type(ii), '0dB', 'hide_expect_hidden.xlsx'];
        end
        error_path = string(join(error_dir,'/'));
        [~,sheet_name]=xlsfinfo(error_path);
        for k=1:numel(sheet_name)
            T=xlsread(error_path,sheet_name{k});
            error_matrix_total{ii,k}=T(:,[4,7,8,11]);
        end
    end
    raw_data=cell(6,2);
    for jj=1:4
        for ii=1:data_type.size(2)
            index=1;
            for kk=[1,4]
                data_per_noise=error_matrix_total{ii,kk};
                raw_data{ii,index}=data_per_noise(:,jj);
                index=index+1;
            end
        end

        xlab={'Conv','joint','babble','factory','leopard','volvo'};
        
        col=[102,255,255, 200;
            51,153,255, 200];
        col=col/255;

        multiple_boxplot(raw_data,xlab, {'Purified', 'Mixed'},col')
        ylabel(metric(jj));
        set(gcf,'WindowStyle','normal','Position', [200,200,640,360]);
        save_array = ['./',speaker_id, '/','expect_hidden-', metric(jj), '.pdf'];
        save_path = string(join(save_array,''));
        saveas(gcf,save_path);
    end
end