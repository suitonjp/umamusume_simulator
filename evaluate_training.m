% �g���[�j���O�]��
function ret = evaluate_training(type, support, settings, vb)
    % ���݂̏�Ԃ�state�ϐ���
    state = settings.state;
    
    % �I���g���[�j���O�̏㏸�ʃ��X�g���擾
    tr_idx = find(contains(settings.tr_type_list, type), 1);
    tr_weight = settings.tr.weight(tr_idx);
    if sum(settings.tr.summer == state.turn) % �č��h���͌Œ��5
        tr_lvl = 5;
        
        % �č��h���̏d�ݖ�������
        if settings.tr.summer_ignore_weight
            tr_weight = 0;
        end
    else
        tr_lvl = fix(state.tr_lvl(tr_idx));
    end
    tr_data = settings.tr_data.(settings.tr_list(tr_idx))(tr_lvl, :);
    
    % �d�݌���
    if settings.tr.att_weight
        tr_weight = tr_weight * ((settings.tr.turn-state.turn) / settings.tr.turn);
    end
    
    % �{�[�i�X/�{���̌v�Z
    rate = 1;
    hp_keigen = 0;
    motiv_up = 1;
    kizuna = 0;
    for i = 1:length(support)
        s = support(i);

        % �����T�|�[�g���s�݂̏ꍇ�̓X�L�b�v
        if s.Training ~= type
            continue
        end
        
        % ������b�l
        if contains(s.StatusBonus, '�X�s�[�h') && tr_data(1) > 0
            tr_data(1) = tr_data(1) + 1;
        elseif contains(s.StatusBonus, '�X�^�~�i') && tr_data(2) > 0
            tr_data(2) = tr_data(2) + 1;
        elseif contains(s.StatusBonus, '�p���[') && tr_data(3) > 0
            tr_data(3) = tr_data(3) + 1;
        elseif contains(s.StatusBonus, '����') && tr_data(4) > 0
            tr_data(4) = tr_data(4) + 1;
        elseif contains(s.StatusBonus, '����') && tr_data(5) > 0
            tr_data(5) = tr_data(5) + 1;
        end
        
        % �F��{�[�i�X (�����̗F��񕜃{�[�i�X���܂�)
        if s.Kizuna >= 80 && s.Type == type
            rate = rate * (1 + s.FriendBonus/100);
            tr_data(7) = tr_data(7) + s.HpHealBoost;
        end
        % �g���[�j���O���ʃA�b�v
        rate = rate * (1.05 + s.TrainingEffUp/100);
        
        % ���q���ʃA�b�v
        motiv_up = motiv_up + s.MotivEffUp/100;
        
        % �̗͏���_�E��
        hp_keigen = hp_keigen + s.HpKeigen/100;
        
        % �J���Z���� (�F�l�T�|��60�܂�)
        if s.Type == "�F�l" && s.Kizuna < 60
            kizuna = kizuna + 6; % �g����̃C�x����������������2���Z
        elseif s.Kizuna < 80
            kizuna = kizuna + 7;
        end
    end
    
    rate = rate * (1 + 0.2*motiv_up);
    
    % �㏸�p�����[�^�̌v�Z
    param = fix(tr_data(1:5) * rate);
    skill_pt = fix(tr_data(6) * rate);
    
    % �㏸�p�����[�^�̌���
    if settings.param.att_status
        w = min(1, max(0, (state.param - settings.param.goal) / settings.param.att_statust_width * 0.2));
        param = param .* (1-w);
    end
    
    % �̗͏���̏���
    if tr_data(7) < 0 % �̗͏���ɁA�̗͏���_�E����K�p
        hp = fix(tr_data(7) * (1-hp_keigen));
    else
        % HP�񕜂�100�𒴂���ꍇ�́A���ߕ��͕]���ɂ���Ȃ�
        hp = min(tr_data(7), 100-state.hp);
    end
    
    % �e��]���v�f�ɏd�݂���Z
    param_wd = param .* settings.param.weight;
    skill_pt_wd = skill_pt * settings.tr.skill_pt_rate;
    hp_wd = hp * settings.tr.hp_rate;
    kizuna_wd = kizuna * settings.tr.kizuna_rate;
    
    if vb
       fprintf(" �]�� �X�e�[�^�X: %.2f, �X�L��Pt: %.2f, �̗�: %.2f, �J: %.2f, �g���d��:%.2f\n", ...
                sum(param_wd), skill_pt_wd, hp_wd, kizuna_wd, tr_weight);
    end
    
    ret = sum(param_wd) + skill_pt_wd + hp_wd + kizuna_wd + tr_weight;

end