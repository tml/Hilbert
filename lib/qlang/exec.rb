module Qlang
  module Exec
    class Compiler
      def initialize(args)
        @args = args
      end

      def output!
        ch_compile_type(@args.first)
        parse_string = parse(@args[1])
        write!(@args[2], parse_string)

      rescue Exception => e
        raise e if @options[:trace] || e.is_a?(SystemExit)

        print "#{e.class}: " unless e.class == RuntimeError
        puts "#{e.message}"
        puts "  Use --trace for backtrace."
        exit 1
      ensure
        exit 0
      end

      private

        def ch_compile_type(lang)
          case lang
          when '-Ruby'
            Qlang.to_ruby
          when '-R'
            Qlang.to_r
          else
            print 'Q support only Ruby and R now.'
          end
        end

        def parse(file_path)
          file = open_file(file_path)
          input_string = read_file(file)
          file.close
          input_string.gsub(
            /(.*)I love mathematics\.(.*)Q\.E\.D(.*)/m,
            "#{$1}#{Kconv.tosjis(Qlang.compile($2))}#{$3}"
          )
        end

        def write!(output_path, string)
          open(output_path, 'w') do |f|
            f.puts string
          end
        end

        def open_file(filename, flag = 'r')
          return if filename.nil?
          File.open(filename, flag)
        end

        def read_file(file)
          file.read
        end
    end
  end
end
