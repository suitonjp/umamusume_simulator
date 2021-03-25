% トレーニング評価
function ret = evaluate_training(type, support, settings, vb)
    % 現在の状態をstate変数へ
    state = settings.state;
    
    % 選択トレーニングの上昇量リストを取得
    tr_idx = find(contains(settings.tr_type_list, type), 1);
    tr_weight = settings.tr.weight(tr_idx);
    if sum(settings.tr.summer == state.turn) % 夏合宿中は固定で5
        tr_lvl = 5;
        
        % 夏合宿中の重み無視処理
        if settings.tr.summer_ignore_weight
            tr_weight = 0;
        end
    else
        tr_lvl = fix(state.tr_lvl(tr_idx));
    end
    tr_data = settings.tr_data.(settings.tr_list(tr_idx))(tr_lvl, :);
    
    % 重み減衰
    if settings.tr.att_weight
        tr_weight = tr_weight * ((settings.tr.turn-state.turn) / settings.tr.turn);
    end
    
    % ボーナス/倍率の計算
    rate = 1;
    hp_keigen = 0;
    motiv_up = 1;
    kizuna = 0;
    for i = 1:length(support)
        s = support(i);

        % もしサポートが不在の場合はスキップ
        if s.Training ~= type
            continue
        end
        
        % 増加基礎値
        if contains(s.StatusBonus, 'スピード') && tr_data(1) > 0
            tr_data(1) = tr_data(1) + 1;
        elseif contains(s.StatusBonus, 'スタミナ') && tr_data(2) > 0
            tr_data(2) = tr_data(2) + 1;
        elseif contains(s.StatusBonus, 'パワー') && tr_data(3) > 0
            tr_data(3) = tr_data(3) + 1;
        elseif contains(s.StatusBonus, '根性') && tr_data(4) > 0
            tr_data(4) = tr_data(4) + 1;
        elseif contains(s.StatusBonus, '賢さ') && tr_data(5) > 0
            tr_data(5) = tr_data(5) + 1;
        end
        
        % 友情ボーナス (賢さの友情回復ボーナスも含む)
        if s.Kizuna >= 80 && s.Type == type
            rate = rate * (1 + s.FriendBonus/100);
            tr_data(7) = tr_data(7) + s.HpHealBoost;
        end
        % トレーニング効果アップ
        rate = rate * (1.05 + s.TrainingEffUp/100);
        
        % 調子効果アップ
        motiv_up = motiv_up + s.MotivEffUp/100;
        
        % 体力消費ダウン
        hp_keigen = hp_keigen + s.HpKeigen/100;
        
        % 絆加算判定 (友人サポは60まで)
        if s.Type == "友人" && s.Kizuna < 60
            kizuna = kizuna + 6; % トレ後のイベ発生分を加味して2加算
        elseif s.Kizuna < 80
            kizuna = kizuna + 7;
        end
    end
    
    rate = rate * (1 + 0.2*motiv_up);
    
    % 上昇パラメータの計算
    param = fix(tr_data(1:5) * rate);
    skill_pt = fix(tr_data(6) * rate);
    
    % 上昇パラメータの減衰
    if settings.param.att_status
        w = min(1, max(0, (state.param - settings.param.goal) / settings.param.att_statust_width * 0.2));
        param = param .* (1-w);
    end
    
    % 体力消費の処理
    if tr_data(7) < 0 % 体力消費時に、体力消費ダウンを適用
        hp = fix(tr_data(7) * (1-hp_keigen));
    else
        % HP回復が100を超える場合は、超過分は評価にいれない
        hp = min(tr_data(7), 100-state.hp);
    end
    
    % 各種評価要素に重みを乗算
    param_wd = param .* settings.param.weight;
    skill_pt_wd = skill_pt * settings.tr.skill_pt_rate;
    hp_wd = hp * settings.tr.hp_rate;
    kizuna_wd = kizuna * settings.tr.kizuna_rate;
    
    if vb
       fprintf(" 評価 ステータス: %.2f, スキルPt: %.2f, 体力: %.2f, 絆: %.2f, トレ重み:%.2f\n", ...
                sum(param_wd), skill_pt_wd, hp_wd, kizuna_wd, tr_weight);
    end
    
    ret = sum(param_wd) + skill_pt_wd + hp_wd + kizuna_wd + tr_weight;

end