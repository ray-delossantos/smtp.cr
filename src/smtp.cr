require "./smtp/*"
require "./socket"
require "benchmark"

module SMTP
  # TODO Put your code here
  class Client
    # Returns the target host.
    #
    # ```
    # client = HTTP::Client.new "smtp.example.com"
    # client.host # => "smtp.example.com"
    # ```
    getter host : String

    # Returns the target port.
    #
    # ```
    # client = HTTP::Client.new "smtp.example.com"
    # client.port # => 25
    # ```
    getter port : Int32

    @socket : TCPSocket | Nil
    @dns_timeout = 60
    @connect_timeout = 60
    @read_timeout = 60

    def initialize(@host, port = nil)
      @port = (port || 25).to_i
    end

    def send(message : Message)
      message.to_io(socket)
      close
    end

    # Closes this client. If used again, a new connection will be opened.
    def close
      @socket.try &.close
      @socket = nil
    end

    private def socket
      socket = @socket
      return socket if socket

      socket = TCPSocket.new @host, @port, @dns_timeout, @connect_timeout
      socket.read_timeout = @read_timeout if @read_timeout
      socket.sync = false
      @socket = socket

      socket
    end

  end

  class Message
    property from : Address?
    property to : Array(Address)
    property cc : Array(Address)
    property bcc : Array(Address)
    property subject : String?
    property body : String?

    def initialize
      @to = Array(SMTP::Address).new
      @cc = Array(SMTP::Address).new
      @bcc = Array(SMTP::Address).new
    end

    def to_io(io)
      response = io.gets
      p response
      if response
        raise SMTPException.new("Failed at sending smtp message") if response.to_s[0..2] != "220"
      end
      io << "HELO smtp\r\n"
      io.flush
      response = io.gets
      if response
        raise SMTPException.new("Failed at sending smtp message") if response.to_s[0..2] != "250"
      end
      p response
      if from = @from
        io << "MAIL FROM:#{from.name if from.name }<#{from.email}>\r\n"
        io.flush
        response = io.gets
        if response
          raise SMTPException.new("Invalid from address") if response.to_s[0..2] != "250"
        end
      else
        raise SMTPException.new("Invalid from address")
      end
      p response
      if to = @to
        to.each do |rcpt|
          io << "RCPT TO:<#{rcpt.email}>\r\n";
          io.flush
          response = io.gets
          if response
            raise SMTPException.new("Invalid to address") if response.to_s[0..2] != "250"
          end
          p response
        end
      else
        raise SMTPException.new("Invalid to address")
      end

      if cc = @cc
        cc.each do |rcpt|
          io << "RCPT TO:<#{rcpt.email}>\r\n"
          io.flush
          response = io.gets
          if response
            raise SMTPException.new("Invalid cc address") if response.to_s[0..2] != "250"
          end
          p response
        end
      end

      if bcc = @bcc
        bcc.each do |rcpt|
          io << "RCPT TO:<#{rcpt.email}>\r\n"
          io.flush
          response = io.gets
          if response
            raise SMTPException.new("Invalid bcc address") if response.to_s[0..2] != "250"
          end
          p response
        end
      end

      io << "DATA\r\n"
      io.flush
      response = io.gets
      if response
        raise SMTPException.new("Error sending DATA") if response.to_s[0..2] != "354"
      end
      p response

      io << "Subject: #{@subject}\r\n"

      if to = @to
        to.each do |rcpt|
          io << "To: #{rcpt.to_s}\r\n"
        end
      end

      if cc = @cc
        cc.each do |rcpt|
          io << "CC: #{rcpt.to_s}\r\n"
        end
      end

      if bcc = @bcc
        bcc.each do |rcpt|
          io << "BCC: #{rcpt.to_s}\r\n"
        end
      end

      if body = @body
        if body.index("<!DOCTYPE")
          io << "MIME-Version: 1.0\r\n"
          io << "Content-Type: text/html;\r\n"
          io << " charset=\"iso-8859-1\"\r\n"
        end
      end

      io << "\r\n" << @body
      io << "\r\n.\r\n"
      io.flush
      response = io.gets
      if response
        raise SMTPException.new("Invalid DATA") if response.to_s[0..2] != "250"
      end
      p response

      io << "QUIT\r\n"
      io.flush
      response = io.gets
      if response
        raise SMTPException.new("Invalid QUIT") if !response.to_s.index("221")
      end

    end
  end

  class Address
    property email : String
    property name : String?

    def initialize(@email, @name = nil)
      if @email == nil
        raise AddressException.new("Address is nil")
      end
    end

    def to_s(io)
      io << @name << '<' << @email << ">"
    end
  end

  class AddressException < Exception
  end

  class SMTPException < Exception
  end
end

 
