% Ode To Joy
local
	BaseD = [
		% Première partie
		% d d d d d d d d d d d d d d d d d d a c d d d e f f f g e e d c c d a c d d d e f f f g e e d c d a c d d d f g g g a la# la# a g a d d e f f g a d d f e e f d e a c d d d e f f f g e e d c c d a c d d d e f f f g e e d c d a c d d d f g g g a la# la# a g a d d e f f g a d d f e e d c d d e f f f g a f d a la# g d la# a + d f + d e + a + c# f g a a a la# a g g g g a a a a la# a g f e d d e f g a g f e f g a g f g a g f e f e d e c d d d c a d e f e f g f g a g f d d e f g a la# d d g f g e d c a d d e f d e d c d d e f d e f g g g a la# d f e d e d c d f a f a c d d e f d e d c d d e f d e f g g g a la# d f e d e d c d d f d
		e e f g g f e d c c d e e e d d e e f g g f e d c c d e d d c c d d e c
	]
	Left1 = [c3 c3 c3 c3 c3 c3 c3 c3]
	Left2 = [g3 g3 g3 g3 g3 g3 g3 g3]


	PartitionBase = {Flatten [BaseD]}
	PartitionLeft1 = {Flatten [Left1]}
	PartitionLeft2 = {Flatten [Left2]}
	FixSizeBase = {Flatten [stretch(factor:0.5 PartitionBase)]}
	FixsizeLeft1 = {Flatten [stretch(factor:0.5 PartitionLeft1)]}
	FixsizeLeft2 = {Flatten [stretch(factor:0.5 PartitionLeft2)]}
	MusicBase = [partition(FixSizeBase)]
	MusicLeft1 = [fade(start:0.5 finish:3.0 [partition(FixsizeLeft1)])]
	MusicLeft2 = [fade(start:0.5 finish:3.0 [partition(FixsizeLeft2)])]
	M_WIP = [1.0#MusicBase 1.0#MusicLeft1]
	MusicMerged = [merge(M_WIP)]
in
	MusicMerged
end
