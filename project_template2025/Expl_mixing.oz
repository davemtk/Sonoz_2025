functor
import
   Project2025
   Mix
   System
   Property
   OS
export
	exemple: Exemple
define
	CWD = {Atom.toString {OS.getCWD}}#"/"

	FileName1 = 'wave/animals/cow.wav'
	FileName2 = 'wave/animals/chicken.wav'
	FileName3 = 'wave/animals/dog.wav'
	FileName4 = 'wave/animals/cat.wav'


	proc {Exemple Mix P2T}
		{System.show '------------------- Exemple ------------------'}
		% Samples =
		% try
		% 	Samples = {Project2025.readFile CWD#FileName}
		% catch E then
		% 	{System.show 'Erreur lors du chargement du fichier WAV'}
		% 	{System.show E}
		% end

		% Samples = [wave(CWD#FileName)]

		MusicSetup = [wave(FileName1)]
		Samples = {Mix P2T MusicSetup}
		MusicSetup2 = [wave(FileName2)]
		Samples2 = {Mix P2T MusicSetup2}

		M_WI1 = [0.5#MusicSetup 0.5#MusicSetup2]
		Music1 = [merge(M_WI1)]

		Music2 = [repeat(amount:3 Samples)]


		Music3 = [loop(duration:2.5 MusicSetup)]


		Fix = [samples(Samples)]
		Music5 = [echo(delay:0.5 decay:0.3 repeat:5 Fix)]
		{System.show {Mix P2T Music5}}



		MusicSetup3 = [wave(FileName3)]
		Music6 = [fade(start:4.0 finish:4.0 MusicSetup3)]

		Music7 = [cut(start:5.0 finish:7.0 MusicSetup3)]


		Music8 = [reverse(Samples)]
		MusicSetup4 = [wave(FileName4)]
		Music9 = [crossfade(duration:2.0 MusicSetup3 MusicSetup4)]

		in
			{System.show '=> out_base.wav'}
			{System.show {Project2025.run Mix P2T MusicSetup 'out_base.wav'}}
			{System.show '=> out_merge.wav'}
			{System.show {Project2025.run Mix P2T Music1 'out_merge.wav'}}
			{System.show '=> out_repeat.wav'}
			{System.show {Project2025.run Mix P2T Music2 'out_repeat.wav'}}
			{System.show '=> out_loop.wav'}
			{System.show {Project2025.run Mix P2T Music3 'out_repeat.wav'}}
			{System.show '=> out_clip.wav'}

			{System.show '=> out_echo.wav'}
			{System.show {Project2025.run Mix P2T Music5 'out_echo.wav'}}
			{System.show '=> out_fade.wav'}
			{System.show {Project2025.run Mix P2T Music6 'out_fade.wav'}}
			{System.show '=> out_cut.wav'}
			{System.show {Project2025.run Mix P2T Music7 'out_cut.wav'}}


			{System.show '=> out_reverse.wav'}
			{System.show {Project2025.run Mix P2T Music8 'out_reverse.wav'}}
			{System.show '=> out_crossfade.wav'}
			{System.show {Project2025.run Mix P2T Music9 'out_crossfade.wav'}}
	end
end
