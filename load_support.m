d = readtable("support_list.xlsx");	
d = fillmissing(d, 'constant',0,'DataVariables', ...
                {'FriendBonus','MotivEffUp','TrainingEffUp','Kizuna', ...
                 'TokuiUp','RaceBonus','FanBonus','HintUp','HpKeigen','HpHealBoost'});

support_list = struct();

for i = 1:size(d, 1)
    f = d{i, 1}{1};
    val = table2struct(d(i, 2:size(d,2)));
    support_list.(f) = val;
end

clear d f val i