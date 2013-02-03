import std.conv;
import std.stdio;
import std.string;
import logic;

int main(string[] args)
{
	auto mines = new MineField(8, 8);
	string entry;
	int x, y, v, bombs = 8;
	bool noConfirm = false;
	
	if(args.length > 1)
	{
		foreach(arg; args[1 .. $])
		{
			if(arg == "--help")
			{
				usage(args[0]);
				return 0;
			}
			else if(arg == "--noconf")
			{
				noConfirm = true;
			}
			else
			{
				writeln("wut.");
				writeln("Enter --help to display the usage guide.");
				return 0;
			}
		}
	}
	
	while(true)
	{
		mines.show();
		if(mines.checkWin())
		{
			mines.revealAll();
			writeln("What do you know, you actually won !");
			break;
		}
		else
		{
			writeln("_______________________________________");
			
			writef("Enter X Y coordinates (line column) or Q to quit (%d bombs left) : ", bombs);
			entry = chomp(readln());
			if(entry == "Q")
			{

				writeln("Yeah that's right. You better run home to your momma.");
				break;
			}
			else
			{
				bool mark = false;
				
				do
				{
					if(parseEntry(entry, x, y, mark))
					{
						mines.select(x, y);
						if(!noConfirm)
						{
							write("\rPress Y to confirm or re-enter the coordinates : ");
							entry = chomp(readln());
						}
					}
					else
					{
						mines.show();
						write("\rwut. Try again, and be serious this time : ");
						entry = chomp(readln());
					}
				}
				while(toLower(entry) != "y" && !noConfirm);
				
				if(mark)
				{
					/* MineField.mark() returns false if the cell wasn't marked before.
					 * In other words, it returns true if the cell is being marked
					 * and false otherwise.
					 * This was necessary in order to keep track of how many bombs are left.
					*/
					if(mines.mark(x, y))
					{
						bombs++;
					}
					else
					{
						bombs--;
					}
				}
				else
				{
					v = mines.reveal(x, y);
				
					if(v == 9)
					{
						mines.revealAll();
						writeln("BAM ! YOU STEPPED ON A LANDMINE BABY ! YOUR LIMBS ARE ALL OVER THE PLACE !");
						break;
					}
				}
			}
		}
	}
	
	return 0;
}

/* the validation here is lousy */
bool parseEntry(string entry, out int x, out int y, out bool mark)
{
	string[] coordinates = std.array.split(entry, " ");

	if(2 <= coordinates.length && coordinates.length <= 3 && 3 <= entry.length && entry.length <= 5)
	{
		x = to!int(chomp(coordinates[0])) - 1;
		y = to!int(chomp(coordinates[1])) - 1;
		mark = coordinates.length == 3;
		
		return true;
	}
	else
	{
		return false;
	}
}

void usage(string executable)
{
	writeln("Usage");
	writeln("``````");
	writefln("%s < --help | --noconf >", executable);
	writeln("  --help   : Prints this notice");
	writeln("  --noconf : The game won't ask for confirmation when you perform an action.");
	writeln("");
	writeln("How to play");
	writeln("````````````");
	writeln("[Q]        : Quits the game.");
	writeln("[M]        : Marks the selected cell as a bomb.");
	writeln("[Y]        : Confirm the selected action.");
	writeln("[1-8]      : Moves to the n-th row (or column).");
	writeln("[ENTER]    : Reveals the selected cell.");
	writeln("");
	writeln("A few guidelines");
	writeln("`````````````````");
	writeln("When the game prompts you to select a cell");
	writeln("enter the coordinates in the following format : (row column <M>).");
	writeln("Marking helps keeping track of how many bombs are left.");
	writeln("A marked cell cannot be revealed unless unmarked (this prevents deadly accidents).");
}
