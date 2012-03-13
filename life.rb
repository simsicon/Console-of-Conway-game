class Cell
  attr_accessor :x, :y, :state, :neighbors_count
  
  def states
    [:alive, :die]
  end
  
  def start_state_machine
    next_index = states.index(@state) + 1 == states.length ? 0 : states.index(@state) + 1
    @state = states[next_index]
  end
  
  def initialize(x, y)
    @x = x
    @y = y
    @state = :die
  end
  
  def rule
    if @state == :alive
      start_state_machine unless [2,3].include?(@neighbors_count)
    elsif @neighbors_count == 3
      start_state_machine
    end
  end
  
  def to_s
    @state == :alive ? " * " : " O " 
  end
  
  def step(neighbors_count)
    @neighbors_count = neighbors_count 
    rule
  end
end

class Game
  attr_accessor :cells
  
  def initialize(width, height)
    @width, @height = width, height
    @cells = Array.new(@height){|y| Array.new(@width){|x|Cell.new(x, y)}}
  end
  
  def to_s
    @cells.map{|row| row.join }.join("\n") + "\n------------------------------------"
  end
  
  def set_cells(bin_ary)
    y = 0
    bin_ary.each do |bin_str|
      x = 0
      bin_str.each_char do |char|
        if char == '1'
          @cells[y][x].start_state_machine
        end
        x = x + 1
      end
      y = y + 1
    end
    self
  end
  
  def start
    @neighbors_counts ||= Array.new(@height){|y| Array.new(@width)}
    
    @cells.each do |row|
      row.each do |cell|
        @neighbors_counts[cell.y][cell.x] = neighbors_count(cell.x, cell.y)
      end
    end
    
    @cells.each do |row|
      row.each do |cell|
        cell.step(@neighbors_counts[cell.y][cell.x])
      end
    end
  end

  def neighbors_count(x, y)
    count = 0
    neighbors_matrix.each do |neighbor|      
      if y + neighbor[1] >= 0 && x + neighbor[0] >= 0 && y + neighbor[1] <= @height - 1 && x + neighbor[0] <= @width -1        
        if @cells[y + neighbor[1]][x + neighbor[0]].state == :alive
          count = count + 1 
        end
      end
    end
    count
  end
  
  def neighbors_matrix
    [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]]
  end
end


game = Game.new(6, 6)
game.set_cells(['0000000','0110000','0110000','0001100','0001100','0000000'])

loop{
  sleep 0.2
  system('clear')
  puts game.to_s
  game.start
}