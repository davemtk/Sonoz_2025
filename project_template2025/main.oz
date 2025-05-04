functor
import
    Project2025
    PartitionToTimedList
    Mix
    Tests
    Application
    OS
    System
    Property
	Expl_mixing
define
    % Get the full path of the program
    CWD = {Atom.toString {OS.getCWD}}#"/"

    % Get the arguments of the program. By default tests are set to false and music is "joy.dj.oz"
    Args = {Application.getArgs record('test'(single type:bool default:false optional:true)
                                        'music'(single type:string default:'joy.dj.oz')
										'music_exemple'(single type:string default:'exemple.dj.oz')
										'exemple'(single type:bool default:false optional:true)
                                        )}

    % Load the music
    Music = {Project2025.load CWD#Args.'music'}
	Music_exemple = {Project2025.load CWD#Args.'music_exemple'}

    if Args.'test' == true then
        % Launch tests
        {Tests.test Mix.mix PartitionToTimedList.partitionToTimedList}
	else
		if Args.'exemple' == true then
			% Launch exemples
			{System.show {Project2025.run Mix.mix PartitionToTimedList.partitionToTimedList Music_exemple 'out_exemple.wav'}}
			{Expl_mixing.exemple Mix.mix PartitionToTimedList.partitionToTimedList}
		else
			% Calls your code, prints the result and outputs the result to `out.wav`.
			% {System.show {Project2025.run Mix.mix PartitionToTimedList.partitionToTimedList Music 'out.wav'}}

			% Launch only ParitionToTimedList. Uncomment me to test and use System.show in PartitionToTimedList (REMOVE ME for submission !)
			% local PartMusic in
			%     [partition(PartMusic)] = Music
			%     {System.show {PartitionToTimedList.partitionToTimedList PartMusic}}
			% end

			% Launch only Mix. Uncomment me to test and use System.show in Mix (REMOVE ME for submission !)
			{System.show Music}

			{System.show {Project2025.run Mix.mix PartitionToTimedList.partitionToTimedList Music 'out.wav'}}

			% System.show PartitionToTimedList.partitionToTimedList}
			% {System.show {Project2025.readFile CWD#'wave/animals/cow.wav'}}
			% {System.show {Mix.mix PartitionToTimedList.partitionToTimedList Music}}
		end
	end	 
end
