 
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
            0.0
        [] X | Y then
            1.0 + {Count Y}
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {ApplyDurationAux DurationPerElement Partition}
        case Partition
        of nil then nil
        [] X | Y then
           if {IsRecord X} andthen {Label X} == note then
              note(name:N octave:O sharp:S duration:D instrument:I) = X
           in
              note(name:N octave:O sharp:S duration:DurationPerElement instrument:I) | {ApplyDurationAux DurationPerElement Y}
           elseif {IsRecord X} andthen {Label X} == silence then
              silence(duration:D) = X
           in
              silence(duration:DurationPerElement) | {ApplyDurationAux DurationPerElement Y}
           end
        end
     end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {ApplyDuration TotalDuration PartitionEtendue}
        NbElements DurationPerElement
        NbElements = {Count PartitionEtendue}
        DurationPerElement = TotalDuration / NbElements
    in
        {ApplyDurationAux DurationPerElement PartitionEtendue}
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fun {ApplyStretch Factor PartitionEtendue}
        case PartitionEtendue
        of nil then nil
        [] X | Y then
           if {IsRecord X} andthen {Label X} == note then
              note(name:N octave:O sharp:S duration:D instrument:I) = X
           in
              note(name:N octave:O sharp:S duration:D * Factor instrument:I) | {ApplyStretch Factor Y}
           elseif {IsRecord X} andthen {Label X} == silence then
              silence(duration:D) = X
           in
              silence(duration:D * Factor) | {ApplyStretch Factor Y}
           end
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

    fun {PartitionToTimedList Partition}
        case Partition
        of nil then
           nil
        [] X | Y then
           if {IsRecord X} then
              case X
              of duration(seconds:S P) then
                 {ApplyDuration S {PartitionToTimedList P}}
              [] stretch(factor:F P) then
                 {ApplyStretch F {PartitionToTimedList P}}
              [] transpose(semitones:N P) then
                 {ApplyTranspose N {PartitionToTimedList P}}
              [] drone(note:N amount:A) then
                 {PartitionToTimedList {HandleDrone N A}}
              [] mute(amount:A) then
                 {PartitionToTimedList {HandleMute A}}
              else
                 {NoteToExtended X} | {PartitionToTimedList Y}
              end
           elseif {IsList X} then
              {PartitionToTimedList X} | {PartitionToTimedList Y}
           else
              {NoteToExtended X} | {PartitionToTimedList Y}
           end
        end
     end
     
end