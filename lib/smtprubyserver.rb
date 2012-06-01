require 'eventmachine'
require 'pry'

class SmtpRubyServer < EM::Protocols::SmtpServer
	def receive_data_chunk( data )
		buffer.concat data
	end

	def receive_message
		@message = buffer.join("\n")
		clear_buffer!
		true
	end

	def buffer
		@buffer ||= []
	end

	def clear_buffer!
		@buffer = []
	end

	def initialize *args
    	super
	end

	def receive_sender(sender)
        @sender = sender
        true
	end

	def receive_recipient(rcpt)
    	# recipients is a Ruby Array. return an array of true/falses.
    	@recepient = rcpt
    	true
  	end

  	def connection_ended
  		
  	end


end