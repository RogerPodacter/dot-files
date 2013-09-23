require 'rubygems'
require 'yaml'

alias q exit

ANSI = {}
ANSI[:RESET] = "\e[0m"
ANSI[:BOLD] = "\e[1m"
ANSI[:UNDERLINE] = "\e[4m"
ANSI[:LGRAY] = "\e[0;37m"
ANSI[:GRAY] = "\e[1;30m"
ANSI[:RED] = "\e[31m"
ANSI[:GREEN] = "\e[32m"
ANSI[:YELLOW] = "\e[33m"
ANSI[:BLUE] = "\e[34m"
ANSI[:MAGENTA] = "\e[35m"
ANSI[:CYAN] = "\e[36m"
ANSI[:WHITE] = "\e[37m"

def extend_console(name, care = true, required = true)
  if care
    require name if required
    yield if block_given?
    $console_extensions << "#{ANSI[:GREEN]}#{name}#{ANSI[:RESET]}"
  else
    $console_extensions << "#{ANSI[:GRAY]}#{name}#{ANSI[:RESET]}"
  end
rescue LoadError
  $console_extensions << "#{ANSI[:RED]}#{name}#{ANSI[:RESET]}"
end
$console_extensions = []

extend_console 'wirble' do
  Wirble.init
  Wirble.colorize
end

extend_console 'ap' do
  alias pp ap
end

extend_console 'net-http-spy'
extend_console 'differ'
extend_console 'hpricot'
extend_console 'mechanize'
extend_console 'map_by_method'

# IRB Options
IRB.conf[:AUTO_INDENT] = true
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:EVAL_HISTORY] = 200

if defined?(Rails) and !Rails.env.nil?
  if Rails.logger
    Rails.logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger = Rails.logger
  end
end

if ENV.include?('RAILS_ENV') && !Object.const_defined?('RAILS_DEFAULT_LOGGER')
  require 'logger'
  RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)
  IRB.conf[:IRB_RC] = Proc.new do
    ActiveRecord::Base.instance_eval { alias :[] :find }
    
    if defined? Delayed::Job
      def dj
        Delayed::Job
      end
      
      Delayed::Job.class_eval do
        def run
          run_with_lock(1,1)
        end
      end
      
      TMail::Mail.class_eval do
        def show
          emails_dir = "#{Rails.root}/tmp/emails"
          raise "You must first create the tmp/emails directory!" if !File.directory?(emails_dir)

          mail_path = File.join(emails_dir, "#{object_id}.html")

          File.open(mail_path, "w") do |f|
            f.puts '<meta http-equiv="Content-type" content="text/html; charset=utf-8"></meta>'
            f.puts "<pre>"
              f.puts "From: #{from.to_sentence}"
              f.puts "Subject: #{subject}"
              f.puts "Date: #{date}"
              f.puts "To: #{to.to_sentence}"
            f.puts "</pre>"
            f.puts self.body
          end
          system("open", "file:///#{mail_path}")
        end
      end
    end

    ActiveRecord::Base.class_eval do
      def navigate(base = :local)
        raise "No path method" unless respond_to? :path
        bases = { :local => "http://#{AppConfig.canonical_domain!}", :rg => 'http://rapgenius.com' }
        system("open", bases[base] + path)
      end
    end
  end  #IRB.conf[:USE_READLINE] = true
end

if ENV.include?('RAILS_ENV') || (defined? Rails and Rails.env)
  # Display the RAILS ENV in the prompt
  env = (ENV["RAILS_ENV"] || Rails.env).capitalize.gsub("Development", "Dev").gsub("Production", "Prod")
  IRB.conf[:PROMPT][:CUSTOM] = {
    :PROMPT_N => "[#{env}]> ",
    :PROMPT_I => "[#{env}]> ",
    :PROMPT_S => nil,
    :PROMPT_C => "?> ",
    :RETURN => "=> %s\n"
  }
  # Set default prompt
  IRB.conf[:PROMPT_MODE] = :CUSTOM
end

def me
  User.find_by_email("tom.s.lehman@gmail.com")
end

class Object
  def local_methods
    (methods - Object.instance_methods).sort
  end
end

class String
  def to_file(filename)
    File.open(filename, 'w') {|f| f.write self }
  end
end

# http://blog.evanweaver.com/articles/2006/12/13/benchmark/
# def benchmark(times = 1000, samples = 20)
#   times *= samples
#   cur = Time.now
#   result = times.times { yield }
#   print "#{cur = (Time.now - cur) / samples.to_f } seconds"
#   puts " (#{(cur / $last_benchmark * 100).to_i - 100}% change)" rescue puts ""
#   $last_benchmark = cur
#   result
# end

def benchmark(trials = 10)
  total_time = Benchmark.realtime do
    trials.times do |i|
      trial_time = Benchmark.realtime do
        yield
      end * 1000
      
      puts "#{i + 1}. #{trial_time.round}ms"
    end
  end
  
  puts "Average: #{((total_time / trials) * 1000).round}ms"
end

def clip(obj)
  IO.popen('pbcopy', 'w') { |f| f << obj.to_s }
end

def diff(new, old, options = {})
  by = (options[:by] || :line)
  puts Differ.send(:"diff_by_#{by}", new, old)
  # puts Differ.diff_by_line(new, old)
end

def get(url)
  open(url).read
end

def H(input)
  Hpricot(input)
end

def sha(input)
  Digest::SHA1.hexdigest(input)
end

def get_web_page(url)
  agent = Mechanize.new rescue nil
  agent.user_agent_alias = 'Mac Safari' rescue nil

  Hpricot(agent.get(url).body) rescue nil
end

def download_file(url, name)
  agent = Mechanize.new rescue nil
  agent.user_agent_alias = 'Mac Safari' rescue nil

  agent.get(url).body.to_s(name)
end

def show_log
  change_log(STDOUT)
end

def hide_log
  change_log(nil)
end

def change_log(stream, colorize=true)
  ActiveRecord::Base.logger = ::Logger.new(stream)
  ActiveRecord::Base.clear_all_connections!
  ActiveRecord::Base.colorize_logging = colorize
end

puts "#{ANSI[:GRAY]}~> Console extensions:#{ANSI[:RESET]} #{$console_extensions.join(' ')}#{ANSI[:RESET]}"