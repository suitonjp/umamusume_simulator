load_support;
training_data;

%% シミュレーション設定部
% 基本設定
% support = [support_list.SpecialWeek, support_list.NaritaTaishin, ...
%            support_list.MihonoBourbon, support_list.AinesuFujin, ...
%            support_list.KiryuinAoi, support_list.VodkaFriend ];

% % 友人/スピ3/パワー1/賢さ1 
% support = [support_list.SpecialWeek, support_list.TwinTurboFriend, ...
%            support_list.TokaiTeioFriend, support_list.VodkaFriend, ...
%            support_list.HayakawaTazunaFriend, support_list.FineMotionFriend];

% 友人/スピ2/パワー2/賢さ1 
support = [support_list.SpecialWeek, support_list.TwinTurboFriend, ...
           support_list.OguriCapFriend, support_list.VodkaFriend, ...
           support_list.HayakawaTazunaFriend, support_list.FineMotionFriend];
       
% 友人/スピ2/パワー1/賢さ1 + タマモクロス
% support = [support_list.SpecialWeek, support_list.TwinTurboFriend, ...
%            support_list.TamamoCrossFriend, support_list.VodkaFriend, ...
%            support_list.HayakawaTazunaFriend, support_list.FineMotionFriend];


kizuna_offset = [10, 10, 10, 10, 10, 10];
training_turn = 65;

% トレーニング評価設定
settings = struct();
settings.tr = struct();
settings.tr.weight = [10, 0, 10, 0, 0]; % トレーニング重み
settings.tr.summer_ignore_weight = true; % 夏合宿時、トレーニング重みを無視
settings.tr.lv5_ignore_weight = true; % Lv5になったトレーニングは重みを無視
settings.tr.att_weight = true; % トレーニング重みの減衰 (線形, 残ターン数/総ターン数で減衰)
settings.tr.kizuna_rate = 1;
settings.tr.hp_rate = 0.5;
settings.tr.skill_pt_rate = 0.3;
settings.tr.hint_rate = 0;
settings.tr.turn = training_turn;

% 夏合宿を逆算 (最終ターンから14-11ターン前、37-34ターン前とする）
settings.tr.summer = [training_turn-37:training_turn-34, training_turn-14:training_turn-11];

% パラメータ評価設定
settings.param = struct();
settings.param.weight = [1, 1, 1, 1, 0.8];
settings.param.goal = [600, 300, 600, 100, 300];
settings.param.att_status = true;
settings.param.att_statust_width = 100; % goalから超過した分は、20%/width の傾きで減衰される

% その他定数
settings.tr_data = tr_data;
settings.tr_type_list = ["スピード", "スタミナ", "パワー", "根性", "賢さ"];
settings.tr_list = ["spd", "stm", "pwr", "spr", "int"];

clear tr_data

%% シミュレーション前処理
% サポーター 固有ボーナス処理, 初期絆補正適用
for i = 1:6
    support(i).Kizuna = support(i).Kizuna + kizuna_offset(i);
    support(i).Training = "none";
    for j = 1:2
        fld_name = ['Unique', num2str(j)];
        [fld, val] = unique_bonus(support(i).(fld_name));
        if fld == "na"
            % do nothing
        elseif fld == "StatusBonus"
            support(i).(fld) = [support(i).(fld), val];
        else
            support(i).(fld) = support(i).(fld) + val;
        end
    end
end

clear kizuna_offset fld_name fld val


%% シミュレーション 実行
mode = 1; % 1: seed指定試行, 2: 単体試行, 3: N回試行
seed = 5439;

N = 10000;
results = zeros(N, 5);

switch mode 
    case 1
        run_umasimu(support, settings, seed, true)
    case 2
        run_umasimu(support, settings, 'shuffle', true)
    case 3
        for num = 1:N
            results(num, :) = run_umasimu(support, settings, num, false);
        end
        scores = sum(results .* settings.param.weight, 2);
        histfit(scores, 50);
        grid on
        pd = fitdist(scores, 'Normal');
        [d, idx] = max(sum(results, 2));
        
        fprintf("平均: %.2f, 中央値: %.2f | 正規分布 mu: %.2f, sigma: %.2f\n", ...
            mean(scores), median(scores), pd.mu, pd.sigma);
        fprintf("最大評価: %d, Seed: %d \n", d, idx);
end




%% ローカル関数
% 固有ボーナス処理
function [field, val] = unique_bonus(str)
    switch str
        case '友情ボーナス'
            field = 'FriendBonus';
            val = 10;
        case 'やる気効果アップ'
            field = 'MotivEffUp';
            val = 18;
        case 'トレ効果アップ'
            field = 'TrainingEffUp';
            val = 5;
        case '初期絆'
            field = 'Kizuna';
            val = 10;
        case '得意率アップ'
            field = 'TokuiUp';
            val = 20;
        case 'スピードボーナス'
            field = 'StatusBonus';
            val = 'スピード';
        case 'スタミナボーナス'
            field = 'StatusBonus';
            val = 'スタミナ';
        case 'パワーボーナス'
            field = 'StatusBonus';
            val = 'パワー';
        case '根性ボーナス'
            field = 'StatusBonus';
            val = '根性';
        case '賢さボーナス'
            field = 'StatusBonus';
            val = '賢さ';
%         case 'レースボーナス'
%         case 'ファンボーナス'
%         case 'ヒント発生率アップ'
        case '体力消費ダウン'
            field = 'HpKeigen';
            val = 5;
        otherwise
            field = 'na';
            val = 0;
    end
end


