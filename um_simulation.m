load_support;
training_data;

%% �V�~�����[�V�����ݒ蕔
% ��{�ݒ�
support = [support_list.SpecialWeek, support_list.NaritaTaishin, ...
           support_list.MihonoBourbon, support_list.AinesuFujin, ...
           support_list.KiryuinAoi, support_list.VodkaFriend ];

kizuna_offset = [10, 10, 10, 10, 10, 10];
training_turn = 65;

% �g���[�j���O�]���ݒ�
settings = struct();
settings.tr = struct();
settings.tr.weight = [10, 0, 10, 0, 0]; % �g���[�j���O�d��
settings.tr.summer_ignore_weight = true; % �č��h���A�g���[�j���O�d�݂𖳎�
settings.tr.lv5_ignore_weight = true; % Lv5�ɂȂ����g���[�j���O�͏d�݂𖳎�
settings.tr.att_weight = true; % �g���[�j���O�d�݂̌��� (���`, �c�^�[����/���^�[�����Ō���)
settings.tr.kizuna_rate = 1;
settings.tr.hp_rate = 0.5;
settings.tr.skill_pt_rate = 0.3;
settings.tr.hint_rate = 0;
settings.tr.turn = training_turn;

% �č��h���t�Z (�ŏI�^�[������14-11�^�[���O�A37-34�^�[���O�Ƃ���j
settings.tr.summer = [training_turn-37:training_turn-34, training_turn-14:training_turn-11];

% �p�����[�^�]���ݒ�
settings.param = struct();
settings.param.weight = [1, 1, 1, 1, 0.8];
settings.param.goal = [800, 300, 800, 100, 400];
settings.param.att_status = true;
settings.param.att_statust_width = 50; % goal���璴�߂������́A20%/width �̌X���Ō��������

% ���̑��萔
settings.tr_data = tr_data;
settings.tr_type_list = ["�X�s�[�h", "�X�^�~�i", "�p���[", "����", "����"];
settings.tr_list = ["spd", "stm", "pwr", "spr", "int"];

clear tr_data

%% �V�~�����[�V�����O����
% �T�|�[�^�[ �ŗL�{�[�i�X����, �����J�␳�K�p
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


%% �V�~�����[�V���� ���s
mode = 2; % 1: seed�w�莎�s, 2: �P�̎��s, 3: N�񎎍s
seed = 60;

N = 3000;
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
end




%% ���[�J���֐�
% �ŗL�{�[�i�X����
function [field, val] = unique_bonus(str)
    switch str
        case '�F��{�[�i�X'
            field = 'FriendBonus';
            val = 10;
        case '���C���ʃA�b�v'
            field = 'MotivEffUp';
            val = 18;
        case '�g�����ʃA�b�v'
            field = 'TrainingEffUp';
            val = 5;
        case '�����J'
            field = 'Kizuna';
            val = 10;
        case '���ӗ��A�b�v'
            field = 'TokuiUp';
            val = 20;
        case '�X�s�[�h�{�[�i�X'
            field = 'StatusBonus';
            val = '�X�s�[�h';
        case '�X�^�~�i�{�[�i�X'
            field = 'StatusBonus';
            val = '�X�^�~�i';
        case '�p���[�{�[�i�X'
            field = 'StatusBonus';
            val = '�p���[';
        case '�����{�[�i�X'
            field = 'StatusBonus';
            val = '����';
        case '�����{�[�i�X'
            field = 'StatusBonus';
            val = '����';
%         case '���[�X�{�[�i�X'
%         case '�t�@���{�[�i�X'
%         case '�q���g�������A�b�v'
        case '�̗͏���_�E��'
            field = 'HpKeigen';
            val = 5;
        otherwise
            field = 'na';
            val = 0;
    end
end


