# MIT License
#
# Copyright (c) 2017 Giorgio Gambino
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

class SudokuSolver
  require_relative 'app_helper'

  def initialize
    @digits   = '123456789'
    @rows     = 'ABCDEFGHI'
    @cols     =  @digits
    @squares  =  AppHelper.cross_prod(@rows, @cols)
    @ulist    =  AppHelper.unitlist(@rows, @cols)
    @units    =  AppHelper.units(@ulist, @squares)
    @peers    =  AppHelper.peers(@units, @squares)
  end

  def parse_grid(grid)
    values = Hash.new
    @squares.each { |s| values[s] = @digits }
    AppHelper.grid_values(grid, @squares).each { |key, val| assign(values, key, val) if @digits.include? val }
    values
  end

  ################ Constraint Propagation ################

  def assign(values, s, d)
    (values[s].sub(d,'').chars.all? { |d2| eliminate(values, s, d2) }) ? values : false
  end

  def eliminate(values, s, d)
    return values unless values[s].include? d
    values[s] = values[s].sub(d,'')
    if values[s].length == 0
      return false
      # (1) If a square s is reduced to one value d2, then eliminate d2 from the peers.
    elsif values[s].length == 1
      return false unless @peers[s].each.all? { |s2| eliminate(values, s2, values[s]) }
    end
    # (2) If a unit u is reduced to only one place for a value d, then put it there.
    dplaces = [ ]
    @units[s].each { |u|
      dplaces.clear
      u.each { |el| dplaces << el if values[el].include? d }
      #puts dplaces
      if dplaces.length == 0
        return false
      elsif dplaces.length == 1
        # d can only be in one place in unit; assign it there
        return false unless assign(values, dplaces[0], d)
      end
    }
    values
  end

  ################ Search ################

  def solve(grid)
    AppHelper.display(search(parse_grid(grid)),@squares,@rows,@cols)
  end

  def search(values)
    return false unless values
    return values if @squares.all? { |s| values[s].length == 1 }
    min_s = values.key(values.each_value.select{|s| s if s.length > 1}.min_by(&:length))
    vals = []
    values[min_s].chars { |d|
      vals.clear
      vals << search(assign(values.dup(), min_s, d) )
      vals.flatten.each {|el| return el if el.instance_of? Hash}
    }


  end

end
