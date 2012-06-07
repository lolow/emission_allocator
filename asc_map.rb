class AscMap

  attr_accessor :params, :cells

  def initialize(filename=nil)
    @params = {}
    @cells = []

    File.foreach(filename) do |line|
      array = line.split
      if array.size == 2
        @params[array.first] = array[1].to_f
      else
        @cells << array.map(&:to_f)
      end
    end

    %w{nrows ncols}.each {|p| @params[p] = @params[p].to_i if @params[p] }
    @params["NODATA_value"] = -9999 unless @params["NODATA_value"]

    # AUSTAL2000 BUG UTM31 DIRTY FIX (Only valid for Luxembourg)
    # xllcorner and yllcorner must start with "31"
    %w{xllcorner yllcorner}.each do |p|
      unless @params[p].to_s[0..1]=="31"
        @params[p] = "31#{@params[p]}"
      end
    end
  end

  def each_data
    (0...@params["nrows"]).each do |row|
      (0...@params["ncols"]).each do |col|
        unless @cells[row][col] == @params["NODATA_value"]
          yield row,col
        end
      end
    end
  end

  def data_values
    values = []
    (0...@params["nrows"]).each { |row|
      (0...@params["ncols"]).each { |col|
        unless @cells[row][col] == @params["NODATA_value"]
          values << @cells[row][col]
        end
      }
    }
    values
  end

  def data_coord
    values = []
    (0...@params["nrows"]).each { |row|
      (0...@params["ncols"]).each { |col|
        unless @cells[row][col] == @params["NODATA_value"]
          values << [row,col]
        end
      }
    }
    values
  end

  def reset_data!(value=nil)
    (0...@params["nrows"]).each do |row|
      (0...@params["ncols"]).each do |col|
        unless @cells[row][col] == @params["NODATA_value"]
          @cells[row][col] = (value.to_f || @params["NODATA_value"])
        end
      end
    end
  end

  def reset!
    @cells = []
    (0...@params["nrows"]).each do
      @cells << [@params["NODATA_value"].to_f] * @params["ncols"]
    end
  end

  def write_asc(filename)
    headers = %w{ncols nrows xllcorner yllcorner cellsize NODATA_value}
    open(filename,"w") do |f|
      headers.each do |p|
        f.puts("#{p} #{@params[p]}") if @params[p]
      end
      @cells.each do |row|
        f.puts(row.collect{|x|x.to_s}.join(" "))
      end
    end
  end

  def coord_x(col)
    @params["xllcorner"].to_i + col * @params["cellsize"].to_i
  end

  def coord_y(row)
    @params["yllcorner"].to_i + (@params["nrows"] - row) * @params["cellsize"].to_i
  end

  def cell_value(x,y)
    row =  @params["nrows"] - (y - @params["yllcorner"].to_i )/@params["cellsize"].to_i
    col =  x - @params["xllcorner"].to_i / @params["cellsize"].to_i
    @cells[row][col]
  end

  def sum_values
    data_values.inject( nil ) { |sum,x| sum ? sum + x : x }
  end

  def multiply!(mul)
    self.each_data do |row,col|
      @cells[row][col] = @cells[row][col] * mul
    end
  end

  def normalize!(total=1.0)
    multiply!(total.to_f/sum_values)
  end

  def round(n=0)
    self.each_data do |row,col|
      @cells[row][col] = @cells[row][col].round(n)
    end
  end

end
