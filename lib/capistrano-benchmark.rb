require 'benchmark'
Capistrano::Configuration.class_eval do
  def execute_task_with_benchmarking(task)
    if fetch(:benchmark, false)
      realtime = Benchmark.realtime do
        execute_task_without_benchmarking(task)
      end

      logger.debug "Finished #{task.fully_qualified_name} in #{format_elapsed_time realtime}"
    else
      execute_task_without_benchmarking(task)
    end
  end

  def format_elapsed_time elapsed
    # elapsed = elapsed.round
    formatted_time = ''
    hours = elapsed.divmod(3600)[0]
    formatted_time << "#{hours.to_s.rjust(2,'0')}:"

    minutes = (elapsed - (hours * 3600)).divmod(60)[0]
    formatted_time << "#{minutes.to_s.rjust(2,'0')}:"

    seconds = 0.0 + elapsed - (hours * 3600) - (minutes * 60)
    frac = ((seconds % 1) || 0.0).to_s.gsub(/0\./,'').to_i
    formatted_time << "#{seconds.to_i.to_s.rjust(2,'0')}.#{frac.to_s[0..3]}"
    formatted_time
  end

  alias_method :execute_task_without_benchmarking, :execute_task
  alias_method :execute_task, :execute_task_with_benchmarking
end

Capistrano::Configuration.instance.load do
  task :benchmark do
    set :benchmark, true
  end
end
