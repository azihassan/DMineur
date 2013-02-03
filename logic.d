module logic;

import std.algorithm;
import std.array;
import std.conv;
import std.random;
import std.stdio;
import std.string;
import std.process;

class MineField
{
	Cell[][] mines;
	bool won = false;
	
	this(int rows, int cols, ushort bombs = 8)
	{
		for(int i = 0; i < rows; i++)
		{
			Cell[] cells;
			for(int j = 0; j < cols; j++)
			{
				cells ~= new Cell(0, i, j);
			}
			mines ~= cells;
		}
		
		placeBombs(bombs);
		fillCells();
	}
	
	bool checkWin()
	{
		Cell[] all = allCells();
		return count!("a.isBomb()")(all) == count!("!a.isRevealed()")(all);
	}
	
	void select(int row, int col)
	{
		foreach(cell; allCells())
		{
			cell.unSelect();
		}
		cellAt(row, col).select();
		show();
	}
	
	bool mark(int x, int y)
	{
		bool wasMarked = cellAt(x, y).isMarked();
		cellAt(x, y).mark();
		show();
		return wasMarked;
	}
	
	int reveal(int x, int y)
	{
		Cell c = cellAt(x, y);
		int v = 0;
		
		if(c.isMarked())
		{
		
		}
		else if(c.isVoid())
		{
			v = c.reveal();
			foreach(cell; getSurrounding(x, y))
			{
				if(!cell.isRevealed())
				{
					int cell_x, cell_y;
					cell.getPos(cell_x, cell_y);
					reveal(cell_x, cell_y);
				}
			}
		}
		else
		{
			v = c.reveal();
		}
		
		show();
		return v;
	}
	
	void revealAll()
	{
		foreach(cell; allCells())
		{
			cell.reveal();
		}
		show();
	}
	
	void show()
	{
		system("CLS");
		foreach(rows; mines)
		{
			foreach(cell; rows)
			{
				writef("%s", cell);
			}
			writeln("\r\n");
		}
	}
	
	private void placeBombs(ushort howMany)
	{
		while(howMany--)
		{
			int x = uniform(0, mines.length);
			int y = uniform(0, mines.length);
			
			cellAt(x, y).placeBomb();
		}
	}
	
	private void fillCells()
	{
		for(int i = 0; i < mines.length; i++)
		{
			for(int j = 0; j < mines.length; j++)
			{
				if(cellAt(i, j).isBomb())
				{
					foreach(cell; getSurrounding(i, j))
					{
						cell++;
					}
				}
			}
		}
	}
	
	private Cell[] getSurrounding(int x, int y)
	{
		Cell[] surrounding;
		
		surrounding ~= cellAt(x - 1, y);
		surrounding ~= cellAt(x, y - 1);
		surrounding ~= cellAt(x + 1, y);
		surrounding ~= cellAt(x, y + 1);
		surrounding ~= cellAt(x - 1, y - 1);
		surrounding ~= cellAt(x - 1, y + 1);
		surrounding ~= cellAt(x + 1, y + 1);
		surrounding ~= cellAt(x + 1, y - 1);
		
		return array(filter!("!a.isInvalid()")(surrounding));
	}
	
	private Cell cellAt(int x, int y)
	{
		if(x < 0 || y < 0)
		{
			return new Cell(-1, x, y); /* invalid cell */;
		}
		if(x > mines.length - 1 || y > mines.length - 1)
		{
			return new Cell(-1, x, y);
		}
		return mines[x][y];
	}
	
	private Cell[] allCells()
	{
		Cell[] all;
		
		for(int i = 0; i < mines.length; i++)
		{
			for(int j = 0; j < mines.length; j++)
			{
				all ~= cellAt(i, j);
			}
		}
		
		return all;
	}
	
}

class Cell
{
	int value, x, y;
	bool selected = false;
	bool revealed = false;
	bool marked = false;
	bool canKaboom = false;
	
	this(int pos_x, int pos_y)
	{
		value = 0;
		x = pos_x;
		y = pos_y;
	}
	
	void getPos(out int pos_x, out int pos_y)
	{
		pos_x = x;
		pos_y = y;
	}
	
	this(int v, int pos_x, int pos_y)
	{
		this(pos_x, pos_y);
		setValue(v);
	}
	
	void setValue(int v)
	{
		value = v;
	}
	
	int getValue()
	{
		return value;
	}
	
	bool isBomb()
	{
		return canKaboom;
	}
	
	void placeBomb()
	{
		canKaboom = true;
		setValue(9);
	}
	
	bool isVoid()
	{
		return value == 0;
	}
	
	bool isInvalid()
	{
		return value == -1;
	}
	
	bool isMarked()
	{
		return marked;
	}
	
	bool isRevealed()
	{
		return revealed;
	}
	
	void mark()
	{
		marked = isMarked() ? false : true;
	}
	
	void select()
	{
		selected = true;
	}
	
	void unSelect()
	{
		selected = false;
	}
	
	int reveal()
	{
		revealed = true;
		return getValue();
	}
	
	int opUnary(string op)()
	{
		if(op == "++")
		{
			int finalValue = 0;
			
			if(!isBomb() && !isInvalid())
			{
				finalValue = ++value;
				if(finalValue == 9)
				{
					finalValue = --value;
				}
			}
			else
			{
				finalValue = value;
			}
			
			return finalValue;
		}
	}
	
	override string toString()
	{
		string strValue;
		
		if(!revealed)
		{
			if(marked)
			{
				strValue = "M";
			}
			else
			{
				strValue = "?";
			}
		}
		else
		{
			if(isVoid())
			{
				strValue = " ";
			}
			else if(isBomb())
			{
				strValue = "B";
			}
			else
			{
				strValue = to!string(value);
			}
		}
		
		return selected ? format("[%s]", strValue) : format(" %s ", strValue);
	}
}