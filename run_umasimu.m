function result = run_umasimu(support, settings, seed, vb)
    % �V�[�h������
    rng(seed);
    
    % ��Ԃ̏�����
    settings.state = struct();
    settings.state.param = [0, 0, 0, 0, 0];
    settings.state.tr_lvl = [1, 1, 1, 1, 1];
    settings.state.hp = 100;
    
    maxturn = settings.tr.turn;
    
    for i=1:maxturn
        settings.state.turn = i;

        % �̗͂� 40 �ȉ��ɂȂ������ (50�Œ�)
        if settings.state.hp < 40
            settings.state.hp = settings.state.hp + 50;
            if vb
                fprintf("Turn: %d , �x��\n", i);
            end
            continue
        end

        % �T�|�[�g�z�u�̎��s
        for j=1:6
            support(j).Training = training_haichi(support(j).Type, support(j).TokuiUp);
        end

        % �e�g���[�j���O�̕]��
        eval_list = arrayfun(@(x) evaluate_training(x, support, settings, false), settings.tr_type_list);
        [m, idx] = max(eval_list);

        % �ō��]���̃g���[�j���O�̎��{
        if vb
            fprintf("Turn: %d , %s (�]���_: %.2f) \n", i, settings.tr_type_list(idx), m);
%             evaluate_training(settings.tr_type_list(idx), support, settings, true);
        end
        [support, settings] = execute_training(settings.tr_type_list(idx), support, settings, vb);
    end
    p = settings.state.param;
    l = fix(settings.state.tr_lvl);
    
    if vb
        fprintf("-----------------------------------------------\n");
        fprintf("�����]���l: %d\n", sum(p));
        fprintf("�X�s�[�h:%d �X�^�~�i:%d �p���[:%d ����:%d ����:%d \n", p(1), p(2), p(3), p(4), p(5));
        fprintf("(�g���[�j���O���x��: %d %d %d %d %d) \n", l(1), l(2), l(3), l(4), l(5));
    end
    result = settings.state.param;
end


% �g���[�j���O�z�u
function ret = training_haichi(type, tokui_up)
    tr_list = ["�X�s�[�h", "�X�^�~�i", "�p���[", "����", "����"];
    
    if type == "�F�l"
        if rand() < 0.15 % �s�ݗ�15%
            ret = "�s��";
        else
            ret = tr_list(randi(5));
        end
    else
        if type == "�X�s�[�h"
            tr_list(1) = [];
            tokui_trn = "�X�s�[�h";
        elseif type == "�X�^�~�i"
            tr_list(2) = [];
            tokui_trn = "�X�^�~�i";
        elseif type == "�p���["
            tr_list(3) = [];
            tokui_trn = "�p���[";
        elseif type == "����"
            tr_list(4) = [];
            tokui_trn = "����";
        else
            tr_list(5) = [];
            tokui_trn = "����";
        end
        
        if rand() < 0.1 % �s�ݗ�10%
            ret = "�s��";
        elseif rand() < (100+tokui_up)/(500+tokui_up)
            ret = tokui_trn;
        else
            ret = tr_list(randi(4));
        end
    end
end
