
 functor
 import
    Project2025
    System
    Property
 export
    partitionToTimedList: PartitionToTimedList
 define

    % Translate a note to the extended notation.
    fun {NoteToExtended Note}
        case Note
        of nil then nil
        [] note(...) then Note
        [] silence(duration: _) then Note
        [] silence then silence(duration:1.0)
        [] Name#Octave then note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {Count L}
        case L
        of nil then
            0
        [] X | Y then
            1 + {Count Y}
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {ApplyDurationAux DurationPerElement Partition}
		case Partition
		of nil then nil
		[] silence|T then
			silence(duration: DurationPerElement) | {ApplyDurationAux DurationPerElement T}
		[] Name#Octave then note(name:Name octave:Octave sharp:true duration:DurationPerElement instrument:none)
		% [] Atom then
		% 	case {AtomToString Atom}
		% 	of [_] then
		% 		note(name:Atom octave:4 sharp:false duration:DurationPerElement instrument:none)
		% 	[] [N O] then
		% 		note(name:{StringToAtom [N]}
		% 			octave:{StringToInt [O]}
		% 			sharp:false
		% 			duration:DurationPerElement
		% 			instrument: none)
		% 	end
		[] X | Y then
			{ApplyDurationAux DurationPerElement X} | {ApplyDurationAux DurationPerElement Y}
		else
			nil
		end
     end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {ApplyDuration TotalDuration PartitionEtendue}
        % NbElements = {CountElements PartitionEtendue}
		% {System.show PartitionEtendue}
		NbElements = {Length PartitionEtendue}
        DurationPerElement = TotalDuration / NbElements
	in
        {ApplyDurationAux DurationPerElement PartitionEtendue}
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {ApplyStretch Factor TimedList}
		NX
	in
		case TimedList
		of nil then nil
		[] X|Y then
			% {System.show X}
			case X of nil then nil
			[] note(...) then
				% {System.show X}
				NX = note(name:X.name octave:X.octave sharp:X.sharp duration:Factor instrument:X.instrument)
				NX | {ApplyStretch Factor Y}
			else
				X | {ApplyStretch Factor Y}
			end
		else
			nil
		end
     end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {NoteToMidi Name Sharp Octave}
        Table = record(c:0 d:2 e:4 f:5 g:7 a:9 b:11)
        Base = Table.Name
        in
        Octave*12 + Base + (if Sharp then 1 else 0 end)
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {MidiToNote Midi Duration Instrument}
        Octave = Midi div 12
        Index = Midi mod 12
        IndexToNote = [
           c#false  % 0
           c#true   % 1
           d#false  % 2
           d#true   % 3
           e#false  % 4
           f#false  % 5
           f#true   % 6
           g#false  % 7
           g#true   % 8
           a#false  % 9
           a#true   % 10
           b#false  % 11
        ]
        Name#Sharp = {List.nth IndexToNote Index}
     in
        note(name:Name octave:Octave sharp:Sharp duration:Duration instrument:Instrument)
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {TransposeNote Note Semitones}
        note(name:N octave:O sharp:S duration:D instrument:I) = Note
        Midi = {NoteToMidi N S O}
        NewMidi = Midi + Semitones
     in
        {MidiToNote NewMidi D I}
     end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {TransposeChord Semitones Chord}
        case Chord
        of nil then nil
        [] Note | Rest then
           {TransposeNote Note Semitones} | {TransposeChord Semitones Rest}
        end
     end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {ApplyTranspose Semitones Partition}
        case Partition
        of nil then nil
        [] note then
            {TransposeNote note Semitones}
        [] silence then
            silence
        [] Chord then
            {TransposeChord Semitones Chord}
        end
     end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {HandleDrone Note Amount}
        if Amount =< 0 then nil
        else
           Note | {HandleDrone Note Amount - 1}
        end
     end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {HandleMute Amount}
        if Amount =< 0 then nil
        else
           silence | {HandleMute Amount - 1}
        end
     end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {IsNote Pi}
        case Pi of silence then true
        [] silence(...) then true
        [] note(...) then true
        [] H | T then false
        [] Name#Octave then {Member Name [a b c d e f g]}
        [] S then
            if {String.isAtom S} then
                String_name = {Atom.toString Pi}
            in
                case String_name of N|_ then {Member [N] ["a" "b" "c" "d" "e" "f" "g"]}  %car "a" --> [97] et donc utilisez {Member [N] ..}
                [] N then {Member [N] ["a" "b" "c" "d" "e" "f" "g"]}
                else
                    false
                end
            else false end
        end
    end


    fun {PartitionToTimedList Partition}
        % TODO
		% {System.show Partition}
        case Partition of nil then nil
        [] duration(seconds:S P)|Y then
			{Append {ApplyDuration S P} {PartitionToTimedList Y}}
        [] stretch(factor:F P)|Y then
            {Append {ApplyStretch F {PartitionToTimedList P}} {PartitionToTimedList Y}}
        [] transpose(semitones:N P)|Y then
			{Append {ApplyTranspose N P} {PartitionToTimedList Y}}
        [] drone(note:N amount:A)|Y then
            {Append {HandleDrone N A} {PartitionToTimedList Y}}
        [] mute(amount:A)|Y then
			{Append {HandleMute A} {PartitionToTimedList Y}}
		[] X|Y then
			{NoteToExtended X} | {PartitionToTimedList Y}
        else
            {NoteToExtended Partition}
        end
    end

end
