require "uri"

class ContentDisposition
  ATTACHMENT = "attachment"
  INLINE     = "inline"

  DEFAULT_TO_ASCII = ->(filename : String) do
    array = [] of Char
    filename.each_char do |char|
      array << (char.ascii? ? char : '?')
    end

    array.join
  end

  class_property to_ascii : Proc(String, String)? = nil

  def self.attachment(filename = nil)
    format(disposition: ATTACHMENT, filename: filename)
  end

  def self.inline(filename = nil)
    format(disposition: INLINE, filename: filename)
  end

  def self.format(**options)
    new(**options).to_s
  end

  def self.call(**options)
    format(**options)
  end

  getter :disposition, :filename, :to_ascii

  def initialize(@disposition : String | Symbol, @filename : String?, to_ascii : Proc(String, String)? = nil)
    unless [ATTACHMENT, INLINE].includes?(disposition.to_s)
      raise ArgumentError.new "unknown disposition: #{disposition.inspect}"
    end

    @to_ascii = to_ascii || self.class.to_ascii || DEFAULT_TO_ASCII
  end

  def to_s
    if filename
      "#{disposition}; #{ascii_filename}; #{utf8_filename}"
    else
      "#{disposition}"
    end
  end

  TRADITIONAL_ESCAPED_CHAR = /[^ A-Za-z0-9!#$+.^_`|~-]/

  def ascii_filename : String?
    "filename=\"" + percent_escape(to_ascii.not_nil!.call(filename.not_nil!), TRADITIONAL_ESCAPED_CHAR) + "\"" if filename
  end

  RFC_5987_ESCAPED_CHAR = /[^A-Za-z0-9!#$&+.^_`|~-]/

  def utf8_filename : String?
    "filename*=UTF-8''" + percent_escape(filename.not_nil!, RFC_5987_ESCAPED_CHAR) if filename
  end

  private def percent_escape(string : String, pattern)
    string.gsub(pattern) do |char|
      char.bytes.map { |byte| "%%%02X" % byte }.join
    end
  end
end
