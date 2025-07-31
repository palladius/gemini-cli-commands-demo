#!/usr/bin/env ruby

require 'json'

TASK_DIR = File.expand_path('./.gemini/agents/tasks')

def print_help
  puts "Usage: #{$0} [--pid <PID> | --task_id <TASK_ID>]"
  puts "  --pid <PID>      : Visualize task associated with the given PID."
  puts "  --task_id <ID>   : Visualize task with the given Task ID."
  puts "  --help           : Display this help message."
  exit 1
end

pid = nil
task_id = nil

ARGV.each_with_index do |arg, i|
  case arg
  when '--pid'
    pid = ARGV[i + 1]
    print_help unless pid
  when '--task_id'
    task_id = ARGV[i + 1]
    print_help unless task_id
  when '--help'
    print_help
  end
end

if pid.nil? && task_id.nil?
  print_help
end

task_file = nil

if task_id
  task_file = File.join(TASK_DIR, "#{task_id}.json")
  unless File.exist?(task_file)
    puts "Error: Task file not found for ID '#{task_id}'."
    exit 1
  end
elsif pid
  Dir.glob(File.join(TASK_DIR, '*.json')).each do |file|
    begin
      task_data = JSON.parse(File.read(file))
      if task_data['pid'].to_s == pid.to_s
        task_file = file
        break
      end
    rescue JSON::ParserError
      # Skip malformed JSON files
      next
    end
  end

  unless task_file
    puts "Error: No task found with PID '#{pid}'."
    exit 1
  end
end

begin
  task_data = JSON.parse(File.read(task_file))
rescue JSON::ParserError => e
  puts "Error: Could not parse task file '#{task_file}': #{e.message}"
  exit 1
end

puts "
[1m[33m--- Task Details ---[0m"
puts "[90m$ cat #{task_file}[0m"
puts "Task ID    : #{task_data['taskId']}"
puts "Status     : #{task_data['status']}"
puts "Agent      : #{task_data['agent']}"
puts "Prompt     : #{task_data['prompt']}"
puts "PID        : #{task_data['pid'] || 'N/A'}"
puts "Created At : #{task_data['createdAt']}"

log_file = task_data['logFile']
plan_file = task_data['planFile']

puts "Log File   : #{log_file} #{(File.exist?(log_file) ? '(exists)' : '(missing)')}"
puts "Plan File  : #{plan_file} #{(File.exist?(plan_file) ? '(exists)' : '(missing)')}"

# Check for .done file
done_file = File.join(TASK_DIR, "#{task_data['taskId']}.done")
puts ".done File : #{done_file} #{(File.exist?(done_file) ? '(exists)' : '(missing)')}"

puts "\n\e[1m\e[33m✨📜 Log Output ✨📜\e[0m"
puts "\e[90m$ tail -20 #{log_file}\e[0m"
if File.exist?(log_file)
  puts `tail -20 #{log_file}`
else
  puts "Log file not found."
end

puts "\n\e[1m\e[33m📝💡 Plan Details 📝💡\e[0m"
glow_exists = system("which glow > /dev/null 2>&1")
if glow_exists
  puts "\e[90m$ glow #{plan_file}\e[0m"
else
  puts "\e[90m$ cat #{plan_file}\e[0m"
end
if File.exist?(plan_file)
  glow_exists = system("which glow > /dev/null 2>&1")
  if glow_exists
    puts `glow #{plan_file}`
  else
    puts File.read(plan_file)
  end
else
  puts "Plan file not found."
end
