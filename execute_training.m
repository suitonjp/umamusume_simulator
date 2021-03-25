% トレーニング実施
function [support, settings] = execute_training(type, support, settings, vb)
    % 現在の状態をstate変数へ
    state = settings.state;
    
    % 選択トレーニングの上昇量リストの取得とトレーニングレベルの更新
    tr_idx = find(contains(settings.tr_type_list, type), 1);
    if sum(settings.tr.summer == state.turn) % 夏合宿中は固定で5
        tr_lvl = 5;
        if vb
            fprintf(" 夏  (");
        end
    else
        tr_lvl = fix(state.tr_lvl(tr_idx));
        settings.state.tr_lvl(tr_idx) = min(settings.state.tr_lvl(tr_idx) + 0.25, 5);
        if vb
            fprintf(" Lv%d (", tr_lvl);
        end
    end
    tr_data = settings.tr_data.(settings.tr_list(tr_idx))(tr_lvl, :);

    % ボーナス/倍率の計算
    rate = 1;
    hp_keigen = 0;
    motiv_up = 1;
    for i = 1:length(support)
        s = support(i);
        
        % もしサポートが不在の場合はスキップ
        if s.Training ~= type
            continue
        end
        
        if vb
            fprintf(" %s", s.Name);
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
            if vb
                fprintf("*");
            end
        end
        % トレーニング効果アップ
        rate = rate * (1.05 + s.TrainingEffUp/100);
        
        % 調子効果アップ
        motiv_up = motiv_up + s.MotivEffUp/100;
        
        % 体力消費ダウン
        hp_keigen = hp_keigen + s.HpKeigen/100;
        
        % 絆加算判定
        if s.Type == "友人"
            support(i).Kizuna = min(support(i).Kizuna+6, 100);
        else
            support(i).Kizuna = min(support(i).Kizuna+7, 100);
        end
    end
    
    
    rate = rate * (1 + 0.2*motiv_up);
    param = fix(tr_data(1:5) * rate);
    
    if vb
        fprintf(" ), %d %d %d %d %d\n", param(1), param(2), param(3), param(4), param(5));
    end

    if tr_data(7) < 0 % 体力消費トレ (賢さ以外)
        hp = fix(tr_data(7) * (1-hp_keigen)) + settings.state.hp;
    else
        hp = min(tr_data(7) + settings.state.hp, 100);
    end
    
    settings.state.param = settings.state.param + param;
    settings.state.hp = hp;
end