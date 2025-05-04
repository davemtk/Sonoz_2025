
functor
import
	Project2025
	OS
	System
	Property
export
	mix: Mix
define
	% Get the full path of the program
	CWD = {Atom.toString {OS.getCWD}}#"/"

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% Addition de 2 listes
	fun {FixValueBound Value}
		if Value < ~1.0 then
			~1.0
		elseif Value > 1.0 then
			1.0
		else
			Value
		end
	end

	fun{Sum X Y} Add in
		case X
		of Xa|Xb then
			case Y
			of Ya|Yb then
				Add = Xa + Ya
				{FixValueBound Add} | {Sum Xb Yb}
			[] nil then Xa | {Sum Xb nil}
			end
		[] nil then
			case Y
			of Ya|Yb then Ya | {Sum nil Yb}
			[] nil then nil
			end
		end
	end


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% Fonction Multiplication sur une liste
	fun {Multi A B}
		case A of H|T then
			(H*B)|{Multi T B}
		else
			nil
		end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




	fun {Note_Index Note Sharp}
        case Note#Sharp
			of c#false then 0
			[] c#true then 1
			[] d#false then 2
			[] d#true then 3
			[] e#false then 4
			[] e#true then 5
			[] f#false then 5 % >E# vaut F
			[] f#true then 6
			[] g#false then 7
			[] g#true then 8
			[] a#false then 9
			[] a#true then 10
			[] b#false then 11
			[] b#true then 0 % >B# vaut C
			else nil
        end
    end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% partition(<partition>)
   	% > liste d'échantillons

	% FlatPartition = [
	% 	note(name:a octave:4 sharp:false duration:1.0),
	% 	chord([note(name:c octave:4 sharp:false duration:1.0) note(name:e octave:4 sharp:false duration:1.0)]),
	% 	silence(duration:0.5)
	% ]

	fun {GetHeigh Note} A4_index Index Delta_octave Delta_note Height in
		A4_index = 9 %{note_index a False}}
		Index = {Note_Index Note.name Note.sharp}
		Delta_octave = Note.octave - 4
		Delta_note = Index - A4_index
		Height = Delta_octave * 12
		Height + Delta_note
	end

	fun {GetFrequency Height}
		{Pow 2.0 ({Int.toFloat Height}/12.0)} * 440.0
	end

	fun {Setup Note}
		fun {Ai I} X in
			% Calculates sample at index I
			X = 2.0 * 3.14159265359 * Frequency * {Int.toFloat I}/44100.0
			0.5 * {Sin X}
		end
		Heigh Frequency SampleSize Lst Ai_v in
		Heigh = {GetHeigh Note}
		Frequency = {GetFrequency Heigh}
		SampleSize	= Note.duration * 44100.0
		% Ai_v = {Ai 1 Frequency}
		Lst	= {List.number 0 {Float.toInt SampleSize}-1 1}



		% {System.show Heigh}
		% {System.show Frequency}
		% {System.show SampleSize}

		% {System.show Ai_v}
		% {System.show '-----------'}
		% {System.show {List.map Lst Ai}}
		{List.map Lst Ai}
	end

	fun {SetupSilence Note}
		fun {MakeZeros N}
			if N == 0 then
			   nil
			else
			   0.0 | {MakeZeros N - 1}
			end
		end
		SampleSize in
		SampleSize = Note.duration * 44100.0
		{MakeZeros {Float.toInt SampleSize}}
	end

	% fun {SetupChord Notes} SampleSize in
	% 	SampleSize = (Notes.1).duration * 44100.0



	% 	{System.show SampleSize}

	% end



	fun {PartitionFlat FlatPartition}
		case FlatPartition of nil then nil
		[] note(duration:D instrument:I name:N octave:O sharp:S)|T then
			% {System.show {Setup H}}
			% {System.show {SetupSilence H}}
			% {System.show {SetupChord H}}
			% {Append H {PartitionFlat T}}
			{Append {Setup note(duration:D instrument:I name:N octave:O sharp:S)} {PartitionFlat T}}
		else
			nil
		end
	end

	fun{Partition Partition P2T} FlatPartition in
		FlatPartition = {P2T Partition}
		{PartitionFlat FlatPartition}
	end


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% wave(<filename>)
	% > liste d’echantillons
	fun {Wave File_name}
		try
			{Project2025.readFile CWD#File_name}
		catch _ then
			nil
		end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% merge(<musics with intensities>)
	% merge([0.5#Music1 0.2#Music2 0.3#Music3])
	% > merge plusieurs liste en une seule
	fun {Merge Music_WI P2T}
		% {System.show Music_WI}
		case Music_WI of nil then nil
		[] (Factor#Music)|T then % merge(<musics with intensities>)
			Sample = {Mix P2T Music}
			SampleScaled = {Multi Sample Factor} % Multiplier par l'intensit

			MixRest = {Merge T P2T}
		in
			{Sum SampleScaled MixRest} % Merge les samples
		end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% repeat(amount:〈natural〉 〈music〉)

	fun {Repeating N Music}
		if N == 0 then
			nil
		else
		%	Music | {Repeat N-1 Music}
			{Append Music {Repeating N-1 Music}}
		end
	end

	fun {Repeat N Music P2T}
		{System.show repeat}
		{System.show Music}
		Samples = {Mix P2T Music}
	in
		{Repeating N Samples}
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% loop(seconds:〈duration〉 〈music〉)
	fun {Loop Duration Music P2T}
		fun {Truncate Music Index SamplesCount}
			if Index >= SamplesCount then
				nil
			else
				case Music of nil then nil
				[] H|T then
					H | {Truncate T Index+1 SamplesCount}
				end
			end
		end

		Samples = {Mix P2T Music}
		{System.show Duration}
		SamplesCount = {FloatToInt (Duration * 44100.0)}
		N = {Int.'div' SamplesCount {Length Samples}}
		Base = {Repeating N Samples}
		Trunc = {Truncate Samples 0 SamplesCount-{Length Samples}*(N)}
	in
		{Append Base Trunc}
	end


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% clip(low:〈sample〉 high:〈sample〉 〈music〉)



	fun {Clip Low High Music P2T}
		fun {ClipSetH H Low High}
			if H < Low then
				Low
			elseif H > High then
				High
			else
				H
			end
		end
		fun {Clipping Low High Music}
			if Low > High then
				nil
			else
				case Music of nil then nil
				[] H|T then
					{ClipSetH H Low High} | {Clipping Low High T}
				end
			end
		end
		Samples = {Mix P2T Music}
		{System.show Samples}
	in
		{Clipping Low High Samples}
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% echo(delay:〈duration〉 decay:〈factor〉 repeat:〈natural〉 〈music〉)

	fun {MakeSilence Duration}
		SamplesCount = {Float.toInt (Duration * 44100.0)}
	in
		{MakeZeros SamplesCount}
	end
	fun {MakeZeros N}
		if N == 0 then
			nil
		else
			0.0 | {MakeZeros N-1}
		end
	end
	% [merge([0.5#([samples([0.1 ~0.2 0.3])]) 0.2#([samples([0.1 ~0.2 0.3])]) 0.3#([samples([0.1 ~0.2 0.3])])])]
	fun {Echo Delay Decay Repeat Music P2T}
		fun {Echoing Delay DelayDt Decay DecayDt Repeat Music P2T} Silence Samples SilenceSample in
			{System.show Repeat}
			if Repeat == 0 then
				nil
			else
				Silence = {MakeSilence Delay}
				Samples = {Mix P2T Music}
				SilenceSample = {Append Silence Samples}
				% {Append Decay#[samples(SilenceSample)] {Echoing Delay Decay Repeat-1 Music P2T}}
				Decay#[samples(SilenceSample)] | {Echoing Delay+DelayDt DelayDt Decay*DecayDt DecayDt Repeat-1 Music P2T}
			end
		end
		Samples = {Mix P2T Music}
		{System.show Delay}
		Echo = {Echoing Delay Delay Decay Decay Repeat Music P2T}
		{System.show Echo}
		ToMerge = {Append [1.0#[samples(Samples)]] Echo}
		{System.show ToMerge}
		CombinedMusic = {Merge ToMerge P2T}
		{System.show CombinedMusic}
	in
		CombinedMusic
	end


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% fade(start:〈duration〉 finish:〈duration〉 〈music〉)

	fun {GetTheValue Value StartSize FinishSize FinishIndex N}
		% {System.show Value}
		if N < StartSize then
			{Int.toFloat N}/{Int.toFloat StartSize} * Value
		elseif N >= FinishIndex then
			{Int.toFloat FinishSize-(N+1-FinishIndex)}/{Int.toFloat FinishSize} * Value
		else
			Value
		end
	end

	fun {Fadeing Samples StartSize FinishSize FinishIndex N}
		case Samples of nil then nil
		[] H|T then
			{GetTheValue H StartSize FinishSize FinishIndex N} | {Fadeing T StartSize FinishSize FinishIndex N+1}
		end
	end

	fun {Fade Start Finish Music P2T}
		StartSize = {Float.toInt (Start*44100.0)}
		FinishSize = {Float.toInt (Finish*44100.0)}
		Samples = {Mix P2T Music}
		TotalLen = {Length Samples}
		FinishIndex = TotalLen - FinishSize

		% {System.show StartSize}
		% {System.show FinishSize}
		% {System.show FinishIndex}

		% Intensite = {Append {Append {FadeIn StartSize 0} {MakeOnes TotalLen - (StartSize + FinishSize)}}{FadeOut FinishSize FinishSize-1}}
	in
		if TotalLen < (StartSize + FinishSize) then
            Samples
		else
			% FadeIn = {ForAll 1 StartSize fun {$ I} {IntToFloat (I-1)} / {IntToFloat StartSize-1} end}
			% {System.show {FadeIn StartSize 0}}
			% {System.show {MakeOnes TotalLen - (StartSize + FinishSize)}}
			% {System.show {FadeOut FinishSize FinishSize-1}}

			% {System.show Intensite}
			% {System.show {SetupIntesite Samples Intensite}}

			% {System.show '---------------'}
			% {System.show {Fadeing Samples StartSize FinishSize FinishIndex 0}}

			{Fadeing Samples StartSize FinishSize FinishIndex 0}
		end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% cut(start:〈duration〉 finish:〈duration〉 〈music〉):

	fun {Cutting Samples Index StartI FinishI}
		case Samples
		of nil then
			if (Index < StartI) then
				{Cutting Samples Index+1 StartI FinishI}
			elseif (Index >= FinishI) then
				nil
			else
				0.0 | {Cutting Samples Index+1 StartI FinishI}
			end
		[] H|T then
			if (Index < StartI) then
				{Cutting T Index+1 StartI FinishI}
			elseif (Index >= FinishI) then
				nil
			else
				H | {Cutting T Index+1 StartI FinishI}
			end
		end
	end

	fun {Cut Start Finish Music P2T}
		StartI = {Float.toInt Start*44100.0}
		FinishI = {Float.toInt Finish*44100.0}
		Samples = {Mix P2T Music}
		{System.show Samples}
	in
		{Cutting Samples 0 StartI FinishI}
	end


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%								Extensions
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% reverse(〈music〉)
	% Inverse la musique

	fun{Reverse Music P2T}
		Samples = {Mix P2T Music}
	in
		{List.reverse Samples}
 	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% crossfade(duration:〈duration〉 〈music1〉 〈music2〉)

	fun {Crossfade Duration Music1 Music2 P2T}
		{System.show Music1}
		{System.show Duration}
		Samples1 = {Mix P2T Music1}
		MusicFade1 = [fade(start:0.0 finish:Duration/2.0 Music1)]
		MusicFade2 = [fade(start:Duration/2.0 finish:0.0 Music2)]
	in
		{System.show {Mix P2T MusicFade1}}
		{System.show {Mix P2T MusicFade2}}
		{Append {Mix P2T MusicFade1} {Mix P2T MusicFade2}}
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%									Mix
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% Genere music samples avec la musique donnée
	% P2T : partition to timed list
	% Music : liste de notes [samples([0.1 ~0.2 0.3])] [tuple]

	fun {Mix P2T Music}
		% TODO
		case Music of nil then nil
		[] samples(S)|T then % samples(<samples>)
			{Append S {Mix P2T T}}
		[] partition(P)|T then % partition(<partition>)
			{Append {Partition P P2T} {Mix P2T T}}
		[] wave(F)|T then % wave(<filename>)
			{Append {Wave F} {Mix P2T T}}
		[] merge(M)|T then % merge(<musics with intensities>)
			{Append {Merge M P2T} {Mix P2T T}}
		[] repeat(amount:N Music)|T then  % repeat(amount:〈natural〉, <music>)
			{Append {Repeat N Music P2T} {Mix P2T T}}
		[] loop(duration:D Music)|T then
			{Append {Loop D Music P2T} {Mix P2T T}}
		[] clip(low:L high:H Music)|T then
			{Append {Clip L H Music P2T} {Mix P2T T}}
		[] echo(delay:D decay:Dc repeat:R Music)|T then
			{Append {Echo D Dc R Music P2T} {Mix P2T T}}
		[] fade(start:S finish:F Music)|T then
			{Append {Fade S F Music P2T} {Mix P2T T}}
		[] cut(start:S finish:F Music)|T then
			{Append {Cut S F Music P2T} {Mix P2T T}}
		[] reverse(P)|T then
             {Append {Reverse P P2T} {Mix P2T T}}
		[] crossfade(duration:D Music1 Music2)|T then
			{Append {Crossfade D Music1 Music2 P2T} {Mix P2T T}}
		else
			nil
		end
		% {Project2025.readFile CWD#'wave/animals/cow.wav'}
	end



end
