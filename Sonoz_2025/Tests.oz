functor
import
   Project2025
   Mix
   System
   Property
   OS
export
   test: Test
define

   PassedTests = {Cell.new 0}
   TotalTests  = {Cell.new 0}

   FiveSamples = 0.00011337868 % Duration to have only five samples

	CWD = {Atom.toString {OS.getCWD}}#"/"

   % Takes a list of samples, round them to 4 decimal places and multiply them by
   % 10000. Use this to compare list of samples to avoid floating-point rounding
   % errors.
   fun {Normalize Samples}
      {Map Samples fun {$ S} {IntToFloat {FloatToInt S*10000.0}} end}
   end

   proc {Assert Cond Msg}
      TotalTests := @TotalTests + 1
      if {Not Cond} then
         {System.show Msg}
      else
         PassedTests := @PassedTests + 1
      end
   end

   proc {AssertEquals A E Msg}
      TotalTests := @TotalTests + 1
      if A \= E then
         {System.show Msg}
         {System.show actual(A)}
         {System.show expect(E)}
      else
         PassedTests := @PassedTests + 1
      end
   end

   fun {NoteToExtended Note}
      case Note
      of note(...) then
         Note
      [] silence(duration: _) then
         Note
      [] _|_ then
         {Map Note NoteToExtended}
      [] nil then
         nil
      [] silence then
         silence(duration:1.0)
      [] Name#Octave then
         note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] Atom then
         case {AtomToString Atom}
         of [_] then
            note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
         [] [N O] then
            note(name:{StringToAtom [N]}
                 octave:{StringToInt [O]}
                 sharp:false
                 duration:1.0
                 instrument: none)
         end
      end
   end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% TEST PartitionToTimedNotes

	proc {TestNotes P2T}
		skip
	 	P1 = [a0 b1 c#2 d#3 e silence]
	 	E1 = {Map P1 NoteToExtended}
	 in
		{System.show '----------- TestNotes -------------'}
		{System.show E1}
	 	{AssertEquals {P2T P1} E1 "TestNotes"}
	end

	proc {TestChords P2T}
		skip
	end

	proc {TestIdentity P2T}
		% test that extended notes and chord go from input to output unchanged
		skip
	end

	proc {TestDuration P2T}
		skip
	end

	proc {TestStretch P2T}
		skip
	end

	proc {TestDrone P2T}
		skip
	end

	proc {TestMute P2T}
		skip
	end

	proc {TestTranspose P2T}
		skip
	end

	proc {TestP2TChaining P2T}
		skip
	end

	proc {TestEmptyChords P2T}
		skip
	end

	proc {TestP2T P2T}
		{TestNotes P2T}
		{TestChords P2T}
		{TestIdentity P2T}
		{TestDuration P2T}
		{TestStretch P2T}
		{TestDrone P2T}
		{TestMute P2T}
		{TestTranspose P2T}
		{TestP2TChaining P2T}
		{TestEmptyChords P2T}
		{AssertEquals {P2T nil} nil 'nil partition'}
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% TEST Mix


	proc {TestSamples P2T Mix}
		E1 = [0.1 ~0.2 0.3]
		M1 = [samples(E1)]
	in
		{AssertEquals {Mix P2T M1} E1 'TestSamples: simple'}
	end

	% Pas de B# ou E#
	proc {TestPartition P2T Mix}
		%P1 = [a]
		%Check1 = {Normalize {(Mix.echsPartition) [a] P2T}}
		%M1 = [partition(P1)]
		%Mixed1 = {Normalize {Mix P2T M1}}
	%in
		%{AssertEquals Mixed1 Check1 'TestSamples: simple'}
		P = [c#4 d#4 e f#4 g#4 a#5 b c d a]
		Music = [partition(P)]

	in
		{System.show '----------- Partition -------------'}
		{System.show Music}
		{System.show {P2T P}}
		{System.show {Mix P2T Music}}
		% {System.show {Project2025.run Mix P2T Music 'out.wav'}}
	end

	proc {TestWave P2T Mix} % Pourquoi load il demande un .oz or dans le pdf il faut un .WAV ???
		% CWD = {Atom.toString {OS.getCWD}}#"/"
		% FileName = 'wave/test/joy.dj.oz'
		FileName = 'wave/animals/cat.wav'
		ExpectedSamples
		Music = [wave(FileName)]
		MixedSamples = {Mix P2T Music}
	in
		try
			{System.show '----------- TestWave -------------'}
			ExpectedSamples = {Project2025.readFile CWD#FileName}
			{System.show ExpectedSamples}
			{System.show MixedSamples}
			{AssertEquals MixedSamples ExpectedSamples 'TestWave: simple wave file'}
		catch E then
			{System.show 'Erreur lors du chargement du fichier WAV'}
			{System.show E}
		end
	end

	proc {TestMerge P2T Mix}
		E1 = [0.1 ~0.2 0.3]
		Music1 = [samples(E1)]
		E2 = [0.1 ~0.2 0.3]
		Music2 = [samples(E2)]
		E3 = [0.1 ~0.2 0.3]
		Music3 = [samples(E3)]

		M_WI1 = [0.5#Music1 0.2#Music2 0.3#Music3]
		MusicMerge = [merge(M_WI1)]

		E21 = [0.1 ~0.2 0.3]
		Music21 = [samples(E21)]
		E22 = [0.0 0.0 0.0 0.4 0.5]
		Music22 = [samples(E22)]

		M_WI2 = [1.0#Music21 1.0#Music22]
		MusicMerge2 = [merge(M_WI2)]
		EM2 = [0.1 ~0.2 0.3 0.4 0.5]
	in
		{System.show '----------- TestMerge -------------'}
		{System.show MusicMerge}
		{AssertEquals {Mix P2T MusicMerge} E1 'TestMerge: simple'}
		{AssertEquals {Mix P2T MusicMerge2} EM2 'TestMerge: add'}
	end

	proc {TestRepeat P2T Mix}
		{System.show '----------- TestRepeat -------------'}
		Samples = [1.0 2.0 3.0]
		Music = [samples(Samples)]
		MusicRepeat = [repeat(amount:3 Music)]
		E =  {Append {Append Samples Samples } Samples}
  	in
		{AssertEquals {Mix P2T MusicRepeat} E 'TestRepeat: simple'}
	end

	proc {TestLoop P2T Mix}
		Samples = [0.1 ~0.2 0.3 0.4]
		Music = [samples(Samples)]
		TempsDeSample = 1.0/44100.0
		MusicLoop = [loop(duration:TempsDeSample*3.0 Music)]
		E = [0.1 ~0.2 0.3]
		MusicLoop2 = [loop(duration:TempsDeSample*9.0 Music)]
		E2 = [0.1 ~0.2 0.3 0.4 0.1 ~0.2 0.3 0.4 0.1]

	in
		{System.show '----------- TestLoop -------------'}
		{AssertEquals {Mix P2T MusicLoop} E 'TestLoop: below size'}
		{AssertEquals {Mix P2T MusicLoop2} E2 'TestLoop: above size'}
	end

	proc {TestClip P2T Mix}
		Samples = [0.1 ~0.2 ~0.7 0.2 0.4 0.9 ~0.9 0.3]
		Music = [samples(Samples)]
		MusicClip = [clip(low: ~0.3 high:0.6 Music)]
		E = [0.1 ~0.2 ~0.3 0.2 0.4 0.6 ~0.3 0.3]
		MusicClip2 = [clip(low: 0.3 high:0.6 Music)]
		E2 = [0.1 ~0.2 ~0.3 0.2 0.4 0.6 ~0.3 0.3 0.6]
		MusicClip3 = [clip(low: 0.5 high:0.0 Music)]
		E3 = nil
	in
		{System.show '----------- TestClip -------------'}
		{AssertEquals {Mix P2T MusicClip} E 'TestClip: normal'}
	end

	proc {TestEcho P2T Mix}
		Samples = [0.1 0.1 0.1 0.1 0.1]
		Music = [samples(Samples)]
		TempsDeSample = 1.0/44100.0
		MusicEcho = [echo(delay: TempsDeSample*1.0 decay:0.9 repeat:3 Music)]
		E = [0.1 0.19 0.271 0.3439 0.3439 0.2439 0.1539 0.0729]
	in
		{System.show '----------- TestEcho -------------'}
		{AssertEquals {Mix P2T MusicEcho} E 'TestEcho: basic'}
	end

	proc {TestFade P2T Mix}
		{System.show '----------- TestFade -------------'}
		% Samples = [0.5 0.5 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0]
		Samples = [0.5 ~0.5 0.5 ~0.5 0.5 ~0.5 0.5 ~0.5 0.5 ~0.5 0.5 ~0.5 0.5 ~0.5 0.5]
		% Samples = [1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0]
		Music = [samples(Samples)]
		TempsDeSample = 1.0/44100.0


		MusicFade = [fade(start:TempsDeSample*5.0 finish:TempsDeSample*3.0 Music)]
		E = [0 ~0.1 0.2 ~0.3 0.4 ~0.5 0.5 ~0.5 0.5 ~0.5 0.5 ~0.375 0.25 ~0.125 0]
		MusicFade2 = [fade(start:TempsDeSample*10.0 finish:TempsDeSample*10.0 Music)]
	in
		{AssertEquals {Mix P2T MusicFade} E 'TestFade: basic'}
		{AssertEquals {Mix P2T MusicFade2} Samples 'TestFade: basic'}
	end

	proc {TestCut P2T Mix}
		{System.show '----------- TestCut -------------'}
		Samples = [0.1 ~0.2 ~0.7 0.2 0.4 0.9 ~0.9 0.3]
		Music = [samples(Samples)]
		TempsDeSample = 1.0/44100.0

		MusicCut = [cut(start:TempsDeSample*2.0 finish:TempsDeSample*6.0 Music)]
		E = [~0.7 0.2 0.4 0.9]
	in
		{AssertEquals {Mix P2T MusicCut} E 'TestCut: basic'}
	end

	% Effets Complexes
	proc {TestReverse P2T Mix}
		{System.show '----------- TestReverse -------------'}
		Samples = [0.1 ~0.2 0.3]
		Music = [samples(Samples)]
		MusicReverse = [reverse(Music)]
		E = [0.3 ~0.2 0.1]
	in
		{AssertEquals {Mix P2T MusicReverse} E 'TestReverse: simple'}
	end

	% Effets Complexes
	proc {TestCrossfade P2T Mix}
		{System.show '----------- TestCrossfade -------------'}
		Samples = [1.0 1.0 1.0 1.0 1.0]
		Music1 = [samples(Samples)]
		Samples2 = [~1.0 ~1.0 ~1.0 ~1.0 ~1.0]
		Music2 = [samples(Samples2)]
		TempsDeSample = 1.0/44100.0

		MusicCrossFade = [crossfade(duration:TempsDeSample*4.0 Music1 Music2)]
		E = [1.0 1.0 1.0 0.5 0.0 ~0.0 ~0.5 ~1.0 ~1.0 ~1.0]
	in
		{AssertEquals {Mix P2T MusicCrossFade} E 'TestCrossfade: simple'}
	end

	proc {TestMuffle P2T Mix}
		{System.show '----------- TestMuffle -------------'}
		Samples = [0.1 ~0.2 ~0.7 0.2 0.4 0.9 ~0.9 0.3]
		Music = [samples(Samples)]
		TempsDeSample = 1.0/44100.0

		MusicCut = [muffle(start:TempsDeSample*2.0 finish:TempsDeSample*6.0 intensity:0.5 Music)]
		E = [0.1 ~0.2 ~0.35 0.1 0.2 0.45 ~0.9 0.3]
		MusicCut2 = [muffle(start:TempsDeSample*0.0 finish:TempsDeSample*1.0 intensity:0.0 Music)]
		E2 = [0.0 ~0.2 ~0.7 0.2 0.4 0.9 ~0.9 0.3]
	in
		{AssertEquals {Mix P2T MusicCut} E 'TestMuffle: basic'}
		{AssertEquals {Mix P2T MusicCut2} E2 'TestMuffle: nothing'}
	end

	proc {TestMix P2T Mix}
		{System.show '=========================== MIX ==========================='}
		{System.show '=========================== MIX ==========================='}
		{TestSamples P2T Mix}
		{TestPartition P2T Mix}
		{TestWave P2T Mix}
		{TestMerge P2T Mix}
		{TestRepeat P2T Mix}
		{TestLoop P2T Mix}
		{TestClip P2T Mix}
		{TestEcho P2T Mix}
		{TestFade P2T Mix}
		{TestCut P2T Mix}
		{TestReverse P2T Mix}
		{TestCrossfade P2T Mix}
		{TestMuffle P2T Mix}
		{AssertEquals {Mix P2T nil} nil 'nil music'}
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	proc {Test Mix P2T}
		{Property.put print print(width:100)}
		{Property.put print print(depth:100)}
		{System.show 'tests have started'}
		{TestP2T P2T}
		{System.show 'P2T tests have run'}
		{TestMix P2T Mix}
		{System.show 'Mix tests have run'}
		{System.show test(passed:@PassedTests total:@TotalTests)}
	end
end
