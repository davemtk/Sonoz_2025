% Ode To Joy
local
	Tune = [b b c5 d5 d5 c5 b a g g a b]
	End1 = [stretch(factor:1.5 [b]) stretch(factor:0.5 [a]) stretch(factor:2.0 [a])]
	End2 = [stretch(factor:1.5 [a]) stretch(factor:0.5 [g]) stretch(factor:2.0 [g])]
	Interlude = [a a b g a stretch(factor:0.5 [b c5])
					b g a stretch(factor:0.5 [b c5])
				b a g a stretch(factor:2.0 [d]) ]

	% This is not a music.
	% Partition = {Flatten [Tune End1 Tune End2 Interlude Tune End2]}
	Partition = {Flatten [Interlude]}
	% Partition = [stretch(factor:1.5 [b]) stretch(factor:0.5 [a]) stretch(factor:2.0 [a])]

	% FileName1 = 'wave/animals/cow.wav'

	% MusicSetup = [wave(FileName1)]
	Music1 = [partition(Partition)]
	Music2 = [partition([b])]
	Music11 = [loop(duration:40.0 Music1)]
	Music22 = [loop(duration:10.0 Music2)]
	M_WI2 = [1.0#Music11 0.5#Music22]
in
   % This is a music :)
    % [repeat(amount:5 partition(Partition))]
	% [echo(delay:0.5 decay:0.3 repeat:5 MusicSetup)]
	% [repeat(amount:2 Music)]
	% [loop(duration:40.0 Music)]

	[merge(M_WI2)]
	end
