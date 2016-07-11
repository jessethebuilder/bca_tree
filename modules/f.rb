class F
  def initialize(path)
    @path = path
  end

  def F.read(path)
    F.new(path).read
  end

  def F.write(path, content)
    F.new(path).write(content)
  end

  def F.append(path, content)
    F.new(path).append(content)
  end

  def F.delete(path)
    F.new(path).delete
  end

  def F.read_json(path)
    F.new(path).read_json
  end

  def F.get_dir(path)
    f = F.new(path)
    f.dir
  end

  def F.log_error(error, path = "error_log.log", note: nil, skip_backtrace: false)
    s = ''
    s += note if note
    s += "\n" if note
    s += error.inspect
    s += "\n"
    s += error.message
    s += error.backtrace.join("\n") unless skip_backtrace
    s += "\n"
    F.write(path, s)
  end

  def F.combine_files(dir, file_suffix = "*")
    combine_all_files(dir, file_suffix)
  end

  def F.combine_all_files(dir, file_suffix = "*", delete_old_files: false)
    output_suffix = file_suffix == "*" ? "txt" : file_suffix
    file_name = "#{dir.to_s.split(/[\\\/]/).last}.#{output_suffix}"
    file = F.new(file_name)
    # puts dir

    s = ""
    Dir["#{dir}/**/*.#{file_suffix}"].each do |f|
      s += F.read(f)
      F.delete(f) if delete_old_files
    end

    F.write(file_name, s)


    file_name
  end

  def read
    f = file
    val = f.read
    f.close
    val
  end

  def read_json
    JSON.parse(read)
  end

  def append(content)
    build_paths
    f = file('a')
    f.write(content)
    f.close
  end

  def prepend(content)
    build_paths
    s = File.exists?(@path) ? read : ''
    write(content + s)
  end

  def <<(content)
    append(content)
  end

  def write(content)
    build_paths
    f = file('w')
    f.write(content)
    f.close
  end

  def delete
    File.delete(@path)
  end

  def dir
    File.dirname(@path)
  end

  def to_csv(save_file = true)
    json = JSON.parse(read)

    csv = CSV.generate do |c|
      json.each do |r|
        c << r.values
      end
    end
    if save_file
      file_name = "#{@path.split('.')[0]}.csv"
      F.new(file_name).write(csv)
    end

    csv
  end

  def F.file_to_env(path, delin: ': ')
    vars = F.new(path).read.split("\n")
    vars.each do |var|
      s = var.split(delin)
      ENV[s[0].upcase] = s[1]
    end
  end
private

  def build_paths
    unless @paths_built
      path_parts = @path.split(/[\\\/]/)[0..-2]

      path_builder = ''
      path_parts.each do |p|
        path_builder += p + '/'
        Dir.mkdir(path_builder) unless File.exists?(path_builder)
      end

      @paths_built = true
    end
  end

  def file(option = nil)
    File.open(@path, option)
  end
end
