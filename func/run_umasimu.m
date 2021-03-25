function result = run_umasimu(support, settings, seed, vb)
    % シード初期化
    rng(seed);
    
    % 状態の初期化
    settings.state = struct();
    settings.state.param = [0, 0, 0, 0, 0];
    settings.state.tr_lvl = [1, 1, 1, 1, 1];
    settings.state.hp = 100;
    
    maxturn = settings.tr.turn;
    
    for i=1:maxturn
        settings.state.turn = i;

        % 体力が 40 以下になったら回復 (50固定)
        if settings.state.hp < 40
            settings.state.hp = settings.state.hp + 50;
            if vb
                fprintf("Turn: %d , 休み\n", i);
            end
            continue
        end

        % サポート配置の実行
        for j=1:6
            support(j).Training = training_haichi(support(j).Type, support(j).TokuiUp);
        end

        % 各トレーニングの評価
        eval_list = arrayfun(@(x) evaluate_training(x, support, settings, false), settings.tr_type_list);
        [m, idx] = max(eval_list);

        % 最高評価のトレーニングの実施
        if vb
            fprintf("Turn: %d , %s (評価点: %.2f) \n", i, settings.tr_type_list(idx), m);
%             evaluate_training(settings.tr_type_list(idx), support, settings, true);
        end
        [support, settings] = execute_training(settings.tr_type_list(idx), support, settings, vb);
    end
    p = settings.state.param;
    l = fix(settings.state.tr_lvl);
    
    if vb
        fprintf("-----------------------------------------------\n");
        fprintf("総合評価値: %d\n", sum(p));
        fprintf("スピード:%d スタミナ:%d パワー:%d 根性:%d 賢さ:%d \n", p(1), p(2), p(3), p(4), p(5));
        fprintf("(トレーニングレベル: %d %d %d %d %d) \n", l(1), l(2), l(3), l(4), l(5));
    end
    result = settings.state.param;
end


% トレーニング配置
function ret = training_haichi(type, tokui_up)
    tr_list = ["スピード", "スタミナ", "パワー", "根性", "賢さ"];
    
    if type == "友人"
        if rand() < 0.15 % 不在率15%
            ret = "不在";
        else
            ret = tr_list(randi(5));
        end
    else
        if type == "スピード"
            tr_list(1) = [];
            tokui_trn = "スピード";
        elseif type == "スタミナ"
            tr_list(2) = [];
            tokui_trn = "スタミナ";
        elseif type == "パワー"
            tr_list(3) = [];
            tokui_trn = "パワー";
        elseif type == "根性"
            tr_list(4) = [];
            tokui_trn = "根性";
        else
            tr_list(5) = [];
            tokui_trn = "賢さ";
        end
        
        if rand() < 0.1 % 不在率10%
            ret = "不在";
        elseif rand() < (100+tokui_up)/(500+tokui_up)
            ret = tokui_trn;
        else
            ret = tr_list(randi(4));
        end
    end
end
