% �g���[�j���O���{
function [support, settings] = execute_training(type, support, settings, vb)
    % ���݂̏�Ԃ�state�ϐ���
    state = settings.state;
    
    % �I���g���[�j���O�̏㏸�ʃ��X�g�̎擾�ƃg���[�j���O���x���̍X�V
    tr_idx = find(contains(settings.tr_type_list, type), 1);
    if sum(settings.tr.summer == state.turn) % �č��h���͌Œ��5
        tr_lvl = 5;
        if vb
            fprintf(" ��  (");
        end
    else
        tr_lvl = fix(state.tr_lvl(tr_idx));
        settings.state.tr_lvl(tr_idx) = min(settings.state.tr_lvl(tr_idx) + 0.25, 5);
        if vb
            fprintf(" Lv%d (", tr_lvl);
        end
    end
    tr_data = settings.tr_data.(settings.tr_list(tr_idx))(tr_lvl, :);

    % �{�[�i�X/�{���̌v�Z
    rate = 1;
    hp_keigen = 0;
    motiv_up = 1;
    for i = 1:length(support)
        s = support(i);
        
        % �����T�|�[�g���s�݂̏ꍇ�̓X�L�b�v
        if s.Training ~= type
            continue
        end
        
        if vb
            fprintf(" %s", s.Name);
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
            if vb
                fprintf("*");
            end
        end
        % �g���[�j���O���ʃA�b�v
        rate = rate * (1.05 + s.TrainingEffUp/100);
        
        % ���q���ʃA�b�v
        motiv_up = motiv_up + s.MotivEffUp/100;
        
        % �̗͏���_�E��
        hp_keigen = hp_keigen + s.HpKeigen/100;
        
        % �J���Z����
        if s.Type == "�F�l"
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

    if tr_data(7) < 0 % �̗͏���g�� (�����ȊO)
        hp = fix(tr_data(7) * (1-hp_keigen)) + settings.state.hp;
    else
        hp = min(tr_data(7) + settings.state.hp, 100);
    end
    
    settings.state.param = settings.state.param + param;
    settings.state.hp = hp;
end