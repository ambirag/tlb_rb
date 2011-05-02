#require 'tlb/run_data'

class FormatterCallback
#  include Tlb::RunData

  def initialize(first, second, third)
    puts first
    puts second
    puts third
  end 

  attr_accessor :time

  def before_steps(args)
    puts args
 #   suite_started("foo")
  end

  def after_steps(args)
    puts args
  #  suite_ended("foo")
  end
  
  def before_feature(args)
    puts args.file
  end

  def before_step_result(one, two, three, four, five, six, seven)
    puts four
  end
end
